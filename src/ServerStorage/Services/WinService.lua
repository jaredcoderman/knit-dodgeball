local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

function WinService:KnitStart()
    self.GameService = Knit.GetService("GameService")
    self.GameService.GameOver:Connect(function(winner)
        self.Client.DisplayWinner:FireAll(winner)
    end)

    self.LobbyService = Knit.GetService("LobbyService")
    self.LobbyService.TeleportWaitOver:Connect(function()
        self.Client.HideWinner:FireAll()
    end)
end

return WinService