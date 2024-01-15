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
DataService.Index = "Player_Save # 1.0.0"
DataService.Template = {
	["Players"] = {},
}
DataService.ProfileStore = ProfileService.GetProfileStore(DataService.Index, DataService.Template)

-- # ================================ PROFILE ================================ #
local Profiles = {}
local Profile_Global = require(ReplicatedStorage["[Rojo]"].Profiles)

---@diagnostic disable-next-line: undefined-type
function DataService:LoadProfile(player: Player): Profile_Global.Profile
	
	if not RunService:IsStudio() then
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
		print(Players:GetPlayers())
		for i,v in pairs(Players:GetPlayers()) do
			print(v)
		end
		if player:IsDescendantOf(Players) == true then
			print(player)
			Profiles[player] = profile
			Profile_Global[player] = profile
			DataServiceRemote:FireClient(player)
		else
			profile:Release()
		end

		return profile
	else
		player:Kick()
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
