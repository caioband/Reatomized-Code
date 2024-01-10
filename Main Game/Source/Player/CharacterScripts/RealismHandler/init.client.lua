local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Jump = require(script:WaitForChild("Jump"))

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local PrimaryPart = Character.PrimaryPart
local Humanoid = Character:WaitForChild("Humanoid")

local function OnJumpRequest()
	Jump:CreateBodyVelocity(Character)
end

UserInputService.JumpRequest:Connect(OnJumpRequest)
