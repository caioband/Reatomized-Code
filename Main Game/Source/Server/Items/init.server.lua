local ItemHandler = require(script.Main)

local Sound = workspace.Musics:WaitForChild("ReatomizedOst-LastMoments") :: Sound
Sound.Looped = true
Sound:Play()

ItemHandler:RenderObjects()