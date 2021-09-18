local E = GM.TypeEnum
function GM.HasLastRequest(ply)
	if GetGMString("JB_GM") ~= "Normal" then return false, _T("LRNormalDay") end
	if ply:Team() ~= TEAM_PRISIONER then return false, _T("NotT") end
	if ply.InDuel then return false, _T("NotDuel") end
	if GetGMEntity("JB_LR", NULL) ~= ply then return false, _T("NotLR") end
	if not ply:GetGM("LRRequest") then return false, _T("LRAlready") end
	return true
end
GM:JBCommand("lastrequest",function(ply)
	if ply:Alive() and GAMEMODE:GetRound() == Round_In and ply:Team() == TEAM_PRISIONER then
		if ply:GetGM("InDuel") then return false, _T("NotLRDuel") end
		if #team.GetPlayers(TEAM_PRISIONER) <= 1 then return false, _T("NotLRPCount") end
		if team.GetCount(TEAM_PRISIONER) > 1 then return false, _T("NotLR") end
		if not GetGMEntity("JB_LR") then return true end
	end
end,{E.player},function(ply) -- jb lastrequest inflictor
	if not GAMEMODE:TimerExists("JBLASTPLAYER1") then
		GAMEMODE:Timer("JBLASTPLAYER1",1,1,function()
			if IsValid(ply) and ply:Alive() and ply:Team() == TEAM_PRISIONER and GAMEMODE:GetRound() == Round_In then
				InfoMsg("info",_T("SelectLR", ply:CNick(), colour_black))
				GlobalMsg(_T("LRGlobal", Color(0,200,0)))
				SetGMEntity("JB_LR", ply)
				ply:SetGM("LRRequest",true)
				LocalMsg(ply, Color(0,200,0), _T("LRNotify"))
			end
		end)
	end
	return true
end)
GM.Actions["lr"] = GM.Actions["lastrequest"]

GM:JBCommand("killct",GM.HasLastRequest,{E.player},function(ply) -- jb killct activator
	local cts = team.GetAlive(TEAM_GUARD)
	if #cts > 0 then
		GAMEMODE:TimerSimple(math.Rand(5,15), function()
			if not IsValid(ply) or not ply:Alive() then
				GlobalMsg(_T("PickKillCTFailed",colour_notify, CTeam(TEAM_GUARD), colour_notify))
				return
			end
			for i,m in pairs(cts) do
				if m:Alive() then
					if math.random(1,2) == 1 then
						GAMEMODE:Explosion(m:GetPos(),ply,400)
						m:Kill()
					else
						GAMEMODE:Dissolve(m)
					end
				end
			end
		end)
		GlobalMsg(_T("PickKillCT", CNick(ply), colour_notify, CTeam(TEAM_GUARD), colour_notify))
		ply:SetGM("LRRequest")
		return true
	end
end)
GM:JBCommand("nextfd",GM.HasLastRequest,{E.player},function(ply) -- jb nextfd activator
	GlobalMsg(_T("PickFD", ply:CNick(), colour_notify))
	ply.NextFD = 250
	local rnd = GAMEMODE.CurrentRound
	GAMEMODE:TimerSimple(math.Rand(1,5), function()
		if rnd ~= GAMEMODE.CurrentRound then
			return
		end
		if IsValid(ply) and ply:Alive() then
			if math.random(1,2) == 1 then
				GAMEMODE:Explosion(ply:GetPos(),ply,400)
				ply:Kill()
			else
				GAMEMODE:Dissolve(ply)
			end
		end
	end)
	ply:SetGM("LRRequest")
	return true
end)
GM:JBCommand("lastwar",GM.HasLastRequest,{E.player},function(ply) -- jb lastwar activator
	local rifle = table.Random(GAMEMODE.WeaponRifles)
	ply:StripWeapons()
	ply:Give("weapon_fist")
	local rif = ply:Give(rifle)
	ply:SelectWeapon(rifle)
	rif.InfiniteClip = true
	local pist = ply:Give(table.Random(GAMEMODE.WeaponPistols))
	pist.InfiniteClip = true
	ply:SetHealth(300)
	ply:SetMaxHealth(ply:Health())
	ply:SetArmor(100)
	ply:SetWalkSpeed(300)
	ply:SetRunSpeed(400)
	ply:SetGravity(0.6)
	ply:SetGM("LRRequest")
	GlobalMsg(_T("RequestLastWar", ply:CNick(), colour_notify, colour_message, colour_notify, CTeam(TEAM_GUARD), colour_notify))
	LocalMsg(team.GetAlive(TEAM_GUARD), colour_notify, _T("KillLastPl"))
	return true
end)
GM:JBCommand("duel",GM.HasLastRequest,{E.player,E.player,E.string},function(ply,frag,wep)
	local random = true
	if wep == "random" then
		wep = table.Random(GAMEMODE.WeaponAll)
	elseif wep == "rifle" then
		wep = table.Random(GAMEMODE.WeaponRifles)
	elseif wep == "pistol" then
		wep = table.Random(GAMEMODE.WeaponPistols)
	elseif wep == "melee" then
		wep = table.Random(GAMEMODE.WeaponMelee)
	elseif GAMEMODE.WeaponDuel[wep] then
		random = false
	else
		return false, _T("WeaponRestricted")
	end
	if frag:Team() == TEAM_GUARD then
		local inf = weapons.GetStored(wep)
		if inf then
			GAMEMODE:GetSpecGM():StartDuel(ply,frag,wep)
			inf = inf.PrintName and inf.PrintName or "???"
			local st = random and _T("SelWeaponRandom", colour_notify, colour_weapon, inf) or _T("SelWeapon", colour_notify, colour_weapon, inf)
			GlobalMsg(_T("PlDuelWith", ply:CNick(), colour_notify, frag:CNick(), colour_notify), st)
			ply:SetGM("LRRequest")
			return true
		end
		return false, _T("WeaponNotFound")
	end
	return false, _T("DuelFailedWrongTeam")
end)

function GM.IsSimon(ply)
	if ply.InDuel then return false, _T("NotDuel") end
	if ply:IsAdmin() then return true end
	if ply:Team() ~= TEAM_GUARD then return false, _T("NotCT") end
	if GetGMEntity("JB_Simon") ~= ply then return false, _T("NotSimon") end
	return true
end
GM:JBCommand("setcmd",function(ply)
	if ply:Alive() and GAMEMODE:GetRound() == Round_In and ply:Team() == TEAM_GUARD then
		local simon = GetGMEntity("JB_Simon")
		if simon == ply then
			return false, _T("SimonAlready")
		elseif IsValid(simon) then
			return false, _T("SimonExists")
		else
			if GetGMInt("FDTime") then return false, _T("SimonCantFreeday") end
			if ply:GetGM("InDuel") and IsValid(GetGMEntity("JB_LR")) then return false, _T("SimonCantLR") end
			return true
		end
	end
end,{E.player},function(ply) -- jb setcmd inflictor
	local simon = GetGMEntity("JB_Simon")
	if IsValid(simon) and simon:Alive() then
		simon:SetModel(simon:GetGM("OriginalModel"))
		simon:SetArmor(max(0,simon:Armor() - 60))
		simon:StripWeapon("weapon_medkit")
		simon:SetupHands()
	end
	ply:SetModel("models/player/barney.mdl")
	ply:SetArmor(ply:Armor() + 60)
	ply:SetupHands()
	ply:Give("weapon_medkit")
	SetGMEntity("JB_Simon", ply)
	hook.Run("JB_SimonChanged",simon,ply)
	GlobalMsg(_T("SimonSelect", colour_notify, ply:CNick(), colour_notify))
	return true
end)
GM.Actions["cmd"] = GM.Actions["setcmd"]
GM.Actions["warden"] = GM.Actions["setcmd"]
GM.Actions["simon"] = GM.Actions["setcmd"]
GM:JBCommand("opencells",GM.IsSimon,{E.playerornull,E.bool},function(e,b)
	local je = GAMEMODE.JailEntities
	if not je then return false end
	local dis, op = b and "Disable" or "Enable", b and "Open" or "Close"
	for i = 1,#je[1] do
		je[1][i]:Fire(dis)
	end
	for i = 1,#je[2] do
		je[2][i]:Fire(op)
	end
	GlobalMsg(_T("SimOpenCells", CNick(e), colour_notify, b))
	return true
end)
local SplitTeams = {[1] = {"red",Vector(1,0,0),_T("Red")},[2] = {"blue",Vector(0,0,1),_T("Blue")},[3] = {"yellow",Vector(1,1,0),_T("Yellow")},[4] = {"green",Vector(0,1,1),_T("Green")}}
GM:JBCommand("splitteam",GM.IsSimon,{E.playerornull,E.bool,E.int},function(e,b,c)
	if b then
		if not isnumber(c) then
			return false, _T("NotNumber")
		end
		local cnt,ts,tsc,ost,tab,ifleft = c,team.GetAlive(TEAM_PRISIONER),0,0,{},0
		tsc = #ts
		if tsc < cnt then
			return false, _T("NotEnougthToSplit")
		end
		ost = math.floor(tsc / cnt) --,(ost*cnt<tsc)
		for i = 1,cnt do
			tab[i] = 0
		end
		for _,v in pairs(ts) do
			v:SetGM("SplitTeam")
		end
		for _,v in RandomPairs(ts) do
			if not v:GetGM("FD") then
				for i = 1,cnt do
					if tab[i] < ost then
						tab[i] = tab[i] + 1
						v:SetPlayerColor(SplitTeams[i][2])
						v:SetGM("SplitTeam",SplitTeams[i][1])
						PInfoMsg(v,"info",_T("YourColor",SplitTeams[i][2]:ToColor(),SplitTeams[i][3],colour_notify))
						break
					end
				end
				if v:GetGM("SplitTeam") == nil then
					if ifleft >= cnt then
						ifleft = 0
					end
					ifleft = ifleft + 1
					v:SetPlayerColor(SplitTeams[ifleft][2])
					v:SetGM("SplitTeam",SplitTeams[ifleft][1])
					PInfoMsg(v,"info",_T("YourColor",SplitTeams[ifleft][2]:ToColor(),SplitTeams[ifleft][3],colour_notify))
				end
			end
		end
		SetGMBool("JB_SplitTeam",true)
		GlobalMsg(_T("SimSplitTeam", CNick(e), colour_notify, CTeam(TEAM_PRISIONER), colour_notify, cnt))
	else
		local ts = team.GetAlive(TEAM_PRISIONER)
		for _,v in pairs(ts) do
			if not v:GetGM("FD") then
				v:SetPlayerColor(v:GetGM("DefaultColor"))
				v:SetGM("SplitTeam",nil)
			end
		end
		SetGMBool("JB_SplitTeam",false)
		GlobalMsg(_T("SimDisSplitTeam", CNick(e), colour_notify, CTeam(TEAM_PRISIONER), colour_notify))
	end
	return true
end)
GM:JBCommand("changeteam",GM.IsSimon,{E.playerornull,E.player},function(ply,v) -- jb changeteam activator inflictor
	local oteam = v:Team()
	if oteam ~= TEAM_SPECTATOR then
		if oteam == TEAM_GUARD then
			GAMEMODE:PlayerChangeTeam(v)
		elseif oteam == TEAM_PRISIONER then
			if type(v.demoted) == "number" then
				return false, {_T("Balance", colour_notify), _T("DemotedGuard", colour_warn, CTeam(TEAM_GUARD))}
			end
			if hook.Run("PlayerCanJoinTeam", v, TEAM_GUARD) then
				GAMEMODE:PlayerChangeTeam(v)
			else
				return false, {_T("Balance", colour_notify), _T("MuchGuards", colour_warn)}
			end
		end
		local team1 = v:Team()
		if oteam ~= team1 then
			GlobalMsg( _T("Balance", colour_notify), _T("SimChTeam", CNick(ply), colour_notify, {team.GetColor(oteam), v:Nick()}, colour_notify, CTeam(team1), colour_notify))
		else
			return false, _T("ChTeamFailed", colour_warn)
		end
		return true
	end
end)
GM:JBCommand("point",GM.IsSimon,{E.player,E.int,E.bool,E.int},function(ply,id,bool,type) -- jb point activator int bool int
	local pos = ply:GetEyeTrace().HitPos - ply:GetAngles():Forward() * 2
	local trace = util.TraceLine({start = pos, endpos = pos-Vector(0,0,1024)})
	if bool then
		if type == 1 then
			id = "Point" .. math.Clamp(id,0,4)
			SetGMVector(id,trace.HitPos)
		elseif type == 2 then
			id = "PointC" .. math.Clamp(id,1,4)
			SetGMVector(id,trace.HitPos)
		elseif type == 3 then
			local id1 = "PointL" .. math.Clamp(id,1,2)
			SetGMVector(id1,trace.HitPos)
			SetGMInt("PointLA" .. id,math.Round((math.NormalizeAngle(ply:EyeAngles().y) + 270) / 45) * 45,true)
			id = id1
		else
			return false
		end
		GetGMTable("Points")[id] = trace.HitPos
	else
		if type == 1 then
			id = "Point" .. math.Clamp(id,1,4)
			SetGMNil(id)
		elseif type == 2 then
			id = "PointC" .. math.Clamp(id,1,4)
			SetGMNil(id)
		elseif type == 3 then
			id = "PointL" .. math.Clamp(id,1,2)
			SetGMNil(id)
		else
			return false
		end
		GetGMTable("Points")[id] = nil
	end
	return true
end)
local adst,ndst = 10 * 10,150 * 150
GM:JBCommand("delpoint",GM.IsSimon,{E.player},function(ply) -- jb delpoint activator
	local tab = GetGMTable("Points")
	local ep,ea,min,mink = ply:EyePos(),ply:EyeAngles(),adst,nil
	for k,v in pairs(tab) do
		local dif = v-ep
		dif = dif:Angle()
		dif:Normalize()
		dif = ea-dif
		dif = dif.p * dif.p + dif.y * dif.y
		if dif < min then
			min = dif
			mink = k
		end
	end
	if mink then
		GetGMTable("Points")[mink] = nil
		SetGMNil(mink)
		return true
	end
	local hp,dist,min,mink = ply:GetEyeTrace().HitPos,0,ndst,nil
	for k,v in next,tab do
		dist = hp:DistToSqr(v)
		if dist < min then
			min = dist
			mink = k
		end
	end
	if mink and min < ndst then
		GetGMTable("Points")[mink] = nil
		SetGMNil(mink)
		return true
	end
	return true
end)
GM:JBCommand("guardgag",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb guardgag activator bool
	SetGMBool("JB_GuardGag", bl)
	GlobalMsg(_T("SimGuardGag", CNick(ply), colour_notify, bl, CTeam(TEAM_GUARD), colour_notify))
	return true
end)
GM:JBCommand("box",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb box activator bool
	if bl then
		InfoMsg("info",_T("NotifyBox"))
	else
		InfoMsg("info",_T("NotifyBoxEnded"))
	end
	SetGMBool("JB_Box", bl)
	GlobalMsg(_T("SimBoxing", CNick(ply), colour_notify, bl))
	return true
end)
GM:JBCommand("bhop",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb bhop activator bool
	SetGMBool("JB_Bhop", bl)
	GlobalMsg(_T("SimBhop", CNick(ply), colour_notify, bl))
	return true
end)
GM:JBCommand("collision",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb collision activator bool
	local bl1 = not bl
	for _, k in pairs(team.GetAlive(TEAM_PRISIONER)) do
		k:SetNoCollideWithTeammates(bl1)
	end
	SetGMBool("JB_Collision", bl)
	GlobalMsg(_T("SimCollision", CNick(ply), colour_notify, bl))
	return true
end)
GM:JBCommand("prisgag",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb prisgag activator bool
	SetGMBool("JB_PrisGag", bl)
	GlobalMsg(_T("SimGagPl", CNick(ply), colour_notify, bl, CTeam(TEAM_PRISIONER), colour_notify))
	return true
end)
GM:JBCommand("givefd",GM.IsSimon,{E.playerornull,E.player,E.bool},function(ply,frag,bool) -- jb givefd activator inflictor bool
	if frag:Team() == TEAM_PRISIONER then
		if bool then
			frag:SetGM("FD",CurTime() + 240)
			frag:SetNW("FreeDayTime", frag:GetGM("FD"))
			frag.NextFD = nil
			frag:SetPlayerColor(GAMEMODE:TableRandom(GAMEMODE.FDColors))
		else
			frag:SetGM("FD",nil)
			frag.NextFD = nil
			frag:SetNW("FreeDayTime", 0)
			frag:SetPlayerColor(frag:GetGM("DefaultColor"))
		end
		GlobalMsg(_T("SimPlayerFD", CNick(ply), colour_notify, bool, frag:CNick(), colour_notify))
		return true
	end
end)
GM:JBCommand("setalter",GM.IsSimon,{E.playerornull,E.player},function(ply,frag) -- jb setalter activator inflictor
	if IsValid(frag) then
		if GetGMEntity("JB_AlterSimon") == frag then
			SetGMEntity("JB_AlterSimon", NULL)
			GlobalMsg(_T("SimUnsetAlter", CNick(ply), colour_notify))
		else
			SetGMEntity("JB_AlterSimon", frag)
			GlobalMsg(_T("SimSelectAlter", CNick(ply), colour_notify, frag:CNick(), colour_notify))
		end
		return true
	end
end)
GM:JBCommand("opendoor",GM.IsSimon,{E.playerornull},function(ply) -- jb opendoor activator inflictor
	local ent = ply:GetEyeTrace().Entity
	if IsValid(ent) and not ent:IsPlayer() and string.find(ent:GetClass(),"door") then
		ent:Fire("Open")
		return true
	end
end)
GM:JBCommand("startgm",GM.IsSimon,{E.playerornull,E.string},function(ply,str) -- jb startgm activator integer
	if GetGMString("JB_GM") ~= "Normal" then return false, _T("GMNotNormal") end
	if GAMEMODE.SpecDays[str] == nil then return false, _T("GMNotExists") end
	if CurTime() - GAMEMODE.DayTime > GAMEMODE:GetRoundStartTime() then return false, _T("GMFirstDay") end
	return GAMEMODE:StartGameMode(str,true)
end)
GM:JBCommand("gag",GM.IsSimon,{E.playerornull,E.player,E.bool},function(ply,inf,bl) -- jb gag activator inflictor bool
	inf:SetNW("JB_Gag",bl)
	GlobalMsg(_T("SimMutePl", CNick(ply), colour_notify, bl, inf:CNick()))
	return true
end)
GM:JBCommand("pickup",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb pickup activator bool
	SetGMBool("JB_Pickup", bl)
	GlobalMsg(_T("SimPickup", CNick(ply), colour_notify, bl))
	return true
end)
GM:JBCommand("avoidness",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb avoidness activator bool
	SetGMBool("JB_Avoidness", bl)
	for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
		v:SetAvoidPlayers(bl)
	end
	GlobalMsg(_T("SimAvoidness", CNick(ply), colour_notify, bl))
	return true
end)
GM:JBCommand("propdamage",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb propdamage activator bool
	SetGMBool("JB_PropDamage", bl)
	GlobalMsg(_T("SimPropDamage", CNick(ply), colour_notify, bl))
	return true
end)
GM:JBCommand("respawn",GM.IsSimon,{E.playerornull,E.player,E.bool},function(ply,inf,cancel) -- jb tspawn activator inflictor bool
	if inf:GetGM("SpawnedOnce") then
		return false, _T("SimSpawnedAlready", inf:CNick(), colour_notify)
	end
	if inf:Alive() then
		return false, _T("SimAlreadyAlive", inf:CNick(), colour_notify)
	end
	inf:SetGM("SpawnedOnce",true)
	local pos, ang
	if cancel then
		if inf:GetGM("DiePos") then
			pos = inf:GetGM("DiePos")
			ang = inf:GetGM("DieAngles",Angle())
		else
			cancel = false -- in case if we failed
		end
	end
	inf:Spawn()
	if pos then
		inf:SetPos(pos)
		inf:SetAngles(ang)
	end
	GlobalMsg(_T("SimRespawn", CNick(ply), colour_notify, CNick(inf), colour_notify, cancel))
	return true
end)
GM:JBCommand("spawn",GM.IsSimon,{E.playerornull,E.int},function(ply,id) -- jb spawn activator name
	local gm = GAMEMODE:GetSpecGM()
	if gm.Spawnable[id] then
		local tb = gm.Spawnable[id]
		if ply:GetGM("SpawnedCount",0) >= gm.SimonMaxProps then
			return false, _T("SimonOverflowLimit", gm.SimonMaxProps)
		end
		local e = DoPlayerEntitySpawn(ply, tb.type, tb.model or "", tb.skin or 0)
		undo.Create( "Spawnable" )
			undo.SetPlayer( ply )
			undo.AddEntity( e )
			cleanup.Add(ply, "Spawnable", e)
		undo.Finish( tostring( tb.name ) )
		e:CallOnRemove( "GetCountUpdate", function( ent, ply )
			if IsValid(ply) and GetGMEntity("JB_Simon") == ply then
				ply:SetGM("SpawnedCount", ply:GetGM("SpawnedCount", 1) - 1)
			end
		end, ply )
		ply:SetGM("SpawnedCount", ply:GetGM("SpawnedCount", 0) + 1)

		if tb.func then
			tb.func(e,ply)
		end
		return true
	else
		return false, _T("ObjectNotExists")
	end
end)
GM:JBCommand("remove",GM.IsSimon,{E.playerornull,E.entity},function(ply,ent) -- jb remove activator entity
	if IsValid(ent) then
		local gm = GAMEMODE:GetSpecGM()
		if gm.ValidProps[ent:GetClass()] then
			SafeRemoveEntity(ent)
		end
	end
	return true
end)
GM:JBCommand("weaponbox",GM.IsSimon,{E.playerornull,E.string},function(ply,name) -- jb weaponbox activator name
	return true
end)
GM:JBCommand("flashlight",GM.IsSimon,{E.playerornull,E.bool},function(ply,bl) -- jb flashlight activator bool
	SetGMBool("JB_Flashlight", bl)
	for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
		v:AllowFlashlight(bl)
	end
	GlobalMsg(_T("SimFlashlight", CNick(ply), colour_notify, bl, CTeam(TEAM_PRISIONER), colour_notify))
	return true
end)
GM:JBCommand("count",GM.IsSimon,{E.playerornull},function(ply) -- jb count activator
	local count = {}
	local cnt, count1 = 0, 0
	for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
		count1 = count1 + 1
		if PlayerSeeingEntity(ply, v, 60, true) then
			cnt = cnt + 1
		else
			count[#count + 1] = v:Nick()
		end
	end
	GlobalMsg(_T("SimCountT", CNick(ply), colour_notify, cnt, CTeam(TEAM_PRISIONER)))
	if cnt < count1 then
		GlobalMsg(_T("SimCountNT", colour_notify, CTeam(TEAM_PRISIONER), colour_notify, colour_warn, table.concat(count,", ")))
	end
	return true
end)
GM:JBCommand("buy",GM.IsSimon,{E.player,E.string},function(ply,wep)
	return true
end)