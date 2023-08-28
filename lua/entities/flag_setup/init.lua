AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local prompts = {
    "You are a messenger of a kingdom. The kingdom you are a part of just won a war against another faction. You are the messenger that delivers the message to the people that the war was won and that the enemy was defeated. You are excited and yell the message out. You should also speak of the great actions of our warriors and praise the king. The message should not be longer than 50 words and no shorter than 40 words. Along with that, the text should not take up more than 254 bytes of data.",
    "You are a messenger of a kingdom The kingdom you are a part of just lost a war against another faction. You are delivering the message of your kingdom's defeat to the people in a sad tone. You need to talk about the defeat of our king and his army of warriors. The message should not be longer than 50 words and no shorter than 40. Along with that, the text should not take up more than 254 bytes of data.",
    "",
    "",
}

local WarTimer = 900 -- 15 min?
local WarCooldown = 1200 -- 20 min?

local teamsToCheck = {
    TEAM_TEAM1,
    TEAM_TEAM2,
    TEAM_TEAM3,
    -- Add more teams as needed
}

function chatGPTRequest(content, temperature)
    local apiKey = "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"  -- Replace with your actual API key
    local apiUrl = "https://api.openai.com/v1/chat/completions"

    local headers = {
        Authorization = "Bearer " .. apiKey,
        ContentType = "application/json"
    }

    local jsonData = {
        model = "gpt-3.5-turbo",  -- Include the "model" parameter here
        messages = {
            { role = "user", content = content }
        },
        temperature = temperature
    }

    local postData = util.TableToJSON(jsonData)
    print(postData)
    HTTP({
        method = "POST",
        url = apiUrl,
        headers = headers,
        body = postData,
        type = "application/json",
        timeout = 60,
        success = function(code, body, headers)
            print("API Response Code: " .. code)
            print("API Response Body: " .. body)

            local jsonResponse = util.JSONToTable(body)
            if jsonResponse and jsonResponse.choices then
                local assistantResponse = jsonResponse.choices[1].message.content
                PrintMessage(HUD_PRINTTALK, assistantResponse)
            end
        end,
        failed = function(error)
            print("API Request Failed: " .. error)
        end
    })
end    

function ENT:Initialize()
   -- constraint.Keepupright( self, self:GetAngles(), 0, 999999 )
	self:SetModel("models/props_c17/signpole001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:SetPersistent(true)
   
    physobj = self:GetPhysicsObject()
    if IsValid(physobj) then
        physobj:SetMass(150)
    end

    self:SetPercent(10)
    self:SetStatus(false)
    self:SetTimer(WarTimer)
    self:SetCooldown(0)
    self.ThinkTime = 1
    self.PointTimer = 0.5
    self.AbandonedTicks = 0
    self.TimeEvent = CurTime() - WarCooldown
end

function ENT:StartEvent()
    self.AbandonedTicks = 0
    self:SetStatus(true)
end

function ENT:EndEvent()
    self:SetCooldown(WarCooldown)
    self:SetStatus(false)
    self:SetPercent(10)
    self:SetTimer(WarTimer)
    self.AbandonedTicks = 0
    self.TimeEvent = CurTime()
    self.Owner:ChatPrint("Event Over")    
end

function ENT:FailedEvent()
    self:SetCooldown(WarCooldown)
    self:SetStatus(false)
    self:SetPercent(10)
    self:SetTimer(WarTimer)
    self.AbandonedTicks = 0
    self.TimeEvent = CurTime()
    PrintMessage(HUD_PRINTTALK, "Failed Event")
    chatGPTRequest(prompts[1], 1)
end


function ENT:SuccessfulEvent()
    --ambient/alarms/warningbell1.wav
    self:SetCooldown(WarCooldown)
    self:SetStatus(false)
    self:SetPercent(10)
    self.TimeEvent = CurTime()
    self.AbandonedTicks = 0
    self:SetTimer(WarTimer)
    PrintMessage(HUD_PRINTTALK, "Successful Event")
    chatGPTRequest(prompts[2], 1)
end

function ENT:Use(ply)
    if !self:GetStatus() and CurTime() >= self.TimeEvent + self:GetCooldown() then
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
        if self:GetStatus() and self:GetPercent() <= 0 then     
            self:FailedEvent()
        end
        if self:GetStatus() and self:GetPercent() >= 100 then
            self:SuccessfulEvent()
        end
        --if self.AbandonedTicks >= 30 then
            --self:FailedEvent()
        --end
        self.ThinkTime = CurTime() + 1 
    end

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
                if GetEnemy > 5 then
                    GetEnemy = 5
                end
                if GetFriendly > 5 then
                    GetFriendly = 5
                end
                --if GetEnemy == 0 then
                    --self.AbandonedTicks = self.AbandonedTicks + 1
                --else
                    --self.AbandonedTicks = 0
                --end
                local AddPoint = GetEnemy - GetFriendly
                self:SetPercent(self:GetPercent() + AddPoint)
                PrintMessage(HUD_PRINTTALK, "---------------------")
                PrintMessage(HUD_PRINTTALK, "Percentage: " .. self:GetPercent())
                PrintMessage(HUD_PRINTTALK, "Friendly Count: " .. GetFriendly)
                PrintMessage(HUD_PRINTTALK, "Enemy Count: " .. GetEnemy)

                self.PointTimer = CurTime() + 0.5
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
