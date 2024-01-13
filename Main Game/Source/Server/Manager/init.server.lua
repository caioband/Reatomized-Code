local Lighting = game:GetService("Lighting")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage.Remotes
local PlayerReady = Remotes.PlayerReady
local Effects = Remotes.Effects
local Animations = Remotes.Animations
local Camera = Remotes.Camera

local ServerReady = false

local Bunker = require(script:WaitForChild("Bunker"))

local BunkerTimer = Workspace:WaitForChild("BunkerTimer")
local Timer = BunkerTimer:WaitForChild("Timer")
local Text = Timer:WaitForChild("Text")
local Alarm = BunkerTimer:WaitForChild("Alarm") :: Sound

local function MakePlayerReady(plr: plr)
	local Character = plr.Character or plr.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

	PlayerReady:FireClient(plr)

	-- # LOCK PLAYER
	PrimaryPart.Anchored = false
	Lighting.Ready.Enabled = false
end

local function teleport(from: Player, to: BasePart)
	Camera:FireClient(from, "Disable")
	local char = from.Character or from.CharacterAdded:Wait()
	char:PivotTo(to:GetPivot())
	task.delay(1.5, function()
		Camera:FireClient(from, "Enable")
	end)
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
		for _i = 1, 10 do
			task.wait(1)
			Text.Text = `{10 - _i}`

			if _i == 15 then
				Alarm:Play()
			end
		end
		local saved = Bunker:GetPlayersIn()
		for _i, player in ipairs(Players:GetPlayers()) do
			if not table.find(saved, player) then
				player:Kick("You were not in the bunker when the server started.")
			end
		end

		local BunkerSpawn = Workspace:WaitForChild("BunkerSpawn")
		local BunkerZone = Workspace:WaitForChild("BunkerZone")
		local BunkerDoor = Workspace:WaitForChild("BunkerDoor")

		-- # TELEPORT TO INSIDE
		for _i, player: Player in ipairs(saved) do
			local char = player.Character or player.CharacterAdded:Wait()
			char.PrimaryPart.Anchored = true

			teleport(player, BunkerZone)
		end

		task.wait(0.5)
		-- # CLOSE THE DOOR

		local Sound = BunkerDoor:WaitForChild("Close")
		Sound:Play()
		for i = 1, 110, 1 do
			BunkerDoor:PivotTo(BunkerDoor:GetPivot())
			task.wait()
		end

		Effects:FireAllClients("FadeEffect", 0.5, 0)

		task.wait(1.35)

		-- # TELEPORT TO BUNKER
		for _i, player: Player in ipairs(saved) do
			local char = player.Character or player.CharacterAdded:Wait()
			char.PrimaryPart.Anchored = false
			teleport(player, BunkerSpawn)
			Effects:FireClient(player, "FadeEffect", 0.5, 1)
		end
		local Sound = workspace.Musics:WaitForChild("ReatomizedOst-LastMoments") :: Sound
		if Sound.Playing then
			Sound:Stop()
		end
	end)
end

local function setCollision(Char: Model)
	local desc = Char:GetDescendants()
	for _i, v in ipairs(desc) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Players"
		end
	end
end

local posT = Workspace.YourHouse["Sofa Positions"]
local positions = { posT.pos1, posT.pos2, posT.pos3, posT.pos4 }

local function OnPlayerJoin(player: plr)
	-- # LOCK PLAYER
	player.CharacterAdded:Connect(setCollision)

	for _, pos in ipairs(positions) do
		if pos:GetAttribute("Used") == true then
			continue
		end
		pos:SetAttribute("Used", true)

		local AnimationId = pos:GetAttribute("Animation") :: number

		local Character = player.Character or player.CharacterAdded:Wait()
		local PrimaryPart = Character:WaitForChild("HumanoidRootPart")
		Character.PrimaryPart = PrimaryPart

		repeat
			task.wait(0.1)
		until Character.Parent == game.Workspace

		Character:PivotTo(pos:GetPivot())
		PrimaryPart.Anchored = true
		setCollision(Character)

		Animations:FireClient(player, AnimationId, { Looped = true })
		return
	end
end

local ReadyPlayers = {}
local function OnServerStart()
	--Lighting.Ready.Enabled = true

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
