local MarketPlaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CurrencyService = require(ServerStorage["[Rojo]"].CurrencyService)

MarketPlaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if player then
        local success, err = pcall(function()
            CurrencyService:Invoke(player, receiptInfo.ProductId)
        end)
        if not success then
            warn("Error processing receipt: " .. err)
        end
        if success then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end