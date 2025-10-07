return {
    {
        'tpope/vim-fugitive'
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
