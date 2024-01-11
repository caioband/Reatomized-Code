local RarityItems = {
	["Soup Can"] = 90,
	["Water Bottle"] = 90,
	["insulating tape"] = 80,
	["Stacks"] = 70,
	["Flashlight"] = 60,
	["SuitCase"] = 50,
	["ToolBox"] = 40,
	["Chess Board"] = 40,
	["BaseballBat"] = 35,
	["Radio"] = 35,
	["MedKit"] = 35,
	["Insecticide"] = 30,
	["GasMask"] = 25,
	["Map"] = 20,
	["Scout book"] = 10,
	["Shotgun"] = 10,
}

RarityItems.CFrameAttributeInfo = {
	["Soup Can"] = "SoupCanCFrameMultiplier",
	["Water Bottle"] = "WaterBottleCFrameMultiplier",
	["BaseballBat"] = "BaseballBatCFrameMultiplier",
	["Chess Board"] = "ChessBoardCFrameMultiplier",
	["Flashlight"] = "FlashlightCFrameMultiplier",
	["Scout book"] = "ScoutBookCFrameMultiplier",
	["Gas Mask"] = "GasMaskCFrameMultiplier",
	["Insecticide"] = "InsecticideCFrameMultiplier",
	["Map"] = "MapCFrameMultiplier",
	["MedKit"] = "MedKitCFrameMultiplier",
	["Radio"] = "RadioCFrameMultiplier",
	["Shotgun"] = "ShotgunCFrameMultiplier",
	["Stacks"] = "StacksCFrameMultiplier",
	["SuitCase"] = "SuitCaseCFrameMultiplier",
	["ToolBox"] = "ToolboxCFrameMultiplier",
}

--for i,v : Instance in pairs(workspace.YourHouse.itemspawn:GetDescendants()) do
--    if v:IsA("BasePart") :: BasePart then
--        local Attributes = v:GetAttributes()
--        for j,k in pairs(RarityItems.CFrameAttributeInfo) do
--            if not Attributes[k] then
--                v:SetAttribute(k, CFrame.new())
--            end
--        end
--    end
--end

RarityItems.SpecificSpawn = {
	["GasMask"] = true,
	["BaseballBat"] = true,
	["Chess Board"] = true,
	["Flashlight"] = true,
	["Insecticide"] = true,
	["Map"] = true,
	["MedKit"] = true,
	["Radio"] = true,
	["Rifle"] = true,
	["Stacks"] = true,
	["SuitCase"] = true,
	["ToolBox"] = true,
	["Scout book"] = true,
}

return RarityItems
