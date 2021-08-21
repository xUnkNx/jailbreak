function GM:ResetGMode()
	for _, v in pairs(player.GetAll()) do
		local tm = v:Team()
		if tm == TEAM_ATTACKER or tm == TEAM_DEFENDER then
			v:SetTeam(v.GMTeam or TEAM_PRISIONER)
			v.GMTeam = nil
			if v:Alive() then
				v:KillSilent()
			end
			v:Spawn()
		end
	end
	self:CheckPlayState()
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
function CustomCountPlayers()
	if not GAMEMODE:TimerExists("GAMEMODERESERVE1") then
		local dzm,dhm = true,true
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_ATTACKER then
				if dzm and v:Alive() then
					dzm = false
					continue
				end
			elseif v:Team() == TEAM_DEFENDER then
				if dhm and v:Alive() then
					dhm = false
					continue
				end
			end
			if not dzm and not dhm then
				break
			end
		end
		if dzm and dhm then
			GAMEMODE:SetRound(Round_End, round_noone)
			return false
		end
		return true,dzm,dhm
	end
	return false
end
function GM:GiveRandomWeapons()
end