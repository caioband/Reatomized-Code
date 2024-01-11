local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyAI: AI = {}
EnemyAI.__index = EnemyAI

local View = require(script.Parent.View)

function EnemyAI.new(Enemy: Model)
    local self = setmetatable({}, EnemyAI)

    Enemy = Enemy :: Model
    local Humanoid: Humanoid = Enemy:WaitForChild("Humanoid")
    local Root: BasePart = Enemy:WaitForChild("HumanoidRootPart")

    self.Enemy = Enemy
    self.Root = Root
    self.Humanoid = Humanoid

    local TargetValue = Instance.new("ObjectValue", Enemy)
    TargetValue.Name = "Target"

    local ChasingValue = Instance.new("BoolValue", Enemy)
    ChasingValue.Name = "Chasing"

    self.Chasing = ChasingValue
    self.Target = TargetValue

    return self
end

function EnemyAI:BindChasing()
    task.spawn(function()
        repeat
            task.wait(.3)
            if not self.Target.Value then continue end
            if self.Chasing.Value == false then continue end

            local Root = self.Target.Value:GetPivot().Position
            self.Humanoid:MoveTo(Root)
        until self.Humanoid.Health == 0
    end)
end

function EnemyAI:Init()
    self:BindChasing()
    task.spawn(function()
        repeat
            local players = Players:GetPlayers()
            local closest = nil

            for _, player in ipairs(players) do
                local Character = player.Character or player.CharacterAdded:Wait()
                local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                local Distance = (HumanoidRootPart.Position - self.Root.Position).Magnitude
                if closest then
                    if Distance < (closest.HumanoidRootPart.Position - self.Root.Position).Magnitude then
                        closest = Character
                    end
                else
                    closest = Character
                end
            end

            self.Target.Value = closest
            task.wait(.5)

        until self.Humanoid.Health == 0
    end)

    task.spawn(function()
        repeat
            if self.Target.Value then
                local Target = self.Target.Value
                local TargetRoot = Target:WaitForChild("HumanoidRootPart")
                local Distance = View:GetDist(self.Root, TargetRoot)
                local InViewFov = View:IsInView(60, self.Root, TargetRoot)
                local InView = (InViewFov or Distance < 15) and (Distance < 30 and View:ObjectInFront(self.Root, TargetRoot))

                if InView then
                    self.Chasing.Value = true
                else
                    self.Chasing.Value = false
                end
            end

            task.wait(.5)
        until self.Humanoid.Health == 0
    end)
end

export type AI = {
    Enemy: Model,
    Humanoid: Humanoid,

    Chasing: BoolValue,
    Target: ObjectValue,

    Init: () -> nil,
    new: () -> AI
}
return EnemyAI