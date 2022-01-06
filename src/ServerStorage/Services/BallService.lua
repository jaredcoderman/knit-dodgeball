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
    local ballComponents = Ball:GetAll()
    for _,component in ipairs(ballComponents) do
        component.Instance:Destroy()
    end
end

function BallService:KnitStart()
    local GameService = Knit.GetService("GameService")
    GameService.GameOver:Connect(function()
        self:ResetBalls()
    end)
end

return BallService