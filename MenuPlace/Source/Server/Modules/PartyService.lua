local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartyService = {}
PartyService.Parties = {} :: { [Player]: Party }

local PartyServiceRemote = ReplicatedStorage.Remotes.PartyService :: RemoteEvent

-- # ================================ PARTIES ================================ #
local Party = {}
Party.__index = Party

function Party.new(members: { Player }, leader: Player): Party
	local self = setmetatable({}, Party)

	self.Leader = leader
	self.Members = members

	function self:Kick(player: Player): boolean
		table.remove(self.Members, table.find(self.Members, player))
		return table.find(self.Members, player) == nil
	end

	function self:Add(player: Player): boolean
		table.insert(self.Members, player)
		return table.find(self.Members, player) ~= nil
	end

	function self:Transfer(player: Player): boolean
		if table.find(self.Members, player) == nil then
			return false
		end

		self.Leader = player
		return self.Leader == player
	end

	return self
end
-- # ================================ PARTIES ================================ #
local Invite = {}
Invite.__index = Invite

local Invites = {}

function Invite.new(id: number, inviter: Player, invited: Player): Invite
	local self = setmetatable({}, Invite)

	Invites[id] = self

	if inviter == invited then
		return error("Inviter and Invited can't be the same player")
	end

	self.Id = id
	self.Inviter = inviter
	self.Invited = invited

	function self:Notify(target: Player, message: string, type: string?)
		PartyServiceRemote:FireClient(target, "Party", {
			Type = type or "Invite",
			Data = {
				Id = self.Id,
				Inviter = self.Inviter,
				Invited = self.Invited,
			},
			Message = message,
		})
	end
	function self:Destroy(message: string)
		self:Notify(self.Invited, message)
		Invites[self.Id] = nil
	end
	function self:Accept()
		self:Destroy("Invite has been accepted")
		PartyService:Accept(self)
	end
	function self:Refuse()
		self:Destroy("Invite has been refused")
		PartyService:Refuse(self)
	end

	return self
end

-- # ================================ PARTY SERVICE ================================ #
function PartyService:CreateParty(members: { Player }, leader: Player): number
	local party = Party.new(members, leader)
	self.Parties[leader] = party
	return party
end

function PartyService:RemoveParty(leader: Player): boolean
	self.Parties[leader] = nil
	return self.Parties[leader] == nil
end

function PartyService:Invite(inviter: Player, player: Player): Invite
	local id = `{inviter.UserId}_{player.UserId}`

	local invite = Invite.new(id, inviter, player)
	invite:Notify(player, `You have been invited to a party of ${inviter.Name}`)

	return invite
end

function PartyService:Accept(inviter: Player, player: Player): Party
	local party = self.Parties[inviter]
	if party == nil then
		return error("Party not found")
	end

	party:Add(player)
	Invites[inviter]:Accept()

	return party
end

function PartyService:GetParty(player: Player): Party
	return self.Parties[player]
end

function PartyService:Refuse(inviter: Player, player: Player): Party
	local party = self.Parties[inviter]
	if party == nil then
		return error("Party not found")
	end

	Invites[inviter]:Refuse()

	return party
end

-- # ================================ PARTY SERVICE ================================ #

-- # ================================ REQUIRE ================================ #
function PartyService.OnRequire(module, Storage: {}) end
-- # ================================ REQUIRE ================================ #

-- # ================================ EXPORT ================================ #
export type Party = {
	Leader: Player,
	Members: { Player },
	Kick: (player: Player) -> boolean,
}
export type Invite = {
	Id: number,
	Inviter: Player,
	Invited: Player,

	Accept: () -> nil,
	Refuse: () -> nil,
	Notify: (Invite, target: Player, message: string) -> nil,
	Destroy: (Invite, message: string) -> nil,
}
-- # ================================ EXPORT ================================ #
return PartyService
