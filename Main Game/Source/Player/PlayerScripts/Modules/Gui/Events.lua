local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerReady = Remotes:WaitForChild("PlayerReady")

local Events: Events = {
	["Game-Ready"] = function(GuiButtonObject, Storage: Storage)
		local Player = Players.LocalPlayer
		local Character = Player.Character or Player.CharacterAdded:Wait()

		local Humanoid = Character:WaitForChild("Humanoid")
		local Animator = Humanoid.Animator :: Animator

		PlayerReady:FireServer(os.time())
		GuiButtonObject.Object:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
		local tracks = Animator:GetPlayingAnimationTracks()

		for i, v in pairs(tracks) do
			v:Stop()
		end

		Storage.Realism:LockFirstPerson()
	end,

	["Open"] = function(GuiButtonObject, Storage: Storage)
		local Gui = GuiButtonObject.Object:FindFirstAncestorWhichIsA("ScreenGui")

		local Frame = Gui:FindFirstChildWhichIsA("Frame")
		if Frame then
			if Gui.Enabled then
				local a = TweenService:Create(Frame, TweenInfo.new(0.5), {
					Position = UDim2.fromScale(0.5,1)
				})
				a:Play()
				a.Completed:Connect(function()
					Gui.Enabled = false
				end)
			else
				Gui.Enabled = true
				TweenService:Create(Frame, TweenInfo.new(0.5), {
					Position = UDim2.fromScale(0.5,0.5)
				}):Play()
			end
		end
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
