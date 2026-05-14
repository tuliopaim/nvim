return {
  "tuliopaim/nvim-export-xlsx",
  dependencies = { "tpope/vim-dadbod" },
  config = function()
    require("export_xlsx").setup()
  end,
}
