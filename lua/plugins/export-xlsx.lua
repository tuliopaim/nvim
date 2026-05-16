return {
  "tuliopaim/dadbod-export-xlsx.nvim",
  dependencies = { "tpope/vim-dadbod" },
  config = function()
    require("dadbod_export_xlsx").setup()
  end,
}
