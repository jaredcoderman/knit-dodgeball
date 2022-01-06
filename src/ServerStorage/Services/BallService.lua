local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Map = workspace:WaitForChild("Map")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Ball = require(ServerStorage.Source.Components.Ball)
local Component = require(ReplicatedStorage.Packages.Component)

local BallService = Knit.CreateService {
    Name = "BallService",
    Client = {},
}

BallService.BallComponents = {}

function BallService.Client:Throw(plr, lookVector)
    local function GetBall()
        if plr.Character then
            local leftHand = plr.Character:FindFirstChild("LeftHand")
            if leftHand then
                if leftHand:FindFirstChild("Ball") then
                    return leftHand:FindFirstChild("Ball")
                end
            end
    
            local rightHand = plr.Character:FindFirstChild("RightHand")
            if rightHand then
                if rightHand:FindFirstChild("Ball") then
                    return rightHand:FindFirstChild("Ball")
                end
            end
            return nil
        end
    end

    local ball = GetBall()
    if ball then
        local ballComponent = Ball.FromInstance(ball, Ball)
        ballComponent:Throw(lookVector)
    end
end

function BallService:ResetBalls()
    for ball, _ in pairs(BallService.BallComponents) do
        local componentInstance = Component.FromInstance(ball, Ball)
        if componentInstance then
            componentInstance:Destroy()
        end
    end
    BallService.BallComponents = {}
end

function BallService:KnitStart()
    local GameService = Knit.GetService("GameService")
    GameService.GameOver:Connect(function()
        self:ResetBalls()
    end)
end

return BallService