local M = {}

local did_save = false

local state = {
  ns = vim.api.nvim_create_namespace("pi_review"),
  bufnr = nil,
  root = nil,
  diff_path = nil,
  json_path = nil,
  md_path = nil,
  scope = nil,
  backend = "raw",
  diffview_args = {},
  attached_buffers = {},
  line_map = {},
  comments = {},
  hidden_comments = {},
  created_at = nil,
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "pi-review" })
end

local function force_redraw()
  -- Multiplexers can briefly repaint the parent Pi TUI while Neovim still owns
  -- stdin. Re-entering the alternate screen on focus/window events makes the
  -- visible pane catch up when moving away/back. Gated on PI_REVIEW_ROOT so
  -- standalone nvim usage doesn't get its scrollback cleared.
  if vim.env.PI_REVIEW_ROOT and not vim.fn.has("gui_running") then
    pcall(function()
      io.write("\027[?1049h\027[?25h\027[H\027[2J")
      io.flush()
    end)
  end
  pcall(vim.cmd, "mode")
  pcall(vim.cmd, "redraw!")
end

-- Forward declared; assigned after `save` exists. Used from both raw and diffview
-- branches to register the VimLeavePre autosave once per session.
local setup_autosave_autocmd

local function iso_now()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function json_read(path)
  if not path or vim.fn.filereadable(path) ~= 1 then return nil end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if ok_decode and type(decoded) == "table" then return decoded end
  return nil
end

local function write_file(path, text)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile(vim.split(text, "\n", { plain = true }), path)
end

local function parse_hunk(line)
  local old_start, old_count, new_start, new_count = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
  if not old_start then return nil end
  return tonumber(old_start), tonumber(old_count ~= "" and old_count or "1"), tonumber(new_start), tonumber(new_count ~= "" and new_count or "1")
end

local function parse_diff()
  state.line_map = {}
  local current_file, old_line, new_line = nil, nil, nil
  local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)

  for idx, line in ipairs(lines) do
    local a, b = line:match("^diff %-%-git a/(.-) b/(.+)$")
    if a and b then
      current_file = b
      old_line, new_line = nil, nil
    elseif line:sub(1, 3) == "+++" then
      local file = line:match("^%+%+%+ b/(.+)$")
      if file then current_file = file end
    else
      local os_, _, ns_ = parse_hunk(line)
      if os_ then
        old_line, new_line = os_, ns_
      elseif current_file and old_line and new_line then
        local prefix = line:sub(1, 1)
        if prefix == "+" and line:sub(1, 3) ~= "+++" then
          state.line_map[idx] = {
            file = current_file, side = "new", line = new_line, old_line = nil, new_line = new_line,
            diff_line = idx, kind = "added", code = line:sub(2),
          }
          new_line = new_line + 1
        elseif prefix == "-" and line:sub(1, 3) ~= "---" then
          state.line_map[idx] = {
            file = current_file, side = "old", line = old_line, old_line = old_line, new_line = nil,
            diff_line = idx, kind = "removed", code = line:sub(2),
          }
          old_line = old_line + 1
        elseif prefix == " " then
          state.line_map[idx] = {
            file = current_file, side = "new", line = new_line, old_line = old_line, new_line = new_line,
            diff_line = idx, kind = "context", code = line:sub(2),
          }
          old_line = old_line + 1
          new_line = new_line + 1
        elseif prefix == "\\" then
          -- no newline marker; do not advance counters
        end
      end
    end
  end
end

local function anchor_id(anchor)
  local line = anchor.line or anchor.new_line or anchor.old_line or 0
  return table.concat({ anchor.file or "", anchor.side or "", tostring(line) }, ":")
end

local function canonical_line(comment)
  if comment.line then return comment.line end
  if comment.side == "old" then return comment.oldLine end
  if comment.side == "new" then return comment.newLine end
  return comment.newLine or comment.oldLine
end

local function comment_key(comment)
  return table.concat({ comment.file or "", comment.side or "", tostring(canonical_line(comment) or 0) }, ":")
end

local function markdown_resolved_map(path)
  -- Parses only the round-trip fields written by save(): the `[x]/[ ]` checkbox in
  -- the heading and the following `Side: \`...\`` line. User edits elsewhere in the
  -- markdown body are not preserved on the next save.
  local map = {}
  if not path or vim.fn.filereadable(path) ~= 1 then return map end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return map end
  local current_file = nil
  local pending = nil
  for _, line in ipairs(lines) do
    local file = line:match("^##%s+(.+)$")
    if file then
      current_file = file
      pending = nil
    else
      local checked, line_no = line:match("^###%s+%[([ xX])%]%s+Line%s+(.+)$")
      if checked and current_file then
        local old_line = line_no:match("old line%s+(%d+)")
        pending = { file = current_file, checked = checked:lower() == "x", line = tonumber(old_line or line_no:match("%d+")) }
      elseif pending then
        local side = line:match("Side:%s+`([^`]+)`")
        if side and pending.line then
          map[table.concat({ pending.file, side, tostring(pending.line) }, ":")] = pending.checked
          pending = nil
        end
      end
    end
  end
  return map
end

local function context_for_line(diff_line, radius)
  radius = radius or 3
  local out = {}
  for i = diff_line - radius, diff_line + radius do
    local anchor = state.line_map[i]
    if anchor and anchor.code then
      table.insert(out, {
        side = anchor.side,
        line = anchor.line,
        code = anchor.code,
      })
    end
  end
  return out
end

local function comment_sort_key(comment)
  return string.format("%s:%09d:%09d", comment.file or "", comment.line or comment.newLine or comment.oldLine or 0, comment.diffLine or 0)
end

local function sorted_comments(opts)
  opts = opts or {}
  local out = {}
  for _, comment in pairs(state.comments) do
    if opts.include_resolved or not comment.resolved then table.insert(out, comment) end
  end
  table.sort(out, function(a, b) return comment_sort_key(a) < comment_sort_key(b) end)
  return out
end

local function render()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    vim.api.nvim_buf_clear_namespace(state.bufnr, state.ns, 0, -1)
  end
  for bufnr in pairs(state.attached_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, state.ns, 0, -1)
    end
  end
  for _, comment in pairs(state.comments) do
    if comment.resolved then goto continue_render end
    local bufnr = state.backend == "diffview" and comment.bufnr or state.bufnr
    local lnum = state.backend == "diffview" and comment.line or comment.diffLine
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and lnum then
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      if lnum >= 1 and lnum <= line_count then
        local body_lines = vim.split(comment.body or "", "\n", { plain = true })
        local virt = {}
        for i, body_line in ipairs(body_lines) do
          local prefix = i == 1 and "  💬 " or "     "
          table.insert(virt, { { prefix .. body_line, "Comment" } })
        end
        table.insert(virt, { { "     [resolve: <leader>rx]", "Comment" } })
        pcall(vim.api.nvim_buf_set_extmark, bufnr, state.ns, lnum - 1, 0, {
          virt_lines = virt,
          virt_lines_above = false,
        })
      end
    end
    ::continue_render::
  end
end

local function load_comments()
  state.comments = {}
  state.hidden_comments = {}
  local data = json_read(state.json_path)
  local md_resolved = markdown_resolved_map(state.md_path)
  state.created_at = (data and data.createdAt) or iso_now()
  if not data or type(data.comments) ~= "table" then return end

  for _, comment in ipairs(data.comments) do
    local md_state = md_resolved[comment_key(comment)]
    if md_state ~= nil then comment.resolved = md_state end
    if comment.resolved then
      state.hidden_comments[comment_key(comment)] = comment
      goto continue_load
    end
    local matched_line = nil
    local diff_line = comment.diffLine
    if type(diff_line) == "number" and state.line_map[diff_line] then
      local anchor = state.line_map[diff_line]
      if anchor.file == comment.file then matched_line = diff_line end
    end
    if not matched_line then
      local wanted_line = comment.line or comment.newLine or comment.oldLine
      for lnum, anchor in pairs(state.line_map) do
        if anchor.file == comment.file and anchor.side == (comment.side or anchor.side) and anchor.line == wanted_line then
          matched_line = lnum
          break
        end
      end
    end
    if matched_line then
      local anchor = state.line_map[matched_line]
      comment.diffLine = matched_line
      comment.line = anchor.line
      comment.id = comment.id or anchor_id(anchor)
      comment.code = comment.code or anchor.code
      comment.context = comment.context or context_for_line(matched_line)
      state.comments[comment_key(comment)] = comment
    elseif comment.file and (comment.line or comment.newLine or comment.oldLine) then
      comment.line = comment.line or (comment.side == "old" and comment.oldLine or comment.newLine) or comment.oldLine
      state.comments[comment_key(comment)] = comment
    end
    ::continue_load::
  end
end

local function comment_from_anchor(anchor, body)
  return {
    id = anchor_id(anchor),
    file = anchor.file,
    side = anchor.side,
    line = anchor.line,
    oldLine = anchor.old_line,
    newLine = anchor.new_line,
    diffLine = anchor.diff_line,
    kind = anchor.kind,
    code = anchor.code,
    context = anchor.diff_line and context_for_line(anchor.diff_line) or {},
    bufnr = anchor.bufnr,
    resolved = false,
    body = body,
  }
end

local function serializable_comments()
  local out_by_key = {}
  for key, c in pairs(state.hidden_comments) do out_by_key[key] = c end
  for key, c in pairs(state.comments) do out_by_key[key] = c end
  local out = {}
  for _, c in pairs(out_by_key) do
    local copy = vim.deepcopy(c)
    copy.bufnr = nil
    table.insert(out, copy)
  end
  table.sort(out, function(a, b) return comment_sort_key(a) < comment_sort_key(b) end)
  return out
end

local function save(opts)
  opts = opts or {}
  local comments = serializable_comments()
  local doc = {
    version = 2,
    repo = state.root,
    diff = state.diff_path,
    scope = state.scope or "HEAD",
    createdAt = state.created_at or iso_now(),
    updatedAt = iso_now(),
    comments = comments,
  }
  write_file(state.json_path, vim.json.encode(doc))

  local md = {
    "# Code Review Comments",
    "",
    "Repo: `" .. (state.root or "") .. "`  ",
    "Generated: `" .. doc.updatedAt .. "`  ",
    "Scope: `" .. (state.scope or "HEAD") .. "`  ",
    "Comments: `" .. tostring(#comments) .. "`",
    "",
  }
  if #comments == 0 then
    table.insert(md, "No comments.")
  end
  local current_file = nil
  for _, c in ipairs(comments) do
    if c.file ~= current_file then
      current_file = c.file
      table.insert(md, "## " .. current_file)
      table.insert(md, "")
    end
    local line_label = c.line and tostring(c.line) or (c.newLine and tostring(c.newLine) or ("old line " .. tostring(c.oldLine or "?")))
    local checkbox = c.resolved and "[x]" or "[ ]"
    table.insert(md, "### " .. checkbox .. " Line " .. line_label)
    table.insert(md, "")
    table.insert(md, "Side: `" .. c.side .. "`, diff line: `" .. tostring(c.diffLine) .. "`, kind: `" .. tostring(c.kind) .. "`")
    table.insert(md, "")
    if c.code and c.code ~= "" then
      table.insert(md, "```")
      table.insert(md, c.code)
      table.insert(md, "```")
      table.insert(md, "")
    end
    table.insert(md, c.body or "")
    table.insert(md, "")
    if type(c.context) == "table" and #c.context > 0 then
      table.insert(md, "<details><summary>Context</summary>")
      table.insert(md, "")
      table.insert(md, "```")
      for _, ctx in ipairs(c.context) do
        table.insert(md, string.format("%s:%s %s", ctx.side or "", tostring(ctx.line or "?"), ctx.code or ""))
      end
      table.insert(md, "```")
      table.insert(md, "")
      table.insert(md, "</details>")
      table.insert(md, "")
    end
  end
  write_file(state.md_path, table.concat(md, "\n"))
  did_save = true
  if not opts.silent then
    notify("Saved review to " .. state.md_path)
  end
end

setup_autosave_autocmd = function()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("pi_review_autosave", { clear = true }),
    callback = function()
      if state.md_path and not did_save then save({ silent = true }) end
    end,
  })
end

local function diffview_file_from_buf(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name:sub(1, #state.root) == state.root then
    return vim.fn.fnamemodify(name, ":.")
  end
  local from_b = name:match("[ab]/(.+)$") or name:match("::(.+)$") or name:match("/(.+)$")
  return from_b
end

local function diffview_side_from_buf(bufnr)
  local winbar = vim.wo.winbar or ""
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name:sub(1, #state.root) == state.root or winbar:match("WORKING TREE") then return "new" end
  return "old"
end

local function current_anchor()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  if state.backend == "diffview" then
    local bufnr = vim.api.nvim_get_current_buf()
    local file = diffview_file_from_buf(bufnr)
    if not file or file == "" then return lnum, nil end
    local code = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local side = diffview_side_from_buf(bufnr)
    return lnum, { file = file, side = side, line = lnum, diff_line = nil, kind = "diffview", code = code, bufnr = bufnr }
  end
  return lnum, state.line_map[lnum]
end

local function edit_multiline(default, done)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.min(90, math.max(40, vim.o.columns - 10))
  local height = math.min(16, math.max(5, vim.o.lines - 8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Review comment (save: <C-s>, cancel: q) ",
  })
  vim.bo[buf].filetype = "markdown"
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(default or "", "\n", { plain = true }))
  local function close_with(value)
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    done(value)
  end
  vim.keymap.set({ "n", "i" }, "<C-s>", function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    close_with(table.concat(lines, "\n"):gsub("%s+$", ""))
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "q", function() close_with(nil) end, { buffer = buf, silent = true })
  vim.cmd("startinsert")
end

local function add_or_edit_comment()
  local _, anchor = current_anchor()
  if not anchor then
    notify("Not a commentable diff body line", vim.log.levels.WARN)
    return
  end
  local key = comment_key(anchor)
  local existing = state.comments[key] or state.hidden_comments[key]
  edit_multiline(existing and existing.body or "", function(input)
    if input == nil then return end
    if input == "" then
      state.comments[key] = nil
      state.hidden_comments[key] = nil
    else
      -- Fresh anchor data (diffLine, code, context) wins over stale existing fields
      -- so edits after a diff regen pick up the new position.
      local updated = vim.tbl_extend("force", existing or {}, comment_from_anchor(anchor, input))
      updated.body = input
      updated.resolved = existing and existing.resolved or false
      updated.updatedAt = iso_now()
      updated.bufnr = anchor.bufnr
      state.hidden_comments[key] = nil
      state.comments[key] = updated
    end
    render()
    save({ silent = true })
  end)
end

local function delete_comment()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local _, anchor = current_anchor()
  local key = anchor and comment_key(anchor) or tostring(lnum)
  if state.comments[key] or state.hidden_comments[key] then
    state.comments[key] = nil
    state.hidden_comments[key] = nil
    render()
    save({ silent = true })
    notify("Deleted comment")
  else
    notify("No comment on this line", vim.log.levels.WARN)
  end
end

local function toggle_resolved()
  local lnum, anchor = current_anchor()
  local key = anchor and comment_key(anchor) or tostring(lnum)
  local comment = state.comments[key]
  if not comment then
    notify("No comment on this line", vim.log.levels.WARN)
    return
  end
  comment.resolved = not comment.resolved
  comment.updatedAt = iso_now()
  if comment.resolved then
    state.comments[key] = nil
    state.hidden_comments[key] = comment
  else
    state.hidden_comments[key] = nil
    state.comments[key] = comment
  end
  render()
  save({ silent = true })
  notify(comment.resolved and "Marked comment resolved" or "Marked comment unresolved")
end

local function jump_comment(direction)
  local current_buf = vim.api.nvim_get_current_buf()
  local targetable = {}
  for _, c in ipairs(sorted_comments()) do
    local lnum = state.backend == "diffview" and c.line or c.diffLine
    local buf_ok = state.backend ~= "diffview" or c.bufnr == current_buf
    if lnum and buf_ok then table.insert(targetable, c) end
  end
  if #targetable == 0 then
    notify("No comments", vim.log.levels.WARN)
    return
  end
  local current = vim.api.nvim_win_get_cursor(0)[1]
  local target = nil
  if direction > 0 then
    for _, c in ipairs(targetable) do
      local lnum = state.backend == "diffview" and c.line or c.diffLine
      if lnum > current then target = c; break end
    end
    target = target or targetable[1]
  else
    for i = #targetable, 1, -1 do
      local lnum = state.backend == "diffview" and targetable[i].line or targetable[i].diffLine
      if lnum < current then target = targetable[i]; break end
    end
    target = target or targetable[#targetable]
  end
  if state.backend == "diffview" and target.bufnr and vim.api.nvim_buf_is_valid(target.bufnr) then
    local win = vim.fn.bufwinid(target.bufnr)
    if win ~= -1 then vim.api.nvim_set_current_win(win) end
  end
  vim.api.nvim_win_set_cursor(0, { state.backend == "diffview" and target.line or target.diffLine, 0 })
end

local function file_header_lines()
  local headers = {}
  local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)
  for idx, line in ipairs(lines) do
    if line:match("^diff %-%-git a/.- b/.+$") then
      table.insert(headers, idx)
    end
  end
  return headers
end

local function jump_file(direction)
  local headers = file_header_lines()
  if #headers == 0 then
    notify("No file headers found", vim.log.levels.WARN)
    return
  end

  local current = vim.api.nvim_win_get_cursor(0)[1]
  local target = nil
  if direction > 0 then
    for _, lnum in ipairs(headers) do
      if lnum > current then target = lnum; break end
    end
    target = target or headers[1]
  else
    for i = #headers, 1, -1 do
      if headers[i] < current then target = headers[i]; break end
    end
    target = target or headers[#headers]
  end
  vim.api.nvim_win_set_cursor(0, { target, 0 })
  vim.cmd("normal! zz")
end

local function reset_review()
  local choice = vim.fn.confirm("Restart review and delete all saved comments?", "&Cancel\n&Restart", 1)
  if choice ~= 2 then return end
  state.comments = {}
  state.hidden_comments = {}
  render()
  save({ silent = true })
  notify("Restarted review; all comments cleared")
end

local function map_review_keys(bufnr)
  local opts = { buffer = bufnr, silent = true, noremap = true }
  vim.keymap.set("n", "<leader>rc", add_or_edit_comment, vim.tbl_extend("force", opts, { desc = "Add/edit review comment" }))
  vim.keymap.set("n", "<leader>rd", delete_comment, vim.tbl_extend("force", opts, { desc = "Delete review comment" }))
  vim.keymap.set("n", "<leader>rx", toggle_resolved, vim.tbl_extend("force", opts, { desc = "Toggle review comment resolved" }))
  vim.keymap.set("n", "<leader>rs", save, vim.tbl_extend("force", opts, { desc = "Save review" }))
  vim.keymap.set("n", "<leader>rq", function()
    save()
    if state.backend == "diffview" then pcall(vim.cmd, "DiffviewClose") end
    vim.cmd("qa")
  end, vim.tbl_extend("force", opts, { desc = "Save review and quit" }))
  vim.keymap.set("n", "<leader>rn", function() jump_comment(1) end, vim.tbl_extend("force", opts, { desc = "Next review comment" }))
  vim.keymap.set("n", "<leader>rp", function() jump_comment(-1) end, vim.tbl_extend("force", opts, { desc = "Previous review comment" }))
  vim.keymap.set("n", "<leader>rR", reset_review, vim.tbl_extend("force", opts, { desc = "Restart review (clear comments)" }))
end

local function attach_diffview_buffer(bufnr)
  state.attached_buffers[bufnr] = true
  vim.wo.number = true
  vim.wo.cursorline = true
  vim.wo.cursorcolumn = false
  map_review_keys(bufnr)
  local file = diffview_file_from_buf(bufnr)
  local side = diffview_side_from_buf(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for _, c in pairs(state.comments) do
    local line = c.line or (c.side == "old" and c.oldLine or c.newLine) or c.oldLine
    if c.file == file and c.side == side and line and line >= 1 and line <= line_count then
      c.line = line
      c.bufnr = bufnr
    elseif c.bufnr == bufnr then
      c.bufnr = nil
    end
  end
  render()
end

local function start_diffview()
  local initial = state.bufnr
  load_comments()
  local group = vim.api.nvim_create_augroup("pi_review_diffview", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "DiffviewDiffBufRead", "DiffviewDiffBufWinEnter" },
    callback = function() attach_diffview_buffer(vim.api.nvim_get_current_buf()) end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "DiffviewViewClosed",
    callback = function() save({ silent = true }) end,
  })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResized", "WinEnter", "TabEnter" }, {
    group = group,
    callback = function() vim.schedule(force_redraw) end,
  })
  setup_autosave_autocmd()
  if vim.fn.exists(":DiffviewOpen") == 0 then
    pcall(function() require("lazy").load({ plugins = { "diffview.nvim" } }) end)
  end
  if vim.fn.exists(":DiffviewOpen") == 0 then
    notify("DiffviewOpen command is unavailable; check diffview.nvim lazy-load config", vim.log.levels.ERROR)
    return
  end
  local cmd = "DiffviewOpen"
  if #state.diffview_args > 0 then
    cmd = cmd .. " " .. table.concat(vim.tbl_map(vim.fn.fnameescape, state.diffview_args), " ")
  end
  vim.cmd(cmd)
  if initial and vim.api.nvim_buf_is_valid(initial) then pcall(vim.api.nvim_buf_delete, initial, { force = true }) end
  save({ silent = true })
  notify("Diffview review ready: <leader>rc edit/autosave, <leader>rd delete, <leader>rR restart")
end

function M.start()
  did_save = false
  state.attached_buffers = {}
  state.line_map = {}
  state.bufnr = vim.api.nvim_get_current_buf()
  state.root = vim.env.PI_REVIEW_ROOT
  state.diff_path = vim.env.PI_REVIEW_DIFF
  state.json_path = vim.env.PI_REVIEW_JSON
  state.md_path = vim.env.PI_REVIEW_MD
  state.scope = vim.env.PI_REVIEW_SCOPE
  state.backend = vim.env.PI_REVIEW_BACKEND or "raw"
  if vim.env.PI_REVIEW_DIFFVIEW_ARGS then
    local ok, decoded = pcall(vim.json.decode, vim.env.PI_REVIEW_DIFFVIEW_ARGS)
    if ok and type(decoded) == "table" then state.diffview_args = decoded end
  end

  if not state.root or not state.json_path or not state.md_path then
    notify("Missing PI_REVIEW_* environment variables", vim.log.levels.ERROR)
    return
  end

  if state.backend == "diffview" then
    start_diffview()
    return
  end

  vim.bo[state.bufnr].filetype = "diff"
  vim.bo[state.bufnr].syntax = "diff"
  vim.bo[state.bufnr].modifiable = false
  vim.wo.number = true
  vim.wo.relativenumber = false
  vim.wo.cursorline = true
  pcall(vim.cmd, "syntax enable")

  parse_diff()
  load_comments()
  render()

  map_review_keys(state.bufnr)
  local opts = { buffer = state.bufnr, silent = true, noremap = true }
  vim.keymap.set("n", "]f", function() jump_file(1) end, vim.tbl_extend("force", opts, { desc = "Next changed file" }))
  vim.keymap.set("n", "[f", function() jump_file(-1) end, vim.tbl_extend("force", opts, { desc = "Previous changed file" }))

  local raw_group = vim.api.nvim_create_augroup("pi_review_raw", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResized", "WinEnter", "TabEnter" }, {
    group = raw_group,
    buffer = state.bufnr,
    callback = function() vim.schedule(force_redraw) end,
  })
  setup_autosave_autocmd()

  save({ silent = true })
  notify("Review mode ready: <leader>rc edit/autosave, <leader>rd delete, <leader>rR restart")
end

return M
