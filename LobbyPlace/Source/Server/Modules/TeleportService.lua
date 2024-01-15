local TeleportService = {}
local TpService = game:GetService("TeleportService")

local PartyService: { GetParty: (player: Player) -> {} } = nil

local Places = {
	["Game"] = 15452317848,
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

	local TeleportData = {
		["Host"] = player
	}

	TpService:TeleportPartyAsync(placeId, Members or { player },TeleportData)
end

function TeleportService.OnRequire(storage: {})
	PartyService = storage.PartyService
end

export type Places = "Game" | "Lobby" | "Menu"
return TeleportService
