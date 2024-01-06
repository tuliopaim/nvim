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
vim.api.nvim_set_keymap('n', 'gj', ':BufferPrevious<CR>', opts)
vim.api.nvim_set_keymap('n', 'gk', ':BufferNext<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>x', ':BufferDelete<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>tp', ':BufferPin<CR>', opts)
vim.api.nvim_set_keymap('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
vim.api.nvim_set_keymap('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)

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

-- tmux
vim.keymap.set("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>")
vim.keymap.set("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>")
vim.keymap.set("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>")

-- git
vim.api.nvim_set_keymap('n', "<leader>gm", "<cmd> LazyGit<CR>", opts)

-- harpoon
vim.keymap.set('n', "<leader>hi", function() require('harpoon.mark').add_file() end)
vim.keymap.set('n', "<leader>hh", function() require('harpoon.ui').toggle_quick_menu() end)
vim.keymap.set('n', "<leader>1", function() require('harpoon.ui').nav_file(1)end, opts)
vim.keymap.set('n', "<leader>2", function() require('harpoon.ui').nav_file(2)end, opts)
vim.keymap.set('n', "<leader>3", function() require('harpoon.ui').nav_file(3)end, opts)
vim.keymap.set('n', "<leader>4", function() require('harpoon.ui').nav_file(4)end, opts)
vim.keymap.set('n', "<leader>gk", function() require('harpoon.ui').nav_next()end, opts)
vim.keymap.set('n', "<leader>gj", function() require('harpoon.ui').nav_prev()end, opts)


vim.keymap.set('n', '<leader>ff', function()

end);
-- test
vim.api.nvim_set_keymap('n', "<leader>rt", "<cmd> TestAtCursor<CR>", opts)

vim.cmd [[
    command! -nargs=? TestAtCursor lua require'tuliopaim.dotnet-test'.test_at_cursor(<q-args>)
]]

vim.cmd [[
    command! -nargs=? TestClass lua require'tuliopaim.dotnet-test'.test_class(<q-args>)
]]

