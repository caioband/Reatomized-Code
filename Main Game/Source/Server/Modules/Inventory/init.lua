local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local DataService = require(script.Parent.DataService)

local InventoryHolder = {}

local ProfileService = require(ServerStorage["[Rojo]"].Modules.ProfileService)

local InventoryService = {}

local ProfileStore = ProfileService.GetProfileStore(DataService.Index, DataService.Template)

function InventoryService:LoadPlayerInventory(plr: Player, inv: Inventory)
	local slots = { inv["Slot1"], inv["Slot2"], inv["Slot3"], inv["Slot4"] }
end

function InventoryService.OnPlayerJoin(player: Player)
	local joinData = player:GetJoinData()
	local teleportData = joinData.TeleportData
	local HostPlayer = Players:GetPlayerByUserId(teleportData.Host) :: Instance
	
	--for i,v in pairs(teleportData) do
	--	print(i,v)
	--end

	local host = teleportData.Host :: number
	Players:SetAttribute("Host", host)

	local isHost = player.UserId == host

	if isHost == false then
		return
	end

	local Profile = ProfileStore:LoadProfileAsync(`{player.UserId}`, "ForceLoad")
	if Profile ~= nil then
		Profile:AddUserId(player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			InventoryHolder[player] = nil
			warn("1")
			--player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			InventoryHolder[player] = Profile
			ReplicatedStorage.Remotes.DataService:FireClient(player, Profile.Data)
		else
			Profile:Release()
		end
	else
		warn("2")
		--player:Kick()
	end
end

function InventoryService.OnPlayerLeaving(player)
	local profile = InventoryHolder[player]
	if profile then
		profile:Release()
		InventoryHolder[player] = nil
	end
end

--Players.PlayerAdded:Connect(InventoryService.OnPlayerJoin)
--Players.PlayerRemoving:Connect(InventoryService.OnPlayerLeaving)

export type Inventory = {
	[string]: any,

	["Slot1"]: nil | string,
	["Slot2"]: nil | string,
	["Slot3"]: nil | string,
	["Slot4"]: nil | string,
}
return InventoryService
