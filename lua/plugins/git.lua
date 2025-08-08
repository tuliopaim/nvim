return {
    {
        'tpope/vim-fugitive'
    },
    {
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup()

            vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>")
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
