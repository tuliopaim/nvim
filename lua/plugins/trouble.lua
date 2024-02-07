return {
 "folke/trouble.nvim",
 dependencies = { "nvim-tree/nvim-web-devicons" },
 opts = {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
 },
    config = function()
        require("trouble").setup()

        vim.keymap.set("n", "<leader>tx", function() require("trouble").toggle() end)
        vim.keymap.set("n", "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end)
        vim.keymap.set("n", "<leader>td", function() require("trouble").toggle("document_diagnostics") end)
    end,
}

