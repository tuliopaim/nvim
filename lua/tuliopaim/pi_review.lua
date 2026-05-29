local M = {}

local did_save = false

local state = {
  ns = vim.api.nvim_create_namespace("pi_review"),
  bufnr = nil,
  root = nil,
  diff_path = nil,
  json_path = nil,
  md_path = nil,
  line_map = {},
  comments = {},
  created_at = nil,
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "pi-review" })
end

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
            file = current_file, side = "new", old_line = nil, new_line = new_line,
            diff_line = idx, kind = "added",
          }
          new_line = new_line + 1
        elseif prefix == "-" and line:sub(1, 3) ~= "---" then
          state.line_map[idx] = {
            file = current_file, side = "old", old_line = old_line, new_line = nil,
            diff_line = idx, kind = "removed",
          }
          old_line = old_line + 1
        elseif prefix == " " then
          state.line_map[idx] = {
            file = current_file, side = "both", old_line = old_line, new_line = new_line,
            diff_line = idx, kind = "context",
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
  local line = anchor.new_line or anchor.old_line or 0
  return table.concat({ anchor.file or "", anchor.side or "", tostring(line), tostring(anchor.diff_line or 0) }, ":")
end

local function sorted_comments()
  local out = {}
  for _, comment in pairs(state.comments) do table.insert(out, comment) end
  table.sort(out, function(a, b) return (a.diffLine or 0) < (b.diffLine or 0) end)
  return out
end

local function render()
  vim.api.nvim_buf_clear_namespace(state.bufnr, state.ns, 0, -1)
  for _, comment in pairs(state.comments) do
    local lnum = comment.diffLine
    if lnum and state.line_map[lnum] then
      vim.api.nvim_buf_set_extmark(state.bufnr, state.ns, lnum - 1, 0, {
        virt_lines = { { { "  💬 " .. (comment.body or ""), "Comment" } } },
        virt_lines_above = false,
      })
    end
  end
end

local function load_comments()
  state.comments = {}
  local data = json_read(state.json_path)
  state.created_at = (data and data.createdAt) or iso_now()
  if not data or type(data.comments) ~= "table" then return end

  for _, comment in ipairs(data.comments) do
    local diff_line = comment.diffLine
    if type(diff_line) == "number" and state.line_map[diff_line] then
      local anchor = state.line_map[diff_line]
      if anchor.file == comment.file then
        state.comments[tostring(diff_line)] = comment
      end
    end
  end
end

local function comment_from_anchor(anchor, body)
  return {
    id = anchor_id(anchor),
    file = anchor.file,
    side = anchor.side,
    oldLine = anchor.old_line,
    newLine = anchor.new_line,
    diffLine = anchor.diff_line,
    kind = anchor.kind,
    body = body,
  }
end

local function save(opts)
  opts = opts or {}
  local comments = sorted_comments()
  local doc = {
    version = 1,
    repo = state.root,
    diff = state.diff_path,
    base = "HEAD",
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
    "Comments: `" .. tostring(#comments) .. "`",
    "",
  }
  if #comments == 0 then
    table.insert(md, "No comments.")
  end
  for _, c in ipairs(comments) do
    local line_label = c.newLine and tostring(c.newLine) or ("old line " .. tostring(c.oldLine or "?"))
    table.insert(md, "## " .. c.file .. ":" .. line_label)
    table.insert(md, "")
    table.insert(md, "Side: `" .. c.side .. "`, diff line: `" .. tostring(c.diffLine) .. "`, kind: `" .. tostring(c.kind) .. "`")
    table.insert(md, "")
    table.insert(md, c.body or "")
    table.insert(md, "")
  end
  write_file(state.md_path, table.concat(md, "\n"))
  did_save = true
  if not opts.silent then
    notify("Saved review to " .. state.md_path)
  end
end

local function current_anchor()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  return lnum, state.line_map[lnum]
end

local function add_or_edit_comment()
  local lnum, anchor = current_anchor()
  if not anchor then
    notify("Not a commentable diff body line", vim.log.levels.WARN)
    return
  end
  local existing = state.comments[tostring(lnum)]
  vim.ui.input({ prompt = "Review comment: ", default = existing and existing.body or "" }, function(input)
    if input == nil then return end
    if input == "" then
      state.comments[tostring(lnum)] = nil
    else
      state.comments[tostring(lnum)] = comment_from_anchor(anchor, input)
    end
    render()
  end)
end

local function delete_comment()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  if state.comments[tostring(lnum)] then
    state.comments[tostring(lnum)] = nil
    render()
    notify("Deleted comment")
  else
    notify("No comment on this line", vim.log.levels.WARN)
  end
end

local function jump_comment(direction)
  local comments = sorted_comments()
  if #comments == 0 then
    notify("No comments", vim.log.levels.WARN)
    return
  end
  local current = vim.api.nvim_win_get_cursor(0)[1]
  local target = nil
  if direction > 0 then
    for _, c in ipairs(comments) do
      if c.diffLine > current then target = c.diffLine; break end
    end
    target = target or comments[1].diffLine
  else
    for i = #comments, 1, -1 do
      if comments[i].diffLine < current then target = comments[i].diffLine; break end
    end
    target = target or comments[#comments].diffLine
  end
  vim.api.nvim_win_set_cursor(0, { target, 0 })
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

function M.start()
  state.bufnr = vim.api.nvim_get_current_buf()
  state.root = vim.env.PI_REVIEW_ROOT
  state.diff_path = vim.env.PI_REVIEW_DIFF
  state.json_path = vim.env.PI_REVIEW_JSON
  state.md_path = vim.env.PI_REVIEW_MD

  if not state.root or not state.json_path or not state.md_path then
    notify("Missing PI_REVIEW_* environment variables", vim.log.levels.ERROR)
    return
  end

  vim.bo[state.bufnr].filetype = "diff"
  vim.bo[state.bufnr].syntax = "diff"
  vim.bo[state.bufnr].modifiable = false
  vim.wo.number = true
  vim.wo.relativenumber = false
  pcall(vim.cmd, "syntax enable")

  parse_diff()
  load_comments()
  render()

  local opts = { buffer = state.bufnr, silent = true, noremap = true }
  vim.keymap.set("n", "<leader>rc", add_or_edit_comment, vim.tbl_extend("force", opts, { desc = "Add/edit review comment" }))
  vim.keymap.set("n", "<leader>rd", delete_comment, vim.tbl_extend("force", opts, { desc = "Delete review comment" }))
  vim.keymap.set("n", "<leader>rs", save, vim.tbl_extend("force", opts, { desc = "Save review" }))
  vim.keymap.set("n", "<leader>rq", function() save(); vim.cmd("quit") end, vim.tbl_extend("force", opts, { desc = "Save review and quit" }))
  vim.keymap.set("n", "<leader>rn", function() jump_comment(1) end, vim.tbl_extend("force", opts, { desc = "Next review comment" }))
  vim.keymap.set("n", "<leader>rp", function() jump_comment(-1) end, vim.tbl_extend("force", opts, { desc = "Previous review comment" }))
  vim.keymap.set("n", "]f", function() jump_file(1) end, vim.tbl_extend("force", opts, { desc = "Next changed file" }))
  vim.keymap.set("n", "[f", function() jump_file(-1) end, vim.tbl_extend("force", opts, { desc = "Previous changed file" }))

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("pi_review_autosave", { clear = true }),
    buffer = state.bufnr,
    callback = function()
      if state.md_path and not did_save then
        save({ silent = true })
      end
    end,
  })

  save({ silent = true })
  notify("Review mode ready: <leader>rc comment, ]f/[f files, <leader>rs save, <leader>rq save+quit")
end

return M
