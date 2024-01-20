local Workspace = game:GetService("Workspace")

local EnemyManager = {
	Folder = Workspace:WaitForChild("Enemies"),
}
EnemyManager.Enemies = {}
EnemyManager.AI = require(script.EnemyAI)

function EnemyManager:Init()
	local Enemies = self.Folder:GetChildren() :: EnemyFolder
	for _, Enemy in pairs(Enemies) do
		local Speed = Enemy:GetAttribute("Speed") or 16
		local Health = Enemy:GetAttribute("Health") or 100
		local Name = Enemy:GetAttribute("Name") or "Untitled Entity"
		local Inteligence = Enemy:GetAttribute("Inteligence") or 5

		local AI = self.AI.new(Enemy, {
			Speed = Speed,
			Health = Health,
			Name = Name,
			Inteligence = Inteligence,
		})
		AI:Init()
	end
end

EnemyManager:Init() --> Initiate the module.

export type EnemyFolder = {
	[number]: Model,
}
return EnemyManager
