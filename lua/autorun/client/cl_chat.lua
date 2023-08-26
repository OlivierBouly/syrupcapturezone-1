-- Syrup CaptureZone-1
-- Author : Maple_Guy
--Capture zone that changes a global variable when the counter is done.
--Started on : 2023-08-26

if SERVER then
    return
end

if not GAMEMODE then
    hook.Remove("Initialize", "sChat_init")
    hook.Add("Initialize", "sChat_init", function()
        include("autorun/client/cl_chat.lua")
    end)
    return
end

