local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemEvent = ReplicatedStorage.Remotes:WaitForChild("Item") :: RemoteFunction
local PlayerReady = ReplicatedStorage.Remotes:WaitForChild("PlayerReady") :: RemoteEvent
local ItemHandler = require(script.Main)

ItemEvent.OnServerInvoke = function(player, ItemName)
	local CanGetItem = ItemHandler:ReceiveItem(player, ItemName)
	return CanGetItem
end

ItemHandler:RenderObjects()
