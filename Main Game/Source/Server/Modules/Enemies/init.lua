local Workspace = game:GetService("Workspace")

local EnemyManager = {
    Folder = Workspace:WaitForChild("Enemies"),
}
EnemyManager.Enemies = {}
EnemyManager.AI = require(script.EnemyAI)

function EnemyManager:Init()
    local Enemies = self.Folder:GetChildren() :: EnemyFolder
    for _, Enemy in pairs(Enemies) do
        local AI = self.AI.new(Enemy)
        AI:Init()
    end
end

EnemyManager:Init() --> Initiate the module.

export type EnemyFolder = {
    [number]: Model
}
return EnemyManager