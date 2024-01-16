local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyHandler = {}

local Remotes = ReplicatedStorage.Remotes
local PartyRemote = Remotes.PartyService
local GuiBindable = Remotes.Gui

function PartyHandler.OnRequire()
	PartyRemote.OnClientEvent:Connect(function(
		event: string,
		params: {
			Data: {
				Inviter: Player,
				Invited: Player,
				Id: number, --> id o invite
			},
			Message: string,
			Type: string,
		}
	)
		if event == "Party" then
			local response = GuiBindable:Invoke("Message", params) :: string | "true" | "false"
			PartyRemote:FireServer("Decision", { Data = params.Data, Response = response })
			print("Player responded with", response)
		end
	end)
end

return PartyHandler
