GM:InitGamemode(function(self,params)
	self:SetRoundTime(CurTime() + self.DayTime * (self.Days - 1))
	self:ResetFD()
	--self:SetTeams(TEAM_ATTACKER,TEAM_DEFENDER)
	self:Timer("GAMEMODERESERVE1", self.DayTime * self.Days * 0.5, 1, function()
		GlobalMsg(_T("DF_Cleaning", colour_info))
	end)
	SetGMBool("JB_Box",false)
	self:Timer("GAMEMODERESERVE2", 60, 1, function()
		GlobalMsg(_T("DF_Begins", colour_info))
		for _,v in pairs(player.GetAll()) do
			if v:Alive() then
				v:SetNoDraw(false)
				v:GodDisable()
			end
		end
		if not self.Opened then
			self:JBRun("opencells",NULL,true)
		end
		GlobalMsg(_T("DF_Ungodmode", CServ(), colour_info))
	end)
	for _,v in pairs(team.GetAlive(TEAM_GUARD)) do
		v:SetArmor(150)
		v:SetMaxHealth(150)
		v:SetHealth(150)
		v:SetNoDraw(true)
		v:GodEnable()
	end
	for _,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
		v:GodEnable()
	end
	GlobalMsg(_T("DF_Gamemode", colour_message, colour_info, 60, colour_message, colour_notify, colour_info, CServ(), colour_message))
	GlobalMsg(_T("DF_Godmode", CServ(), colour_info))
end)