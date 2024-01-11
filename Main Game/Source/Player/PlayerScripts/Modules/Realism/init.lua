local RunService = game:GetService("RunService")
local CameraModuleHandler = require(script.CameraModule.Handler)
local FootstepsHandler = require(script.FootstepModule.Handler)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid") :: Humanoid

Humanoid.Jumping:Connect(function()
	for i, v in pairs(Char:WaitForChild("HumanoidRootPart"):GetChildren()) do
		if v:IsA("Sound") then
			v:Destroy()
		end
	end
end)

local Realism = {}

function Realism:LockFirstPerson()
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	Player.CameraMode = Enum.CameraMode.LockFirstPerson
	CameraModuleHandler:CreateNewCamera("FirstPerson")
end

function Realism:UnLockFirstPerson()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

function Realism:FootstepStart()
	FootstepsHandler:Start()
end

function Realism:SetMouseIcon(icon: number)
	UserInputService.MouseIcon = `rbxassetid://{icon}`
end

Realism:FootstepStart()
Realism:SetMouseIcon(15941568825)

return Realism
