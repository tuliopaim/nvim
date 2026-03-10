return {
    "supermaven-inc/supermaven-nvim",
    enabled = false,
    event = "InsertEnter", -- Only load when entering insert mode
    config = function()
        require("supermaven-nvim").setup({
            ignore_filetypes = { "markdown" },
            keymaps = {
                accept_suggestion = "<Tab>",
                clear_suggestion = "<C-]>",
                accept_word = "<C-j>",
            }
        })
    end,
};
