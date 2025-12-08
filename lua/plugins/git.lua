return {
    {
        'tpope/vim-fugitive',
        cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse", "GRemove", "GRename", "Glgrep", "Gedit" },
    },
    {
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup()
		end,
	},
    {
		"sindrets/diffview.nvim",
		event = "VeryLazy",
        config = function()
            vim.api.nvim_create_user_command('Gd', 'DiffviewOpen', {})
        end,
	}
}
