local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemEvent = ReplicatedStorage.Remotes:WaitForChild("Item")
local SoundService = game:GetService("SoundService")

local Events: Events = {
	["Pick-Up"] = function(self)
		print("pick")
		local object = self.Object
		object:Destroy()

		--> Play sound
		local folder = SoundService:WaitForChild("Pick-Up")
		local children = folder:GetChildren()
		children[math.random(1, #children)]:Play()

		-- # FIRE SERVER
	end,
	["Door"] = function(self)
		print("Door", self.Object)
	end,
}

export type Prompt = {
	Object: ProximityPrompt,
	Outline: Highlight,
	ProximityPrompt: ProximityPrompt,
	Connections: { RBXScriptConnection },
}
export type Events = {
	[string]: (self: Prompt) -> nil,
}

return Events
