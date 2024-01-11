local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ProximityPromptService = game:GetService("ProximityPromptService")
local SoundService = game:GetService("SoundService")
local Doors = {}

local Door = {}
Door.__index = Door

function Door.new(door: Model)
	local prompt = Instance.new("ProximityPrompt", door)
	prompt.Name = "DoorPrompt"
	prompt.ActionText = ""
	prompt.MaxActivationDistance = 6
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt.ObjectText = ""
	prompt.Style = Enum.ProximityPromptStyle.Custom

	local self = setmetatable({
		Door = door,
		Prompt = prompt,
		Open = false,
	}, Door)

	local function createConnection(event: RBXScriptSignal, connection: (any) -> nil): RBXScriptConnection
		return event:Connect(connection)
	end

	function self.Toggle()
		self.Open = not self.Open
		prompt.Enabled = false

		task.delay(0.8, function()
			prompt.Enabled = true
		end)

		if self.Open then
			local DoorOpen = SoundService:WaitForChild("Door Open"):Clone()
			DoorOpen.Parent = door.PrimaryPart
			DoorOpen:Play()

			Debris:AddItem(DoorOpen, DoorOpen.TimeLength)

			for _i, v in ipairs(door:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end

			for i = 1, 25, 1 do
				self.Door:PivotTo(self.Door:GetPivot() * CFrame.Angles(0, math.rad(4), 0))
				task.wait()
			end

			for _i, v in ipairs(door:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
				end
			end
		else
			local DoorClose = SoundService:WaitForChild("Door Close"):Clone()
			DoorClose.Parent = door.PrimaryPart
			DoorClose:Play()

			Debris:AddItem(DoorClose, DoorClose.TimeLength)

			for _i, v in ipairs(door:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end

			for i = 1, 25, 1 do
				self.Door:PivotTo(self.Door:GetPivot() * CFrame.Angles(0, math.rad(-4), 0))
				task.wait()
			end

			for _i, v in ipairs(door:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
				end
			end

		end
	end

	createConnection(prompt.Triggered, function(player: Player)
		self.Toggle()
	end)

	return self
end

function Doors.Init()
	local doors = CollectionService:GetTagged("Door")
	for _i, door in ipairs(doors) do
		Door.new(door)
	end
end

Doors.Init()
return Doors
