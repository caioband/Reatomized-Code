local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badges = {}

-- # ================================ TYPES ================================ #
local Types = require(ReplicatedStorage:WaitForChild("[Rojo]"):WaitForChild("Types"))

function Badges.OnProfileLoad(Profile: Types.Profile)
	--> Soon...
end
function Badges.OnRequire(self, Storage: { Types.Module }) end

return Badges
