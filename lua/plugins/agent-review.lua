return {
	{
		--dir = "~/dev/personal/agent-review.nvim",
		--name = "agent-review",
        "tuliopaim/agent-review.nvim",
		dependencies = { "sindrets/diffview.nvim" },
		cmd = { "ReviewDiff", "ReviewComment", "ReviewRefresh", "ReviewDelete" },
		keys = {
			{
				"<leader>rR",
				function()
					require("agent-review").start({})
				end,
				desc = "Open Diffview review",
			},
			{
				"<leader>rr",
				function()
					require("agent-review").refresh()
				end,
				desc = "Refresh review",
			},
			{
				"<leader>rc",
				function()
					require("agent-review").comment()
				end,
				desc = "Add review comment on current line",
			},
		},
		config = function()
			require("agent-review").setup()
		end,
	},
}
