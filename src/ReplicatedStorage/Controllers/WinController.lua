local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WinController = Knit.CreateController { Name = "WinController"}

function WinController:DisplayWinner(winner: string)
    local color 
    if winner == "Blue" then
        color = Color3.fromRGB(0, 74, 177)
    else 
        color = Color3.fromRGB(255, 48, 48)
    end

    self.Winner = self.playerGui:WaitForChild("Winner")
    self.WinnerLabel = self.Winner:WaitForChild("WinnerLabel")

    self.WinnerLabel.TextColor3 = color
    self.WinnerLabel.Text = winner .. " Team Wins!"

    self.Winner.Enabled = true
end

function WinController:HideWinner()
    self.Winner = self.playerGui:WaitForChild("Winner")
    self.Winner.Enabled = false
end

function WinController:KnitInit()
    local player = Players.LocalPlayer
    self.playerGui = player.PlayerGui
end

function WinController:KnitStart()
    self.WinService = Knit.GetService("WinService")
    self.WinService.DisplayWinner:Connect(function(winner)
        self:DisplayWinner(winner)
    end)
    self.WinService.HideWinner:Connect(function()
        self:HideWinner()
    end)
end

return WinController