local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- # ================================ VARIABLES ================================ #
local RemoteEvents = ReplicatedStorage.Remotes
local Data = ServerStorage["[Rojo]"]
local Modules = Data.Modules
local RunService = game:GetService("RunService")
-- # ================================ REMOTES ================================ #
local DataServiceRemote = RemoteEvents.DataService

-- # ================================ MODULES ================================ #
local ProfileService = require(Modules.ProfileService)

-- # ================================ MODULE ================================ #
local DataService = {}
DataService.Index = "Player_Save # 0.0.13"

DataService.PlayerTemplate = {
	["Items"] = {},
	["Sleep"] = 100,
	["Hunger"] = 100,
	["Thirst"] = 100,
	["Sanity"] = 100,
	["DataInfo"] = {
		["Version"] = DataService.Index,
	},
}

DataService.SaveTemplate = {
	["Players"] = {},
	["Bunker"] = {
		["Items"] = {},
	},
	["PrologueCompleted"] = false,
}

DataService.Template = {
	["Saves"] = {
		["Slot1"] = DataService.SaveTemplate,
		["Slot2"] = DataService.SaveTemplate,
		["Slot3"] = DataService.SaveTemplate,
		["Slot4"] = DataService.SaveTemplate,
	},
}
DataService.ProfileStore = ProfileService.GetProfileStore(DataService.Index, DataService.Template)

-- # ================================ PROFILE ================================ #
local Profiles = {}
local Profile_Global = require(ReplicatedStorage["[Rojo]"].Profiles)

function DataService:LoadProfile(player: Player): Profile_Global.Profile
	local IsStudio = RunService:IsStudio() == true
	local host
	Players:SetAttribute("IsStudio", IsStudio)

	if not RunService:IsStudio() then
		local joinData = player:GetJoinData()
		local teleportData = joinData.TeleportData
		local HostPlayer = Players:GetPlayerByUserId(teleportData.Host) :: Instance

		host = teleportData.Host :: number
		Players:SetAttribute("Host", host)
		Players:SetAttribute("SaveSlot", teleportData.Host)
		local isHost = player.UserId == host

		if isHost == false then
			return
		end
	else
		host = player.UserId
		Players:SetAttribute("Host", player.UserId)
		Players:SetAttribute("SaveSlot", "Slot1")
	end

	if Profiles[player] then
		return Profiles[player]
	end

	local Store = self.ProfileStore
	local profile = Store:LoadProfileAsync(`{player.UserId}`, "ForceLoad")
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile
			Profile_Global[player] = profile
			if not Profile_Global[player].Data.Saves[Players:GetAttribute("SaveSlot")].Players[tostring(host)] then
				Profile_Global[player].Data.Saves[Players:GetAttribute("SaveSlot")].Players[tostring(host)] =
					DataService.PlayerTemplate
				Profile_Global[player].Data.Saves[Players:GetAttribute("SaveSlot")].Players[tostring(host)]["IsHost"] =
					true
			end
			--print(Profile_Global[player].Data)
			Players:SetAttribute("ServerDataLoaded", true)
			DataServiceRemote:FireClient(player)
		else
			profile:Release()
		end

		return profile
	else
		player:Kick()
	end
end

function DataService:GetCurrentSlot()
	repeat
		task.wait()
	until Players:GetAttribute("SaveSlot") ~= nil
	return Players:GetAttribute("SaveSlot")
end

function DataService:GetPlayerInGameData(player)
	--if player and Profile_Global[player] then
	--	return Profile_Global[player].Data
	--else
	--	warn(`Unable to load {player.Name}'s data`)
	--end
end

function DataService:GetServerData()
	repeat
		task.wait()
	until Players:GetAttribute("ServerDataLoaded") ~= nil

	local Host = Players:GetAttribute("Host")
	local player = Players:GetPlayerByUserId(Host)
	local CurrentSlot = self:GetCurrentSlot()
	if player and Profile_Global[player] then
		--print(Profile_Global[player].Data.Saves[CurrentSlot])
		return Profile_Global[player].Data.Saves[CurrentSlot]
	else
		warn(`Unable to load Server data`)
		return false
	end
end

function DataService.PlayerAdded(player)
	DataService:LoadProfile(player)
end
function DataService.PlayerLeaving(player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
	Profile_Global[player] = nil
end

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(DataService.PlayerAdded, player)
end
--# ================================ EVENTS ================================ #
Players.PlayerAdded:Connect(DataService.PlayerAdded)
Players.PlayerRemoving:Connect(DataService.PlayerLeaving)

-- # ================================ REQUIRE ================================ #
function DataService.OnRequire(self, Storage: {}) end

return DataService
