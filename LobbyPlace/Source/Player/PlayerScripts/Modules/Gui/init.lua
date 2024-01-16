local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local GuiHandler = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Events = require(script:WaitForChild("Events"))

local GuiButtonObject = {}
GuiButtonObject.__index = GuiButtonObject

local GLOBAL_CONFIG = {
	Normal_Scale = 1,
	Hover_Scale = 1.2,
}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Bindable = Remotes:WaitForChild("Gui")

local Messages = PlayerGui:WaitForChild("Messages")
local Message = Messages:WaitForChild("Message")

function GuiButtonObject.new(object: GuiButton)
	local self = setmetatable({}, GuiButtonObject)

	self.Object = object
	self._Connections = {}
	self.ShouldAnimate = true
	self.HoverSound = SoundService:WaitForChild("GuiButtonHover")
	self.ClickSound = SoundService:WaitForChild("GuiButtonClick")

	local function loadSettings()
		local atr = self.Object:GetAttributes()
		for name, value in pairs(atr) do
			if name == "Animate" then
				self.ShouldAnimate = value
			end
		end
	end

	local function createConnection(event: RBXScriptSignal, connection: (any) -> nil): RBXScriptConnection
		self._Connections[#self._Connections + 1] = event:Connect(connection)
		return self._Connections[#self._Connections]
	end

	createConnection(object.Activated, function()
		local Default = Events.Default
		local Event = Events[object:GetAttribute("Click")]

		Default(self)
		if Event then
			Event(self)
		end
	end)

	self.Object.Destroying:Once(function()
		for _i, connection: RBXScriptConnection in ipairs(self._Connections) do
			connection:Disconnect()
		end
	end)

	createConnection(object.MouseEnter, function()
		self.HoverSound:Play()
		if self.ShouldAnimate == false then
			return
		end

		local UIStroke = object:FindFirstChildWhichIsA("UIStroke")
		if UIStroke then
			TweenService:Create(UIStroke, TweenInfo.new(0.2), { Transparency = 0.1, Color = Color3.new(1, 1, 1) })
				:Play()
		end

		local UIScale = object:FindFirstChildWhichIsA("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = GLOBAL_CONFIG.Hover_Scale }):Play()
		end
	end)
	createConnection(object.MouseLeave, function()
		if self.ShouldAnimate == false then
			return
		end

		local UIStroke = object:FindFirstChildWhichIsA("UIStroke")
		if UIStroke then
			TweenService:Create(UIStroke, TweenInfo.new(0.2), { Transparency = 0.3, Color = Color3.new(0.5, 0.5, 0.5) })
				:Play()
		end

		local UIScale = object:FindFirstChildWhichIsA("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = GLOBAL_CONFIG.Normal_Scale }):Play()
		end
	end)

	loadSettings()
	return self
end

function GuiHandler:Init()
	Bindable.OnInvoke = function(event: string, args: { [string]: any, Message: string })
		local response
		if event == "Message" then
			local message = args.Message

			local Background = Message:WaitForChild("Background")

			Background.Position = UDim2.fromScale(0.5, -1.5)

			local MessageText = Background:WaitForChild("Message")
			MessageText.Text = message

			Message.Enabled = true

			Background:TweenPosition(UDim2.fromScale(0.5, 0.5))

			local Accept = Background:WaitForChild("Accept")
			local Refuse = Background:WaitForChild("Refuse")

			Lighting.Blur.Enabled = true

			local function OnClick()
				local tween =
					TweenService:Create(Background, TweenInfo.new(0.2), { Position = UDim2.fromScale(0.5, 1.5) })
				tween:Play()
				tween.Completed:Once(function(playbackState)
					Lighting.Blur.Enabled = false
					Message.Enabled = false
					Background.Position = UDim2.fromScale(0.5, 0.5)
				end)
			end

			Accept.Activated:Once(function()
				response = "true"
				OnClick()
			end)
			Refuse.Activated:Once(function()
				response = "false"
				OnClick()
			end)
		end

		repeat
			task.wait(0.1)
		until response
		return response
	end
	for _index, object: GuiObject in ipairs(PlayerGui:GetDescendants()) do
		if object.ClassName:find("Button") then
			GuiButtonObject.new(object)
		end
	end
	PlayerGui.DescendantAdded:Connect(function(object: GuiObject)
		if object.ClassName:find("Button") then
			GuiButtonObject.new(object)
		end
	end)
end

--> Starts the module
GuiHandler:Init()
return GuiHandler
