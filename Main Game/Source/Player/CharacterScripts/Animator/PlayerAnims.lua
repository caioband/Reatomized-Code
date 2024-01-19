local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Handler = {}

function Handler:StartCharacter()
    local Character = game.Players.LocalPlayer.Character
    local Humanoid = Character:WaitForChild("Humanoid")
    local Animator = Humanoid:WaitForChild("Animator") :: Animator
    local IdleAnimationTrack = Animator:LoadAnimation(ReplicatedFirst:WaitForChild("Animations").PlayerAnimations.Idle)
    IdleAnimationTrack.Priority = Enum.AnimationPriority.Action
    IdleAnimationTrack.Looped = true
    IdleAnimationTrack:Play()
    print(Animator:GetPlayingAnimationTracks())
end

return Handler