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



export type Inventory = {
	[string]: any,

	["Slot1"]: nil | string,
	["Slot2"]: nil | string,
	["Slot3"]: nil | string,
	["Slot4"]: nil | string,
}
return InventoryService
