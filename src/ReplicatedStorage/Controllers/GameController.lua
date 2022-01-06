local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GameController = Knit.CreateController { Name = "GameController"}

function GameController:DisplayWinner(winner: string)
    local player = Players.LocalPlayer
    local playerGui = player.PlayerGui

    self.Winner = playerGui:WaitForChild("Winner")
    self.WinnerLabel = self.Winner:WaitForChild("WinnerLabel")
    self.WinnerLabel.Text = winner .. " Team Wins!"
end

function GameController:KnitStart()
    self.GameService = Knit.GetService("GameService")
    -- self.GameService.GameOver:Connect(function(winner)
    --     self:DisplayWinner(winner)
    -- end)
end

return GameController