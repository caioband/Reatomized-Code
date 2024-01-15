local Players = game:GetService("Players")
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
	task.wait(1.5)
	for _index, Module in ipairs(script:GetDescendants()) do
		if not Module:IsA("ModuleScript") then continue end
		print(1 , Module)
		local module = require(Module)
		Storage[Module.Name] = module
	end
	print("fr")
	for _name, Module in pairs(Storage) do
		print(Module)
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
print(#Players.LocalPlayer.PlayerScripts["[Rojo]"].Modules:GetDescendants())
-- # ================================ CONNECTIONS ================================ #
DataStoreRemote.OnClientEvent:Connect(function(event: string, ...)
	print("a")
	if event == "Load" then
		print("b")
		OnProfileLoad(...)
	end
end)
