local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

local Ball = ReplicatedStorage.Assets.Ball

local Knit = require(ReplicatedStorage.Packages.Knit)
local Option = require(ReplicatedStorage.Packages.Option)

local MapService = Knit.CreateService {
    Name = "MapService",
    Client = {}
}

MapService.Map = workspace:WaitForChild("Map")
MapService.BlueSpawns = MapService.Map:WaitForChild("BlueSpawns")
MapService.RedSpawns = MapService.Map:WaitForChild("RedSpawns")
MapService.BallSpawns = MapService.Map:WaitForChild("BallSpawns")

function MapService:TeleportPlayersIn()
    local TeamService = Knit.GetService("TeamService")
    local teamRed = TeamService._TeamRed
    local teamBlue = TeamService._TeamBlue

    local blueSpawnList = MapService.BlueSpawns:GetChildren()
    local redSpawnList = MapService.RedSpawns:GetChildren()

    local function GetHumanoid(player)
        if player.Character then
            local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
            return Option.Wrap(humanoid)
        end
        return Option.None
    end

    -- teleport blue team
    for i,point in pairs(blueSpawnList) do
        local currentPlayer = teamBlue[i]
        if currentPlayer then
            local hrp = currentPlayer.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(point.Position + Vector3.new(0, 2, 0))
            GetHumanoid(currentPlayer):Match {
                Some = function(humanoid)
                    humanoid.WalkSpeed = 18
                end;
                None = function() end
            }
        end
    end

    -- teleport red team
    for i,point in pairs(redSpawnList) do
        local currentPlayer = teamRed[i]
        if currentPlayer then
            local hrp = currentPlayer.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(point.Position + Vector3.new(0, 2, 0))
            GetHumanoid(currentPlayer):Match {
                Some = function(humanoid)
                    humanoid.WalkSpeed = 18
                end;
                None = function() end
            }
        end
    end
end

function MapService:TeleportPlayersOut(players)
    local function GetHumanoidRootPart(player)
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            return Option.Wrap(hrp)
        end
        return Option.None
    end

    for _,player in ipairs(players) do
        GetHumanoidRootPart(player):Match {
            Some = function(hrp)
                local spawnLocation = workspace.SpawnLocation
                local offset = Vector3.new(0, 4, 0)
                hrp.CFrame = CFrame.new(spawnLocation.Position + offset)
            end;
            None = function() end
        }
    end
end

function MapService:SpawnBalls()
    for _,point in ipairs(MapService.BallSpawns:GetChildren()) do
        local newBall = Ball:Clone()
        newBall.Position = point.Position + Vector3.new(0, .5, 0)
        newBall.Parent = workspace
        CollectionService:AddTag(newBall, "Ball")
    end
end

function MapService:SetCollisionGroups()
    local TeamService = Knit.GetService("TeamService")
    local teamRed = TeamService._TeamRed
    local teamBlue = TeamService._TeamBlue

    for _,player in ipairs(teamBlue) do
        if player.Character then
            for _,descendant in ipairs(player.Character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    PhysicsService:SetPartCollisionGroup(descendant, "BlueTeam")
                end
            end
        end
    end
    for _,player in ipairs(teamRed) do
        if player.Character then
            for _,descendant in ipairs(player.Character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    PhysicsService:SetPartCollisionGroup(descendant, "RedTeam")
                end
            end
        end
    end
    PhysicsService:CollisionGroupSetCollidable("RedTeam", "BlueCollider", false)
    PhysicsService:CollisionGroupSetCollidable("BlueTeam", "RedCollider", false)
end

function MapService:KnitInit()
    local redCollider = MapService.Map.RedCollider
    local blueCollider = MapService.Map.BlueCollider

    PhysicsService:CreateCollisionGroup("RedCollider")
    PhysicsService:CreateCollisionGroup("BlueCollider")
    PhysicsService:CreateCollisionGroup("RedTeam")
    PhysicsService:CreateCollisionGroup("BlueTeam")
    PhysicsService:SetPartCollisionGroup(redCollider, "RedCollider")
    PhysicsService:SetPartCollisionGroup(blueCollider, "BlueCollider")
end

return MapService