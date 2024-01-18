
vim.cmd [[
    command! -nargs=? TestAtCursor lua require'tuliopaim.dotnet-test'.test_at_cursor(<q-args>)
]]

vim.cmd [[
    command! -nargs=? TestClass lua require'tuliopaim.dotnet-test'.test_class(<q-args>)
]]

vim.cmd [[
    command! -nargs=? UserSecrets lua require'tuliopaim.user-secrets'.open_or_create_secrets_file()
]]

