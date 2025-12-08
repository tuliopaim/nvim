return {
    "ThePrimeagen/harpoon",
    dependencies = {"nvim-lua/plenary.nvim"},
    keys = {
        { "<leader>hi", function() require('harpoon.mark').add_file() end, desc = "Harpoon add file" },
        { "<leader>hh", function() require('harpoon.ui').toggle_quick_menu() end, desc = "Harpoon menu" },
        { "<leader>1", function() require('harpoon.ui').nav_file(1) end, desc = "Harpoon file 1" },
        { "<leader>2", function() require('harpoon.ui').nav_file(2) end, desc = "Harpoon file 2" },
        { "<leader>3", function() require('harpoon.ui').nav_file(3) end, desc = "Harpoon file 3" },
        { "<leader>4", function() require('harpoon.ui').nav_file(4) end, desc = "Harpoon file 4" },
        { "<leader>5", function() require('harpoon.ui').nav_file(5) end, desc = "Harpoon file 5" },
        { "<leader>gk", function() require('harpoon.ui').nav_next() end, desc = "Harpoon next" },
        { "<leader>gj", function() require('harpoon.ui').nav_prev() end, desc = "Harpoon prev" },
    },
    config = function()
        require("harpoon").setup({
            menu = {
                width = 120
            }
        })
    end
}
