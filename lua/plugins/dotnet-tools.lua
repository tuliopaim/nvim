return {
    "dotnet-tools",
    dir = "/usr/local/share/.dotfiles/nvim/.config/nvim/lua/tuliopaim/dotnet-tools",
    event = "VeryLazy",
    keys = {
        {
            "<leader>rt",
            ":TestAtCursor<CR>",
            desc="Run test at cursor"
        },
        {
            "<leader>rc",
            ":TestClass<CR>",
            desc="Run test class"
        },
    },
    config = function()
        require("dotnet-tools").setup()
    end
}
