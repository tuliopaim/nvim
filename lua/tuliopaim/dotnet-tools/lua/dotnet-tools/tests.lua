local helpers = require('dotnet-tools.helpers')

local run_test_and_print = function(testCmd)
   -- Open a new split window at the bottom
    vim.cmd('botright split')

    -- Run 'dotnet test' command in Neovim's terminal
    vim.cmd('terminal ' .. testCmd)

    -- Optionally, switch to normal mode immediately after opening the terminal
    vim.cmd('startinsert!')
end

local M = {}

M.run_test_at_cursor = function()
    local class_name = helpers.get_class_name()
    local test_name = helpers.get_function_name_with_treesitter()

    if not test_name then
        print ('No test name found')
        return
    end

    local cmd = string.format('dotnet test --filter "%s.%s"', class_name, test_name)

    run_test_and_print(cmd)
end

M.run_test_class = function()
    local class_name = helpers.get_class_name()

    local cmd = string.format("dotnet test --filter FullyQualifiedName~%s", class_name)

    run_test_and_print(cmd)
end

return M
