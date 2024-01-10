local TeleportService = {}
local TpService = game:GetService("TeleportService")

local PartyService: { GetParty: (player: Player) -> {} } = nil

local Places = {
	["Game"] = 15189343458,
	["Lobby"] = 15922022852,
	["Menu"] = 15189343458,
}

function TeleportService:TeleportTo(name: Places, player: Player)
	local placeId = Places[name]
	if placeId == nil then
		return error("Place not found")
	end

	local Members
	local Party = PartyService:GetParty(player)
	if Party then
		Members = Party.Members
	end

	TpService:TeleportPartyAsync(placeId, Members or { player })
end
function TeleportService.OnRequire(self, storage: {})
	PartyService = storage.PartyService
end

export type Places = "Game" | "Lobby" | "Menu"
return TeleportService
