return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        branch = 'main',
        lazy = false,
        config = function()
            require('nvim-treesitter').install({
                'regex',
                'bash',
                'c',
                'css',
                'html',
                'javascript',
                'json',
                'lua',
                'markdown',
                'markdown_inline',
                'nix',
                'prisma',
                'sql',
                'tsx',
                'typescript',
                'vim',
                'c_sharp',
                'yaml',
                'tmux',
            })

            local group = vim.api.nvim_create_augroup('nvim-treesitter-migration', { clear = true })

            vim.api.nvim_create_autocmd('FileType', {
                group = group,
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    }
}

