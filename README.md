# Neovim Configuration

A comprehensive Neovim setup optimized for .NET/C# development with excellent full-stack support. Built with lazy.nvim for modular plugin management.

![Neovim](assets/nvim.png)

## Table of Contents

- [Plugins](#plugins)
  - [Completion & AI](#completion-%26-ai)
  - [LSP & Language Support](#lsp-%26-language-support)
  - [Debugging & Testing](#debugging-%26-testing)
  - [Formatting & Linting](#formatting-%26-linting)
  - [Git Integration](#git-integration)
  - [File Navigation & Management](#file-navigation-%26-management)
  - [UI & Appearance](#ui-%26-appearance)
  - [Code Editing](#code-editing)
  - [Database & HTTP](#database-%26-http)
  - [Command Line & Utilities](#command-line-%26-utilities)
- [Configuration Structure](#configuration-structure)
- [Key Bindings](#key-bindings)
  - [File Navigation](#file-navigation-1)
  - [Harpoon](#harpoon)
  - [LSP](#lsp-1)
  - [Git](#git)
  - [Testing (Neotest)](#testing-%28neotest%29)
  - [Utilities](#utilities)
- [Key Features](#key-features)

## Plugins

### Completion & AI

- **blink.cmp** - Modern completion plugin with LSP, snippet, and buffer support plus pre-configured snippets
- **copilot.lua** - GitHub Copilot integration for AI-powered code suggestions
- **supermaven-nvim** - Supermaven AI code completion (currently disabled)

### LSP & Language Support

- **mason.nvim** - Package manager for LSP servers, formatters, and linters with automatic lspconfig bridge
- **nvim-lspconfig** - Quickstart configurations for Neovim's built-in LSP client
- **roslyn.nvim** - Roslyn LSP integration for C# and .NET development with extended features
- **neodev.nvim** - Neovim Lua API development setup with type definitions

### Testing

- **neotest** - Testing framework with .NET adapter (neotest-dotnet) and async IO support (nvim-nio)

### Formatting & Linting

- **none-ls.nvim** - LSP bridge for formatters and linters with extras (ruff, eslint_d) and mason integration

### Git Integration

- **vim-fugitive** - Git wrapper providing commands like :Git, :Gwrite, :Gdiffsplit
- **gitsigns.nvim** - Git decorations showing added/modified/deleted lines in sign column
- **diffview.nvim** - Single tabpage interface for cycling through diffs of all modified files

### File Navigation & Management

- **oil.nvim** - File explorer that lets you edit the filesystem like a regular Neovim buffer
- **harpoon** - Quick file navigation allowing you to mark and jump between files
- **snacks.nvim** - Collection of utilities: picker, lazygit, notifier, dashboard, zen mode

### UI & Appearance

- **catppuccin/nvim** - Soothing pastel colorscheme with extensive plugin integrations
- **lualine.nvim** - Blazing fast statusline with file info, git status, and diagnostics
- **nvim-web-devicons** - File type icons for various plugins and UI elements
- **trouble.nvim** - Pretty list for diagnostics, references, quickfix, and location lists
- **undotree** - Visualizes undo history as a tree for easy navigation

### Code Editing

- **mini.ai** - Advanced text objects with "next" and "last" variants for efficient editing
- **nvim-treesitter** - Syntax highlighting and code parsing using tree-sitter

### Database & HTTP

- **vim-dadbod** - Database interface with UI and SQL completion for managing connections and queries
- **kulala.nvim** - HTTP REST client for making API requests from .http files

### Command Line & Utilities

- **wilder.nvim** - Enhanced command-line with fuzzy matching and popup menu
- **vim-tmux-navigator** - Seamless navigation between tmux panes and Neovim splits
- **plenary.nvim** - Lua utility functions library used by many plugins
- **dotnet-tools** - Custom .NET tools for running tests and building projects

## Configuration Structure

```
nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── config/             # Core configuration
│   │   ├── keymaps.lua
│   │   ├── options.lua
│   │   └── lazy.lua
│   └── plugins/            # Plugin configurations (organized by feature)
│       ├── blink.lua
│       ├── catppuccin.lua
│       ├── copilot.lua
│       ├── dotnet-tools.lua
│       ├── git.lua
│       ├── harpoon.lua
│       ├── kulala.lua
│       ├── lsp.lua
│       ├── lua-line.lua
│       ├── markdown.lua
│       ├── mini.lua
│       ├── none-ls.lua
│       ├── oil.lua
│       ├── snacks.lua
│       ├── supermaven.lua
│       ├── tests.lua
│       ├── tmux.lua
│       ├── treesitter.lua
│       ├── trouble.lua
│       ├── undo-tree.lua
│       ├── vim-dadbod.lua
│       └── wilder.lua
└── lazy-lock.json          # Lockfile for plugin versions
```

## Key Bindings

### Leader Key
Space (`<leader>`)

### Essential Mappings

#### File Navigation
- `<leader>ff` - Find files (with hidden)
- `<leader>fg` - Grep in project
- `<leader><leader>` - Switch buffers
- `<leader>-` - Toggle Oil file explorer

#### Harpoon
- `<leader>hi` - Add file to harpoon
- `<leader>hh` - Toggle harpoon menu
- `<leader>1-5` - Jump to harpoon file 1-5

#### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `gi` - Go to implementations
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>ds` - Search document symbols
- `K` - Hover documentation
- `]d` / `[d` - Next/prev diagnostic
- `]e` / `[e` - Next/prev error

#### Git
- `<leader>lg` - Open Lazygit
- `<leader>gb` - Git blame line
- `<leader>gfl` - File history in Lazygit
- `:Gd` - Open diffview

#### Utilities
- `<leader>u` - Toggle undotree
- `<leader>z` - Zen mode
- `<leader>Z` - Zoom current window
- `<leader>td` - Open TODO notes
- `<leader>uw` - Toggle wrap
- `<leader>uL` - Toggle relative line numbers

## Key Features

- **Multi-language Support**: Primary focus on C#/.NET with support for JavaScript, TypeScript, Python, Go, Lua, CSS, Docker, and Prisma
- **Git Workflow**: Complete git integration with fugitive, gitsigns, and diffview
- **Database Management**: Integrated vim-dadbod for database exploration
- **HTTP Client**: Built-in REST client via kulala.nvim
- **Modern UI**: Catppuccin theme with comprehensive icons and statusline
- **AI Assistance**: GitHub Copilot integration enabled
