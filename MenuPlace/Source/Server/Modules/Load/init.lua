local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LoadService = {}

function LoadService:LoadPlayerGui(player: Player)
	local gui = StarterGui:GetChildren()
	for _, v in ipairs(gui) do
		v:Clone().Parent = player:WaitForChild("PlayerGui")
	end
	StarterGui.ChildAdded:Connect(function(child)
		child:Clone().Parent = player:WaitForChild("PlayerGui")
	end)
end

function LoadService.OnPlayerJoin(player: Player)
	--> # ================================ PLAYER GUI ================================ #
	LoadService:LoadPlayerGui(player)
end

Players.PlayerAdded:Connect(LoadService.OnPlayerJoin)
return LoadService
