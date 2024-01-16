local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local Modules = script:GetChildren()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local PartyServiceRemote = Remotes:WaitForChild("PartyService") :: RemoteEvent
local RemoteFunction = Remotes:WaitForChild("Gui") :: RemoteFunction
local PartyService = require(script.PartyService)

-- # ================================ MODULES ================================ #

local Storage: { Module } = {}

-- # ================================ MODULES ================================ #

local PartyReceiver = {
	["Invite"] = function(Args)
		local Player = Players:GetPlayerByUserId(Args.PlayerID)
		PartyService:Invite(Args.Inviter, Player)
	end,
}

local function LoadModule(Module: ModuleScript): Module
	ContentProvider:PreloadAsync({ Module })
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

local function GetTheOtherPlayer(You)
	for i, v in pairs(game.Players:GetPlayers()) do
		if v == You then
			continue
		else
			return v
		end
	end
end

LoadModules()
