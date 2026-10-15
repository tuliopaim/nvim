return {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
        require("github-theme").setup({
            groups = {
                all = {
                    RenderMarkdownCode = { bg = "#161b22" },
                    RenderMarkdownCodeBorder = { bg = "#161b22" },
                    RenderMarkdownCodeInline = { bg = "#21262d", fg = "#e6edf3" },
                },
            },
        })
        vim.cmd.colorscheme("github_dark_default")
    end,
}
