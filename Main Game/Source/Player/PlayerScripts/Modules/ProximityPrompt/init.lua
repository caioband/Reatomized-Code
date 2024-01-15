local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local ProximityPromptHandler = {}

local Events = require(script:WaitForChild("Events"))

local Prompt = {}
Prompt.__index = Prompt

function Prompt.new(ProximityPrompt: ProximityPrompt)
	local MainObject = ProximityPrompt.Parent

	if ProximityPrompt.Parent.Parent:IsA("Model") then
		MainObject = ProximityPrompt.Parent.Parent
	end

	local Outline = Instance.new("Highlight", MainObject)
	Outline.Name = "Outline"

	Outline.Enabled = false
	Outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	Outline.FillColor = Color3.fromRGB(255, 255, 255)
	Outline.OutlineColor = Color3.fromRGB(255, 255, 255)

	Outline.OutlineTransparency = 1
	Outline.FillTransparency = 1

	local self = setmetatable({
		Object = MainObject,
		Outline = Outline,
		ProximityPrompt = ProximityPrompt,
		Connections = {},
	}, Prompt)

	local function createConnection(event: RBXScriptSignal, connection: (any) -> nil): RBXScriptConnection
		self.Connections[#self.Connections + 1] = event:Connect(connection)
		return self.Connections[#self.Connections]
	end

	createConnection(ProximityPrompt.Triggered, function(player: Player)
		local Trigger = ProximityPrompt:GetAttribute("Trigger")
		local Event = Events[Trigger]
		if Event then
			Event(self)
		end
	end)
	createConnection(ProximityPrompt.PromptShown, function(player: Player)
		Outline.Enabled = true
		TweenService:Create(Outline, TweenInfo.new(0.2), {
			OutlineTransparency = 0.1,
			FillTransparency = 0.9,
		}):Play()
	end)
	createConnection(ProximityPrompt.PromptHidden, function(player: Player)
		TweenService:Create(Outline, TweenInfo.new(0.2), {
			OutlineTransparency = 1,
			FillTransparency = 1,
		}):Play()
		task.delay(0.2, function()
			Outline.Enabled = false
		end)
	end)

	return self
end

function ProximityPromptHandler.OnRequire()
	local atr = Players:GetAttribute("HouseItemLoad")
	if not atr then
		repeat
			atr = Players:GetAttributeChangedSignal("HouseItemLoad"):Wait()
		until atr ~= nil
	end

	local prompts = CollectionService:GetTagged("Prompt")

	for _, prompt: ProximityPrompt in ipairs(prompts) do
		Prompt.new(prompt)
	end
	CollectionService:GetInstanceAddedSignal("Prompt"):Connect(function()
		local Tagged = CollectionService:GetTagged("Prompt")
		local Object = Tagged[#Tagged]
		Prompt.new(Object)
	end)
end

return ProximityPromptHandler
