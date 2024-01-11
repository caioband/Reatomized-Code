local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local PlayerReady = Remotes.PlayerReady

local ServerReady = false

local function MakePlayerReady(plr: plr)
	local Character = plr.Character or plr.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

	PlayerReady:FireClient(plr)

	-- # LOCK PLAYER
	PrimaryPart.Anchored = false
	Lighting.Ready.Enabled = false
end

local function OnServerReady()
	if ServerReady == true then
		return
	end
	ServerReady = true

	for _i, plr: plr in ipairs(Players:GetPlayers()) do
		MakePlayerReady(plr)
	end

	-- # 60 SECONDS TIMER
	task.spawn(function()
		for _i = 1, 60 do
			task.wait(1)
			print("Server will be ready in " .. tostring(60 - _i) .. " seconds.")
		end
		print("Server is ready!")
	end)
end

local function OnPlayerJoin(player: plr)
	local Character = player.Character or player.CharacterAdded:Wait()
	local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

	-- # LOCK PLAYER
	PrimaryPart.Anchored = true
end

local ReadyPlayers = {}
local function OnServerStart()
	Lighting.Ready.Enabled = true

	task.delay(60, function()
		if #ReadyPlayers < (#Players:GetPlayers()) then
			OnServerReady()
			print("Starting with the current players...")
		end
	end)

	PlayerReady.OnServerEvent:Connect(function(player)
		table.insert(ReadyPlayers, player)
		if #ReadyPlayers == #Players:GetPlayers() then
			OnServerReady()
		end
	end)
end

OnServerStart()

type plr = Player
Players.PlayerAdded:Connect(OnPlayerJoin)
