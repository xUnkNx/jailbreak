GM:InitGamemode(function(self,params)
	self:SetRoundTime(CurTime() + (2 + math.ceil(team.GetCount(TEAM_PRISIONER) / 5)) * self.DayTime + self.RoundPrepare)
	self:ResetTimers()
	self:ResetFD()
	ClearGlobals()
	self:SetTeams(TEAM_DEFENDER,TEAM_ATTACKER)
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
	if pl:Team() == TEAM_ATTACKER and victim:Team() == TEAM_DEFENDER then
		return true
	end
	return false
end)
GM.HookGamemode("PlayerCanEquipWeapon",function(ply,wep)
	if ply:Team() == TEAM_DEFENDER then
		return false
	end
end)
GM.HookGamemode("CountPlayers",function(cts,ts)
	local atk, def = CustomCountPlayers(TEAM_DEFENDER, TEAM_ATTACKER)
	if atk then
		if not def then
			GAMEMODE:SetRound(Round_End, round_winhider)
		end
	else
		if def then
			GAMEMODE:SetRound(Round_End, round_winseeker)
		else
			GAMEMODE:SetRound(Round_End, round_alldead)
		end
	end
	return true
end)