local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DataService")

-- # ================================ TYPES ================================ #
local Types = require(ReplicatedStorage:WaitForChild("[Rojo]"):WaitForChild("Types"))

local Storage: { Types.Module } = {}

local function OnProfileLoad(Profile)
	print("Profile Loaded")
	print(Profile)
	for _name, Module in pairs(Storage) do
		if Module.OnProfileLoad then
			Module.OnProfileLoad(Profile)
		end
	end
end

local function LoadModules()
	for _index, Module in ipairs(script:GetChildren()) do
		task.spawn(function()
			local module = require(Module)
			Storage[Module.Name] = module
		end)
	end
	for _name, Module in pairs(Storage) do
		task.spawn(function()
			if Module.OnRequire then
				Module.OnRequire(Module, Storage)
			end
		end)
	end
end

-- # ================================ INITIALIZE ================================ #
LoadModules()

-- # ================================ CONNECTIONS ================================ #
DataStoreRemote.OnClientEvent:Connect(function(event: string, ...)
	if event == "Load" then
		OnProfileLoad(...)
	end
end)
