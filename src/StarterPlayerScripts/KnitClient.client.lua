local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = ReplicatedStorage.Source.Components
local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)
Knit.AddControllers(ReplicatedStorage.Source.Controllers)

Knit.Start():andThen(function()
    Loader.LoadChildren(Components)
end)