local M = {}

-- Helper function to find project root by searching for .csproj file
local function find_project_root()
	-- First try: find .csproj in current file's directory tree
	local current_file = vim.fn.expand("%:p")
	if current_file ~= "" then
		local current_dir = vim.fn.fnamemodify(current_file, ":h")
		local csproj = vim.fn.findfile("*.csproj", current_dir .. ";")
		if csproj ~= "" then
			return vim.fn.fnamemodify(csproj, ":h")
		end
	end

	-- Second try: search cwd for .csproj files
	local csproj_files = vim.fn.globpath(vim.fn.getcwd(), "**/*.csproj", false, true)
	if #csproj_files > 0 then
		-- If multiple projects, prefer one with launchSettings.json
		for _, csproj in ipairs(csproj_files) do
			local proj_dir = vim.fn.fnamemodify(csproj, ":h")
			local launch_settings = proj_dir .. "/Properties/launchSettings.json"
			if vim.fn.filereadable(launch_settings) == 1 then
				return proj_dir
			end
		end
		-- Otherwise just use the first one
		return vim.fn.fnamemodify(csproj_files[1], ":h")
	end

	return vim.fn.getcwd()
end

-- Helper function to read and parse launchSettings.json
local function read_launch_settings(project_path)
	local launch_settings_path = project_path .. "/Properties/launchSettings.json"

	local file = io.open(launch_settings_path, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	local ok, launch_settings = pcall(vim.json.decode, content)
	if not ok then
		vim.notify("Failed to parse launchSettings.json", vim.log.levels.WARN)
		return nil
	end

	return launch_settings
end

-- Helper to get profile data (name and profile object)
local function get_launch_profile_data(project_path, launch_settings)
	if not launch_settings or not launch_settings.profiles then
		return nil
	end

	-- Get all "Project" profiles
	local profile_names = {}
	local profiles_map = {}
	for name, profile in pairs(launch_settings.profiles) do
		if profile.commandName == "Project" then
			table.insert(profile_names, name)
			profiles_map[name] = profile
		end
	end

	if #profile_names == 0 then
		return nil
	end

	return {
		names = profile_names,
		map = profiles_map,
	}
end

-- Check if DLL exists and optionally prompt to build
local function check_and_build_dll(project_path)
	local dll = require("dap-dll-autopicker").build_dll_path()

	if dll and dll ~= "" and vim.fn.filereadable(dll) == 1 then
		return dll
	end

	-- DLL missing or not found, prompt to build
	local choice = vim.fn.confirm(
		"DLL not found. Build the project?",
		"&Yes\n&No",
		1 -- default to Yes
	)

	if choice ~= 1 then
		return nil
	end

	-- Build the project
	local project_name = vim.fn.fnamemodify(project_path, ":t")
	local csproj_files = vim.fn.globpath(project_path, "*.csproj", false, true)

	if #csproj_files == 0 then
		vim.notify("No .csproj file found in " .. project_path, vim.log.levels.ERROR)
		return nil
	end

	vim.notify("Building " .. project_name .. "...", vim.log.levels.INFO)
	local build_cmd = "dotnet build " .. vim.fn.shellescape(csproj_files[1])
	local build_result = vim.fn.system(build_cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("Build failed:\n" .. build_result, vim.log.levels.ERROR)
		return nil
	end

	vim.notify("Build succeeded!", vim.log.levels.INFO)

	-- Try to get DLL path again after build
	dll = require("dap-dll-autopicker").build_dll_path()
	if not dll or dll == "" then
		vim.notify("Failed to find DLL even after build", vim.log.levels.ERROR)
		return nil
	end

	return dll
end

-- Prompt user to select a launch profile (async with callback)
local function select_launch_profile(profile_data, callback)
	vim.ui.select(profile_data.names, {
		prompt = "Select launch profile:",
	}, function(choice)
		if choice then
			callback(profile_data.map[choice])
		else
			callback(nil)
		end
	end)
end

local function configure_debug_session(callback)
	-- Find project root
	local project_path = find_project_root()

	-- Check/build DLL
	local dll = check_and_build_dll(project_path)
	if not dll then
		vim.notify("Cannot start debugging without DLL", vim.log.levels.ERROR)
		callback(nil)
		return
	end

	-- Read launch settings
	local launch_settings = read_launch_settings(project_path)
	if not launch_settings then
		-- No launchSettings.json, return basic config
		callback({
			type = "coreclr",
			name = "Launch .NET App",
			request = "launch",
			program = dll,
			cwd = project_path,
			env = {},
			args = {},
		})
		return
	end

	-- Get profile data
	local profile_data = get_launch_profile_data(project_path, launch_settings)
	if not profile_data then
		vim.notify("No Project profiles found in launchSettings.json", vim.log.levels.WARN)
		callback({
			type = "coreclr",
			name = "Launch .NET App",
			request = "launch",
			program = dll,
			cwd = project_path,
			env = {},
			args = {},
		})
		return
	end

	-- Always prompt user to select profile (async)
	select_launch_profile(profile_data, function(selected_profile)
		if not selected_profile then
			vim.notify("No profile selected, aborting debug session", vim.log.levels.WARN)
			callback(nil)
			return
		end

		-- Build final configuration
		local env_vars = selected_profile.environmentVariables or {}
		local args_str = selected_profile.commandLineArgs or ""
		local args = args_str ~= "" and vim.split(args_str, " ") or {}

		callback({
			type = "coreclr",
			name = "Launch .NET App",
			request = "launch",
			program = dll,
			cwd = project_path,
			env = env_vars,
			args = args,
		})
	end)
end

function M.start_debugging()
	configure_debug_session(function(config)
		if not config then
			-- User cancelled or configuration failed
			return
		end

		local dap = require("dap")
		dap.run(config)
	end)
end

return M
