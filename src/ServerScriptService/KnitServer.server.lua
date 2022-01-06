local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddServicesDeep(ServerStorage.Source.Services)

Knit.Start():andThen(function()
    print("Knit Started On Server")
end)