local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

local Knit = require(ReplicatedStorage.Packages.Knit)

local BallController = Knit.CreateController {
    Name = "BallController",
}

function BallController:KnitStart()
    local BallService = Knit.GetService("BallService")
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            BallService:Throw(mouse.Hit.LookVector)
        end
    end)
end

return BallController