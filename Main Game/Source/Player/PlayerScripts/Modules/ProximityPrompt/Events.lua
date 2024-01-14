local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemEvent = ReplicatedStorage.Remotes:WaitForChild("Item") :: RemoteFunction
local SoundService = game:GetService("SoundService")

local Events: Events = {
	["Pick-Up"] = function(self)
		--print(self.Object.Name)
		local ItemResponse = ItemEvent:InvokeServer(self.Object.Name)
		--print(ItemResponse)
		if not ItemResponse then return end 

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
