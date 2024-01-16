local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ZonePlus = require(ReplicatedStorage["[Rojo]"].Zone)
local ItemsHandler = require(script.Parent.Parent.Items.Main)
local BunkerZone = Workspace:WaitForChild("BunkerZone")

local Bunker = {}
Bunker.PlayersInBunker = {}

function Bunker:GetPlayersIn()
	return self.PlayersInBunker
end

function Bunker.OnPlayerEntered(player: Player)
	table.insert(Bunker.PlayersInBunker, player)
end

function Bunker.OnPlayerLeave(player: Player)
	table.remove(Bunker.PlayersInBunker, table.find(Bunker.PlayersInBunker, player))
end

function Bunker:CreateZone()
	local Zone = ZonePlus.new(BunkerZone)

	Zone.playerEntered:Connect(function(player: Player)
		--print(ItemsHandler, ItemsHandler.PlayerItems, player)
		self.OnPlayerEntered(player)
		if not ItemsHandler.PlayerItems[player] then return end
		for i, v in pairs(ItemsHandler.PlayerItems[player]) do
			table.insert(ItemsHandler.BunkerTotalItems, v)
		end
		ItemsHandler.PlayerItems[player] = {}
	end)
	Zone.playerExited:Connect(function(player: Player)
		self.OnPlayerLeave(player)
	end)
end

Bunker:CreateZone()
return Bunker
