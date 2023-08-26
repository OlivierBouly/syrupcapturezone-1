AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
   -- constraint.Keepupright( self, self:GetAngles(), 0, 999999 )
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
   
    physobj = self:GetPhysicsObject()
    if IsValid(physobj) then
        physobj:SetMass(150)
    end
    
    local WarTimer = 900 -- 15 min?
    local WarCooldown = 1200 -- 20 min?

    self:SetPercent(0)
    self:SetStatus(false)
    self:SetTimer(WarTimer)
    self:SetCooldown(0)
    self.ThinkTime = 1
    self.PointTimer = 5
end

function ENT:StartEvent()
    self:SetStatus(true)
end

function ENT:EndEvent()
    self:SetCooldown(WarCooldown)
    self:SetStatus(false)
    self:SetPercent(0)
    self:SetTimer(WarTimer)
    self.Owner:ChatPrint("Event Over")    
end

function ENT:FailedEvent()
    self:SetCooldown(WarCooldown)
    self:SetStatus(false)
    self:SetPercent(0)
    self:SetTimer(WarTimer)
    self.Owner:ChatPrint("Failed Event")
end

function ENT:SuccessfulEvent()
    self:SetStatus(false)
    self.Owner:ChatPrint("Successful Event")
end

function ENT:Use( ply )
--ply:Team() == TEAM_CITIZEN
    if ( !self:GetStatus() ) then
        self:StartEvent()
        ply:ChatPrint("Started flag event")
    end

end

function ENT:Think()

    if ( self.ThinkTime <= CurTime() ) then 
        if self:GetStatus() and self:GetTimer() > 0 then
            self:SetTimer( self:GetTimer() - 1 )
        elseif self:GetStatus() and self:GetTimer() <= 0 then
            self:FailedEvent()
        end
        if self:GetStatus() and self:GetPercent() >= 100 then
            self:SuccessfulEvent()
        end
    end
    
    self.ThinkTime = CurTime() + 1 

    if ( self.PointTimer <= CurTime() ) then 
        --local distanceSquared = self:GetPos():DistToSqr(ent2:GetPos())

        -- check how many of x team is in sqr to dist
        -- cap at 5 players each team
        -- local GetFriendly, GetEnemy = 0,0
        -- if GetFriendly >= 5 then GetFriendly = 5 end
        -- local AddPoint = GetEnemy - GetFriendly // This is adding x from enemy and taking x from friendly eg, 4 - 3 or 2-5 = -3 etc
        -- self:SetPercent( self:GetPercent() + AddPoint )
         -- check if getpercent <= 0 // if under you would need to call self:FailedEvent()   
        --if distanceSquared <= (200 * 200) then
            -- Code to execute when the squared distance is within a certain range

        --end


/*

    local GetFriendly, GetEnemy = 0, 0
    
    for _, target in pairs(ents.FindInSphere(self:GetPos(), 200)) do
        if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
            if target:IsPlayer() and target:Team() == TEAM_CITIZEN then
                GetFriendly = GetFriendly + 1
            elseif target:IsPlayer() and target:Team() == TEAM_ENEMY then
                GetEnemy = GetEnemy + 1
            elseif target:IsNPC() then
                GetEnemy = GetEnemy + 1
            end
        end
    end
    
    -- Now you have the counts of friendly and enemy players/NPCs within the distance
    print("Friendly Count:", GetFriendly)
    print("Enemy Count:", GetEnemy)
*/

        self.PointTimer = CurTime() + 5
    end
end

function ENT:OnRemove()

end


--[[
local distanceSquared = self:GetPos():DistToSqr(ent2:GetPos())
if distanceSquared <= (200 * 200) then
    local GetFriendly, GetEnemy = 0, 0
    
    local radiusSquared = 200 * 200
    for _, target in pairs(ents.FindByClass("player")) do
        if IsValid(target) then
            local targetDistanceSquared = self:GetPos():DistToSqr(target:GetPos())
            if targetDistanceSquared <= radiusSquared then
                if target:Team() == TEAM_CITIZEN then
                    GetFriendly = GetFriendly + 1
                elseif target:Team() == TEAM_ENEMY then
                    GetEnemy = GetEnemy + 1
                end
            end
        end
    end
    
    for _, target in pairs(ents.FindByClass("npc_*")) do
        if IsValid(target) then
            local targetDistanceSquared = self:GetPos():DistToSqr(target:GetPos())
            if targetDistanceSquared <= radiusSquared then
                GetEnemy = GetEnemy + 1
            end
        end
    end
    
    -- Now you have the counts of friendly and enemy players/NPCs within the distance
    print("Friendly Count:", GetFriendly)
    print("Enemy Count:", GetEnemy)
end
]]
