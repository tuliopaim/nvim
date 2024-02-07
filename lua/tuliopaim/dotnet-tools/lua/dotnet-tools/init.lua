local tests = require('dotnet-tools.tests')
local secrets = require('dotnet-tools.secrets')
local open_in_rider = require('dotnet-tools.open-in-rider')

local M = {}

M.run_test_at_cursor = tests.run_test_at_cursor
M.run_test_class = tests.run_test_class
M.open_or_create_secrets_file = secrets.open_or_create_secrets_file

M.setup = function(opts)
    vim.api.nvim_create_user_command('TestAtCursor', tests.run_test_at_cursor, {})
    vim.api.nvim_create_user_command('TestClass', tests.run_test_class, {})
    vim.api.nvim_create_user_command('UserSecrets', secrets.open_or_create_secrets_file, {})
    vim.api.nvim_create_user_command('OpenInRider', function() open_in_rider.open_in_rider(opts) end, {})
end

return M
