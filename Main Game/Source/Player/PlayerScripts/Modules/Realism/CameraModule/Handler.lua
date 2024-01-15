local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Handler = {}
local Camera = workspace.CurrentCamera
local BaseFOV = Camera.FieldOfView
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ControllerHandler = require(Character:WaitForChild("[Rojo]").Controller.Handler)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CameraRemote = Remotes:WaitForChild("Camera")

local TweenService = game:GetService("TweenService")
local Vel, t, x, y
local sway
local MouseDelta
local Drift = 0

Handler.Limiter = 0
Handler.CurrentVel = 0
Handler.RenderStepped = nil

-------[FIRST PERSON CAMERA OFFSETS] --------

----Base Info
Handler.FirstPerson = {}
Handler.FirstPerson.Activated = false
Handler.FirstPerson.Modes = {}

---- Calm mode offsets
Handler.FirstPerson.Modes.Calm = {}
Handler.FirstPerson.Modes.Calm.Idle = {}
Handler.FirstPerson.Modes.Calm.Idle.X = 1.5
Handler.FirstPerson.Modes.Calm.Idle.Y = 0.3

---- Panting mode offsets
Handler.FirstPerson.Modes.Panting = {}
Handler.FirstPerson.Modes.Panting.Idle = {}
Handler.FirstPerson.Modes.Panting.Idle.X = 4
Handler.FirstPerson.Modes.Panting.Idle.Y = 0.5

function Handler:FirstPersonCamera(dt)
	if ControllerHandler.CrouchTweeStarted == true then
		return
	end
	Handler.Limiter += dt

	if not Handler.FirstPerson.Activated then
		Player.CameraMode = Enum.CameraMode.LockFirstPerson
		Handler.FirstPerson.Activated = true
	end

	if Handler.Limiter >= 1 / 60 then
		t = os.clock()
		MouseDelta = UserInputService:GetMouseDelta()

		Vel = NumLerp(Handler.CurrentVel, GetVelMag(Character.HumanoidRootPart), 0.25)

		if not Vel then
			return
		end
		x = math.cos(t * Handler.FirstPerson.Modes.Calm.Idle.X) * Handler.FirstPerson.Modes.Calm.Idle.Y
		--y = math.sin(t * 2.3) * .5

		sway = GetSwayVal(x, 1)

		Handler.Drift = GetMouseDrift(Handler.Driftft, MouseDelta, dt)

		Camera.FieldOfView = BaseFOV + math.sqrt(Vel)

		Handler.CurrentVel = Vel
		--Camera.CFrame = Camera.CFrame * CFrame.new(0,CalculateCurve(7,.4) * Vel / 12, 0) * CFrame.Angles(0,0,math.rad(CalculateCurve(2.5,.4) * Vel/12) + math.rad(Drift))
		if ControllerHandler.IsCrouching then
			Character.Humanoid.CameraOffset = ConvCFrameToOrientation(sway) + Vector3.new(0, -2, 0)
		elseif not ControllerHandler.IsCrouching then
			Character.Humanoid.CameraOffset = ConvCFrameToOrientation(sway)
		end

		Camera.CFrame = Camera.CFrame
			* CFrame.new(0, CalculateCurve(14, 0.2) * Vel / 24, 0)
			* CFrame.Angles(0, 0, math.rad(CalculateCurve(5, 0.3) * Vel / 12) + math.rad(Drift))

		Handler.Limiter -= 1 / 60
	end
end

Handler.CameraModes = {
	["FirstPerson"] = function(dt)
		Handler:FirstPersonCamera(dt)
	end,
}

function GetSelf()
	return Handler
end

function NumLerp(num1: number, num2: number, rate: number): number
	if not num1 then
		return
	end
	return num1 + (num2 - num1) * rate
end

function CalculateCurve(Base: number, Set: number): number
	return math.sin(os.clock() * Base) * Set
end

function GetVelMag(Part): number
	return math.round(
		Vector3.new(Part.AssemblyLinearVelocity.X, Part.AssemblyLinearVelocity.Y, Part.AssemblyLinearVelocity.Z).Magnitude
	)
end

function GetMouseDrift(Drift: number, MouseDelta: Vector2, dt: number): number
	return NumLerp(Drift, math.clamp(MouseDelta.X, -3, 1), (12 * dt))
end

function GetSwayVal(x: number, y: number): CFrame
	return CFrame.new(Vector3.new(x, y, 0), Vector3.new(x * 0.95, y * 0.95, -10)) + Camera.CFrame.Position
end

--local function setBlur() : BlurEffect
--	local MotionBlur : BlurEffect = workspace.Lightning:FindFirstChild("MotionBlur", true)
--
--	if not MotionBlur then
--		local newMotionBlur = Instance.new("BlurEffect")
--		newMotionBlur.Size = 0
--		newMotionBlur.Name = 'MotionBlur'
--		newMotionBlur.Enabled = true
--		newMotionBlur.Parent = workspace.Lightning:
--
--		MotionBlur = newMotionBlur
--	end
--
--	return MotionBlur
--end

function ConvCFrameToOrientation(_CFrame: CFrame)
	local setX, setY, setZ = _CFrame:ToOrientation()
	return Vector3.new(math.deg(setX), math.deg(setY), math.deg(setZ))
end

function Handler:CreateNewCamera(CameraMode: string)
	self:Reset()

	if self.CameraModes[CameraMode] then
		Handler.RenderStepped = CameraMode
		RunService:BindToRenderStep(CameraMode, Enum.RenderPriority.Camera.Value, self.CameraModes[CameraMode])
	end
end

function Handler:Reset()
	if self.RenderStepped then
		RunService:UnbindFromRenderStep(self.RenderStepped)
	end
	Player.CameraMode = Enum.CameraMode.Classic
	self.FirstPerson.Activated = false
end

CameraRemote.OnClientEvent:Connect(function(event: string)
	if event == "Enable" then
		Handler:CreateNewCamera("FirstPerson")
	elseif event == "Disable" then
		Handler:Reset()
	end
end)

return Handler
