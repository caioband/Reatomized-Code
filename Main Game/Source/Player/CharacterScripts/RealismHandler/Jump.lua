local Debris = game:GetService("Debris")
local Jump = {}

local DirectionMultiplier = 8

Jump.Jumping = false

function Jump:CreateBodyVelocity(Character: { Humanoid: Humanoid }): BodyVelocity
	if self.Jumping == true then
		return
	end

	self.Jumping = true

	local Direction = Character.Humanoid.MoveDirection
	local Magnitude = math.clamp(Direction.Magnitude, 0, 0.5)

	local PrimaryPart = Character.PrimaryPart

	PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.MaxForce = Vector3.new(15000, 53894, 15000)
	BodyVelocity.Velocity = Vector3.new(Direction.X * DirectionMultiplier, 12, Direction.Z * DirectionMultiplier)
	BodyVelocity.Parent = Character.HumanoidRootPart

	task.delay(0.09 - (0.09 * Magnitude), function()
		BodyVelocity:Destroy()
	end)
	task.delay(1.5 - (1 * Magnitude), function()
		self.Jumping = false
	end)
end

return Jump
