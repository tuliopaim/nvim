local get_class_name = function()
    return vim.fn.expand('%:t:r')
end

local get_node_text = function(node, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local start_row, start_col, _, end_col = node:range()
  local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
  return line and string.sub(line, start_col + 1, end_col) or ""
end

local get_node_at_cursor = function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local parser = vim.treesitter.get_parser()
  if not parser then
    return
  end
  local lang_tree = parser:language_for_range { line, col, line, col }
  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    local node = root:named_descendant_for_range(line, col, line, col)
    if node then
      return node
    end
  end
end

local get_test_name = function()
    local node = get_node_at_cursor()
    if not node then
        print ('No node found')
        return
    end

    return get_node_text(node)
end

local show_test_results = function(output)
    -- Create a new horizontal split and set it to 10 lines high.
    vim.cmd('botright 20new')

    -- Get the buffer number of the current buffer (which is the new split).
    local bufnr = vim.api.nvim_get_current_buf()

    -- Set the buffer to be a scratch buffer.
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'dotnet-test-output')

    -- Insert the output into the buffer.
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(output, '\n'))

    -- Get the number of lines in the buffer.
    local lines_count = vim.api.nvim_buf_line_count(bufnr)

    -- Go to the end of the buffer.
    vim.api.nvim_win_set_cursor(0, {lines_count, 0})
end

local run_test_cmd = function(testCmd)

    vim.cmd("split | terminal")

    local command = ':call jobsend(b:terminal_job_id, "' .. testCmd ..'\\n")'

    vim.cmd(command)
end

local M = {}

M.test_at_cursor = function()
    local class_name = get_class_name()
    local test_name = get_test_name()

    if not test_name then
        print ('No test name found')
        return
    end

    local cmd = string.format("dotnet test --filter FullyQualifiedName~%s.%s", class_name, test_name)

    local output = vim.fn.system(cmd)

    show_test_results(output)
end

M.test_class = function()
    local class_name = get_class_name()

    local cmd = string.format("dotnet test --filter FullyQualifiedName~%s", class_name)

    local output = vim.fn.system(cmd)

    show_test_results(output)
end

return M
