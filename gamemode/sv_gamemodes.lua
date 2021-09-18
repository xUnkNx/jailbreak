function GM:ResetGMode()
	for _, v in pairs(player.GetAll()) do
		local tm = v:Team()
		if tm == TEAM_ATTACKER or tm == TEAM_DEFENDER then
			v:SetTeam(v.GMTeam or TEAM_PRISIONER)
			v.GMTeam = nil
		end
		if tm ~= TEAM_SPECTATOR then
			v:Freeze(false)
			if v:Alive() then
				v:KillSilent()
			end
			v:UnSpectate()
			v:Spawn()
		end
	end
end
function GM:StartGameMode( name, spawnall )
	if self:GetRound() ~= Round_In then return false end
	if self.SpecDays[name] == nil then
		return false
	end
	local cnt = 0
	if spawnall then
		for _,t in pairs(player.GetAll()) do
			if t:Team() ~= TEAM_SPECTATOR and not t:Alive() then
				t:Spawn()
			end
		end
	end
	for _,t in pairs(player.GetAll()) do
		if t:Alive() and t:Team() ~= TEAM_SPECTATOR then
			cnt = cnt + 1
		end
	end
	if cnt <= 3 then
		return false, _T("NotEnoughtPlayers")
	end
	self:SetGamemode(name)
	return true
end
function GM:SetTeams(t1,t2) -- TODO: Its gamemodes function
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_PRISIONER then
			v.GMTeam = TEAM_PRISIONER
			v:SetTeam(t1)
		elseif v:Team() == TEAM_GUARD then
			v.GMTeam = TEAM_GUARD
			v:SetTeam(t2)
		end
	end
	self:CheckPlayState()
end
function CustomCountPlayers(tm1, tm2)
	local t1, t2 = false, false
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			if v:Team() == tm1 then
				t1 = true
				if t2 then
					break
				end
			elseif v:Team() == tm2 then
				t2 = true
				if t1 then
					break
				end
			end
		end
	end
	return t1, t2
end
function GM:GiveRandomWeapons()
end