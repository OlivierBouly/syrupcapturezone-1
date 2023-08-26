AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

PrintTable( team.GetAllTeams() )

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
        if self:GetStatus() then
            local distanceSquared = self:GetPos():DistToSqr(self:GetPos())
            if distanceSquared <= (200 * 200) then
                local GetFriendly, GetEnemy = 0, 0
                
                local radiusSquared = 200 * 200
                for _, target in pairs(ents.FindByClass("player")) do
                    if IsValid(target) then
                        local targetDistanceSquared = self:GetPos():DistToSqr(target:GetPos())
                        if targetDistanceSquared <= radiusSquared then
                            if target:Team() == TEAM_UNASSIGNED then
                                GetFriendly = GetFriendly + 1
                            elseif target:Team() == TEAM_ENEMY then
                                GetEnemy = GetEnemy + 1
                            end
                        end
                    end
                end
                --for testing
                for _, target in pairs(ents.FindByClass("npc_*")) do
                    if IsValid(target) then
                        local targetDistanceSquared = self:GetPos():DistToSqr(target:GetPos())
                        if targetDistanceSquared <= radiusSquared then
                            GetEnemy = GetEnemy + 1
                        end
                    end
                end
            
            local AddPoint = GetEnemy - GetFriendly
            self:SetPercent(self:GetPercent() + AddPoint)
            PrintMessage(HUD_PRINTTALK, "---------------------")
            PrintMessage(HUD_PRINTTALK, "Percentage: " .. self:GetPercent())
            PrintMessage(HUD_PRINTTALK, "Friendly Count: " .. GetFriendly)
            PrintMessage(HUD_PRINTTALK, "Enemy Count: " .. GetEnemy)

            self.PointTimer = CurTime() + 5
        end
    end
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
