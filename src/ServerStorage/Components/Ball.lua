local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local PhysicsService = game:GetService("PhysicsService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Trove = require(Packages.Trove)
local Option = require(Packages.Option)
local Component = require(Packages.Component)
local Signal = require(Packages.Signal)

local BallThrower = require(script.Parent.BallThrower)
local BallConfig = require(script.Parent.BallConfig)

local BallColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 255, 37),
    Color3.fromRGB(0, 0, 255)
}

local function GetPlayerFromPart(part)
    return Option.Wrap(Players:GetPlayerFromCharacter(part.Parent))
end

local function GetHumanoid(player: Player)
    if (player.Character) then
        local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
        return Option.Wrap(humanoid)
    end
    return Option.None
end

local Ball = Component.new({
    Tag = "Ball",
})

function Ball:Construct()
    self._trove = Trove.new()
end

function Ball:_registerHit(player: Player)
    GetHumanoid(player):Match {
        Some = function(humanoid)
            humanoid.Health = 0
        end;
        None = function() end
    }
end

function Ball:ListenForHits()
    local plr = Players:GetPlayerByUserId(self.Instance:GetAttribute("PlayerId"))
    local function ResetBallComponent()
        self:SetPlayer(0)
        self:SetTeam("")
        local debounce = coroutine.create(function()
            task.wait(.5)
            self:SetLastThrower(0)
        end)
        coroutine.resume(debounce)
    end
    if plr then
        local function GetPlayerFromPart(part)
            return Option.Wrap(Players:GetPlayerFromCharacter(part.Parent))
        end
        local hitConnection
        hitConnection = self.Instance.Touched:Connect(function(part)
            if part.Name == "Floor" then
                ResetBallComponent()
                hitConnection:Disconnect()
            else
                GetPlayerFromPart(part):Match {
                    Some = function(player)
                        local playerTeam = Knit.GetService("TeamService"):FindTeam(player).name
                        if self.Instance:GetAttribute("Team") ~= playerTeam  then
                            hitConnection:Disconnect()
                            self:_registerHit(player)
                            ResetBallComponent()
                        end
                    end;
                    None = function() end
                }
            end
        end)
    end
end

function Ball:_listenForTouches()

    local playerTrove = Trove.new()
    local function DetachFromPlayer()
        playerTrove:Clean()
    end
    local function GetHand(player: Player)
        local char = player.Character 
        if char then
            local rightHand = char:FindFirstChild("RightHand")
            local leftHand = char:FindFirstChild("LeftHand")
            if not rightHand:FindFirstChild("Ball") then
                return Option.Wrap(rightHand)
            elseif not leftHand:FindFirstChild("Ball") then
                return Option.Wrap(leftHand)
            end
        end
        return Option.None
    end
    local function DebounceThrowOnPickup(player: Player, hand)
        if player.Character then
            local ballThrower = Component.FromInstance(player.Character, BallThrower)
            if hand.Name == "RightHand" then
                ballThrower._ballComponents.Right = self
            else
                ballThrower._ballComponents.Left = self
            end
            task.wait(.25)
            ballThrower._hasBall:Set(true)
        end
    end
    local function GetGrip(hand: Part)
        if hand.Name == "RightHand" then
            return hand.RightGripAttachment
        else 
            return hand.LeftGripAttachment
        end
    end
    local function AttachToPlayerHand(player: Player, hand: Part, humanoid: Humanoid)
        local grip = GetGrip(hand)
        if grip then
            self.Instance:SetAttribute("PlayerId", player.UserId)
            self.Instance.Anchored = false
            self.Instance.RigidConstraint.Attachment0 = grip 
            self.Instance.Parent = hand
            local debounceCoro = coroutine.create(function()
                DebounceThrowOnPickup(player, hand)
            end)
            coroutine.resume(debounceCoro)
            playerTrove:Add(function()
                if self.Instance.Parent then
                    self.Instance.Parent = workspace
                    self.Instance.RigidConstraint.Attachment0 = nil
                end
                self:SetPlayer(0)
            end)
            playerTrove:Add(humanoid.Died:Connect(DetachFromPlayer))
            playerTrove:Add(Players.PlayerRemoving:Connect(function(playerThatLeft)
                if playerThatLeft == player then
                    DetachFromPlayer()
                end
            end))
        end
    end

    self._trove:Add(self.Instance.Touched:Connect(function(part)
        GetPlayerFromPart(part):Match {
            Some = function(player: Player)
                if self.Instance:GetAttribute("PlayerId") ~= 0 then return end
                if self.Instance:GetAttribute("Team") ~= "" then return end
                if self.Instance:GetAttribute("LastThrower") == player.UserId then return end
                GetHumanoid(player):Match {
                    Some = function(humanoid)
                        if humanoid.Health > 0 then
                            GetHand(player):Match {
                                Some = function(hand)
                                    AttachToPlayerHand(player, hand, humanoid)
                                end;
                                None = function() end
                            }
                        end
                    end;
                    None = function() end
                }
            end,
            None = function() end
        }
    end))
end

function Ball:SetTeam(team: string)
    self.Instance:SetAttribute("Team", team)
end

function Ball:SetLastThrower(id: number)
    self.Instance:SetAttribute("LastThrower", id)
end

function Ball:SetPlayer(id: number)
    self.Instance:SetAttribute("PlayerId", id)
end

function Ball:Start()
    self.Instance.Color = BallColors[math.random(1, #BallColors)]
    self._trove:AttachToInstance(self.Instance)
    self._trove:Add(function()
        self._playerId = 0
    end)

    self:_listenForTouches()
end

function Ball:Stop()
    self._trove:Destroy()
end

return Ball