local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Badges = {}

-- # ================================ TYPES ================================ #
local Types = require(ReplicatedStorage:WaitForChild("[Rojo]"):WaitForChild("Types"))


---@diagnostic disable-next-line: undefined-type
function Badges.OnProfileLoad(Profile: Types.Profile)
	--> Soon...
end

---@diagnostic disable-next-line: undefined-type
function Badges.OnRequire(self, Storage: { Types.Module }) end

return Badges
