local Modules = script:GetChildren()

-- # ================================ MODULES ================================ #

local Storage: { Module } = {}

-- # ================================ MODULES ================================ #

local function LoadModule(Module: ModuleScript): Module
	return require(Module)
end

local function LoadModules(): { [string]: Module }
	for _, Module in ipairs(Modules) do
		task.spawn(function()
			local module = LoadModule(Module)
			Storage[Module.Name] = module

			if module.OnRequire then
				module.OnRequire(module, Storage)
			end
		end)
	end
	return Storage
end

export type Module = {
	[string]: any,
	OnRequire: (self: Module, Storage: { Module }) -> nil | string,
}

LoadModules()


--game.Players.PlayerAdded:Connect(function(player)
--	Storage.Inventory.OnPlayerJoin(player)
--end)