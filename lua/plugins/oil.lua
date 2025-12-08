return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons"},
    keys = {
        { "<leader>-", function() require("oil").toggle_float() end, desc = "Open oil file browser" },
    },
    config = function()
        require("oil").setup {
            columns = { "icon" },
            keymaps = {
                ["<C-h>"] = false,
                ["<M-h>"] = "actions.select_split",
            },
            view_options = {
                show_hidden = true,
            }
        }
    end,
}
