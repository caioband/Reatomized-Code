local a = {}

return a
--local ContentProvider = game:GetService("ContentProvider")
--local ProximityPromptService = game:GetService("ProximityPromptService")
--local Workspace = game:GetService("Workspace")
--
--local PromptService = {}
--
----ContentProvider:PreloadAsync({
----	Workspace:GetDescendants(),
----})
--
--local function CreateProximityBind(asset: any | ProximityPrompt, bind: (player: Player) -> nil)
--	if asset:IsA("ProximityPrompt") then
--		return
--	end
--
--	asset.Triggered:Connect(function(playerWhoTriggered)
--		local event = asset:GetAttribute("Event") or "Interact"
--		local complement = asset:GetAttribute("Complement") or ""
--
--		bind(playerWhoTriggered, event, asset, complement)
--	end)
--end
--
---- # ================================ PROXIMITY PROMPT SERVICE ================================ #
--function ProximityPromptService:OnProximityTriggered(player: Player, event: string, ...)
--	if self.Events[event] then
--		self.Events[event](player, ...)
--	end
--end
--local Events: { [string]: (player: Player, prompt: ProximityPrompt, complement: string) -> nil } = {
--	--> Default event, if it is not specified in the ProximityPrompt
--	["Interact"] = function(player, prompt, complement) end,
--	["StartGame"] = function(player, prompt)
--		print("StartGame")
--	end,
--}
--ProximityPromptService.Events = Events
--
--for _index, asset: any | ProximityPrompt in ipairs(Workspace:GetDescendants()) do
--	CreateProximityBind(asset, function(player: Player, event: string, prompt: ProximityPrompt, complement: string)
--		ProximityPromptService:OnProximityTriggered(player, event, prompt, complement)
--	end)
--end
--return PromptService
