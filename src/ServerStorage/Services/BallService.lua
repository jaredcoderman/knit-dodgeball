local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage.Packages
local Option = require(Packages.Option)

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
                local ball = leftHand:FindFirstChild("Ball")
                if ball then
                    return Option.Wrap(ball)
                end
            end
            local rightHand = plr.Character:FindFirstChild("RightHand")
            if rightHand then
                local ball = rightHand:FindFirstChild("Ball")
                if ball then
                    return Option.Wrap(ball)
                end
            end
        end
        return Option.None
    end
    GetBall():Match {
        Some = function(ball)
            local ballComponent = Ball.FromInstance(ball, Ball)
            ballComponent:Throw(lookVector)
        end;
        None = function() end
    }
end

function BallService:ResetBalls()
    local ballComponents = Ball:GetAll()
    for i = 1, #ballComponents do
        ballComponents[1].Instance:Destroy()
    end
end

function BallService:KnitStart()
    local GameService = Knit.GetService("GameService")
    GameService.GameOver:Connect(function()
        self:ResetBalls()
    end)
end

return BallService