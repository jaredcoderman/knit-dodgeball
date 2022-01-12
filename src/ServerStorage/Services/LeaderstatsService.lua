local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local LeaderstatsService = Knit.CreateService { Name = "LeaderstatsService", Client = {}, }

function LeaderstatsService:KnitInit()
    for _,player in ipairs(Players:GetPlayers()) do
        local ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        ls.Parent = player
    end
    Players.PlayerAdded:Connect(function(player)
        local ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        ls.Parent = player
    end)
end

function LeaderstatsService:KnitStart()

end

return LeaderstatsService