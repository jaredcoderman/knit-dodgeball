local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Trove = require(Packages.Trove)
local Component = require(Packages.Component)
local Comm = require(Packages.Comm)
local Option = require(Packages.Option)

local BallThrower = Component.new({
    Tag = "BallThrower"
})

function BallThrower:Construct()
    self._trove = Trove.new()
    self._comm = self._trove:Construct(Comm.ServerComm, self.Instance)
    self._comm:WrapMethod(self, "PlayThrowAnimation")
    self._comm:WrapMethod(self, "Throw")
    self._hasBall = self._comm:CreateProperty("HasBall", true)
    self._playedAnimation = self._comm:CreateProperty("PlayedAnimation", false)
    self._ballComponents = {
        Left = "",
        Right = ""
    }
end

function BallThrower:UpdateHasBall()
    local rightHand = self.Instance:FindFirstChild("RightHand")
    local leftHand = self.Instance:FindFirstChild("LeftHand")
    if rightHand and leftHand then
        if rightHand:FindFirstChild("Ball") or leftHand:FindFirstChild("Ball") then
            self._hasBall:Set(true)
        else
            self._hasBall:Set(false)
        end
    end
end

function BallThrower:Throw(plr, lookVector, hand)
    if not self._hasBall:Get() then return end
    local function GetBall()
        local ball = hand:FindFirstChild("Ball")
        if ball then
            return Option.Wrap(ball)
        end
        return Option.None
    end
    GetBall():Match {
        Some = function(ball)
            local function SetBallPhysics()
                local TeamService = Knit.GetService("TeamService")
                local team = TeamService:FindTeam(plr)
                if team then
                    PhysicsService:CreateCollisionGroup(plr.Name)
                    PhysicsService:SetPartCollisionGroup(ball, plr.Name)
                    if team.name == "Red" then
                        PhysicsService:CollisionGroupSetCollidable(plr.Name, "RedTeam", false)
                    elseif team.name == "Blue" then
                        PhysicsService:CollisionGroupSetCollidable(plr.Name, "BlueTeam", false)
                    end
                    local groupName = plr.Name
                    task.wait(1)
                    PhysicsService:RemoveCollisionGroup(groupName)
                end
            end
            local ballComponent
            if hand.Name == "RightHand" then
                ballComponent = self._ballComponents.Right
            else
                ballComponent = self._ballComponents.Left
            end
            if ballComponent then
                local physicsCoro = coroutine.create(SetBallPhysics)
                coroutine.resume(physicsCoro)
                task.wait()
                ballComponent:SetLastThrower(plr.UserId)
                ballComponent:SetTeam(Knit.GetService("TeamService"):FindTeam(plr).name)

                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
                bodyVelocity.Velocity = (lookVector * 150) + Vector3.new(0, 10, 0)
                if ball:FindFirstChild("RigidConstraint") then
                    ball.RigidConstraint.Attachment0 = nil
                end
                bodyVelocity.Parent = ball

                ballComponent:ListenForHits()
                ball:SetNetworkOwner()
                ball.Parent = workspace

                if hand.Name == "RightHand" then
                    self._ballComponents.Right = ""
                else 
                    self._ballComponents.Left = ""
                end
                self:UpdateHasBall()

                self._playedAnimation:Set(false)
                task.wait(.25)
                bodyVelocity:Destroy()

            end
        end;
        None = function() end
    }
end

function BallThrower:PlayThrowAnimation(plr, hand)
    if not self._hasBall:Get() then return end
    local function GetThrowAnimation()
        local ball = hand:FindFirstChild("Ball")
        if ball then
            if hand.Name == "RightHand" then
                return Option.Wrap(ball:FindFirstChild("Right"))
            else 
                return Option.Wrap(ball:FindFirstChild("Left"))
            end
        end
    end
    local function GetHumanoid()
        local humanoid = self.Instance:FindFirstChild("Humanoid")
        if humanoid then
            return Option.Wrap(humanoid)
        end
        return Option.None
    end
    GetHumanoid():Match {
        Some = function(humanoid)
            GetThrowAnimation():Match {
                Some = function(animation)
                    self._playedAnimation:Set(true)
                    local track = humanoid:LoadAnimation(animation)
                    track.Priority = Enum.AnimationPriority.Action
                    track:Play()
                end;
                None = function() end
            }
        end;
        None = function() end
    }
end

function BallThrower:PrepareThrow()
    task.wait(.5)
    self._canThrow = true
    self._playedAnimation:Set(false)
end

function BallThrower:Start()
    local humanoid = self.Instance:FindFirstChild("Humanoid")
    if humanoid then
        self._trove:Add(humanoid.Died:Connect(function()
            self._trove:Clean()
        end))
    end
    
    local GameService = Knit.GetService("GameService")
    self._trove:Add(GameService.GameOver:Connect(function()
        self._playedAnimation:Set(false)
        self._canThrow = true
    end))
end

function BallThrower:Stop()
    self._trove:Destroy()
end

return BallThrower