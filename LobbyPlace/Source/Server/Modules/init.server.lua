local ContentProvider = game:GetService("ContentProvider")
local Modules = script:GetChildren()

-- # ================================ MODULES ================================ #

local Storage: { Module } = {}

-- # ================================ MODULES ================================ #

local function LoadModule(Module: ModuleScript): Module
	ContentProvider:PreloadAsync({Module})
	return require(Module)
end

local function LoadModules(): { [string]: Module }
	for _, Module in ipairs(Modules) do
		local module = LoadModule(Module)
		Storage[Module.Name] = module

		if module.OnRequire then
			module.OnRequire(module, Storage)
		end
	end
	return Storage
end

export type Module = {
	[string]: any,
	OnRequire: (self: Module, Storage: { Module }) -> nil | string,
}


local function GetTheOtherPlayer(You)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v == You then 
			continue
		else
			return v
		end

	end
end




LoadModules()

--print(Storage)

game.Players.PlayerAdded:Connect(function(player)
	if #game.Players:GetPlayers() > 1 then
		local TheOtherPlayer = GetTheOtherPlayer(player)
		print(Storage.PartyService)
		print(TheOtherPlayer.Name)
		Storage.PartyService:Invite(TheOtherPlayer,player)
		Storage.PartyService:Accept(TheOtherPlayer,player)

		local Party = Storage.PartyService:GetParty(TheOtherPlayer)
		print(Party)
		Storage.TeleportService.OnRequire(Storage)
		Storage.TeleportService:TeleportTo("Game",TheOtherPlayer)
	else
		print(#game.Players:GetPlayers())
		Storage.PartyService:CreateParty({player}, player)
		local Party = Storage.PartyService:GetParty(player)
		print(Party)
	end
end)