return {
    {
		"zbirenbaum/copilot.lua",
        command = "Copilot",
        enabled = false,
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
                enabled = true,
                auto_refresh = true,
				suggestion = {
					enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept = "<Tab>",
                        next = "<down>",
                        prev = "<up>",
                    }
				},
				panel = { enabled = false },
			})
		end,
	}
}
