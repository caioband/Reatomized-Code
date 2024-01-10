local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera
local Humanoid = Character:WaitForChild("Humanoid")

local Handler = {}
Handler.IsRunning = false
Handler.IsCrouching = false
Handler.CrouchTweeCompleted = false
Handler.StartingSpeed = 10
Handler.MaxSpeed = 25
Handler.RunButtonPressed = false
Handler.Actions = {
    ["Sprint"] = function(Is, Io)
        if Is == Enum.UserInputState.Begin then 
            Handler.RunButtonPressed = true
            if not Handler.IsRunning then
                Handler.IsRunning = true
                repeat
                    task.wait()
                    Humanoid.WalkSpeed *= 1.02
                until Humanoid.WalkSpeed >= Handler.MaxSpeed or not Handler.RunButtonPressed
                Humanoid.WalkSpeed = Handler.MaxSpeed
            end
        elseif Is == Enum.UserInputState.End then
            Handler.RunButtonPressed = false
            if Handler.IsRunning then
                Handler.IsRunning = false
                repeat
                    task.wait()
                    Humanoid.WalkSpeed *= .98
                until Humanoid.WalkSpeed <= Handler.StartingSpeed or Handler.RunButtonPressed
                Humanoid.WalkSpeed = Handler.StartingSpeed
            end
        end
    end,
    ["Crouch"] = function(Is, Io)
        local goal = {}
        if Is == Enum.UserInputState.Begin then
            Handler.IsRunning = false
            if Humanoid then
                if Handler.IsCrouching == false then
                    Humanoid.WalkSpeed = 2
                    Handler.IsCrouching = true
                    goal.CameraOffset = Vector3.new(0,-2,0)
                end
            end
        elseif Is == Enum.UserInputState.End then
            print("a")
            if Humanoid then
                if Handler.IsCrouching == true then
                    Humanoid.WalkSpeed = 8
                    Handler.IsCrouching = false
                    Handler.CrouchTweeCompleted = false
                    goal.CameraOffset = Vector3.new(0,0,0)
                end
            end
        end
        local crouchTween = TweenService:Create(Humanoid, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        crouchTween:Play()
        crouchTween.Completed:Connect(function()
            
            Handler.CrouchTweeCompleted = true
        end)
    end,
}
local function HandleAction(actionName, inputState, _inputObject)
    if Handler.Actions[actionName] then
        Handler.Actions[actionName](inputState, _inputObject)
    end
end



function Handler:CharacterMovimentation()
    ContextActionService:BindAction("Sprint",HandleAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.Thumbstick1)
    ContextActionService:BindAction("Crouch",HandleAction, true, Enum.KeyCode.LeftControl, Enum.KeyCode.Thumbstick2)
end


return Handler