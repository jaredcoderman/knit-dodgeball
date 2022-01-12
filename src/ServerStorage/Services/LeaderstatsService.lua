local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local LeaderstatsStore = DataStoreService:GetDataStore("LeaderstatsStore")
local LeaderstatsService = Knit.CreateService { Name = "LeaderstatsService", Client = {}, }

function LeaderstatsService:LoadStats(player: Player)
    local data 
    local _,err = pcall(function()
        data = LeaderstatsStore:GetAsync(player.UserId)
    end)
    if data then
        for statName,value in pairs(data) do
            player.leaderstats[statName].Value = value
        end
    else
        warn(err)
    end
end

function LeaderstatsService:CreateStats(player: Player)
    local ls = Instance.new("Folder")
    ls.Name = "leaderstats"
    ls.Parent = player

    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Value = 0
    wins.Parent = ls
end

function LeaderstatsService:KnitInit()
    for _,player in ipairs(Players:GetPlayers()) do
        self:CreateStats(player)
        self:LoadStats(player)
    end
    Players.PlayerAdded:Connect(function(player)
        self:CreateStats(player)
        self:LoadStats(player)
    end)
end

function LeaderstatsService:KnitStart()
    Players.PlayerRemoving:Connect(function(player: Player)
        local statsTable = {}
        for _,stat in ipairs(player.leaderstats:GetChildren()) do
            statsTable[stat.Name] = stat.Value
        end
        local _,err = pcall(function()
            LeaderstatsStore:SetAsync(player.UserId, statsTable)
        end)
        if err then warn(err) end
    end)
end

return LeaderstatsService