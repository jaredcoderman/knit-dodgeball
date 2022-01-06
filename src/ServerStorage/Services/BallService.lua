local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Map = workspace:WaitForChild("Map")
local BallSpawns = Map:WaitForChild("BallSpawns")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Ball = require(ServerStorage.Source.Components.Ball)

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
        local ballComponent = BallService.BallComponents[ball]
        ballComponent:Throw(lookVector)
    end
end

function BallService:ResetBalls()
    for ball, component in pairs(BallService.BallComponents) do
        component:Destroy()
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