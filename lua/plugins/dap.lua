return {
	{
		-- Debug Framework
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<F5>", "<Cmd>lua require'dap'.continue()<CR>", desc = "Continue debugging" },
			{ "<F9>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "Toggle breakpoint" },
			{ "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", desc = "Step over" },
			{ "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", desc = "Step into" },
			{ "<F8>", "<Cmd>lua require'dap'.step_out()<CR>", desc = "Step out" },
			{ "<leader>di", "<Cmd>lua require'dap'.step_into()<CR>", desc = "Step into" },
			{ "<leader>dT", "<Cmd>lua require'dap'.terminate()<CR>", desc = "Terminate" },
			{ "<leader>dD", "<Cmd>lua require'dap'.disconnect()<CR>", desc = "Disconnect" },
			{ "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", desc = "Open REPL" },
			{ "<leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", desc = "Run last" },
		},
		config = function()
			local dap = require("dap")

			local netcoredbg_adapter = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
			dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging

			-- Simplified configuration - actual config is built by dotnet-tools.dap
			dap.configurations.cs = {}
		end,
	},
	{
		-- UI for debugging
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
			{ "<leader>dw", function() require("dapui").eval(nil, { enter = true }) end, mode = { "n", "v" }, desc = "Add to watches" },
			{ "Q", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Hover eval" },
		},
		config = function()
			local dapui = require("dapui")
			local dap = require("dap")

			--- open ui immediately when debugging starts
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.fn.sign_define("DapBreakpoint", {
				text = "●",
				texthl = "DapBreakpointSymbol",
				linehl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})

			vim.fn.sign_define("DapStopped", {
				text = "→",
				texthl = "yellow",
				linehl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})
			vim.fn.sign_define("DapBreakpointRejected", {
				text = "⭕",
				texthl = "DapStoppedSymbol",
				linehl = "DapBreakpoint",
				numhl = "DapBreakpoint",
			})

			-- more minimal ui
			dapui.setup({
				expand_lines = true,
				controls = { enabled = false }, -- no extra play/step buttons
				floating = { border = "rounded" },
				render = {
					max_type_length = 60,
					max_value_lines = 200,
				},
				layouts = {
					{
						elements = {
							{ id = "repl", size = 1.0 },
						},
						size = 15,
						position = "bottom",
					},
					{
						elements = {
							{ id = "scopes", size = 1.0 },
						},
						size = 70,
						position = "right",
					},
				},
			})
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"Issafalcon/neotest-dotnet",
		},
		-- Only load when actually running tests
		keys = {
			{ "<F6>", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", desc = "Debug nearest test" },
			{ "<leader>dt", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", desc = "Debug nearest test" },
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-dotnet"),
				},
			})
		end,
	},
}
