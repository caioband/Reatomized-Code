local CurrencyService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local products: {[number]: {}} = {
    [123] = {
        give = function(plr: Player)
            print(plr.Name .. " bought product 123")
        end,
    },

    --// Change
    ["life"] = function(plr: Player)
        local Profiles = require(ReplicatedStorage["[Rojo]"].Profiles)
        local profile = Profiles[plr]
        if profile then
            profile.Lives += 1
        end
    end
}
CurrencyService.Products = products

function CurrencyService:Invoke(plr: Player, product: number)
    if products[product] then
        products[product].give(plr)
    end
end



return CurrencyService