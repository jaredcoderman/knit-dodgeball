local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Players = game:GetService("Players")

local LobbyController = Knit.CreateController { Name = "LobbyController"}

function LobbyController:UpdateCountdown(timeLeft)
    local player = Players.LocalPlayer
    local playerGui = player.PlayerGui

    self.countdown = playerGui:WaitForChild("Countdown")
    self.timeLeftLabel = self.countdown:WaitForChild("TimeLeftLabel")
    self.timeLeftLabel.Text = timeLeft .. " Seconds"   

    if timeLeft == 0 then
        self.countdown.Enabled = false
    else
        self.countdown.Enabled = true
    end
end

function LobbyController:KnitStart()
    self.LobbyService = Knit.GetService("LobbyService")
    self.LobbyService.UpdateCountdown:Connect(function(timeLeft)
        self:UpdateCountdown(timeLeft)
    end)
end

return LobbyController