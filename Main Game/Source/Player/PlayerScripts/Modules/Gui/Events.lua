local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerReady = Remotes:WaitForChild("PlayerReady")

local Events: Events = {
	["Game-Ready"] = function(GuiButtonObject, Storage: Storage)
		PlayerReady:FireServer(os.time())
		GuiButtonObject.Object:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false

		print("Player is ready...")

		Storage.Realism:LockFirstPerson()
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
export type Storage = {
	Realism: {
		LockFirstPerson: () -> nil,
		UnLockFirstPerson: () -> nil,
	},
}
return Events
