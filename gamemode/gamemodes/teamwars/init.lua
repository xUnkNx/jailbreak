GM:InitGamemode(function(self, params)
	self:SetRoundTime(CurTime() + self.DayTime * self.Days)
	self:ResetTimers()
	self:ResetFD()
	ClearGlobals()
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
	local cteams = {}
	for i = 1, teams do
		colortab[i] = {}
		table.insert(cteams, { params.TeamColors[i][2]:ToColor(), params.TeamColors[i][3]})
		table.insert(cteams, ", ")
	end
	table.remove(cteams)
	GlobalMsg( _T("TW_TeamsToday", colour_notify), cteams )
	for w, x in RandomPairs(team.GetPlayers(TEAM_ATTACKER)) do
		table.insert(colortab[teamc], x:Nick())
		x:SetPlayerColor(params.TeamColors[teamc][2])
		x:SetNW("SplitTeam", teamc)
		PInfoMsg(x, "info", _T("TW_TeamColor", colour_black, params.TeamColors[teamc][2]:ToColor(), params.TeamColors[teamc][3]))
		LocalMsg(x, _T("TW_TeamColor", colour_notify, params.TeamColors[teamc][2]:ToColor(), params.TeamColors[teamc][3]))
		teamc = teamc + 1
		if teamc > teams then
			teamc = 1
		end
	end
	for i,j in pairs(colortab) do
		colortab[i] = table.concat(j, ", ")
	end
	for k, v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		local clr = v:GetNW("SplitTeam")
		LocalMsg(v, _T("TW_Teammates", colour_message, params.TeamColors[clr][2]:ToColor(), colortab[clr]))
	end
end)
GM.HookGamemode("CountPlayers", function()
	local win
	for k, ply in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		if ply:Alive() then
			if win then
				if win ~= ply:GetNW("SplitTeam") then
					win = false
					break
				end
			else
				win = ply:GetNW("SplitTeam")
			end
		end
	end
	if win then
		local winners = {}
		for k,v in pairs(player.GetAll()) do
			if v:GetNW("SplitTeam") == win then
				table.insert(winners, v)
			end
		end
		local tcol = GAMEMODE:GetSpecGM().TeamColors[win]
		GAMEMODE:SetRound(Round_End, round_battleend, winners, tcol and tcol[3])
		GlobalMsg(_T("TW_TeamWin", colour_notify, tcol[2]:ToColor(), tcol[3]))
	end
	return true
end)
GM.HookGamemode("OnTimeout",function()
	local gm = GAMEMODE:GetSpecGM()
	local tms,tcnt = {},#gm.TeamColors
	for i = 1, tcnt do
		tms[i] = 0
	end
	for k,v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		if v:Alive() then
			local tm = v:GetNW("SplitTeam")
			tms[tm] = tms[tm] + 1
		end
	end
	InsertionSort(tms)
	local top, winners = tms[1], {1}
	for i = 2, tcnt do
		if tms[i] == top then
			table.insert(winners, i)
		end
	end
	if #winners == 1 then
		local tcol = gm.TeamColors[winners[1]]
		GlobalMsg(_T("TW_TeamWin", colour_notify, tcol[2]:ToColor(), tcol[3]))
	else
		local tab = {}
		for i = 1, #winners do
			local tcol = gm.TeamColors[winners[i]]
			table.insert(tab, tcol[2]:ToColor() )
			table.insert(tab, tcol[3] )
			table.insert(tab, ", ")
		end
		table.remove(tab)
		GlobalMsg(_T("TW_TeamWinners", colour_notify), tab)
	end
end)
GM.HookGamemode("PlayerDamagePlayer", function(inf, atk)
	return inf == atk or inf:GetNW("SplitTeam") ~= atk:GetNW("SplitTeam")
end)
GM.HookGamemode("PlayerDeath", function(ply)
	local color, count = ply:GetNW("SplitTeam"), 0
	for k,v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
		if v ~= ply and v:Alive() and v:GetNW("SplitTeam") == color then
			count = count + 1
		end
	end
	local gm = GAMEMODE:GetSpecGM()
	GlobalMsg(_T("TW_TeamAlive", colour_notify,
		{gm.TeamColors[color][2]:ToColor(), gm.TeamColors[color][3]}, colour_notify, count) )
end)