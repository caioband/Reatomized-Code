local RunService = game:GetService("RunService")
local CameraModuleHandler = require(script.CameraModule.Handler)
local FootstepsHandler = require(script.FootstepModule.Handler)


CameraModuleHandler:CreateNewCamera("FirstPerson")
FootstepsHandler:Start()
