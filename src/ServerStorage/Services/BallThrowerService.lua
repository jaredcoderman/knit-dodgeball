local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
local CollectionService = game:GetService("CollectionService")

local Knit = require(Packages.Knit)
local BallThrowerService = Knit.CreateService { Name = "BallThrowerService", Client = {}, }

function BallThrowerService:KnitStart()
    local function onCharacterAdded(character)
		CollectionService:AddTag(character, "BallThrower")
	end
	local function onPlayerAdded(player)
		if player.Character then
			onCharacterAdded(player.Character)
		end
		player.CharacterAdded:Connect(onCharacterAdded)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(onPlayerAdded, player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return BallThrowerService