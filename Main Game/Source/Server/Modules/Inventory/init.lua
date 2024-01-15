local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local InventoryHolder = {}

local ProfileService = require(ReplicatedStorage["[Rojo]"].ProfileService)

local InventoryService = {}

local InventoryData = ProfileService.GetProfileStore("Inventory", {
	["Players"] = {},
})

function InventoryService:LoadPlayerInventory(plr: Player, inv: Inventory)
	local slots = { inv["Slot1"], inv["Slot2"], inv["Slot3"], inv["Slot4"] }
end

function InventoryService.OnPlayerJoin(player: Player)
	local joinData = player:GetJoinData()
	local teleportData = joinData.TeleportData
	
	print(joinData, teleportData, teleportData.Host)
	--for i,v in pairs(teleportData) do
	--	print(i,v)
	--end

	local host = teleportData.Host :: number
	Players:SetAttribute("Host", host)

	local isHost = player.UserId == host

	if isHost == false then
		return
	end

	local Profile = InventoryData:LoadProfileAsync(player.UserId, "ForceLoad")
	if Profile ~= nil then
		Profile:AddUserId(player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			InventoryHolder[player] = nil
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			InventoryHolder[player] = Profile
			InventoryService.RemoteEvents.Load:FireClient(player, Profile.Data)
		else
			Profile:Release()
		end
	else
		player:Kick()
	end
end

function InventoryService.OnPlayerLeaving(player)
	local profile = InventoryHolder[player]
	if profile then
		profile:Release()
		InventoryHolder[player] = nil
	end
end

Players.PlayerAdded:Connect(InventoryService.OnPlayerJoin)
Players.PlayerRemoving:Connect(InventoryService.OnPlayerLeaving)

export type Inventory = {
	[string]: any,

	["Slot1"]: nil | string,
	["Slot2"]: nil | string,
	["Slot3"]: nil | string,
	["Slot4"]: nil | string,
}
return InventoryService
