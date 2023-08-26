
if not GAMEMODE then
	hook.Remove("Initialize", "schat_init")
	hook.Add("Initialize", "schat_init", function()
		include("autorun/server/sv_chat.lua")
	end)
	return
end




