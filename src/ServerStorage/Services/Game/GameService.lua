local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local GameService = Knit.CreateService {
    Name = "GameService",
    Client = {},
    BallThrowers = {},
}

GameService.GameOver = Signal.new()

function GameService:CheckGameStatus()
    local redTeamOut = 0
    local blueTeamOut = 0
    local teamSize = self.TeamService.TeamConfig.TEAM_SIZE
    for _,player in ipairs(self.TeamService._PlayersOut) do
        local playerTeam = self.TeamService:FindTeam(player).name
        if playerTeam == "Red" then
            redTeamOut += 1
        else 
            blueTeamOut += 1
        end
    end
    if redTeamOut == teamSize then
        GameService.GameOver:Fire("Blue")
    elseif blueTeamOut == teamSize then
        GameService.GameOver:Fire("Red")
    end
end

function GameService:StartGame()
    local MapService = Knit.GetService("MapService")
    print("Game Starting!")
    MapService.TeleportPlayersIn()
    MapService:SpawnBalls()
    MapService.SetCollisionGroups()
end

function GameService:KnitStart()
    self.TeamService = Knit.GetService("TeamService")
    self.TeamService.TeamsFull:Connect(function()
        self:StartGame()
    end)
    self.TeamService.PlayerGotOut:Connect(function()
        self:CheckGameStatus()
    end)
end

return GameService