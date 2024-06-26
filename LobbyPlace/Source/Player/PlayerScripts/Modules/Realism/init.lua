local RunService = game:GetService("RunService")
local FootstepsHandler = require(script.FootstepModule.Handler)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid") :: Humanoid

local Realism = {}

function Realism:FootstepStart()
	FootstepsHandler:Start()
end

function Realism:SetMouseIcon(icon: number)
	UserInputService.MouseIcon = `rbxassetid://{icon}`
end

Realism:FootstepStart()
Realism:SetMouseIcon(15941568825)

return Realism
