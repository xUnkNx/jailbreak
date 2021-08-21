local TeamColors = {
	[1] = {"red", Vector(1, 0, 0), _T("Red")},
	[2] = {"blue", Vector(0, 0, 1), _T("Blue")},
	[3] = {"yellow", Vector(1, 1, 0), _T("Yellow")},
	[4] = {"green", Vector(0, 1, 1), _T("Green")}
}
GM:InitGamemode(function(self, params)
	ClearGlobals()
	self:ResetFD()
	self:ResetTimers()
	self:SetDay(0)
	self:SetDayTime(CurTime())
	self:SetRoundTime(CurTime() + self.Daytime * self.Days)
	self:SetTeams(TEAM_ATTACKER, TEAM_ATTACKER)
	local teams, teamc, colortab = math.Clamp(math.ceil(#team.GetPlayers(TEAM_ATTACKER) / 4), 2, 4), 1, {}
	GlobalMsg(_T("TW_Begin", colour_message))
	GlobalMsg(_T("TW_NotifyGodmode", CServ(), colour_info, 60))
	if not self.Opened then
		self:JBRun("opencells", NULL, true)
	end
	GlobalMsg(_T("TW_NotifyGamemode", colour_info))
	self:Timer("GAMEMODERESERVE1", 60, 1, function()
		GlobalMsg(_T("TW_WarBegins", colour_info))
		for k, v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
			v:GodDisable()
		end
	end)
	for k, v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		v:GodEnable()
		v:SetHealth(100)
		v:SetArmor(65)
	end
	for i = 1, teams do
		colortab[TeamColors[i][1]] = {}
	end
	for w, x in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		table.insert(colortab[TeamColors[teamc][1]], x:Nick())
		x:SetPlayerColor(TeamColors[teamc][2])
		x:SetGM("SplitTeam", TeamColors[teamc][1])
		PInfoMsg(x, "info", _T("TW_TeamColor", colour_black, TeamColors[teamc][2]:ToColor(), TeamColors[teamc][3]))
		LocalMsg(x, _T("TW_TeamColor", colour_notify, TeamColors[teamc][2]:ToColor(), TeamColors[teamc][3]))
		teamc = teamc + 1
		if teamc > teams then
			teamc = 1
		end
	end
	for k, v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		local z = colortab[v:GetGM("SplitTeam")]
		LocalMsg(v, _T("TW_Teammates", colour_message, colour_info, table.concat(z, ", ")))
	end
end)
GM.HookGamemode("CountPlayers", function()
	local win
	for k, ply in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		if ply:Alive() then
			if win then
				if win ~= ply:GetGM("SplitTeam") then
					win = false
					break
				end
			else
				win = ply:GetGM("SplitTeam")
			end
		end
	end
	if win then
		GAMEMODE:SetRound(Round_End, round_battleend)
	end
	return false, TEAM_ATTACKER, TEAM_ATTACKER
end)
GM.HookGamemode("PlayerDamagePlayer", function(inf, atk)
	return inf == atk or inf:GetGM("SplitTeam") ~= atk:GetGM("SplitTeam")
end)