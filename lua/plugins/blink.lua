return {
    'saghen/blink.cmp',
    dependencies = {
        'rafamadriz/friendly-snippets',
        'Kaiser-Yang/blink-cmp-avante'
    },
    version = '*',
    opts = {
        keymap = { preset = 'default' },
        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono'
        },
        signature = {
          enabled = false,
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
            default = { 'lsp', 'path', 'snippets', 'buffer', 'dadbod', 'avante'},
            providers = {
                avante = { name = 'Avante',  module = 'blink-cmp-avante' },
                dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
            }
        },
    },
    opts_extend = { "sources.default" }
}
