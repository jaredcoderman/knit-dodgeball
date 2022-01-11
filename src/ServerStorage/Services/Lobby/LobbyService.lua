local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local LobbyConfig = require(script.Parent.LobbyConfig)


local LobbyService = Knit.CreateService {
    Name = "LobbyService",
    Client = {
        UpdateCountdown = Knit.CreateSignal()
    },
    _WaitingPlayers = {},
    TeleportWaitOver = Signal.new()
}

function LobbyService:AssignPlayers()
    local TeamService = Knit.GetService("TeamService")
    for i = 1, LobbyConfig.REQUIRED_PLAYERS do
        local randomPlayer = self._WaitingPlayers[math.random(1, #self._WaitingPlayers)]
        local position = table.find(self._WaitingPlayers, randomPlayer)
        table.remove(self._WaitingPlayers, position)
        if i % 2 == 0 then
            TeamService:JoinTeam(randomPlayer, "Red")
        else
            TeamService:JoinTeam(randomPlayer, "Blue")
        end
        TeamService:AddPlayer(randomPlayer)
    end
end

function LobbyService:AddPlayer(player: Player)
    table.insert(self._WaitingPlayers, player)
end

function LobbyService:RemovePlayer(player: Player)
    local position: number? = table.find(self._WaitingPlayers, player)
    if position then
        table.remove(self._WaitingPlayers, position)
    end 
end

function LobbyService:CheckReadiness()
    local len: number = #self._WaitingPlayers
    if len >= LobbyConfig.REQUIRED_PLAYERS then
        self:Countdown()
        self:AssignPlayers()
    end
end

function LobbyService:KnitInit()
	Players.PlayerAdded:Connect(function(player: Player)
        player.CharacterAdded:Wait()
        task.wait()
		self:AddPlayer(player)
        self:CheckReadiness()
	end)
    
	Players.PlayerRemoving:Connect(function(player: Player)
		self:RemovePlayer(player)
	end)
end

function LobbyService:ReassignPlayers()
    for _,player in ipairs(Players:GetPlayers()) do
        self:AddPlayer(player)
    end
    self:CheckReadiness()
end

function LobbyService:Countdown()
    LobbyService.TeamService = Knit.GetService("TeamService")
    local teleportWaitTime = LobbyService.TeamService.TeamConfig.TELEPORT_WAIT_TIME
    task.wait(teleportWaitTime)
    self.TeleportWaitOver:Fire()
    for i = LobbyConfig.TIMER, 0, -1 do
        LobbyService.Client.UpdateCountdown:FireAll(i)
        task.wait(1)
    end
end

function LobbyService:KnitStart()
    LobbyService.GameService = Knit.GetService("GameService")
    
    LobbyService.GameService.GameOver:Connect(function(winner)
        self:ReassignPlayers()
    end)
end

return LobbyService
