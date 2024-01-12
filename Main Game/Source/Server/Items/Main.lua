local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerReady = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerReady") :: RemoteEvent
local Handler = {}
Handler.ItemsLoaded = false
local Info = require(script.Parent.Info)

function Handler:WillSpawn()
	local T = {
		["WillSpawn"] = 55,
		["WontSpawn"] = 45,
	}

	local Weight = 0
	local randomNum = math.random(1, 100)

	for decision, rarity in pairs(T) do
		Weight += rarity

		if randomNum <= Weight then
			--print(decision, itemName)
			return decision
		end
	end
end

function Handler:GetItemsInfoWeight()
	local w = 0
	for item, rarity in pairs(Info) do
		if Info.SpecificSpawn[item] or typeof(rarity) ~= "number" then
			continue
		end
		w += rarity
	end
	--print(w)
	return w
end

function Handler:SingleItemSpawnDecision(itemName): string
	local Rarity = Info[itemName]

	if not Rarity then
		return
	end

	local T = {
		["WillSpawn"] = Rarity,
		["WontSpawn"] = 100 - Rarity,
	}

	local Weight = 0
	local randomNum = math.random(1, 100)

	for decision, rarity in pairs(T) do
		Weight += rarity

		if randomNum <= Weight then
			--print(decision, itemName)
			return decision
		end
	end
end

function Handler:SetItemToPartPos(Part: BasePart, ItemName): nil
	if ReplicatedStorage.HouseItems:FindFirstChild(ItemName) ~= nil then
		--print("a")
		--if not Info.CFrameAttributeInfo[ItemName] or Part:GetAttribute(Info.CFrameAttributeInfo[ItemName]) then return end
		local CloneModel = ReplicatedStorage.HouseItems:FindFirstChild(ItemName):Clone() :: Instance
		CloneModel.Parent = workspace.HouseItemsSpawned

		local Parent = CloneModel

		if CloneModel:IsA("Model") then
			if not CloneModel.PrimaryPart then
				warn(CloneModel.Name .. " don't have PrimaryPart")
				return
			end
			Parent = CloneModel.PrimaryPart
			CloneModel.PrimaryPart.Anchored = true
		else
			CloneModel.Anchored = true
		end
		if Info.CFrameAttributeInfo[ItemName] and Part:GetAttribute(Info.CFrameAttributeInfo[ItemName]) then
			--print("b")
			local CFrameMultiplier = Part:GetAttribute(Info.CFrameAttributeInfo[ItemName])
			CloneModel:PivotTo(Part.CFrame * CFrameMultiplier)
		else
			--print("c")
			CloneModel:Destroy()
			return
		end

		task.wait()

		local ProximityPrompt = Instance.new("ProximityPrompt", Parent)
		ProximityPrompt.HoldDuration = 0
		ProximityPrompt.ActionText = ""
		ProximityPrompt.ObjectText = ""
		ProximityPrompt.MaxActivationDistance = 4
		ProximityPrompt.RequiresLineOfSight = false
		ProximityPrompt.Name = "Pickup"
		ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
		ProximityPrompt:SetAttribute("Trigger", "Pick-Up")

		CollectionService:AddTag(CloneModel, "Item")
		CollectionService:AddTag(ProximityPrompt, "Prompt")

		--CloneModel:PivotTo(Part.CFrame)
	else
		warn("This Item don't have a model" .. " " .. ItemName)
	end
end

function Handler:DecideItemToSpawn(): string
	local self = GetSelf()
	local itemChoosedDict = {}
	local itemChoosedTable = {}
	local Weight = self:GetItemsInfoWeight()

	local rarityChoosed = math.random(1, Weight)

	Weight = 0

	for item, rarity in pairs(Info) do
		if Info.SpecificSpawn[item] or typeof(rarity) ~= "number" then
			continue
		end
		Weight += rarity

		if rarityChoosed <= Weight then
			itemChoosedDict[item] = {
				itemName = item,
				itemRarity = rarity,
			}
			table.insert(itemChoosedTable, rarity)
		end
	end
	table.sort(itemChoosedTable)
	if itemChoosedTable[1] ~= nil and itemChoosedTable[1] == itemChoosedTable[2] then
		local NamesT = {}
		for _, v in pairs(itemChoosedDict) do
			if v.itemRarity == itemChoosedTable[1] then
				table.insert(NamesT, v.itemName)
			end
		end

		local Choosedindex = math.random(1, #NamesT)
		return NamesT[Choosedindex]
	else
		for _, v in pairs(itemChoosedDict) do
			if v.itemRarity == itemChoosedTable[1] then
				return v.itemName
			end
		end
	end
end

function Handler:IsExclusiveSpawn(Part: BasePart): boolean
	if Part.Parent:IsA("Folder") and not Part.Parent:GetAttribute("Ignore") then
		return true
	end
	return false
end

function Handler:GetExclusiveItemSpawnName(Part: BasePart): string
	if Handler:IsExclusiveSpawn(Part) then
		return Part.Parent.Name
	end

	return false
end

function Handler:RenderObjects()
	local self = GetSelf()
	for i, v: Instance in pairs(workspace.YourHouse.itemspawn:GetDescendants()) do
		if v:IsA("BasePart") then
			local WillSpawn = self:WillSpawn()

			if WillSpawn == "WontSpawn" then
				continue
			end
			if self:IsExclusiveSpawn(v) then
				local ItemName = self:GetExclusiveItemSpawnName(v)
				local SpawnDecision = self:SingleItemSpawnDecision(ItemName) :: string

				if SpawnDecision == "WillSpawn" then
					self:SetItemToPartPos(v, ItemName)
					continue
				else
					--if not v:GetAttribute("CannotSpawnOtherItemType") then
						local Item = self:DecideItemToSpawn() :: string
						self:SetItemToPartPos(v, Item)
						continue
					--end
				end
			else
				local Item = self:DecideItemToSpawn() :: string
				self:SetItemToPartPos(v, Item)
				continue
			end
		end
	end
	Handler.ItemsLoaded = true
end

function GetSelf()
	return Handler
end

return Handler
