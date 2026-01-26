return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = 'master',
        event = { "BufReadPost", "BufNewFile" }, -- Load when opening a file
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
                    "markdown_inline",
                    "prisma",
                    "tsx",
                    "typescript",
                    "vim",
                    "c_sharp",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })

            vim.treesitter.language.register("c_sharp", "csharp")
        end
    }
}

