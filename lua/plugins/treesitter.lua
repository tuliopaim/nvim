return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        tag = 'v0.9.3',
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                ensure_installed = {
                    "regex",
                    "bash",
                    "c",
                    "css",
                    "html",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "prisma",
                    "tsx",
                    "typescript",
                    "vim",
                    "c_sharp",
                    "markdown",
                    "markdown_inline"
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })

            vim.treesitter.language.register("c_sharp", "csharp")
        end
    }
}

