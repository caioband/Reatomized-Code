local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Handler = {}
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ControllerHandler = require(Character:WaitForChild("[Rojo]").Controller.Handler)

-- Consts --
local SPEED_GATE = 2
local SPEED_MAXIMUM = 14
local MIN_DISTANCE = 0
local MAX_DISTANCE = 100

local FOOTSTEPS: Folder = ReplicatedStorage:WaitForChild("Footsteps")

local SKIN_VECTOR = Vector3.new(0.1, 0, 0.1)
local DELAY_UPPER = (0.1 * (SPEED_MAXIMUM / 17.5)) * (SPEED_MAXIMUM / SPEED_GATE)

-- Vars --
local LastMaterial: string = nil
local LastNum: number = nil

function GetSelf()
	return Handler
end

local function FootstepLoop()
	if Character:WaitForChild("Humanoid").Health <= 0 then
		return
	end

	local walkSpeed = Vector3.new(
		Character.HumanoidRootPart.AssemblyLinearVelocity.X,
		0,
		Character.HumanoidRootPart.AssemblyLinearVelocity.Z
	).Magnitude
	local delayTime = math.clamp(0.5 * (SPEED_MAXIMUM / walkSpeed), 0.1, DELAY_UPPER)

	if walkSpeed > SPEED_GATE then
		local HumanoidStateType = Character.Humanoid:GetState()
		local castParams = RaycastParams.new()
		castParams.FilterDescendantsInstances = { Character, workspace.CurrentCamera }
		castParams.FilterType = Enum.RaycastFilterType.Exclude
		castParams.RespectCanCollide = false

		local cast = workspace:Blockcast(
			CFrame.new(Character.HumanoidRootPart.Position),
			Character.HumanoidRootPart.Size - Vector3.new(0.1, 0, 0.1),
			Vector3.new(0, -4, 0) * (Character.Humanoid.HipHeight + 1),
			castParams
		)
		if cast then
			if
				HumanoidStateType == Enum.HumanoidStateType.Jumping
				or HumanoidStateType == Enum.HumanoidStateType.FallingDown
				or HumanoidStateType == Enum.HumanoidStateType.Freefall
			then
				return
			end
			local soundOveride = cast.Instance:GetAttribute("Material")
			--if cast.Instance.Name == "Wood Pallet" then
			--local NewPart = Instance.new("Part", workspace.DebugFolder)
			--NewPart.Shape = Enum.PartType.Ball
			--NewPart.Material = Enum.Material.Neon
			--NewPart.Size = Vector3.new(.5,.5,.5)
			--NewPart.Anchored = true
			--NewPart.CanCollide = false
			--NewPart.Position = cast.Position
			--end

			if soundOveride then
				local soundTable: table = FOOTSTEPS.Raw[soundOveride]:GetChildren()

				local newNum = math.random(#soundTable)
				if LastMaterial == soundOveride and #soundOveride ~= 1 then
					while newNum == LastNum do
						newNum = math.random(#soundTable)
					end
				end
				local sound: Sound = soundTable[newNum]:Clone()

				LastMaterial = soundOveride
				LastNum = newNum

				sound.Name = "step"
				if ControllerHandler.IsCrouching then
					sound.Volume = 0.05
				else
					sound.Volume = 0.33
				end
				sound.RollOffMode = Enum.RollOffMode.Linear
				sound.RollOffMinDistance = MIN_DISTANCE
				sound.RollOffMaxDistance = MAX_DISTANCE
				sound.Parent = Character.HumanoidRootPart
				sound:Play()

				Debris:AddItem(sound, sound.TimeLength + 0.1)
			end
		end
	end
	task.delay(delayTime, function()
		FootstepLoop()
	end)
end

function Handler:Start()
	task.wait(0.1)
	for i, v in pairs(Character:WaitForChild("HumanoidRootPart"):GetChildren()) do
		if v:IsA("Sound") then
			v:Destroy()
		end
	end

	FootstepLoop()
end

return Handler
