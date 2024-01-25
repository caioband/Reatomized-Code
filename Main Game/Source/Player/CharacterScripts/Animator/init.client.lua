local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local Animations = ReplicatedFirst:WaitForChild("Animations"):GetDescendants()
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Animations") :: RemoteEvent

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")
local PlayerAnims = require(script.PlayerAnims)

PlayerAnims:StartCharacter()

ContentProvider:PreloadAsync(Animations, function(assetId) end)

Remote.OnClientEvent:Connect(function(animation: Animation, props: { [string]: any })
	local AnimationTrack = Animator:LoadAnimation(animation) :: AnimationTrack
	--print(AnimationTrack:GetAni)
	AnimationTrack.Priority = Enum.AnimationPriority.Action
	for name, value in pairs(props) do
		AnimationTrack[name] = value
	end
	AnimationTrack:Play()
end)
