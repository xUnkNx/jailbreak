GM:InitGamemode(function(self,params)
	self:SetDay(0)
	self:SetDayTime(CurTime())
	self:SetRoundTime(CurTime() + self.Daytime * (self.Days - 1))
	SetGMNil("JB_FDTime")
	--self:SetTeams(TEAM_ATTACKER,TEAM_DEFENDER)
	self:Timer("GAMEMODERESERVE1", self.Daytime * self.Days * 0.5, 1, function()
		GlobalMsg(_T("DF_Cleaning", colour_info))
	end)
	SetGMBool("JB_Box",false)
	self:ResetFD()
	self:Timer("GAMEMODERESERVE2", 60, 1, function()
		GlobalMsg(_T("DF_Begins", colour_info))
		for _,v in pairs(team.GetPlayers(TEAM_GUARD)) do
			v:SetNoDraw(false)
			v:GodDisable()
		end
		if not self.Opened then
			self:JBRun("opencells",NULL,true)
		end
		GlobalMsg(_T("DF_Ungodmode", CServ(), colour_info))
	end)
	for _,v in pairs(team.GetPlayers(TEAM_GUARD)) do
		v:SetArmor(150)
		v:SetMaxHealth(150)
		v:SetHealth(150)
		v:SetNoDraw(true)
		v:GodEnable()
	end
	GlobalMsg(_T("DF_Gamemode", colour_message, colour_info, 60, colour_message, colour_notify, colour_info, CServ(), colour_message))
	GlobalMsg(_T("DF_Godmode", CServ(), colour_info))
end)
--[[GM.HookGamemode("CountPlayers",function()
	local b,dat,def = CustomCountPlayers()
	if b then
		if dat then
			GAMEMODE:SetRound(Round_End, round_winguards)
		elseif def then
			GAMEMODE:SetRound(Round_End, round_winassault)
		end
	end
	return false,TEAM_ATTACKER,TEAM_DEFENDER
end)]]