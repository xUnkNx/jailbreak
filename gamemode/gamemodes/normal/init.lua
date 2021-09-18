local gm = GM:InitGamemode(function(self,params)
	self:SetRoundTime(CurTime() + math.min(1 + math.ceil(team.GetCount(TEAM_PRISIONER) / 3), 6) * self.DayTime + self.RoundPrepare )
	for k,v in pairs(player.GetAll()) do
		if v:Team() ~= TEAM_SPECTATOR then
			v:Freeze(true)
		end
	end
	self:TimerSimple(1, function()
		for k,v in pairs(team.GetPlayers(TEAM_GUARD)) do
			v:Freeze(false)
		end
	end)
	self:TimerSimple(self.RoundPrepare, function()
		for k, v in pairs(team.GetPlayers(TEAM_PRISIONER)) do
			v:Freeze(false)
			if v.NextFD then
				v.NextFD = nil
				self:JBRun("givefd",NULL,v,true)
			end
		end
		self:RoundStatus(round_begin)
		params:RoundStarted(self)
	end)
	if params.AutoOpenCells then
		self:Timer("JB_OpenCells", params.AutoOpenTime, 1, function()
			if not self.Opened then
				self:JBRun("opencells", NULL, true)
			end
		end)
	end
	if params.MarkAsPassive then
		self:Timer("JB_PrisionerCheck", params.CheckTime, 0, params.CheckPrisioners)
	end
end)
function gm:CheckPrisioners()
	local cmd = GetGMEntity("JB_Simon")
	if IsValid(cmd) then
		local p1 = cmd:EyePos()
		for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
			hook.Run("OnPrisionerVisible", cmd, v, PlayerSeeingEntity(cmd, v, 180, true))
		end
	end
end
GM.HookGamemode("OnPrisionerVisible",function(cmd, pris, bool)
	local params = GAMEMODE:GetSpecGM()
	local tmr = "Passive" .. pris:UserID()
	if pris:GetGM("PassiveRebel") then
		if bool and not pris:GetGM("ActiveRebel") then
			GAMEMODE:TimerRemove(tmr)
			pris:SetNW("ActiveRebel", 0, pris)
			params.MarkAsRebel(pris, false)
		end
	elseif not bool and not GAMEMODE:TimerExists(tmr) then
		GAMEMODE:Timer(tmr, params.RebelTime, 1, params.MarkAsRebel, pris, true)
		pris:SetNW("ActiveRebel", GAMEMODE:TimerLeft(tmr), pris)
	end
end)
function gm.MarkAsRebel(pris, bool)
	if not pris:Alive() then
		pris:SetNW("Rebel")
		return
	end
	local cmd = GetGMEntity("JB_Simon")
	if bool and IsValid(cmd) and PlayerSeeingEntity(cmd, pris, 180, true) then
		hook.Run("OnPrisionerVisible", cmd, pris, true)
		return
	end
	GAMEMODE:SetForceVisible(pris, bool)
	pris:SetGM("PassiveRebel", bool)
	if bool and not pris:GetNW("Rebel") then
		GlobalMsg(_T("MarkedAsRebel", colour_notify, pris:CNick(), colour_notify, bool, bool and (pris:GetGM("ActiveRebel") and _T("ActiveRebel") or _T("PassiveRebel")) or ""))
	end
	pris:SetNW("Rebel", bool)
end
GM.HookGamemode("OnPrisionerAttack",function(pris, ct, dmg)
	local params = GAMEMODE:GetSpecGM()
	if params.MarkAsActive then
		pris:SetGM("ActiveRebel", true)
	end
	if GAMEMODE:TimerExists("Passive" .. pris:UserID()) and not pris:GetGM("Rebel") then
		pris:SetGM("RebelDamage", pris:GetGM("RebelDamage",0) + dmg:GetDamage())
		if pris:GetGM("RebelDamage") > params.MinimumActiveDamage then
			pris:SetGM("RebelDamage", pris:GetGM("RebelDamage") - params.MinimumActiveDamage)
			local nm = "Passive" .. pris:UserID()
			GAMEMODE:TimerAdjust(nm, - params.AdditionalActiveTime)
			pris:SetNW("ActiveRebel", GAMEMODE:TimerLeft(nm), pris)
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
function gm:RoundStarted(GM)
	if self.RandomWeapon then
		local aliv,kcnt,kct,knive,t = team.GetAlive(TEAM_PRISIONER)
		kcnt = #aliv
		kct = math.ceil(kcnt * self.RandomWeaponCounter)
		for i = 1, kct do
			knive = math.random(1,kcnt)
			table.remove(aliv,knive)
			kcnt = kcnt - 1
			t = aliv[knive]
			if t and IsValid(t) then
				local ch,rn = math.random(0,100)
				if ch < 15 then
					rn = table.Random(GM.WeaponPistols)
				elseif ch < 50 then
					rn = table.Random(GM.WeaponGrenades)
				else
					rn = table.Random(GM.WeaponMelee)
				end
				inf = weapons.GetStored(rn)
				if inf then
					inf = inf.PrintName and inf.PrintName or "???"
					t:Give(rn)
					PInfoMsg(t, "add", _T("PrisRandomWep", inf))
				end
			end
		end
	end
end
GM.HookGamemode("JB_SimonChanged",function(old,new)
	local params = GAMEMODE:GetSpecGM()
	if IsValid(new) then
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
		if params.AutoOpenCells then
			GAMEMODE:TimerRemove("JB_OpenCells")
		end
	else
		if params.ShouldGag and GAMEMODE:TimerExists("jb_Unmute") then
			GAMEMODE:TimerExecute("jb_Unmute")
		end
	end
end)
GM.HookGamemode("PlayerKilledByPlayer",function(ply,i,a)
	if a:Team() == TEAM_PRISIONER and GAMEMODE:GetRound() == Round_In and team.GetCount(ply:Team()) > 1 then
		return true, nil, "???", "#ATK_PRISIONER" -- let lang system work
	end
	return true
end)
GM.HookGamemode("PostPlayerDeath",function(ply)
	gm:LoseDuel(ply)
	if ply == GetGMEntity("JB_Simon") then
		SetGMBool("JB_GuardGag", false)
		SetGMBool("JB_PrisGag", false)
		SetGMEntity("JB_Simon", NULL)
		InfoMsg("add", _T("SimDead"))
	end
end)
GM.HookGamemode("PlayerDisconnected",function(ply)
	gm:LoseDuel(ply,true)
end)
GM.HookGamemode("DoPlayerDeath",function(ply,a,d)
	if ply:LastHitGroup() ~= HITGROUP_HEAD and d:GetDamage() < 150 then
		ply:EmitSound(select(1,table.Random(DeathSounds)),140,100)
	end
	ply:SetGM("DiePos",ply:GetPos())
	ply:SetGM("DieAngles",ply:GetAngles())

	local undos = undo.GetTable()[ply:UniqueID()]
	if undos then
		for k,v in pairs(undos) do
			undo.Do_Undo(v)
		end
		undo.GetTable()[ply:UniqueID()] = nil
		cleanup.CC_Cleanup(ply, "", {})
	end
end)
GM.HookGamemode("PlayerShouldTaunt",function(ply,act)
	if ply:Team() == TEAM_GUARD then
		return true
	elseif ply:Team() == TEAM_PRISIONER and not IsValid(GetGMEntity("JB_Simon")) then
		return true
	else
		return false
	end
end)
GM.HookGamemode("PlayerLoadout",function(ply)
	if ply:Team() == TEAM_PRISIONER then
		ply:SetArmor(0)
		ply:SetAvoidPlayers(true)
		ply:AllowFlashlight(false)

		GAMEMODE:TimerSimple(0,function()
			if team.GetCount(TEAM_PRISIONER) > 1 then
				local lr = GetGMEntity("JB_LR")
				if IsValid(lr) then
					SetGMEntity("JB_LR")
					lr:SetGM("LRRequest")
					GlobalMsg(_T("NotLastRequest",lr:CNick(),colour_notify))
				end
			end
		end)
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
	if not GetGMBool("JB_Pickup") then return false end
end)
GM.HookGamemode("PlayerCanPickupWeapon", function(ply, ent)
	if ply:GetGM("InDuel") then return false end
end)
GM.HookGamemode("PlayerCanEquipWeapon", function(ply, wep, rep, force)
	if ply:Team() == TEAM_PRISIONER and not force and (ply:EyePos():DistToSqr(wep:GetPos()) > 3600 or not PlayerSeeingEntity(ply, wep, 25)) then
		return false
	end
end)
GM.HookGamemode("EntityTakeDamage",function(vict,dmginfo)
	if not vict:IsPlayer() then
		local atk = dmginfo:GetAttacker()
		-- let simon press any button by damage it
		if IsValid(atk) and atk:IsPlayer() and GetGMEntity("JB_Simon") == atk and vict:GetClass() == "func_button" then
			vict:Fire("Use")
		end
		return
	end
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
	local atk = dmginfo:GetAttacker()
	if IsValid(atk) then
		if atk:IsPlayer() then
			local inf = dmginfo:GetInflictor()
			if IsValid(inf) and inf:IsWeapon() and inf.SpecialGun then
				return true
			end
			if atk:Team() == TEAM_PRISIONER or vict:Team() == TEAM_GUARD then
				hook.Run("OnPrisionerAttack", atk, vict, dmginfo)
			end
		elseif not GetGMBool("JB_PropDamage") then
			local cl = atk:GetClass():sub(1,4)
			if cl == "func" or cl == "prop" then
				return true
			end
		end
	end
	local inf = dmginfo:GetInflictor()
	if IsValid(inf) and not GetGMBool("JB_PropDamage") then
		local cl = inf:GetClass():sub(1,4)
		if cl == "func" or cl == "prop" then
			return true
		end
	end
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
		if GetGMEntity("JB_AlterSimon") then
			local zam = GetGMEntity("JB_AlterSimon")
			SetGMNil("JB_AlterSimon")
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
	local ct = CurTime()
	if v:GetGM("FD") and v:GetGM("FD") <= ct then
		v:SetGM("FD",nil)
		v:SetNW("FreeDayTime", 0)
		GlobalMsg(_T("FDPrisEnd", colour_info, v:CNick(), colour_info))
	end
	if GetGMEntity("JB_Simon") == v then
		v:SetNW("Tracer", mv:KeyDown(IN_USE)) -- let client handle everything
		-- we can do that because eyeangles is correct both server and client (+-)
		--[[if us and v:GetGM("TracerLast",0) < ct then
			v:SetGM("TracerLast", ct + 0.1)
			local hit = v:GetEyeTrace().HitPos
			v:SetGM("TracerLastPos",hit)
			if v:GetGM("TracerLastPos",vector_origin):DistToSqr(hit) < 250 then
				if v:GetGM("TracerCounter",0) > 5 then
					if GetGMVector("JB_Point0",vector_origin):DistToSqr(hit) > 1000 then
						print("TEMP POINT")
						v:SetGM("TracerCounter",0)
					end
				else
					v:SetGM("TracerCounter",v:GetGM("TracerCounter",0) + 1)
				end
			else
				v:SetGM("TracerCounter",0)
			end
		end]]
	end
end)
GM.HookGamemode("CountPlayers",function()
	local at, act = 0, false
	for k,v in pairs(player.GetAll()) do
		if v:Alive() then
			if v:Team() == TEAM_PRISIONER then
				at = at + 1
				if act and at > 1 then
					break
				end
			elseif v:Team() == TEAM_GUARD then
				act = true
				if at > 1 then
					break
				end
			end
		end
	end
	if at == 1 and act and not GetGMEntity("JB_LR") and #team.GetPlayers(TEAM_PRISIONER) > 1 then
		GAMEMODE:JBRun("lastrequest",team.GetAlive(TEAM_PRISIONER)[1])
	end
	if at == 0 then
		if act then
			GAMEMODE:SetRound(Round_End, round_winct)
		else
			GAMEMODE:SetRound(Round_End, round_alldead)
		end
	elseif not act then
		GAMEMODE:SetRound(Round_End, round_wint)
	end
	return true
end)
GM.HookGamemode("PlayerChangePlayState",function(ply, bl)
	local params = GAMEMODE:GetSpecGM()
	if ply:Alive() then
		local afktmr = "AFK" .. ply:UserID()
		if bl and params.KillAFK then
			GAMEMODE:Timer(afktmr, params.KillTime, 1, function()
				if ply:Alive() then
					GAMEMODE:Dissolve(ply)
					GlobalMsg(_T("AFKAutoSlay", ply:CNick(), colour_notify))
				end
			end)
			ply:SetNW("AutoSlay", GAMEMODE:TimerLeft(afktmr), ply)
		else
			ply:SetNW("AutoSlay", 0, ply)
			GAMEMODE:TimerRemove(afktmr)
		end
	end
end)
GM.HookGamemode("CanPlayerSuicide",function(ply)
	if ply:Team() == TEAM_PRISIONER then
		return false
	end
end)
function gm:StartDuel( ply, frag, wpn )
	local g = GAMEMODE
	if ply:Team() == TEAM_PRISIONER and ply:GetGM("FD",0) >= CurTime() then
		ply:SetNW( "FreeDayTime", 0)
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
			op:SetGM("OldHP",op:Health())
			op:SetMaxHealth(op:Health())
			op:SetArmor(op:Armor() + 65)
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

local ccadd = concommand.Add
concommand.Add = function() end
pcall(include,"sandbox/gamemode/commands.lua")
concommand.Add = ccadd

GM.HookGamemode("PlayerSpawnProp",function(ply, model)
	if GetGMEntity("JB_Simon") == ply then
		return true
	end
end)
GM.HookGamemode("PlayerSpawnSENT", function(ply, ent)
	if GetGMEntity("JB_Simon") == ply then
		return true
	end
end)
GM.HookGamemode("PlayerUse", function(ply,ent)
	if ply:Alive() and ply:Team() == TEAM_GUARD and IsValid(ent) and ply:GetGM("LastForcePickup",0) < CurTime() then
		local gm = GAMEMODE:GetSpecGM()
		if gm.ValidProps[ent:GetClass()] then
			if ent:IsPlayerHolding() then
				DropEntityIfHeld(ent)
			end
			ply:PickupObject( ent )
			ply:SetGM("LastForcePickup",CurTime() + 0.5)
		end
	end
end)