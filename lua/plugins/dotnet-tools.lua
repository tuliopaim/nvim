return {
	{
		"dotnet-tools",
		dir = "~/.config/nvim/lua/tuliopaim/dotnet-tools",
		event = "VeryLazy",
		keys = {
			{
				"<leader>rt",
				":Test<CR>",
				desc = "Run test at cursor",
			},
			{
				"<leader>rc",
				":TestClass<CR>",
				desc = "Run test class",
			},
		},
		config = function()
			require("dotnet-tools").setup({
				script_path = "/Applications/Rider.app/Contents/MacOS/rider",
			})
		end,
	},
	{
		"ramboe/ramboe-dotnet-utils",
		dependencies = { "mfussenegger/nvim-dap" },
	},
}
