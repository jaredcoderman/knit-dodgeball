
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Option = require(ReplicatedStorage.Packages.Option)
local Component = require(ReplicatedStorage.Packages.Component)

local BallConfig = require(script.Parent.BallConfig)

local BallColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 255, 37),
    Color3.fromRGB(0, 0, 255)
}

local function GetPlayerFromPart(hit)
    return Option.Wrap(Players:GetPlayerFromCharacter(hit.Parent))
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
    self.TeamService = Knit.GetService("TeamService")
end

function Ball:_setFlying(bool)
    self.Instance:SetAttribute("Flying", bool)
end

function Ball:_setTeam(team: string)
    self.Instance:SetAttribute("Team", team)
end

function Ball:_getPlayerOut(player: Player)
    local TeamService = Knit.GetService("TeamService")
    GetHumanoid(player):Match {
        Some = function(humanoid)
            TeamService:GetPlayerOut(player)
        end;
        None = function() end
    }
end

function Ball:_listenForEnemyHit()
    self._hitConnection = self.Instance.Touched:Connect(function(hit)
        if hit.Name == "Floor"then
            self._hitConnection:Disconnect()
            self:_setFlying(false)
            self:_setTeam("")
        else 
            GetPlayerFromPart(hit):Match {
                Some = function(player)
                    local playerTeam = self.TeamService:FindTeam(player).name
                    local ballTeam = self.Instance:GetAttribute("Team")
                    if ballTeam ~= "" and ballTeam ~= playerTeam then
                        self:_getPlayerOut(player)
                        player.Character.Humanoid.Health = 0
                        self:_setFlying(false)
                        self:_setTeam("")
                        self._hitConnection:Disconnect()
                    end
                end;
                None = function() end
            }
        end
    end)
end

function Ball:_getThrowAnimation(plr)

    if plr.Character then
        local leftHand = plr.Character:FindFirstChild("LeftHand")
        if leftHand then
            if leftHand:FindFirstChild("Ball") then
                return self.Instance.Left
            end
        end

        local rightHand = plr.Character:FindFirstChild("RightHand")
        if rightHand then
            if rightHand:FindFirstChild("Ball") then
                return self.Instance.Right
            end
        end
        return self.Instance.Right
    end

end

function Ball:_prepareThrow(plr)
    GetHumanoid(plr):Match {
        Some = function(humanoid)
            if self.Instance:GetAttribute("Flying") == false then
                self:_setFlying(true)
                local animation = self:_getThrowAnimation(plr)
                local track = humanoid:LoadAnimation(animation)
                track.Priority = Enum.AnimationPriority.Action
                track:Play()
                task.wait(.25)
                local teamName = self.TeamService:FindTeam(plr).name
                self:_setTeam(teamName)
                self.Instance.CanCollide = true
                self._playerTrove:Clean()
            end
        end;
        None = function() end
    }
end

function Ball:_fire(lookVector)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
    bodyVelocity.Velocity = (lookVector * BallConfig.VELOCITY) + Vector3.new(0, BallConfig.HEIGHT, 0)
    bodyVelocity.Parent = self.Instance
    self.Instance.Anchored = false
    self.Instance:SetNetworkOwner()
    self:_listenForEnemyHit()
    task.wait(.25)
    bodyVelocity:Destroy()
end

function Ball:_resetOwner()
    self.Instance:SetAttribute("PlayerId", 0)
    self.Instance.Parent = workspace
end


function Ball:_listenForTouches()
    local playerTrove = Trove.new()
    self._trove:Add(playerTrove)
    self._playerTrove = playerTrove

    local function GetOpenHand(player: Player)
        if(player.Character) then
            local rightHand = player.Character:FindFirstChild("RightHand")
            local leftHand = player.Character:FindFirstChild("LeftHand")
            if not rightHand:FindFirstChild("Ball") then
                return Option.Wrap(rightHand)
            elseif not leftHand:FindFirstChild("Ball") then
                return Option.Wrap(leftHand)
            end
            return Option.None
        end
    end

    local function CreateAttachment(hand, player)
        self.Instance.CanCollide = false
        self.Instance.Anchored = false 
        local attachment = Instance.new("Attachment")
        attachment.Position = Vector3.new(0, 0, -1.5)
        attachment.Parent = hand

        local alignPos = Instance.new("AlignPosition")
        alignPos.RigidityEnabled = true 
        alignPos.Attachment0 = self.Instance.Attachment
        alignPos.Attachment1 = attachment
        alignPos.Parent = self.Instance

        local alignOrientation = Instance.new("AlignOrientation")
        alignOrientation.RigidityEnabled = true
        alignOrientation.Attachment0 = self.Instance.Attachment
        alignOrientation.Attachment1 = attachment
        alignOrientation.Parent = self.Instance
        
        self.Instance.Parent = hand

        playerTrove:Add(function()
            self.Instance.CanCollide = true
        end)
        playerTrove:Add(attachment)
        playerTrove:Add(alignPos)
        playerTrove:Add(alignOrientation)
        self.Instance:SetNetworkOwner(player)
        local readyCoro = coroutine.create(function()
            task.wait(.5)
            self._ready = true
        end)
        coroutine.resume(readyCoro)
    end

    local function DetachFromPlayer()
        self.Instance.Parent = workspace
        playerTrove:Clean()
    end

    local function AttachToPlayer(player: Player, humanoid: any)
        self.Instance:SetAttribute("PlayerId", player.UserId)
        self._ready = false

        playerTrove:Add(humanoid.Died:Connect(DetachFromPlayer))
        playerTrove:Add(function()
            self.Instance:SetAttribute("PlayerId", 0)
        end)
        playerTrove:Add(Players.PlayerRemoving:Connect(function(plr: Player)
                if plr == player then
                    DetachFromPlayer()
                end
        end))
        GetOpenHand(player):Match {
            Some = function(hand)
                CreateAttachment(hand, player)
            end;
            None = function() end
        }
    end

    local function HandsFull(player: Player)
        if player.Character then
            if player.Character.RightHand:FindFirstChild("Ball") and player.Character.LeftHand:FindFirstChild("Ball") then
                return true
            end
        end
        return false
    end

    self._trove:Add(self.Instance.Touched:Connect(function(hit)
        if self.Instance:GetAttribute("PlayerId") ~= 0 then return end
        if self.Instance:GetAttribute("Flying") == true then return end
        if self.Instance:GetAttribute("Team") ~= "" then return end
        GetPlayerFromPart(hit):Match {
            Some = function(player: Player)
                if self.Instance:GetAttribute("PlayerId") ~= player.UserId and not HandsFull(player) then
                    GetHumanoid(player):Match {
                        Some = function(humanoid)
                            if humanoid.Health > 0 then
                                AttachToPlayer(player, humanoid)
                            end
                        end;
                        None = function() end
                    }
                end
            end;
            None = function() end
        }
    end))
end

function Ball:Throw(lookVector)
    local plr = Players:GetPlayerByUserId(self.Instance:GetAttribute("PlayerId"))
    print("player:",plr)
    if plr then
        if plr.Character and self._ready then
            self._ready = false
            self:_prepareThrow(plr)
            self:_fire(lookVector)
            self:_resetOwner()
        end
    end
end

function Ball:Start()
    self.Instance.Color = BallColors[math.random(1, #BallColors)]
    self:_setTeam("")
    self:_listenForTouches()
end

function Ball:Stop()
    print("Stopping")
    self._trove:Destroy()
end

return Ball 