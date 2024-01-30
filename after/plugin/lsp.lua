local lsp_zero = require('lsp-zero')

lsp_zero.set_sign_icons({
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
})

lsp_zero.on_attach(function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }
    --local telescope = require('telescope.builtin')
    --vim.keymap.set("n", "gr", function() telescope.lsp_references() end, opts)

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>k", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

local lspconfig = require('lspconfig')

--local csharp_ls_bin = "/usr/local/share/csharp-language-server/src/CSharpLanguageServer/bin/Debug/net7.0/CSharpLanguageServer"
--local csharp_ls_config = {
--    --cmd = { csharp_ls_bin }, -- specify if you build project locally (modify csharp_ls_bin path first), otherwise download using `dotnet tools` & keep that like ignored
--
--    handlers = {
--        ["textDocument/definition"] = require('csharpls_extended').handler,
--    },
--
--    root_dir = function(startpath)
--        return lspconfig.util.root_pattern("*.sln")(startpath)
--        or lspconfig.util.root_pattern("*.csproj")(startpath)
--        or lspconfig.util.root_pattern("*.fsproj")(startpath)
--        or lspconfig.util.root_pattern(".git")(startpath)
--    end,
--
--    on_attach = lsp_zero.on_attach,
--}

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'tsserver',
        'eslint',
        'lua_ls'
    },
    handlers = {
        lsp_zero.default_setup,

        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            lspconfig.lua_ls.setup(lua_opts)
        end,
    },
})

local cmp = require('cmp')

local cmp_select = { behavior = cmp.SelectBehavior.Select }

local cmp_mappings = {
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ["<C-Space>"] = cmp.mapping.complete(),
}

cmp.setup({
    formating = lsp_zero.cmp_format(),
    mapping = cmp.mapping.preset.insert(cmp_mappings),
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'buffer', keyword_length = 3 },
        { name = 'luasnip', keyword_length = 2 },
    }
})

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


require("roslyn").setup({
    dotnet_cmd = "dotnet", -- this is the default
    roslyn_version = "4.8.0-3.23475.7", -- this is the default
    on_attach = lsp_zero.on_attach,
    capabilities = lsp_zero.capabilities,
})
