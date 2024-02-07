return {
    {
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = "0.1.5",
        dependencies = {
            {'nvim-lua/plenary.nvim'},
            {'folke/trouble.nvim'},
            {'ThePrimeagen/git-worktree.nvim'}
        },
        config = function()
            local trouble = require("trouble.providers.telescope")
            local telescope = require("telescope")

            telescope.setup {
                defaults = {
                    mappings = {
                        i = { ["<c-t>"] = trouble.open_with_trouble },
                        n = { ["<c-t>"] = trouble.open_with_trouble },
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown()
                    }
                }
            }

            telescope.load_extension("ui-select")

            local builtin = require('telescope.builtin')

            vim.keymap.set('n', '<leader>ff', function()
                builtin.find_files({ hidden= true })
            end);

            vim.keymap.set('n', '<C-p>', builtin.git_files, {})

            vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})

            vim.keymap.set('n', '<leader>fws', function()
                local word = vim.fn.expand("<cword>")
                builtin.grep_string({ search = word })
            end)

            vim.keymap.set('n', '<leader>fWs', function()
                local word = vim.fn.expand("<cWORD>")
                builtin.grep_string({ search = word })
            end)

            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})

            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = "[?] [S]earch [H]elp" })

            vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })

            vim.keymap.set("n", "<leader>ss", function()
                require("telescope.builtin").spell_suggest(require("telescope.themes").get_dropdown({
                    previewer = false,
                }))
            end, { desc = "[S]earch [S]pelling suggestions" })

            -- worktree
            vim.keymap.set('n', '<leader>fwt', function()
                telescope.extensions.git_worktree.git_worktrees()
            end)

            vim.keymap.set('n', '<leader>fwT', function()
                telescope.extensions.git_worktree.create_git_worktree()
            end)
        end
    }
}
