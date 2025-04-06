local M = {}

---@type string
M.global_settings_path = "~/.config/simple-settings/settings.json"
---@type boolean
M.init = false
---@type string
M.matched_setting_path = ""
---@type table<string, any>
M.current_settings = {}
---@type table<string, boolean>
M.default_fields = {}

---Read the global settings file, return the settings file content with the paths normalized
---
---@return table<string, any>|nil
local read_global_settings = function()
    local global_settings_raw_content = vim.secure.read(M.global_settings_path)

    if global_settings_raw_content == nil then
        return nil
    end

    local global_settings_json_content = vim.json.decode(global_settings_raw_content)

    local global_settings = {}

    -- normalize paths in global settings
    for key, value in pairs(global_settings_json_content) do
        global_settings[vim.fs.normalize(key)] = value
    end

    return global_settings
end

---Given the global settings and a working directory path, return the settings that should be used for the current working directory
---
---@param global_settings table<string, any>: Normalized global settings
---@param current_working_dir string: Current working directory path, in which we are interested to get the settings for
---@return string, table<string, any>
local get_directory_settings = function(global_settings, current_working_dir)
    local start_path = vim.fs.normalize(current_working_dir)

    if global_settings[start_path] ~= nil then
        return start_path, global_settings[start_path]
    end

    for dir in vim.fs.parents(start_path) do
        if global_settings[dir] ~= nil then
            return dir, global_settings[dir]
        end
    end

    return "", {}
end

---@class settings.Opts
---@field config string|nil: Path to global settings settings.json (default is ~/.config/simple-settings/settings.json)

---Setup the plugin
---
---@param opts settings.Opts|nil: Setup options
M.setup = function(opts)
    if opts == nil then
        return
    end

    if opts.config ~= nil then
        M.global_settings_path = opts.config
    end
end

---Set the current project's settings by reading from the configured global settings path
---
---@param config_structure table<string, any>: Expected configuration structure. Any extra fields in the config file not specified in this table's key list will be ignored and discarded. On the other hand, if the config file is missing a table's key, the key's value will be the default value for the missing key
M.read_config = function(config_structure)
    if M.init then
        error("should not call read_config() multiple times")
    end

    M.init = true

    local global_settings = read_global_settings()

    if global_settings == nil then
        return
    end

    local current_dir = vim.fn.getcwd()

    local dir_settings = {}
    local matched_dir_setting_path = ""
    matched_dir_setting_path, dir_settings = get_directory_settings(global_settings, current_dir)

    M.matched_setting_path = matched_dir_setting_path
    M.current_settings = {}

    for key, value in pairs(config_structure) do
        if dir_settings[key] ~= nil then
            M.current_settings[key] = dir_settings[key]
        else
            M.current_settings[key] = value
            M.default_fields[key] = true
        end
    end
end

--- Get the particular field
--- @param field_name string: Name of the field
--- @return any
M.get_field = function(field_name)
    if not M.init then
        error("should not call get_field() before read_config()")
    end

    return M.current_settings[field_name]
end

return M
