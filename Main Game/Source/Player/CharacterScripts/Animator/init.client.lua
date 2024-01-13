local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Animations") :: RemoteEvent

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

Remote.OnClientEvent:Connect(function(animationId: number, props: { [string]: any })
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://" .. animationId
	Animation.Parent = Character
	Animation.Name = "Starter-Animation"

	Debris:AddItem(Animation, 60)

	local tracks = Animator:GetPlayingAnimationTracks()
	for _, track in ipairs(tracks) do
		track:Stop()
	end

	local AnimationTrack = Animator:LoadAnimation(Animation)
	for name, value in pairs(props) do
		AnimationTrack[name] = value
	end
	AnimationTrack:Play(0.1, 1, 1)
end)
