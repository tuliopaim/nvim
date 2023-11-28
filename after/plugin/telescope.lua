require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown()
    }
  }
}

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', function()
    builtin.find_files({ hidden= true })
end);

vim.keymap.set('n', '<C-t>', builtin.git_files, {})
vim.keymap.set('n', '<leader>fs', function() builtin.grep_string(); end)

vim.keymap.set('n', '<leader>fb', builtin.buffers, {})


require("telescope").load_extension("ui-select")
