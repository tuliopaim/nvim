-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'


    -- Telescope
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'nvim-telescope/telescope-ui-select.nvim'}
        }
    }

    -- Nvim Tree
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
        tag = 'nightly'
    }

    -- Theme
    use { "catppuccin/nvim", as = "catppuccin" }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    use {
        'romgrk/barbar.nvim',
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        tag = 'v0.9.1'
    }

    use 'mbbill/undotree'

    -- LSP
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
            {'Decodetalkers/csharpls-extended-lsp.nvim'},
            { 'jmederosalvarado/roslyn.nvim' }
        }
    }

    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    }

    -- Markdown
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- tmux
    use "christoomey/vim-tmux-navigator"

    -- git
    use({
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })

    use 'tpope/vim-fugitive'

    --copilot
    use 'github/copilot.vim'

    -- harpoon!
    use {
        "ThePrimeagen/harpoon",
        requires = {"nvim-lua/plenary.nvim"},
    }

    -- trouble
    use {
        "folke/trouble.nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
    }

end)

