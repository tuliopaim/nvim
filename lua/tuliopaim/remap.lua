vim.g.mapleader = ' '
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

local opts = { noremap = true, silent = true }

--Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", opts)

vim.cmd("command W w")

-- Normal --
-- Better window navigation
vim.api.nvim_set_keymap('n', "<C-d>", "<C-d>zz", opts)
vim.api.nvim_set_keymap('n', "<C-u>", "<C-u>zz", opts)
vim.api.nvim_set_keymap('n', "<leader>v", ":vsplit<CR>", opts)
vim.api.nvim_set_keymap('n', "<leader>b", ":split<CR>", opts)

-- Tabs
vim.api.nvim_set_keymap("n", "<leader>sk", ":resize +2<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>sj", ":resize -2<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>sh", ":vertical resize -2<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>sl", ":vertical resize +2<CR>", opts)

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", "\"0p")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- dotnet test
--
vim.api.nvim_set_keymap('n', "<leader>rt", "<cmd> TestAtCursor<CR>", opts)

vim.cmd [[
    command! -nargs=? TestAtCursor lua require'tuliopaim.dotnet-test'.test_at_cursor(<q-args>)
]]

vim.cmd [[
    command! -nargs=? TestClass lua require'tuliopaim.dotnet-test'.test_class(<q-args>)
]]

vim.cmd [[
    command! -nargs=? UserSecrets lua require'tuliopaim.user-secrets'.open_or_create_secrets_file()
]]

