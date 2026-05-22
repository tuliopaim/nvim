return {
    {
        "kristijanhusak/vim-dadbod-ui",
        Lazy = true,
        dependencies = {
            { "tpope/vim-dadbod",                     lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            -- Use the sandbox-local dadbod state when direnv exports it;
            -- otherwise keep vim-dadbod-ui's normal global location so local
            -- connections and saved queries remain available outside sandboxes.
            vim.g.db_ui_save_location = vim.env.DB_UI_SAVE_LOCATION
                or vim.fn.expand("~/.local/share/db_ui")

            -- dadbod-ui's own dotenv scanner matches any env var containing
            -- "DB_UI_", which picks up DB_UI_SAVE_LOCATION as a bogus
            -- connection. Point it at a sentinel that never matches.
            vim.g.db_ui_dotenv_variable_prefix = "DADBOD_DOTENV_DISABLED__"
            vim.g.db_ui_env_variable_url = "DADBOD_ENV_DISABLED__"
            vim.g.db_ui_env_variable_name = "DADBOD_ENV_NAME_DISABLED__"

            local dbs = {}
            for k, v in pairs(vim.fn.environ()) do
                if k:match("^DB_") and type(v) == "string" and v:match("^%a[%w+%-.]*:") then
                    dbs[k:sub(4):lower()] = v
                end
            end
            if next(dbs) then vim.g.dbs = dbs end

            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_winwidth = 30
            vim.g.db_ui_show_help = 0
            vim.g.db_ui_use_nvim_notify = 1
            vim.g.db_ui_win_position = "left"
            vim.g.db_ui_execute_on_save = 0
        end,
    },
}
