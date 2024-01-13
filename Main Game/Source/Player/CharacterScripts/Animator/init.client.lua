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

ContentProvider:PreloadAsync(Animations,function(assetId)
	print(ContentProvider:GetAssetFetchStatus(assetId))
end)


Remote.OnClientEvent:Connect(function(T : {[string]: any}, props: { [string]: any })
	print(Remote,T.PosPart)
	local Animation = ReplicatedFirst.Animations.SofaAnimations[T.PosPart.Name]
	Animation.AnimationId = "rbxassetid://" .. T.animationId
	--Animation.Parent = Character
	--Animation.Name = "Starter-Animation"
	--Debris:AddItem(Animation, 60)

	--local tracks = Animator:GetPlayingAnimationTracks()
	--for _, track in ipairs(tracks) do
	--	track:Stop()
	--end

	local AnimationTrack = Animator:LoadAnimation(Animation) :: AnimationTrack
	AnimationTrack.Priority = Enum.AnimationPriority.Action
	for name, value in pairs(props) do
		AnimationTrack[name] = value
	end
	AnimationTrack:Play()
	print(AnimationTrack.IsPlaying)
end)


