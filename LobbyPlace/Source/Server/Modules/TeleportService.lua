local TeleportService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TpService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local PartyService: { GetParty: (player: Player) -> {} } = nil
local Remotes = ReplicatedStorage.Remotes
local TeleportRemote = Remotes.Teleport

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
		["Host"] = player.UserId,
	}

	local TeleportOptions = Instance.new("TeleportOptions") :: TeleportOptions
	TeleportOptions.ShouldReserveServer = true
	TeleportOptions:SetTeleportData(TeleportData)

	print("Host", TeleportData.Host)

	TpService:TeleportPartyAsync(placeId, Members or { player }, TeleportData)
end

function TeleportService.OnRequire(storage: {})
	PartyService = storage.PartyService

	TeleportRemote.OnServerEvent:Connect(function(player)
		TeleportService:TeleportTo("Game", player)
	end)
end

export type Places = "Game" | "Lobby" | "Menu"
return TeleportService
