local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local CameraPoses = workspace.Poses
local sway
local Vel, t, x, y
local Handler = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

Handler.InMainMenu = true
Handler.Limiter = 0
Handler.CurrentVel = 0
Handler.SToG = nil

local CameraService = require(ReplicatedStorage.OpenResources.CameraService)

function GetSelf()
	return Handler
end

function NumLerp(num1: number, num2: number, rate: number): number
	return num1 + (num2 - num1) * rate
end

function GetVelMag(Part): number
	return math.round(
		Vector3.new(Part.AssemblyLinearVelocity.X, Part.AssemblyLinearVelocity.Y, Part.AssemblyLinearVelocity.Z).Magnitude
	)
end

function CalculateCurve(Base: number, Set: number): number
	return math.sin(os.clock() * Base) * Set
end

function GetSwayVal(x: number, y: number, CCamera): CFrame
	return CFrame.new(Vector3.new(x, y, 0), Vector3.new(x * 0.95, y * 0.95, -10)) + CCamera.CFrame.Position
end

function ConvCFrameToOrientation(_CFrame: CFrame)
	local setX, setY, setZ = _CFrame:ToOrientation()
	return Vector3.new(math.deg(setX), math.deg(setY), math.deg(setZ))
end

local function WaveIdleEffectUpdt(dt)
	Handler.Limiter += dt
	if Handler.Limiter >= 1 / 60 then
		t = os.clock()
		x = math.cos(t * 2) * 0.003
		y = math.sin(t * 2) * 0.003

		sway = GetSwayVal(x, y, Camera)

		Camera.CFrame = sway
	end
end

function Handler:StartMenuScenes()
	task.spawn(function()
		local Music = SoundService:WaitForChild("Musics"):WaitForChild("When Stars Collide")
		Music:Play()

		while Handler.InMainMenu == true do
			self:PosMenuCamera()
			task.wait(10)
			FadeEffect(0)
			task.wait(2)
			RunService:UnbindFromRenderStep("MainMenuCamera")
			FadeEffect(1)
			self:NonEuclideanScene()
			repeat
				task.wait()
			until self.SToG == true
			NeonEuclideanGarage(Camera)
			repeat
				task.wait()
			until self.SToG == nil
		end
	end)
end

function Handler:PosMenuCamera()
	local NewCamera = workspace.CurrentCamera
	FadeEffect(1)
	CameraService:ChangeFOV(70, true)
	NewCamera.CameraType = Enum.CameraType.Scriptable
	NewCamera.CFrame = CameraPoses.Main.CFrame
	RunService:BindToRenderStep("MainMenuCamera", Enum.RenderPriority.Camera.Value, WaveIdleEffectUpdt)
end

function FadeEffect(Transparency)
	local Tween1 = TweenService:Create(
		ScreenGui.TransitionFrame,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ BackgroundTransparency = Transparency }
	)
	Tween1:Play()
end

function NeonEuclideanGarage(NewCamera)
	local Distance2 = (CameraPoses.Main3.Position - CameraPoses.Transaction2.Position).Magnitude
	local Time2 = Distance2 / 3
	local Tween2 = TweenService:Create(
		NewCamera,
		TweenInfo.new(Time2, Enum.EasingStyle.Linear),
		{ CFrame = CameraPoses.Transaction2.CFrame }
	)
	NewCamera.CFrame = CameraPoses.Main3.CFrame
	Tween2:Play()
	task.delay(Time2 * 0.8, function()
		FadeEffect(0)
	end)
	Tween2.Completed:Connect(function()
		Handler.SToG = nil
	end)
end

function Handler:NonEuclideanScene()
	FadeEffect(1)
	local NewCamera = workspace.CurrentCamera
	NewCamera.CameraType = Enum.CameraType.Scriptable
	NewCamera.CFrame = CameraPoses.Transaction1.CFrame
	CameraService:ChangeFOV(50, true)
	local Distance1 = (CameraPoses.Transaction1.Position - CameraPoses.Main2.Position).Magnitude
	local Time = Distance1 / 3
	local Distance2 = (CameraPoses.Main3.Position - CameraPoses.Transaction2.Position).Magnitude
	local Time2 = Distance2 / 3
	local Tween1 = TweenService:Create(
		NewCamera,
		TweenInfo.new(Time, Enum.EasingStyle.Linear),
		{ CFrame = CameraPoses.Main2.CFrame }
	)
	Tween1:Play()
	task.wait(Time * 0.999)
	self.SToG = true
end

return Handler
