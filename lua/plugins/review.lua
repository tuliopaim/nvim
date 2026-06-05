return {
  {
    dir = vim.fn.stdpath("config"),
    name = "review",
    dependencies = { "sindrets/diffview.nvim" },
    cmd = { "ReviewStart" },
    keys = {
      { "<leader>rR", function() require("tuliopaim.review").start({}) end, desc = "Open Diffview review" },
      { "<leader>rc", function() require("tuliopaim.review").comment() end, desc = "Add review comment on current line" },
    },
    config = function()
      vim.api.nvim_create_user_command("ReviewStart", function(opts)
        require("tuliopaim.review").start(opts.fargs)
      end, { nargs = "*", desc = "Open Diffview review UI" })
    end,
  },
}
