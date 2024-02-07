return {
    "dotnet-tools",
    dir = "~/.dotfiles/nvim/.config/nvim/lua/tuliopaim/dotnet-tools",
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
        require("dotnet-tools").setup({
            script_path = "~/.local/share/JetBrains/Toolbox/scripts/rider"
        })
    end
}
