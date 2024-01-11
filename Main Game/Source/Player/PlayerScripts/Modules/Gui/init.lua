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
local PlayerReady = Remotes:WaitForChild("PlayerReady")

local Storage: {
	Realism: {
		LockFirstPerson: () -> nil,
		UnLockFirstPerson: () -> nil,
	},
} = {}

local GuiButtonObjectStore = {}

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

		Default(self, Storage)
		if Event then
			Event(self, Storage)
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
	PlayerGui:WaitForChild("Ready"):WaitForChild("Freeze").Enabled = true

	for _index, object: GuiObject in ipairs(PlayerGui:GetDescendants()) do
		if object.ClassName:find("Button") then
			GuiButtonObjectStore[object.Name] = GuiButtonObject.new(object)
		end
	end
	PlayerGui.DescendantAdded:Connect(function(object: GuiObject)
		if object.ClassName:find("Button") then
			GuiButtonObjectStore[object.Name] = GuiButtonObject.new(object)
		end
	end)
end

function GuiHandler.OnRequire(self, str: {})
	Storage = str

	PlayerReady.OnClientEvent:Once(function()
		Events["Game-Ready"](GuiButtonObjectStore["Game-Ready"], Storage)
	end)
end

--> Starts the module
GuiHandler:Init()
return GuiHandler
