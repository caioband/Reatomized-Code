local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid.Animator :: Animator
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerReady = Remotes:WaitForChild("PlayerReady")

local Events: Events = {
	["Game-Ready"] = function(GuiButtonObject, Storage: Storage)
		PlayerReady:FireServer(os.time())
		GuiButtonObject.Object:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
		local tracks = Animator:GetPlayingAnimationTracks()

		for i,v in pairs(tracks) do
			v:Stop()
		end

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
