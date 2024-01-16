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

	if not inviter == invited then
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
	self.Parties[leader.UserId] = party
	return party
end

function PartyService:RemoveParty(leader: Player): boolean
	self.Parties[leader.UserId] = nil
	return self.Parties[leader.UserId] == nil
end

function PartyService:Invite(inviter: Player, player: Player): Invite
	local id = `{inviter.UserId}_{player.UserId}`

	local invite = Invite.new(id, inviter, player)
	invite:Notify(player, `You have been invited to a party by {inviter.Name}`)

	return invite
end

function PartyService:Accept(inviter: Player, player: Player): Party
	local party = self.Parties[inviter.UserId]
	if party == nil then
		return error("Party not found")
	end

	party:Add(player)
	--Invites[inviter]:Accept()

	return party
end

function PartyService:GetParty(player: Player): Party
	return self.Parties[player.UserId]
end

function PartyService:Refuse(inviter: Player, player: Player): Party
	local party = self.Parties[inviter.UserId]
	if party == nil then
		return error("Party not found")
	end
	local invite = Invites[`{inviter.UserId}_}{player.UserId}`]
	if not invite then
		return error("Invite not found")
	end

	invite:Refuse()

	return party
end

-- # ================================ PARTY SERVICE ================================ #

-- # ================================ REQUIRE ================================ #
function PartyService.OnRequire(module, Storage: {})
	PartyServiceRemote.OnServerEvent:Connect(function(Player, BindTo, ...)
		if BindTo == "Invite" then
			local params = ...
			local Inviter = Player
			local Invited = params.Player

			if PartyService:GetParty(Player) == nil then
				PartyService:CreateParty({ Player }, Player)
			end
			PartyService:Invite(Inviter, Invited)
		end
		if BindTo == "Accept" then
			local params = ...
			local Inviter = params.Inviter
			local InviteId = params.Data.Id

			PartyService:Accept(Inviter, Player)
		end
		if BindTo == "Refuse" then
			local params = ...
			local Inviter = params.Inviter
			local InviteId = params.Data.Id

			PartyService:Refuse(Inviter, Player)
		end
		if BindTo == "Decision" then
			local params: { Data: {
				Inviter: Player,
				Invited: Player,
				Id: number,
			}, Response: string } =
				...

			print(params.Data)
			print(PartyService.Parties)
			if params.Response == "true" then
				PartyService:Accept(params.Data.Inviter, params.Data.Invited)
			else
				PartyService:Refuse(params.Data.Inviter, params.Data.Invited)
			end
		end
	end)
end
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
