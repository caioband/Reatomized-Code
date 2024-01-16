local StarterGui = game:GetService("StarterGui")

repeat
	local success = pcall(function()
		StarterGui:SetCore("ResetButtonCallback", false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	end)
	task.wait(1)
until success
