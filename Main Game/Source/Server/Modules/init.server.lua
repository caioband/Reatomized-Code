local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = script:GetChildren()
local Remotes = ReplicatedStorage.Remotes
local DataService = require(script.DataService)
local Comms = Remotes:WaitForChild("Comms") :: RemoteFunction
-- # ================================ MODULES ================================ #

local Storage: { Module } = {}

-- # ================================ MODULES ================================ #

local Requests = {
	["GetServerData"] = function(Args)
		return DataService:GetServerData()
	end,
}

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

Comms.OnServerInvoke = function(Player: Player, BindTo: string, Args: any)
	--print(BindTo)
	if Requests[BindTo] then
		return Requests[BindTo](Args)
	end
end
--game.Players.PlayerAdded:Connect(function(player)
--	Storage.Inventory.OnPlayerJoin(player)
--end)
