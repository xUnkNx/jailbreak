GM:InitGamemode(function(self,params)
	ClearGlobals()
	self:ResetGMode()
	game.SetTimeScale(1)
	self:ResetTimers()
	self:JBRun("opencells",NULL,true)
	GlobalMsg(_T("PVPReason", colour_message))
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
		v:Fire("SetDamage",0)
		v:Fire("Disable")
	end
	SetGMBool("JB_Bhop",true)
end)
GM.HookGamemode("PlayerLoadout",function(ply)
	ply:Give( "weapon_fist" )
	ply:SelectWeapon( "weapon_fist")
	ply:SetAvoidPlayers(false)
	ply:AllowFlashlight(true)
end)
GM.HookGamemode("AcceptInput",function(ent,inp)
	if GAMEMODE.JailTriggers and GAMEMODE.JailTriggers[ent:GetName()] and (inp == "Close" or inp == "Enable" or inp == "Toggle") then
		return true
	elseif ent:GetClass() == "trigger_hurt" then
		return true
	end
end)
GM.HookGamemode("PlayerCanSpawn",function()
	return true
end)
GM.HookGamemode("OnTimeout",function()
	GAMEMODE:SetRound(Round_Wait)
	ClearGlobals()
	GAMEMODE:ResetTimers()
	game.SetTimeScale(1)
	return true
end)