require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'onedark',
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {
        'mode'
    },
    lualine_b = {
        'branch', 'diff',
    },
    lualine_c = {
    }
  },
}

