return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function(_, opts)
    local snacks = require("snacks")
    snacks.setup(opts)
    vim.ui.input = snacks.input.input
    vim.ui.select = snacks.picker.select
  end,
  opts = {
    styles = {
      notification_history = {
        width = 0.8,
        height = 0.8,
      },
    },
    image = { enabled = false },
    bigfile = { enabled = true },
    lazygit = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    dashboard = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = true,
      ui_select = true,
      sources = {
        explorer = {
          layout = {
            layout = {
              width = 80,
              min_width = 40,
              position = "right",
            },
          },
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    explorer = { enabled = true },
  },
  keys = {
    { "<leader>ff",  function() Snacks.picker.smart({ hidden = true }) end, desc = "Find files - smart" },
    { "<leader><leader>",  function() Snacks.picker.buffers() end, desc = "Find buffers" },
    { "<leader>fg",  function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fw",  function() Snacks.picker.grep_word() end, desc = "Grep word" },
    { "<leader>fp",  function() Snacks.picker() end, desc = "Pickers" },
    { "<leader>fb",  function() Snacks.picker.git_branches() end, desc = "Find git branches" },
    { "<leader>fc",  function() Snacks.picker.commands() end, desc = "Find commands" },
    { "<leader>fh",  function() Snacks.picker.help() end, desc = "Find help" },
    { "<leader>fk",  function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
    { "<leader>fd",  function() Snacks.picker.diagnostics() end, desc = "Find diagnostics" },
    { "<leader>fn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>es", function() Snacks.picker.explorer({ hidden = true }) end, desc = "Explorer with hidden files" },
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>nh",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>db", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gfl", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<leader>]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "<leader>[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.8,
          height = 0.8,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    }
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
