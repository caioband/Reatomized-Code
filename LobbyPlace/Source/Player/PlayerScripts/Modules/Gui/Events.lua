local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PartyService = Remotes:WaitForChild("PartyService") :: RemoteEvent
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Events: Events = {
	["Party"] = function(GuiButtonObject)
		Lighting.Blur.Enabled = not Lighting.Blur.Enabled

		local pGui = PlayerGui:WaitForChild("PartyGui")
		pGui.Enabled = not pGui.Enabled
	end,
	["Invite"] = function(GuiButtonObject)
		local playerName = GuiButtonObject.Object.Parent.Name
		local playerId = GuiButtonObject.Object.Parent:GetAttribute("UserId")
		local plr = Players:GetPlayerByUserId(playerId)

		PartyService:FireServer("Invite", { Inviter = Player, Player = plr })

		print(GuiButtonObject.Object.Parent)
	end,
	["Kick"] = function(GuiButtonObject)
		print(GuiButtonObject.Object.Parent)
	end,
	["Default"] = function(GuiButtonObject)
		local GuiButtonClick = SoundService:WaitForChild("GuiButtonClick")
		GuiButtonClick:Play()
		return
	end,
}

export type GuiButtonObject = {
	Object: GuiButton,
	_Connections: { RBXScriptConnection },
}
export type Events = {
	[string]: (self: GuiButtonObject) -> nil,
}
return Events
