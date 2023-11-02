return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    tag = 'v0.9.1',
    config = function()
        local config = require("nvim-treesitter.configs")
        config.setup({
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}

