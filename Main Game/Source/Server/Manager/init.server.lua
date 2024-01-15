local Lighting = game:GetService("Lighting")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

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

local assets = ReplicatedStorage.Assets
local playerGui = assets.playerGui

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
		local Time = 60
		if RunService:IsStudio() then
			Time = 10
		end

		for _i = 1, Time do
			task.wait(1)
			Text.Text = `{Time - _i}`

			if _i == math.floor(Time / 4) then
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
	local pGui = playerGui:Clone()
	pGui.Parent = Char
	pGui.nickname.Text = Players:GetPlayerFromCharacter(Char).DisplayName
	pGui.Adornee = Char:WaitForChild("HumanoidRootPart")
	pGui.PlayerToHideFrom = Players:GetPlayerFromCharacter(Char)

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
	--task.wait(2)
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

		setCollision(Character)

		local Humanoid = Character:WaitForChild("Humanoid")
		local Animator = Humanoid:WaitForChild("Animator")
		local Animation = ReplicatedFirst.Animations.SofaAnimations[pos.Name]

		local AnimationTrack = Animator:LoadAnimation(Animation) :: AnimationTrack
		--AnimationTrack.Looped = true
		AnimationTrack.Priority = Enum.AnimationPriority.Action
		AnimationTrack:Play()

		Animations:FireClient(player, Animation, { Looped = true })

		Character:PivotTo(pos:GetPivot())

		PrimaryPart.Anchored = true
		return
	end
end

local ReadyPlayers = {}
local function OnServerStart()
	--Lighting.Ready.Enabled = true

	task.delay(60, function()
		if #ReadyPlayers < (#Players:GetPlayers()) then
			OnServerReady()
		end
	end)

	PlayerReady.OnServerEvent:Connect(function(player)
		local Character = player.Character
		local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
		local Animator = Humanoid.Animator :: Animator

		local tracks = Animator:GetPlayingAnimationTracks()

		for i, v in pairs(tracks) do
			v:Stop()
		end

		table.insert(ReadyPlayers, player)
		if #ReadyPlayers == #Players:GetPlayers() then
			OnServerReady()
		end
	end)
end

OnServerStart()

type plr = Player
Players.PlayerAdded:Connect(OnPlayerJoin)
