GM:InitGamemode(function(self,params)
	self:SetDay(0)
	self:SetDayTime(CurTime())
	self:SetRoundTime(CurTime() + self.Daytime * self.Days)
	SetGMNil("JB_FDTime")
	self:SetTeams(TEAM_DEFENDER,TEAM_ATTACKER)
	self:ResetFD()
	SetGMBool("JB_Box",false)
	self:Timer("GAMEMODERESERVE1", 90, 1, function()
		GlobalMsg(_T("HS_NotHidden", colour_info, CServ(), colour_info))
		for _,v in pairs(team.GetPlayers(TEAM_DEFENDER)) do
			v:SetNoDraw(false)
			v:GodDisable()
		end
	end)
	for _,v in pairs(team.GetPlayers(TEAM_DEFENDER)) do
		v:SetNoDraw(true)
		v:GodEnable()
	end
	GlobalMsg(_T("HS_Begin", colour_message))
	GlobalMsg(_T("HS_Godmode", CServ(), colour_info))
	if not self.Opened then
		self:JBRun("opencells",NULL,true)
	end
	GlobalMsg(_T("HS_Gamemode", colour_info, 90, colour_info))
end)
GM.HookGamemode("PlayerKilledByPlayer",function(ply,inf,atk)
	if atk:Team() == TEAM_ATTACKER and GAMEMODE:GetRound() == Round_In then
		return true, ply:Nick(), "weapon_stunstick", atk:Nick(), _T("HS_Catch",atk:CNick(),colour_notify,ply:CNick(),colour_notify)
	end
end)
GM.HookGamemode("PlayerDamagePlayer",function(victim,pl)
	if victim:Team() == TEAM_ATTACKER then
		return false
	end
end)
GM.HookGamemode("PlayerCanEquipWeapon",function(ply,wep)
	if ply:Team() == TEAM_DEFENDER then
		return false
	end
end)
GM.HookGamemode("CountPlayers",function(cts,ts)
	local b,dat,def = CustomCountPlayers()
	if b then
		if dat then
			GAMEMODE:SetRound(Round_End, round_winhider)
		elseif def then
			GAMEMODE:SetRound(Round_End, round_winseeker)
		end
	end
	return false,TEAM_ATTACKER,TEAM_DEFENDER
end)