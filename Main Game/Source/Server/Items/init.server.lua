local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemEvent = ReplicatedStorage.Remotes:WaitForChild("Item") :: RemoteFunction
local PlayerReady = ReplicatedStorage.Remotes:WaitForChild("PlayerReady") :: RemoteEvent
local ItemHandler = require(script.Main)

local Sound = workspace.Musics:WaitForChild("ReatomizedOst-LastMoments") :: Sound
Sound.Looped = true
Sound:Play()

ItemEvent.OnServerInvoke = function(player, ItemName)
	local CanGetItem = ItemHandler:ReceiveItem(player, ItemName)
	return CanGetItem
end

ItemHandler:RenderObjects()
