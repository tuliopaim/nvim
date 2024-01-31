local on_attach = function(client, bufnr)
    local map = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    map("gD", vim.lsp.buf.type_definition, "Type [D]efinition")
    map("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")

    local telescope_builtin = require("telescope.builtin")
    map("gi", telescope_builtin.lsp_implementations, "[G]o to [I]mplementations")

    map("<leader>ds", telescope_builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
    map("<leader>ws", telescope_builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("<leader>k", vim.diagnostic.open_float, "Float Documentation")
    map("<leader>sh", vim.lsp.buf.signature_help, "Signature Help")

    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_buf_create_user_command(
            bufnr,
            "Format",
            vim.lsp.buf.format,
            { desc = "Format current buffer with LSP" }
        )

        map("<leader>fm", vim.lsp.buf.format, "Format buffer")
    end
end

return {

    { "williamboman/mason.nvim", config = true },

    {
        "williamboman/mason-lspconfig.nvim",
        event = "BufReadPre",
        dependencies = {
            "neovim/nvim-lspconfig",
            -- plugins to setup lsp servers
            "folke/neodev.nvim",
            "jmederosalvarado/roslyn.nvim",
            "Decodetalkers/csharpls-extended-lsp.nvim",

            -- better ui for lsp progress
            { "j-hui/fidget.nvim", tag = "legacy", config = true },
        },
        config = function()
            vim.diagnostic.config({
                virtual_text = true,
                severity_sort = true,
                float = {
                    style = 'minimal',
                    border = 'rounded',
                    source = 'always',
                    header = '',
                    prefix = '',
                },
            })
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                cmp_nvim_lsp.default_capabilities()
            )

            require("roslyn").setup({
                dotnet_cmd = "dotnet",
                roslyn_version = "4.9.0-3.23604.10",
                on_attach = on_attach,
                capabilities = capabilities,
            })

            require("mason-lspconfig").setup()
            require("mason-lspconfig").setup_handlers({
                -- The first entry (without a key) will be the default handler
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup({
                        on_attach = on_attach,
                        capabilities = capabilities,
                    })
                end,

                ["lua_ls"] = function()
                    require("neodev").setup()
                    require("lspconfig").lua_ls.setup({
                        on_attach = on_attach,
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                format = { enable = false },
                                telemetry = { enable = false },
                                workspace = { checkThirdParty = false },
                            },
                        },
                    })
                end,

                ["csharp_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.csharp_ls.setup({
                        handlers = {
                            ["textDocument/definition"] = require('csharpls_extended').handler,
                        },

                        root_dir = function(startpath)
                            return lspconfig.util.root_pattern("*.sln")(startpath)
                                or lspconfig.util.root_pattern("*.csproj")(startpath)
                                or lspconfig.util.root_pattern("*.fsproj")(startpath)
                                or lspconfig.util.root_pattern(".git")(startpath)
                        end,

                        on_attach = on_attach,
						capabilities = capabilities,
                    })
                end,

				["gopls"] = function()
					require("lspconfig").gopls.setup({
						on_attach = on_attach,
						capabilities = capabilities,
						settings = {
							gopls = {
								staticcheck = true,
								gofumpt = false,
							},
						},
					})
				end,

			})
		end,
	},
    {
        "Fildo7525/pretty_hover",
        event = "LspAttach",
        opts = {}
    },
}
