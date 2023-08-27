include("shared.lua")

function ENT:Draw()
	self:DrawModel()	
end

local debugMode = true
hook.Add("PostDrawTranslucentRenderables", "DrawWeaponShape", function()
    if CLIENT and debugMode then

        debugoverlay.Line(startPos, endPos, 5, Color(255, 0, 0), false)
        local boneIndex = LocalPlayer():LookupBone("ValveBiped.Bip01_R_Hand") -- Get the index of the hand bone in the view model
        local endPos = startPos + offset  -- Adjust the end position
        -- Get a list of all props and draw a marker on screen for each prop
        render.SetColorMaterial()
        render.DrawSphere(endPos, 2, 100, 100, Color(255, 255, 255, 255))
    end
end)