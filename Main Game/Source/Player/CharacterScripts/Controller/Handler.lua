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
Handler.CrouchTweeStarted = false
Handler.StartingSpeed = 8
Handler.MaxSpeed = 16
Handler.CrouchSpeed = 5
Handler.RunButtonPressed = false
Handler.YCharacterVelocity = 0
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
					goal.CameraOffset = Vector3.new(0, -2, 0)
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
					goal.CameraOffset = Vector3.new(0, 0, 0)
				end
			end
		end
		local crouchTween = TweenService:Create(Humanoid, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
		crouchTween:Play()
		Handler.CrouchTweeStarted = true
		crouchTween.Completed:Connect(function()
			Handler.CrouchTweeStarted = false
		end)
	end,
	["YCharacterVelocity"] = function()
		local Character = game.Players.LocalPlayer.Character
		print(Character.Humanoid.FloorMaterial)
	end,
}
local function HandleAction(actionName, inputState, _inputObject)
	if Handler.Actions[actionName] then
		Handler.Actions[actionName](inputState, _inputObject)
	end
end

function Handler:CharacterMovimentation()
	ContextActionService:BindAction("Sprint", HandleAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.Thumbstick1)
	ContextActionService:BindAction("Crouch", HandleAction, true, Enum.KeyCode.LeftControl, Enum.KeyCode.Thumbstick2)
	--RunService:BindToRenderStep("YCharacterVelocity", Enum.RenderPriority.Character.Value, Handler.Actions["YCharacterVelocity"]) 
	Character.Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			print(Character.Humanoid.FloorMaterial)
			local soundOveride = Handler.TerrainMaterialConversion[Character.Humanoid.FloorMaterial]
			if not soundOveride then return end
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
		end
	end)
end

return Handler
