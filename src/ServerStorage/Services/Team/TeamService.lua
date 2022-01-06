local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local function _getLengthOfKeyValueTable(t: table)
    local count = 0
    for i,v in pairs(t) do
        if i ~= "name" then
            count += 1
        end
    end
    return count
end

local function _removeValueFromTable(t: table, value: any)
    local position = table.find(t, value)
    if position then
        table.remove(t, position)
        return true
    end
    return false
end

local TeamService = Knit.CreateService {
    Name = "TeamService",
    Client = {},
    _PlayersInGame = {},
    _PlayersOut = {},
    _TeamRed = {
        name = "Red"
    },
    _TeamBlue = {
        name = "Blue"
    },
}

TeamService.TeamsFull = Signal.new()
TeamService.PlayerGotOut = Signal.new()
TeamService.TeamConfig = require(script.Parent.TeamConfig)

function TeamService:Reset()
    self._PlayersOut = {}
    self._TeamRed = {
        name = "Red"
    }
    self._TeamBlue = {
        name = "Blue"
    }
end

function TeamService:CheckTeamCapacity(team: table)
    local len = _getLengthOfKeyValueTable(team)
    if len == TeamService.TeamConfig.TEAM_SIZE then
        local otherTeam
        if self._TeamRed == team then
            otherTeam = self._TeamBlue
        else
            otherTeam = self._TeamRed
        end
        local otherLen = _getLengthOfKeyValueTable(otherTeam)
        if otherLen == TeamService.TeamConfig.TEAM_SIZE then
            TeamService.TeamsFull:Fire()
        end
        if TeamService.TeamConfig.SOLO_TESTING then
            TeamService.TeamsFull:Fire()
        end

    end
end

function TeamService:JoinTeam(player: Player, team: string)
    local teamTable: table?
    if table.find(self._TeamRed, player) or table.find(self._TeamBlue, player) then return end
    if team == "Red" then 
        table.insert(self._TeamRed, player)
        self:CheckTeamCapacity(self._TeamRed)
    elseif team == "Blue" then
        table.insert(self._TeamBlue, player)
        self:CheckTeamCapacity(self._TeamBlue)
    end
end

function TeamService:AddPlayer(player: Player)
    table.insert(self._PlayersInGame, player)
end

function TeamService:GetPlayerIn(player: Player)
    local outPosition = table.find(self._PlayersOut, player)
    if outPosition then
       table.remove(self._PlayersOut, outPosition) 
    end
end

function TeamService:GetPlayerOut(player: Player)
    local outPosition = table.find(self._PlayersOut, player)
    if not outPosition then
       table.insert(self._PlayersOut, player)
       TeamService.PlayerGotOut:Fire(player, self:FindTeam(player))
    end
end

function TeamService.Client:FindTeam(player: Player)
    return self.Server:FindTeam(player)
end

function TeamService:FindTeam(player: Player)
    if table.find(self._TeamRed, player) then return self._TeamRed end
    if table.find(self._TeamBlue, player) then return  self._TeamBlue end
    return nil
end

function TeamService:RemovePlayer(player: Player)
    _removeValueFromTable(self._PlayersInGame, player)
    local team = self:FindTeam(player)
    if table.find(self._PlayersOut, player) then
        _removeValueFromTable(self._PlayersOut, player)
    end
    if team then
        _removeValueFromTable(team, player)
    end
end

function TeamService:KnitInit()
    Players.PlayerRemoving:Connect(function(player: Player)
        self:RemovePlayer(player)
    end)
end

function TeamService:KnitStart()
    TeamService.GameService = Knit.GetService("GameService")
    TeamService.MapService = Knit.GetService("MapService")

    TeamService.GameService.GameOver:Connect(function(winner)
        self:Reset()
        task.wait(TeamService.TeamConfig.TELEPORT_WAIT_TIME)
        TeamService.MapService:TeleportPlayersOut(self._PlayersInGame)
        self._PlayersInGame = {}
    end)
end

return TeamService