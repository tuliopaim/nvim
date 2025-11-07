return {
    'saghen/blink.cmp',
    event = "InsertEnter",
    dependencies = {
        'rafamadriz/friendly-snippets',
    },
    version = '*',
    opts = {
        keymap = { preset = 'default' },
        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono'
        },
        signature = {
          enabled = true,
          trigger = {
            enabled = true,
          },
        },
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
            },
            menu = {
                auto_show = true,
                draw = {
                    treesitter = { "lsp" },
                    columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
                }
            }
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer', 'dadbod' },
            providers = {
                dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
            }
        },
    },
    opts_extend = { "sources.default" }
}
