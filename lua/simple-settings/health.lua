local M = {}

M.check = function()
    vim.health.start("simple-settings report")

    local plugin = require('simple-settings')

    if not plugin.init then
        vim.health.error("read_config() is not called, plugin is not active.")
        return
    end

    local normalized_global_settings_path = vim.fs.normalize(plugin.global_settings_path)

    vim.health.info("Global settings path: '" .. normalized_global_settings_path .. "'")
    vim.health.info("Settings path used by this project: '" .. plugin.matched_setting_path .. "'")

    if plugin.matched_setting_path == "" then
        if not vim.fn.exists(normalized_global_settings_path) then
            vim.health.warn("File '" ..
                normalized_global_settings_path .. "' does not exist so default configuration is active.")
        else
            vim.health.info("No entry in '" ..
                normalized_global_settings_path ..
                "' matched '" .. vim.fs.normalize(vim.fn.getcwd()) .. "' so using default settings.")
        end
    end

    vim.health.info("Current active settings:")

    for key, value in pairs(plugin.current_settings) do
        vim.health.info("* " .. key .. " = " .. tostring(value))
    end

    vim.health.info("These fields are using default values:")

    for key, value in pairs(plugin.default_fields) do
        if value then
            vim.health.info("* " .. key)
        end
    end

    vim.health.ok("Plugin is loaded successfully.")
end

return M
