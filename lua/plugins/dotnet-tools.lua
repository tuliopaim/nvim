return {
	{
		"dotnet-tools.nvim",
		dir = "~/dev/personal/dotnet-tools.nvim",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
		},
		ft = "cs", -- Only load for C# files
		keys = {
			{
				"<leader>rt",
				":DotnetTest<CR>",
				desc = "Run test at cursor",
			},
			{
				"<leader>rc",
				":DotnetTestClass<CR>",
				desc = "Run test class",
			},
			{
				"<leader>dd",
				":DotnetDebug<CR>",
				desc = "Start .NET debugging",
			},
			{
				"<leader>ds",
				":UserSecrets<CR>",
				desc = "Open user secrets",
			},
			{
				"<leader>dr",
				":OpenInRider<CR>",
				desc = "Open in Rider",
			},
			{
				"<leader>na",
				":DotnetNugetAdd<CR>",
				desc = "Add NuGet package",
			},
			{
				"<leader>nl",
				":DotnetNugetList<CR>",
				desc = "List NuGet packages",
			},
			{
				"<leader>nu",
				":DotnetNugetUpdate<CR>",
				desc = "Update NuGet package",
			},
			{
				"<leader>nr",
				":DotnetNugetRemove<CR>",
				desc = "Remove NuGet package",
			},
		},
		config = function()
			require("dotnet-tools").setup({
				rider_path = "/Applications/Rider.app/Contents/MacOS/rider",
			})
		end,
	}
}
