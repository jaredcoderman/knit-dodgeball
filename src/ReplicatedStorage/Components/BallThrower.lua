local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Trove = require(Packages.Trove)
local Component = require(Packages.Component)
local Comm = require(Packages.Comm)
local Option = require(Packages.Option)

local player = Players.LocalPlayer

local OnlyLocalPlayer = {}
function OnlyLocalPlayer.ShouldConstruct(component)
    local char = player.CharacterAdded:Wait()
    return component.Instance == char
end

local BallThrower = Component.new({
    Tag = "BallThrower",
    Extensions = { OnlyLocalPlayer }
})

function BallThrower:Construct()
    self._trove = Trove.new()
    self._comm = self._trove:Construct(Comm.ClientComm, self.Instance, false)
end

function BallThrower:_throw(hand)
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    local lookVector = mouse.Hit.LookVector
    self._comm:GetFunction("Throw")(lookVector, hand)
end

function BallThrower:Start()
    local hasBall = self._comm:GetProperty("HasBall")
    local playedAnimation = self._comm:GetProperty("PlayedAnimation")

    local function GetHand()
        local rightHand = self.Instance:FindFirstChild("RightHand")
        local leftHand = self.Instance:FindFirstChild("LeftHand")
        if leftHand then
            local ball = leftHand:FindFirstChild("Ball")
            if ball then
                return Option.Wrap(leftHand)
            end
        end
        if rightHand then
            local ball = rightHand:FindFirstChild("Ball")
            if ball then
                return Option.Wrap(rightHand)
            end
        end
        return Option.None
    end

    self._trove:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and hasBall:Get() and not playedAnimation:Get() then
            GetHand():Match {
                Some = function(hand)
                    print(hand.Name)
                    self._comm:GetFunction("PlayThrowAnimation")(hand)
                    task.wait(.3)
                    self:_throw(hand)
                end;
                None = function() end
            }
        end
    end))
end

function BallThrower:Stop()
    self._trove:Destroy()
end

return BallThrower