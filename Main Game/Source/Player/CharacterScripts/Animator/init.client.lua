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

ContentProvider:PreloadAsync(Animations, function(assetId)
	print(ContentProvider:GetAssetFetchStatus(assetId))
end)

Remote.OnClientEvent:Connect(function(animation: Animation, props: { [string]: any })
	local AnimationTrack = Animator:LoadAnimation(animation) :: AnimationTrack
	AnimationTrack.Priority = Enum.AnimationPriority.Action
	for name, value in pairs(props) do
		AnimationTrack[name] = value
	end
	AnimationTrack:Play()
	print(AnimationTrack.IsPlaying)
end)
