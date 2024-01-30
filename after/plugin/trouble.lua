require("trouble").setup();

vim.keymap.set("n", "<leader>tx", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>td", function() require("trouble").toggle("document_diagnostics") end)
vim.keymap.set("n", "gr", function() require("trouble").toggle("lsp_references") end)
