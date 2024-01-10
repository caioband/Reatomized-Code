local TeleportService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TpService = game:GetService("TeleportService")

local Places = {
	["Game"] = 15189343458,
	["Lobby"] = 15922022852,
	["Menu"] = 15189343458,
}

local Remotes = ReplicatedStorage.Remotes
local TeleportEvent = Remotes.Teleport

function TeleportService:TeleportTo(name: Places, player: Player)
	local placeId = Places[name]
	if placeId == nil then
		return error("Place not found")
	end

	TpService:Teleport(placeId, player)
end
function TeleportService.OnRequire(self, storage: {}) end

TeleportEvent.OnServerEvent:Connect(function(player, event: string)
	if event == "Join-Game" then
		TeleportService:TeleportTo("Game", player)
	end
end)

export type Places = "Game" | "Lobby" | "Menu"
return TeleportService
