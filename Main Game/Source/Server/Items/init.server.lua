local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerReady = ReplicatedStorage.Remotes:WaitForChild("PlayerReady") :: RemoteEvent
local ItemHandler = require(script.Main)

local Sound = workspace.Musics:WaitForChild("ReatomizedOst-LastMoments") :: Sound
Sound.Looped = true
Sound:Play()


game.Players.PlayerAdded:Connect(function(player)
    if ItemHandler.ItemsLoaded then
        PlayerReady:FireClient(player)
    end
end)

ItemHandler:RenderObjects()