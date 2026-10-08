---@class neorg.module
---@field config    table
---@field name      string   Name of the module, module can be required under "neorg.modules.<name>"
---@field setup     function Called before loading dependencies or anything
---@field load      function Called after loading dependencies
---@field requires? string[] List of modules we need as dependencies TODO: consider making this more complex, to e.g. allow optinoal dependencies
---@field api       table    The api the module provides

local log = require "neorg.core.log"

local modules = {}

---@type neorg.module[]
modules.loaded_modules = {}

local function load_dependencies(dependencies)
    for _, dep in ipairs(dependencies) do
        local ok, err = modules.load_module_by_name(dep)
        if not ok then
            log.error("Error while loading dependency " .. dep .. ": " .. err)
        end
    end
end

---@param module neorg.module
function modules.load_module(module)
    if modules.loaded_modules[module.name] then
        return modules.loaded_modules[module.name]
    end
    -- TODO: fix this
    if neorg.config.modules[module.name] then
        module.config = vim.tbl_deep_extend("force", module.config, neorg.config.modules[module.name])
    end

    if module.setup then
        local ok, err = pcall(module.setup)
        if not ok then
            log.error("Error while setting up module " .. module.name .. ": " .. err)
        end
    end

    if module.requires then
        load_dependencies(module.requires)
    end

    if module.load then
        local ok, err = pcall(module.load)
        if not ok then
            log.error("Error while loading module " .. module.name .. ": " .. err)
        end
    end
    modules.loaded_modules[module.name] = module
end

function modules.load_module_by_name(name)
    if modules.loaded_modules[name] then
        return modules.loaded_modules[name]
    end

    local ok, module = pcall(require, "neorg.modules." .. name)
    if not ok then
        log.error("Couldn't load module " .. name .. " (error while requiring)")
        return false
    end
    if not type(module) == "table" then
        log.error("Couldn't load module " .. name .. " (returned wrong type)")
        return false
    end
    modules.load_module(module)
end

return modules
