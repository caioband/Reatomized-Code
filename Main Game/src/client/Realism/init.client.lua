local RunService = game:GetService("RunService")
local CameraModuleHandler = require(script.CameraModule.Handler)
local FootstepsHandler = require(script.FootstepModule.Handler)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid") :: Humanoid

Humanoid.Jumping:Connect(function()
    for i,v in pairs(Char:WaitForChild("HumanoidRootPart"):GetChildren()) do
        if v:IsA("Sound") then
            v:Destroy()
        end
    end
end)

CameraModuleHandler:CreateNewCamera("FirstPerson")
FootstepsHandler:Start()
