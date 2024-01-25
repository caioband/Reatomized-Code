local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera
local Humanoid = Character:WaitForChild("Humanoid")
local FOOTSTEPS: Folder = ReplicatedStorage:WaitForChild("Footsteps")
local Camera = workspace.CurrentCamera
local CameraShaker = require(ReplicatedStorage["[Rojo]"].CameraShake)
--local FootstepsHandler = require(Player.PlayerScripts["[Rojo]"].Modules:WaitForChild("Realism").FootstepModule.Handler)

local Handler = {}
Handler.TerrainMaterialConversion = {
	[Enum.Material.Grass] = "Grass",
	[Enum.Material.Asphalt] = "Concrete",
	[Enum.Material.Mud] = "Ground",
	[Enum.Material.Ground] = "Dirt",
	[Enum.Material.Concrete] = "Concrete",
	[Enum.Material.CorrodedMetal] = "Metal_Solid",
	[Enum.Material.Metal] = "Grate_Metal",
	--[Enum.Material.Cobblestone] = ,
	[Enum.Material.Wood] = "Wood",
	[Enum.Material.WoodPlanks] = "Wood",
	--[Enum.Material.Sand] = "Sand",
	--[Enum.Material.Sandstone] = "Sand",
	--[Enum.Material.Snow] = "Snow",
	--[Enum.Material.Ice] = "Ice",
	--[Enum.Material.LeafyGrass] = "Grass",
	--[Enum.Material.Salt] = "Concrete",
	--[Enum.Material.Limestone] = "Concrete",
	[Enum.Material.Basalt] = "Concrete",
	--[Enum.Material.Pavement] = "Concrete",
	--[Enum.Material.Brick] = "Concrete",
	--[Enum.Material.Glacier] = "Ice",
}
Handler.IsRunning = false
Handler.IsCrouching = false
Handler.ShakingCamera = false
Handler.CrouchTweeStarted = false
Handler.StartingSpeed = 8
Handler.MaxSpeed = 16
Handler.CrouchSpeed = 5
Handler.RunButtonPressed = false
Handler.YCharacterVelocity = 0
Handler.CameraOffset = {}
Handler.CameraOffset.Normal = Vector3.new(0.25, 0, -1)
Handler.CameraOffset.Crouched = Vector3.new(0.25, -2, -1)
Handler.CameraOffset.Running = Vector3.new(0.25, 0, -3)
Handler.Actions = {
	["Sprint"] = function(Is, Io)
		if Is == Enum.UserInputState.Begin then
			if Handler.IsCrouching then
				local goal = {}
				Handler.IsCrouching = false
				Handler.CrouchTweeCompleted = false
				goal.CameraOffset = Vector3.new(0, 0, 0)
				local crouchTween = TweenService:Create(
					Humanoid,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					goal
				)
				crouchTween:Play()
				Handler.CrouchTweeStarted = true
				crouchTween.Completed:Connect(function()
					Handler.CrouchTweeStarted = false
				end)
			end
			Handler.RunButtonPressed = true
			if not Handler.IsRunning then
				Handler.IsRunning = true
				repeat
					task.wait()
					Humanoid.WalkSpeed *= 1.02
				until Humanoid.WalkSpeed >= Handler.MaxSpeed or not Handler.RunButtonPressed
				Humanoid.WalkSpeed = Handler.MaxSpeed
			end
		elseif Is == Enum.UserInputState.End then
			Handler.RunButtonPressed = false
			if Handler.IsRunning then
				Handler.IsRunning = false
				repeat
					task.wait()
					Humanoid.WalkSpeed *= 0.98
				until Humanoid.WalkSpeed <= Handler.StartingSpeed or Handler.RunButtonPressed
				Humanoid.WalkSpeed = Handler.StartingSpeed
			end
		end
	end,
	["Crouch"] = function(Is, Io)
		local goal = {}
		if Is == Enum.UserInputState.Begin then
			Handler.IsRunning = false
			if Humanoid then
				if Handler.IsCrouching == false then
					goal.CameraOffset = Vector3.new(0.25, -2, -1)
					Handler.IsCrouching = true
					task.spawn(function()
						repeat
							task.wait()
							Humanoid.WalkSpeed *= 0.98
						until Humanoid.WalkSpeed <= Handler.CrouchSpeed
					end)
				else
					Humanoid.WalkSpeed = Handler.StartingSpeed
					Handler.IsCrouching = false
					Handler.CrouchTweeCompleted = false
					goal.CameraOffset = Vector3.new(0.25, 0, -1)
				end
			end
		end
		local crouchTween =
			TweenService:Create(Humanoid, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
		crouchTween:Play()
		Handler.CrouchTweeStarted = true
		crouchTween.Completed:Connect(function()
			Handler.CrouchTweeStarted = false
		end)
	end,
	["ShakeCamera"] = function()
		local Character = game.Players.LocalPlayer.Character
		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
			Camera.CFrame = Camera.CFrame * shakeCf
		end)
		--Handler.ShakingCamera = true
		--print(Character.HumanoidRootPart.AssemblyLinearVelocity.Y)
		camShake:Start()
		camShake:ShakeOnce(
			math.abs(Character.HumanoidRootPart.AssemblyLinearVelocity.Y) * 0.1,
			math.abs(Character.HumanoidRootPart.AssemblyLinearVelocity.Y) * 0.1,
			math.abs(Character.HumanoidRootPart.AssemblyLinearVelocity.Y) * 0.006,
			math.abs(Character.HumanoidRootPart.AssemblyLinearVelocity.Y) * 0.006
		)
		--task.delay(1, function()
		--	Handler.ShakingCamera = false
		--end)
		--task.delay(2,function()
		--	camShake:Stop()
		--	Handler.ShakingCamera = false
		--end)
		--print(Character.Humanoid.FloorMaterial)
	end,
}
local function HandleAction(actionName, inputState, _inputObject)
	if Handler.Actions[actionName] then
		Handler.Actions[actionName](inputState, _inputObject)
	end
end

function CalculateCurve(Base: number, Set: number): number
	return math.sin(os.clock() * Base) * Set
end

function Handler:CharacterMovimentation()
	ContextActionService:BindAction("Sprint", HandleAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.Thumbstick1)
	ContextActionService:BindAction("Crouch", HandleAction, true, Enum.KeyCode.LeftControl, Enum.KeyCode.Thumbstick2)
	RunService:BindToRenderStep("ShowArms", Enum.RenderPriority.Character.Value, function()
		for i, v: BasePart in pairs(Character:GetChildren()) do
			if not v:IsA("BasePart") then
				continue
			end
			if v.Name ~= "Head" then
				v.LocalTransparencyModifier = 0
				v.CastShadow = false
				--print(v.LocalTransparencyModifier)
			end
		end
	end)
	Character.Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			--print(Character.Humanoid.FloorMaterial)
			local soundOveride = Handler.TerrainMaterialConversion[Character.Humanoid.FloorMaterial]
			if not soundOveride then
				return
			end
			local soundTable: table = FOOTSTEPS.Raw[soundOveride]:GetChildren()
			local newNum = math.random(#soundTable)
			local sound: Sound = soundTable[newNum]:Clone()
			sound.Name = "Landed"
			sound.Volume = 0.33
			sound.RollOffMode = Enum.RollOffMode.Linear
			sound.RollOffMinDistance = 0
			sound.RollOffMaxDistance = 100
			sound.Parent = Character.HumanoidRootPart
			sound:SetAttribute("Ignore", true)
			sound:Play()
			Debris:AddItem(sound, sound.TimeLength + 0.1)
			Handler.Actions["ShakeCamera"]()
		end
	end)
end

return Handler
