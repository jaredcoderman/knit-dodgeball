local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local WinService = Knit.CreateService { 
    Name = "WinService", 
    Client = {
        DisplayWinner = Knit.CreateSignal(),
        HideWinner = Knit.CreateSignal()
    }, 
}

function WinService:GiveWinsToTeam(teamName: string)
    local TeamService = Knit.GetService("TeamService")
    local teamTable
    if teamName == "Blue" then
        teamTable = TeamService._TeamBlue
    else 
        teamTable = TeamService._TeamRed
    end
    for i,player in pairs(teamTable) do
        if i ~= "name" then
           player.leaderstats.Wins.Value += 1
        end
    end
end

function WinService:KnitStart()
    self.GameService = Knit.GetService("GameService")
    self.GameService.GameOver:Connect(function(teamName)
        self:GiveWinsToTeam(teamName)
        self.Client.DisplayWinner:FireAll(teamName)
    end)
    self.LobbyService = Knit.GetService("LobbyService")
    self.LobbyService.TeleportWaitOver:Connect(function()
        self.Client.HideWinner:FireAll()
    end)
end

return WinService