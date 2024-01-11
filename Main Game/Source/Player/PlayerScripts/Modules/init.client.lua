local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DataService")

-- # ================================ TYPES ================================ #
local Types = require(ReplicatedStorage:WaitForChild("[Rojo]"):WaitForChild("Types"))

---@diagnostic disable-next-line: undefined-type
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
		local module = require(Module)
		Storage[Module.Name] = module
	end
	for _name, Module in pairs(Storage) do
		if Module.OnRequire then
			print(_name, "OnRequire")
			task.spawn(function()
				Module:OnRequire(Storage)
			end)
		end
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
