local gm = GM:InitGamemode(function(self,params)
	self:SetDay(0)
	self:SetDayTime(CurTime())
	self:ResetGMode()
	for k,ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply:IsPlayer() and (ply:Team() == TEAM_GUARD or ply:Team() == TEAM_PRISIONER) then
			if ply:Alive() then
				ply:KillSilent()
			end
			ply:UnSpectate()
			ply:Spawn()
			ply:Freeze(true)
		end
	end
	local cts,ts = team.GetAlive(TEAM_GUARD),team.GetAlive(TEAM_PRISIONER)
	self:TimerSimple(1,function()
		for k,v in pairs(cts) do
			v:Freeze(false)
			if not v:Alive() then
				v:Spawn()
			end
		end
	end)
	self:TimerSimple(3, function()
		for k, v in pairs(team.GetAlive(TEAM_PRISIONER)) do
			v:Freeze(false)
			if not v:Alive() then
				v:Spawn()
			end
			if v.NextFD then
				v.NextFD = nil
				self:JBRun("givefd",NULL,v,true)
			end
		end
		self:RoundStatus(round_begin)
	end)
	local aliv,kcnt,kct,knive,t = team.GetAlive(TEAM_PRISIONER)
	kcnt = #aliv
	kct = math.ceil(kcnt * 0.125)
	for i = 1,kct do
		knive = math.random(1,kcnt)
		table.remove(aliv,knive)
		kcnt = kcnt-1
		t = aliv[knive]
		if t and IsValid(t) then
			local ch,rn = math.random(0,100)
			if ch < 15 then
				rn = table.Random(self.WeaponPistols)
			elseif ch < 50 then
				rn = table.Random(self.WeaponGrenades)
			else
				rn = table.Random(self.WeaponMelee)
			end
			inf = weapons.GetStored(rn)
			inf = inf.PrintName and inf.PrintName or "???"
			t:Give(rn)
			PInfoMsg(t, "add", _T("PrisRandomWep", rn))
		end
	end
end)
local DeathSounds = {
	Sound("player/death1.wav"),Sound("player/death2.wav"),Sound("player/death3.wav"),Sound("player/death4.wav"),Sound("player/death5.wav"),
	Sound("player/death6.wav"),Sound("vo/npc/male01/pain07.wav"),Sound("vo/npc/male01/pain08.wav"),Sound("vo/npc/male01/pain09.wav"),
	Sound("vo/npc/male01/pain04.wav"),Sound("vo/npc/Barney/ba_pain06.wav"),Sound("vo/npc/Barney/ba_pain07.wav"),Sound("vo/npc/Barney/ba_pain09.wav"),
	Sound("vo/npc/Barney/ba_no01.wav"),Sound("vo/npc/male01/no02.wav"),Sound("hostage/hpain/hpain1.wav"),Sound("hostage/hpain/hpain2.wav"),
	Sound("hostage/hpain/hpain3.wav"),Sound("hostage/hpain/hpain4.wav"),Sound("hostage/hpain/hpain5.wav"),Sound("hostage/hpain/hpain6.wav")
}
GM.HookGamemode("JB_SimonChanged",function(old,new)
	if IsValid(new) then
		local params = GAMEMODE:GetSpecGM()
		if params.ShouldGag then
			GAMEMODE:Timer("jb_Unmute", params.UngagTime, 1, function()
				if GetGMBool("JB_PrisGag",false) == true then
					SetGMBool("JB_PrisGag",false)
					InfoMsg("info", _T("PrisUnmuteRound"))
				end
			end)
			SetGMBool("JB_PrisGag", true)
			InfoMsg("add", _T("PrisMuteRound", params.UngagTime))
		end
	else
		if params.ShouldGag and GAMEMODE:TimerExists("jb_Unmute") then
			GAMEMODE:TimerExecute("jb_Unmute")
		end
	end
end)
GM.HookGamemode("PlayerKilledByPlayer",function(ply,i,a)
	if a:Team() == TEAM_PRISIONER and GAMEMODE:GetRound() == Round_In and team.GetCount(ply:Team()) > 1 then
		return true, nil, "???", _T("Prisioner")
	end
	return true
end)
GM.HookGamemode("PostPlayerDeath",function(ply)
	gm:LoseDuel(ply)
	if ply == GetGMEntity("JB_Simon") then
		SetGMBool("JB_GuardGag", false)
		SetGMBool("JB_PrisGag", false)
		SetGMEntity("JB_Simon", NULL)
		if leave then
			InfoMsg("add", _T("SimLeft"))
		else
			InfoMsg("add", _T("SimDead"))
		end
	end
end)
GM.HookGamemode("PlayerDisconnected",function(ply)
	gm:LoseDuel(ply,true)
end)
GM.HookGamemode("DoPlayerDeath",function(ply,a,d)
	if ply:LastHitGroup() ~= HITGROUP_HEAD and d:GetDamage() < 150 then
		ply:EmitSound(select(1,table.Random(DeathSounds)),140,100)
	end
end)
GM.HookGamemode("PlayerShouldTaunt",function(ply,act)
	if ply:Team() == TEAM_GUARD then
		return true
	elseif ply:Team() == TEAM_PRISIONER and GAMEMODE:GetRound() == Round_In and not IsValid(GetGMEntity("JB_Simon")) then
		return true
	else
		return false
	end
end)
GM.HookGamemode("PlayerLoadout",function(ply)
	if ply:GetNWInt("FreeDayTime",0) ~= 0 then
		ply:SetNWInt("FreeDayTime", 0)
	end
	if ply:Team() == TEAM_PRISIONER then
		ply:SetArmor(0)
		ply:SetAvoidPlayers(true)
		ply:AllowFlashlight(false)
	elseif ply:Team() == TEAM_GUARD then
		ply:SetAvoidPlayers(false)
		ply:SetArmor(65)
		ply:AllowFlashlight(true)
	end
end)
--p=Entity(1)hook.Add("Tick","1",function()print(util.TraceLine({start=p:GetPos(),endpos=p:GetPos()-Vector(0,0,128)}).HitPos:Distance(p:GetPos()))end)
GM.HookGamemode("PlayerDamagePlayer",function(victim,pl)
	if victim:GetGM("InDuel") then
		return victim:GetGM("InDuel") == pl
	end
	if pl:GetGM("InDuel") then
		return pl:GetGM("InDuel") == victim
	end
	if victim:Team() == pl:Team() then
		if GetGMBool("JB_Box") and (pl:Team() ~= TEAM_GUARD or GAMEMODE:GetRound() ~= Round_In) then
			if GetGMBool("JB_SplitTeam") and pl:GetGM("SplitTeam") == victim:GetGM("SplitTeam") then
				return false
			else
				return true
			end
		else
			return false
		end
	end
	return true
end)
GM.HookGamemode("CanDropWeapon", function(ply, ent)
	if ply:GetGM("InDuel") then return false end
end)
GM.HookGamemode("AllowPlayerPickup", function(ply, ent)
	if ply:GetGM("InDuel") then return false end
end)
GM.HookGamemode("PlayerCanPickupWeapon", function(ply, ent)
	if ply:GetGM("InDuel") then return false end
end)
GM.HookGamemode("PlayerCanEquipWeapon", function(ply, wep, force)
	if ply:Team() == TEAM_PRISIONER and not force and (ply:EyePos():DistToSqr(wep:GetPos()) > 4096 or not PlayerSeeingEntity(ply, wep)) then
		return false
	end
end)
GM.HookGamemode("EntityTakeDamage",function(vict,dmginfo)
	if not vict:IsPlayer() then return end
	--[[if vict:Alive() and vict:Armor() == 0 then
		local chance = (dmginfo:GetDamage()/vict:GetMaxHealth())
		vict.TimeStunned = CurTime() + chance * 4
		chance= (1-chance)/3 
		local sp,spd,spc,spj = vict:GetRunSpeed(),vict:GetWalkSpeed(),vict:GetCrouchedWalkSpeed(),vict:GetJumpPower()
		vict:SetRunSpeed(sp*chance)
		vict:SetWalkSpeed(spd*chance)
		vict:SetCrouchedWalkSpeed(spc*chance)
		vict:SetJumpPower(spj*chance)
		if vict.Nextime and vict.Nextime < CurTime() then
			vict.Nextime = nil
		end
	end]]
	if vict:Alive() and vict:Armor() == 0 then
		local vel,px,py = vict:GetVelocity()
		px = vel.x * math.Rand(0.3,0.7)
		py = vel.y * math.Rand(0.3,0.7)
		vict:SetVelocity(Vector(-px,-py,0))
	end
	local dmg = dmginfo:GetDamage()
	if dmg > 10 and dmg < vict:Health() and (vict:GetGM("NextPain") == nil or vict:GetGM("NextPain") < CurTime()) then
		PlaySingleSound(vict,"ambient/voices/cough" .. math.random(1,4) .. ".wav")
		vict:SetGM("NextPain",CurTime() + math.Rand(1.5,5))
	end
end)
GM.HookGamemode("RoundTick",function(ct)
	if GetGMFloat("JB_FDTime") and GetGMFloat("JB_FDTime") <= ct then
		SetGMNil("JB_FDTime")
		InfoMsg("info", _T("FDEnd"))
	end
	local cmd = GetGMEntity("JB_Simon")
	if cmd then
		if IsValid(cmd) then
			if not cmd:Alive() then
				SetGMNil("JB_Simon")
				hook.Run("JB_SimonChanged",cmd,NULL)
				InfoMsg("add",_T("SimDead"))
			end
		else
			SetGMNil("JB_Simon")
			hook.Run("JB_SimonChanged",NULL,NULL)
			--InfoMsg("add",_T("SimRemove"))
		end
	else
		if GetGMEntity("JB_ZamCmd") then
			local zam = GetGMEntity("JB_ZamCmd")
			SetGMNil("JB_ZamCmd")
			if IsValid(zam) and zam:Alive() and zam:Team() == TEAM_GUARD then
				GAMEMODE:JBRun("setcmd",zam,true)
			end
		end
	end
end)
GM.HookGamemode("PlayerTick",function(v, mv)
	if v:GetGM("InDuel") then
		if v:GetGM("OldHP") then
			if v:Health() <= v:GetGM("OldHP") then
				v:SetGM("OldHP", v:Health())
			else
				v:SetHealth(v:GetGM("OldHP"))
			end
		else
			v:SetGM("OldHP", v:Health())
		end
	end
	if v:GetGM("FD") and v:GetGM("FD") <= CurTime() then
		v:SetGM("FD",nil)
		v:SetNWInt("FreeDayTime", 0)
		GlobalMsg(_T("FDPrisEnd", colour_info, v:CNick(), colour_info))
	end
	if GetGMEntity("JB_Simon") == v then
		v:SetNW2Bool("Tracer", mv:KeyDown(IN_USE))
	end
end)
GM.HookGamemode("CountPlayers",function()
	if GAMEMODE:GetRound() ~= Round_In then return end
	local cts,ts,dt,dct = team.GetPlayers(TEAM_GUARD),team.GetPlayers(TEAM_PRISIONER),0,true
	for k,v in pairs(cts) do
		if v:Alive() then
			dct = false
			break
		end
	end
	for k,v in pairs(ts) do
		if v:Alive() then
			dt = dt + 1
			if dt > 1 then
				break
			end
		end
	end
	if dt == 1 and not dct and not GetGMEntity("JB_LR") and #ts > 1 then
		GAMEMODE:JBRun("lastrequest",team.GetAlive(TEAM_PRISIONER)[1])
	end
	if dt == 0 and dct then
		GAMEMODE:SetRound(Round_End, round_alldead)
	elseif dt == 0 then
		GAMEMODE:SetRound(Round_End, round_winct)
	elseif dct then
		GAMEMODE:SetRound(Round_End, round_wint)
	end
	return false,TEAM_GUARD,TEAM_PRISIONER
end)
function gm:StartDuel( ply, frag, wpn )
	local g = GAMEMODE
	if ply:Team() == TEAM_PRISIONER and ply:GetGM("FD",0) >= CurTime() then
		ply:SetNWInt( "FreeDayTime", 0)
		ply:SetGM("FD", nil)
	end
	if not wpn then
		wpn = table.Random(g.WeaponAll) -- TODO: Weapon check
	end
	GlobalMsg(CServ(true), colour_notify, _T("DuelBeginIn",5))

	SetGMEntity("DUELINIT", ply)
	SetGMEntity("DUELFRAG", frag)

	ply:SetHealth(100)
	ply:SetMaxHealth(ply:Health())
	ply:SetArmor(0)
	ply:StripWeapons()
	ply:GodEnable()

	frag:SetHealth(100)
	frag:SetMaxHealth(frag:Health())
	frag:StripWeapons()
	frag:SetArmor(0)
	frag:GodEnable()

	ply:SetGM("InDuel", frag)
	frag:SetGM("InDuel", ply)

	local counter = 0
	g:Timer("JB_DuelSnd",1,5,function()
		counter = counter + 1
		PlaySurfaceSound("tools/ifm/beep.wav")
		if counter == 5 then
			if IsValid(frag) and IsValid(ply) and frag:Alive() and ply:Alive() then
				ply:SetGM("InDuel",nil)
				ply:Give("weapon_fist")
				local wpn1 = ply:Give(wpn)
				wpn1.InfiniteClip = true
				ply:SetGM("SwitchWeapon",wpn1)
				ply:SetGM("InDuel", frag)

				frag:SetGM("InDuel",nil)
				frag:Give("weapon_fist")
				wpn1 = frag:Give(wpn)
				wpn1.InfiniteClip = true
				frag:SetGM("SwitchWeapon",wpn1)
				frag:SetGM("InDuel",ply)

				ply:GodDisable()
				frag:GodDisable()
				GlobalMsg(CServ(true), colour_notify, _T("DuelBegin"))
			else
				GlobalMsg(CServ(true), colour_notify, _T("DuelFailed"))
				if IsValid(ply) then
					ply:SetGM("InDuel",nil)
					ply:GodDisable()
				end
				if IsValid(frag) then
					frag:SetGM("InDuel",nil)
					frag:GodDisable()
				end
			end
		end
		--self:TimerRemove("JB_DuelSnd")
		--GlobalMsg(CServ(true),colour_notify," Дуэль не состоялась.")
	end)
end
function gm:LoseDuel( ply, leave )
	local g = GAMEMODE
	local op = ply:GetGM("InDuel")
	if op then
		ply:SetGM("InDuel", nil)
		SetGMEntity("DUELINIT")
		SetGMEntity("DUELFRAG")
		if IsValid(op) and op:IsPlayer() then
			if op:Team() == TEAM_PRISIONER then
				op:SetGM("LRRequest",true)
			end
			local wn = op:GetGM("winduels",0) + 1
			op:SetGM("winduels", wn)
			op:SetHealth(100 + wn * 25)
			op:SetMaxHealth(op:Health())
			op:SetArmor(op:Armor() + 25)
			op:SetGM("InDuel", nil)
			if leave then
				GlobalMsg(_T("DuelLeft", ply:CNick(), colour_notify, op:CNick()))
			else
				GlobalMsg(_T("DuelLose", ply:CNick(), colour_notify, op:CNick()))
			end
		end
	end
end
include("sv_commands.lua")