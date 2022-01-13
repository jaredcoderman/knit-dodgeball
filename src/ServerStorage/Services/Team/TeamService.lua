local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Option = require(ReplicatedStorage.Packages.Option)
local Trove = require(ReplicatedStorage.Packages.Trove)

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
    _trove = Trove.new(),
    _RedSize = 0,
    _BlueSize = 0
}

TeamService.TeamsFull = Signal.new()
TeamService.PlayerGotOut = Signal.new()
TeamService.TeamConfig = require(script.Parent.TeamConfig)

function TeamService:CheckTeamCapacity(team: table)
    local len = _getLengthOfKeyValueTable(team)
    if len >= TeamService.TeamConfig.MAX_TEAM_SIZE then
        return false
    end
    return true
end

function TeamService:JoinTeam(player: Player, team: string)
    if table.find(self._TeamRed, player) or table.find(self._TeamBlue, player) then return end
    if team == "Red" and self:CheckTeamCapacity(self._TeamRed) then 
        table.insert(self._TeamRed, player)
    elseif team == "Blue" and self:CheckTeamCapacity(self._TeamBlue) then
        table.insert(self._TeamBlue, player)
    end
end

function TeamService:AddPlayer(player: Player)
    -- local function GetHumanoid()
    --     if player.Character then
    --         local hum = player.Character:FindFirstChild("Humanoid")
    --         return Option.Wrap(hum)
    --     end
    --     Option.None()
    -- end

    -- GetHumanoid():Match {
    --     Some = function(humanoid)
    --         self._trove:Add(humanoid.Died:Connect(function()
    --             self:GetPlayerOut(player)
    --         end))
    --     end;
    --     None = function() end
    -- }
    table.insert(self._PlayersInGame, player)
    self._trove:Add(Players.PlayerRemoving:Connect(function(plr: Player)
        if plr == player then
            self:GetPlayerOut(player)
        end
    end))
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
end

function TeamService:PlayerIsInGame(player: Player)
    if table.find(self._PlayersOut, player) or not table.find(self._PlayersInGame, player) then
        return false
    end
    return true
end

function TeamService:SetTeamSizes()
    self._RedSize = _getLengthOfKeyValueTable(self._TeamRed)
    self._BlueSize = _getLengthOfKeyValueTable(self._TeamBlue)
end

function TeamService:Reset()
    self._PlayersOut = {}
    self._TeamRed = {
        name = "Red"
    }
    self._TeamBlue = {
        name = "Blue"
    }
    self._PlayersInGame = {}
    self._RedSize = 0
    self._BlueSize = 0
    self._trove:Clean()
end

function TeamService:KnitStart()
    TeamService.GameService = Knit.GetService("GameService")
    TeamService.MapService = Knit.GetService("MapService")

    TeamService.GameService.GameOver:Connect(function(winner)
        task.wait(TeamService.TeamConfig.TELEPORT_WAIT_TIME)
        TeamService.MapService:TeleportPlayersOut(self._PlayersInGame)
        self:Reset()
    end)
end

return TeamService