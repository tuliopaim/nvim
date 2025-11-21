# dotnet-tools

A collection of Neovim utilities for .NET development.

## Setup

```lua
require('dotnet-tools').setup({
    -- Optional configuration
})
```

## Features

### Debug with Launch Settings
Smart debugging that reads your `launchSettings.json` and lets you choose which profile to run:
- Automatically finds your .csproj and builds if needed
- Prompts you to select a launch profile
- Applies environment variables and command-line arguments from the profile
- Non-blocking async UI for smooth experience

**Command**: `:DotnetDebug`

**Function**: `require('dotnet-tools.debug').start_debugging()`

**DAP Integration**: Works seamlessly with nvim-dap and netcoredbg. The debug launcher:
1. Finds your .csproj file
2. Checks if DLL exists (prompts to build if missing)
3. Reads `Properties/launchSettings.json`
4. Lets you select a "Project" profile
5. Configures the debug session with proper env vars and args

### User Secrets Management
Quickly access and edit your .NET user secrets.

**Command**: `:UserSecrets`

**Function**: `require('dotnet-tools').open_or_create_secrets_file()`

### Open in Rider
Launch your project in JetBrains Rider.

**Command**: `:OpenInRider`

### Test Runner
Run .NET tests directly from Neovim.

**Commands**:
- `:Test` - Run test at cursor
- `:TestClass` - Run all tests in current class

**Functions**:
- `require('dotnet-tools.tests').run_test_at_cursor()`
- `require('dotnet-tools.tests').run_test_class()`
