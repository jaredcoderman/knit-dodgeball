local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)
local Components = ServerStorage.Source.Components

Knit.AddServicesDeep(ServerStorage.Source.Services)

Knit.Start():andThen(function()
    Loader.LoadChildren(Components)
end)