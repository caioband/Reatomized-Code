local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Events: Events = {
	["Start-Game"] = function(GuiButtonObject)
		local TeleportEvent = Remotes:WaitForChild("Teleport")

		TeleportEvent:FireServer("Join-Game")
	end,
	["Default"] = function(GuiButtonObject)
		local GuiButtonClick = SoundService:WaitForChild("GuiButtonClick")
		GuiButtonClick:Play()
		return
	end,
}

export type GuiButtonObject = {
	Object: GuiButton,
	_Connections: { RBXScriptConnection },
}
export type Events = {
	[string]: (self: GuiButtonObject) -> nil,
}
return Events
