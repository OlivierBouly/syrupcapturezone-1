ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Flag System"
ENT.Author = "Maple"
ENT.Category = "Elder Scrolls Kingdom"
ENT.Spawnable = true
ENT.AdminSpawnable = false
 
function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "Percent")
	self:NetworkVar("Int", 1, "Timer")
	self:NetworkVar("Int", 2, "Cooldown")
	self:NetworkVar("Bool", 0, "Status")

end
