local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Teleport")

local Events: Events = {
	["StartGame"] = function(self)
		TeleportRemote:FireServer()
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
