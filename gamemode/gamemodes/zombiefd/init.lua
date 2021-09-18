--==ZFD==--
local function MakeZombie(ply,inf)
	local pos, ang = ply:GetPos(), ply:GetAngles()
	ply:SetGM("IsZombie",true)
	if inf then
		ply:TakeDamage(ply:Health() * 10, inf, inf:GetActiveWeapon())
	else
		ply:Kill()
	end
	GAMEMODE:TimerSimple(0,function()
		ply:Spawn()
		ply:SetPos(pos)
		if ang then
			ply:SetAngles(ang)
		end
	end)
end
local function FindZombie()
	local zombie
	for k,v in RandomPairs(player.GetAll()) do
		if v:Alive() and v:Team() == TEAM_DEFENDER then
			zombie = v
			break
		end
	end
	if IsValid(zombie) then
		MakeZombie(zombie)
		GlobalMsg(_T("ZFD_FirstZombie", zombie:CNick(), colour_info))
	else
		GAMEMODE:SetGamemode("Normal")
		GlobalMsg(_T("ZFD_ZombieNotFound", colour_info))
	end
end
GM:InitGamemode(function(self,params)
	self:SetRoundTime(CurTime() + self.DayTime * 4)
	self:ResetTimers()
	self:ResetFD()
	ClearGlobals()
	self:SetTeams(TEAM_DEFENDER,TEAM_DEFENDER)
	for k,v in pairs(team.GetPlayers(TEAM_DEFENDER)) do
		self:SetForceVisible(v, true) -- zombies should see anyone
	end
	self:Timer("GAMEMODERESERVE1", 30, 1, function()
		FindZombie(self)
		SetGMInt("Wave",1)
		GlobalMsg(_T("ZFD_Wave", colour_info, 1))
		PlaySurfaceSound("ambient/creatures/town_zombie_call1.wav")
		self:Timer("GAMEMODERESERVE2", self.DayTime, 2, function()
			SetGMInt("Wave",GetGMInt("Wave") + 1)
			if self.Wave == 3 then
				GlobalMsg(_T("ZFD_FinalWave", colour_info))
			else
				GlobalMsg(_T("ZFD_Wave", colour_info, GetGMInt("Wave"), colour_info))
			end
		end)
	end)
	GlobalMsg(_T("ZFD_Begin", colour_message))
	if not self.Opened then
		self:JBRun("opencells",NULL,true)
	end
	GlobalMsg(_T("ZFD_Desc",colour_info, 30))
	--[[self:Timer("GAMEMODERESERVE3", 5, 0, function()
		for k,v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
			if not v:Alive() then
				v:Spawn()
			end
		end
	end)]]
end)
GM.HookGamemode("PlayerKilledByPlayer",function(ply,inf,atk)
	if atk:Team() == TEAM_ATTACKER and GAMEMODE:GetRound() == Round_In then
		return true, ply:Nick(), "weapon_zombiefist", atk:Nick(), _T("ZFD_Infect",atk:CNick(), ply:Nick())
	end
end)
GM.HookGamemode("DoPlayerDeath",function(ply,atk,dbd)
	if ply:Team() == TEAM_DEFENDER then
		ply:SetTeam(TEAM_ATTACKER)
	end
	if ply:Team() == TEAM_ATTACKER then
		ply:EmitSound("npc/zombie/zombie_die" .. math.random(1,3) .. ".wav",180,100)
		GAMEMODE:TimerSimple(0,function()
			ply:SetGM("NextSpawnTime",CurTime() + 10)
		end)
	end
end)
GM.HookGamemode("PlayerDisconnected",function(ply)
	local cts,ts
	for _,v in pairs(player.GetAll()) do
		if v ~= ply then
			if v:Team() == TEAM_ATTACKER then
				ts = true
			elseif v:Team() == TEAM_DEFENDER then
				cts = true
			end
		end
	end
	if not ts then
		FindZombie()
		return true
	elseif not cts then
		return false -- let countplayer handle it
	end
end)
local LastPly = {"music/hl1_song10.mp3","music/hl1_song14.mp3","music/hl1_song15.mp3",
"music/hl1_song19.mp3","music/hl1_song20.mp3","music/hl1_song24.mp3",
"music/hl2_song23_suitsong3.mp3","music/hl2_song20_submix4.mp3",
"music/hl2_song25_teleporter.mp3","music/hl2_song16.mp3"}
GM.HookGamemode("GetFallDamage",function(ply)
	if ply:Team() == TEAM_ATTACKER then return 0 end
end)
GM.HookGamemode("PlayerLoadout",function(ply)
	if ply:Team() == TEAM_ATTACKER then
		local typ,wave = math.random(1,3),GetGMInt("Wave",1)
		ply:SetWalkSpeed(350)
		ply:SetRunSpeed(ply:GetWalkSpeed() * 1.2)
		ply:SetCrouchedWalkSpeed(0.6)
		ply:SetMaxHealth(300)
		if typ == 1 then
			ply:SetModel("models/player/zombie_classic.mdl")
			ply:SetCrouchedWalkSpeed(0.4)
			ply:SetMaxHealth(150 + wave * 50) -- 300
			ply:SetWalkSpeed(300 + wave * 15) -- 345
			ply:SetJumpPower(210 + wave * 7.5) -- 235.5
		elseif typ == 2 then
			ply:SetModel("models/player/zombie_fast.mdl")
			ply:SetCrouchedWalkSpeed(0.5)
			ply:SetMaxHealth(100 + wave * 33.33) -- 200
			ply:SetWalkSpeed(315 + wave * 15) -- 360
			ply:SetJumpPower(210 + wave * 15) -- 255
		elseif typ == 3 then
			ply:SetModel("models/player/zombie_soldier.mdl")
			ply:SetCrouchedWalkSpeed(0.3)
			ply:SetMaxHealth(300 + wave * 33.33) -- 400
			ply:SetWalkSpeed(285 + wave * 15) -- 330
			ply:SetJumpPower(180 + wave * 10) -- 210
		end
		ply:SetGM("OriginalModel",ply:GetModel())
		ply:SetNoCollideWithTeammates(true)
		ply:SetAvoidPlayers(true)
		ply:SetRunSpeed(ply:GetWalkSpeed())
		ply:SetHealth(ply:GetMaxHealth())
		ply:SetPlayerColor(Vector(1,1,1))
		ply:Give("weapon_zombiefist")
		ply:AllowFlashlight(false)
		ply:SelectWeapon( "weapon_zombiefist")
		ply:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1,14) .. ".wav")
	else
		ply:Give( "weapon_fist" )
		ply:SelectWeapon( "weapon_fist")
		ply:SetAvoidPlayers(false)
	end
	ply:SetupHands()
	return true
end)
GM.HookGamemode("PlayerDamagePlayer",function(vict,atk)
	if vict:Team() == TEAM_DEFENDER and atk:Team() == TEAM_ATTACKER then
		if GetGMEntity("ZFD_LastSurvivorP") == vict or math.random(1,2) == 1 then return true end
		if vict == atk then return true end
		if vict:GetGM("IsZombie") == nil then
			MakeZombie(vict,atk)
		end
		return true
	end
	return atk:Team() ~= vict:Team() or atk == vict
end)
GM.HookGamemode("EntityTakeDamage",function(vict,dmg)
	if vict:IsPlayer() and vict:Team() == TEAM_ATTACKER then
		local atk = dmg:GetAttacker()
		if IsValid(atk) and atk:IsPlayer() and atk:Team() == TEAM_DEFENDER then
			local dist = atk:GetPos():DistToSqr(vict:GetPos())
			if dist > 250000 then
				dmg:SetDamage( dmg:GetDamage() * math.Clamp(250000 / dist, 0.25, 1))
			end
		end
		if math.random(1,3) == 1 and dmg:GetDamage() > 10 then
			vict:EmitSound("npc/zombie/zombie_pain" .. math.random(1,6) .. ".wav")
		end
		local vel,px,py = vict:GetVelocity()
		px = vel.x * math.Rand(0.3,0.7)
		py = vel.y * math.Rand(0.3,0.7)
		vict:SetVelocity(Vector(-px,-py,0))
	end
end)
GM.HookGamemode("PlayerCanEquipWeapon",function(ply,wep)
	if ply:Team() == TEAM_ATTACKER and wep:GetClass() ~= "weapon_zombiefist" then return false end
end)
GM.HookGamemode("PlayerUse",function(ply,ent)
	if ply:Team() == TEAM_ATTACKER then
		return false
	end
end)
GM.HookGamemode("WeaponEquip",function(wep, ply)
	if not wep.AlreadyInf then
		wep.AlreadyInf = true
		if wep:GetMaxClip1() > 5 then
			local count = math.min(wep:GetMaxClip1() * 20, 999)
			ply:GiveAmmo(count, game.GetAmmoName(wep:GetPrimaryAmmoType()))
		end
	end
end)
GM.HookGamemode("PlayerDroppedWeapon",function(ply, wep)
	if wep.AlreadyInf then
		wep.AlreadyInf = nil
		if wep:GetMaxClip1() > 5 then
			local atype = game.GetAmmoName(wep:GetPrimaryAmmoType())
			local count = ply:GetAmmoCount(atype)
			ply:RemoveAmmo(count, atype)
		end
	end
end)
GM.HookGamemode("OnTimeout",function()
	if not GetGMBool("Ended") then
		PlaySurfaceSound("ambient/atmosphere/city_beacon_loop1.wav")
		GAMEMODE:TimerSimple(4, function()
			PlaySurfaceSound("ambient/atmosphere/city_rumble_loop1.wav")
		end)
		GAMEMODE:TimerSimple(4.5, function()
			GAMEMODE:SetRound(Round_End, round_winhuman)
			for _, v in pairs(team.GetPlayers(TEAM_ATTACKER)) do
				if v:Alive() then
					v:Kill()
				end
				v:SetTeam(v.GMTeam or TEAM_PRISIONER)
				v.GMTeam = nil
			end
		end)
		GAMEMODE:TimerSimple(5, function()
			GAMEMODE:SetRound(Round_End, round_winhuman)
			GAMEMODE:SetRoundTime(CurTime() + math.random(5,15))
		end)
		SetGMBool("Ended", true)
	end
	return true
end)
local WinZombie = {"ambient/levels/citadel/weaponstrip1_adpcm.wav","ambient/levels/citadel/citadel_ambient_voices1.wav","ambient/levels/citadel/citadel_ambient_scream_loop1.wav","ambient/levels/citadel/citadel_drone_loop3.wav",
"ambient/levels/citadel/citadel_drone_loop5.wav"}
GM.HookGamemode("CountPlayers",function()
	local a1, z1 = 0, 0
	for k,v in pairs(player.GetAll()) do
		local tm = v:Team()
		if tm == TEAM_DEFENDER and v:Alive() then
			a1 = a1 + 1
		elseif tm == TEAM_ATTACKER then
			z1 = z1 + 1
		elseif tm ~= TEAM_SPECTATOR then
			v:SetTeam(TEAM_ATTACKER) -- force joined players to be zombies
		end
	end
	if a1 == 0 then
		if z1 > 0 then
			PlaySurfaceSound(GAMEMODE:TableRandom(WinZombie))
			GAMEMODE:SetRound(Round_End, round_winzombie)
		else
			GAMEMODE:SetRound(Round_End, round_alldead)
		end
	elseif a1 == 1 then
		local surv = team.GetAlive(TEAM_DEFENDER)[1]
		if GetGMEntity("ZFD_LastSurvivorP") == nil and IsValid(surv) and surv:Alive() then
			SetGMEntity("ZFD_LastSurvivorP", surv)
			surv:StripWeapons()
			surv:Give("weapon_fist")
			surv:Give("weapon_deagle_ultra")
			surv:Give("weapon_ultimax")
			surv:SetWalkSpeed(300)
			surv:SetRunSpeed(300)
			surv:SetMaxHealth(150)
			surv:SetHealth(150)
			surv:SetJumpPower(225)
			InfoMsg("add",_T("ZFD_NotifyLastSurvivor"))
			GlobalMsg(_T("ZFD_LastSurvivor", surv:CNick(), colour_notify))
			PlaySurfaceSound(GAMEMODE:TableRandom(LastPly))
		end
	end
	return true
end)
GM.HookGamemode("PlayerCanSpawn",function(ply)
	return ply:Team() == TEAM_ATTACKER
end)
GM.HookGamemode("CanPlayerSuicide",function(ply)
	if ply:Alive() and (ply:Team() == TEAM_DEFENDER or ply:Team() == TEAM_ATTACKER) then
		return true
	end
	return false
end)