local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Source.Controllers)

Knit.Start():andThen(function()
    print("Knit Started On Client")
end)