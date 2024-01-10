local ContentProvider = game:GetService("ContentProvider")
local Modules = script:GetChildren()

-- # ================================ MODULES ================================ #

local Storage: { Module } = {}

-- # ================================ MODULES ================================ #

local function LoadModule(Module: ModuleScript): Module
	ContentProvider:PreloadAsync(Module)
	return require(Module)
end

local function LoadModules(): { [string]: Module }
	for _, Module in ipairs(Modules) do
		local module = LoadModule(Module)
		Storage[Module.Name] = module

		if module.OnRequire then
			module.OnRequire(module, Storage)
		end
	end
	return Storage
end

export type Module = {
	[string]: any,
	OnRequire: (self: Module, Storage: { Module }) -> nil | string,
}

LoadModules()
