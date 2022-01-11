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