local function pointsel(s)
	local ptype,id,p = s.max,0,s.pref
	for i = 1,ptype do
		if not GetGMVector("Point" .. p .. i) then
			id = i
			break
		end
	end
	if id == 0 then id = 1 end
	JBCommand("point",id,true,s.type)
end
local function t_Add(t,a)
	local i = #t
	for k,v in pairs(a) do
		i = i + 1
		t[i] = k
	end
	return t
end
do
	local function pointrem(s,p)
		JBCommand("delpoint")
	end
	--[[local cache,menu,id=GAMEMODE.Precache
	menu,id=cache.PointMenu,cache.PointTypes
	local act=math.Clamp(#menu-id,0,4)==0
	for i=1,4 do
		if GetGMVector("Point"..i) then
			menu[id+i].hidden=false
			menu[id+i].type=GetGMInt("PointType"..i,0)
		else
			menu[id+1].hidden=true
		end
		menu[i].hidden=act
	end]]--
	local PointThink = function(s)
		local id = 1
		for i = 1,s.max do
			if not GetGMVector("Point" .. s.pref .. i) then
				id = i
				break
			end
		end
		s.desc = tostring(id)
	end
	GM:PrecacheMenu("PointMenu", RegisterMenu({
		{ title = _C("Point"),type = 1,pref = "",max = 4,select = pointsel,think = PointThink },
		{ title = _C("Circle"),type = 2,pref = "C",max = 4,select = pointsel,think = PointThink },
		{ title = _C("LineUp"),type = 3,pref = "L",max = 2,select = pointsel,think = PointThink },
		{ title = _C("Remove"),select = pointrem },
	}))
	local setstatus = function(s,p)
		if (s.inv and not GetGMBool(s.gvar)) or (not s.inv and GetGMBool(s.gvar)) then
			s.desc = s.dis or _C("Disable")
			s.dcol = Color(200,0,0)
			s.type = 1
		else
			s.desc = s.en or _C("Enable")
			s.dcol = Color(0,200,0)
			s.type = 2
		end
	end
	local selectstatus = function(s,p)
		JBCommand(s.cvar, s.type == (s.inv and 1 or 2))
	end
	GM:PrecacheMenu("StatusMenu", RegisterMenu({
		{ title = _C("Collisions"), think = setstatus, select = selectstatus, gvar = "JB_Collision", cvar = "collision" },
		{ title = _C("Bhop"), think = setstatus, select = selectstatus, gvar = "JB_Bhop", cvar = "bhop" },
		{ title = _C("Avoidness"), think = setstatus, select = selectstatus, gvar = "JB_Avoidness", cvar = "avoidness"},
		{ title = _C("PropDamage"), think = setstatus, select = selectstatus, gvar = "JB_PropDamage", cvar = "propdamage" },
		{ title = _C("Pickup"), think = setstatus, select = selectstatus, gvar = "JB_Pickup", cvar = "pickup" },
		{ title = _C("Flashlight"), think = setstatus, select = selectstatus, gvar = "JB_Flashlight", cvar = "flashlight" }
	}))
	GM:PrecacheMenu("VoiceMenu", RegisterMenu({
		{ title = _C("PrisVoice"), think = setstatus, select = selectstatus, gvar = "JB_PrisGag", cvar = "prisgag", inv = true },
		{ title = _C("GuardVoice"), think = setstatus, select = selectstatus, gvar = "JB_GuardGag", cvar = "guardgag", inv = true },
	}))
	local function SelSplit(Eb)
		JBCommand("splitteam", true, Eb.count or 2)
	end
	GM:PrecacheMenu("SplitMenu", RegisterMenu({
		{
			title = _C("RemovePrisSplit"),
			select = function()
				JBCommand("splitteam", false, 0)
			end
		},
		{
			title = _C("TeamsCnt",2),
			count = 2,
			select = SelSplit
		},
		{
			title = _C("TeamsCnt",3),
			count = 3,
			select = SelSplit
		},
		{
			title = _C("TeamsCnt",4),
			count = 4,
			select = SelSplit
		}
	}))
	local function selectentity(ent)
		JBCommand("spawn",ent.id)
	end
	GM:PrecacheMenu("GameMenu", RegisterMenu({
		{ title = _C("Boxing"), think = setstatus, select = selectstatus, gvar = "JB_Box", cvar = "box"},
		{ title = _C("GameModes"), select = function(s,p)
			local gms = {}
			for k,v in pairs(GAMEMODE.SpecDays) do
				if v and v[2] and v[2].Usable then
					gms[k] = v[2].Name
				end
			end
			Select(_C("GameModes"),gms,function(k,v)
				JBCommand("startgm",k)
			end)
		end, keep = true },
		{ title = _C("TeamManagement"), select = function(s,p)
			if player.GetCount() > 1 then
				local ct,t,lp = {},{},LocalPlayer()
				for k,v in pairs(player.GetAll()) do
					if v == lp or not v:Alive() then
						continue
					end
					if v:Team() == TEAM_GUARD then
						ct[v] = _C("ChangeTeam", v:Nick(), team.GetName(TEAM_PRISIONER) )
					elseif v:Team() == TEAM_PRISIONER then
						t[v] = _C("ChangeTeam", v:Nick(), team.GetName(TEAM_GUARD) )
					end
				end
				local sort = t_Add({},ct)
				t_Add(sort,t)
				table.Merge(ct,t)
				Select(_C("TeamManagement"),ct,function(k,v)
					JBCommand("changeteam",k:EntIndex())
				end,sort)
			end
		end, keep = true },
		{ title = _C("FreedayMenu"), select = function(s,p)
			if team.GetCount(TEAM_PRISIONER) > 1 then
				local tk,gv = {},{}
				for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
					if not v:Alive() then continue end
					if v:GetNW("FreeDayTime",0) - CurTime() > 0 then
						tk[v] = _C("GiveFD", false, v:Nick())
					else
						gv[v] = _C("GiveFD", true, v:Nick())
					end
				end
				local sort = t_Add({},tk)
				t_Add(sort,gv)
				table.Merge(tk,gv)
				Select(_C("FreedayMenu"),tk,function(k,v)
					JBCommand("givefd", k:EntIndex(), (k:GetNW("FreeDayTime",0) - CurTime()) <= 0)
				end,sort)
			end
		end, keep = true },
		{ title = _C("AlterSelectMenu"), select = function(s,p)
			if team.GetCount(TEAM_GUARD) > 1 then
				local pl,zam,lp = {},GetGMBool("JB_AlterSimon"),LocalPlayer()
				for k,v in pairs(team.GetAlive(TEAM_GUARD)) do
					if v == lp or not v:Alive() then
						continue
					end
					if zam == v then
						pl[v] = _C("ChangeAlter",v:Nick())
					else
						pl[v] = v:Nick()
					end
				end
				Select(_C("AlterSelectMenu"),pl,function(k,v)
					JBCommand("setalter",k:EntIndex())
				end)
			end
		end, keep = true },
		{ title = _C("RespawnMenu"), select = function(s,p)
			local pris = team.GetPlayers(TEAM_PRISIONER)
			if #pris > 1 then
				local stor = {}
				for k,v in pairs(pris) do
					if not v:Alive() then
						stor[v] = _C("RespawnPlayer", v:Nick())
					end
				end
				Select(_C("RespawnMenu"),stor,function(k,v)
					JBCommand("respawn", k:EntIndex(), 1)
				end)
			end
		end, keep = true }
	}))
	local SimonMenu = RegisterMenu({
	{ title = _C("Point"), select = function(s,p)
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.PointMenu)
	end },
	{ title = _C("StatusMenu"), select = function(s,p)
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.StatusMenu)
	end },
	{ title = _C("Cells"), think = setstatus, select = selectstatus, gvar = "JB_Jails", cvar = "opencells", dis = _C("Close"), en = _C("Open") },
	{ title = _C("VoiceMenu"), select = function(s,p)
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.VoiceMenu)
	end },
	{ title = _C("Count"), select = function(s,p)
		JBCommand("count")
	end },
	{ title = _C("GameMenu"), select = function(s,p)
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.GameMenu)
	end },
	{ title = _C("PrisSplit"), select = function(s,p)
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.SplitMenu)
	end },
	{ title = _C("SpawnMenu"), select = function(s,p)
		local spwnb = {}
		local gm = GAMEMODE:GetSpecGM()
		for k,v in pairs(gm.Spawnable) do
			spwnb[k] = { title = v.name, id = k, select = selectentity }
		end
		GAMEMODE:OpenQMenu(RegisterMenu(spwnb))
	end },
	--[[{ title = _C("BuyMenu"), select = function(s,p)
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.BuyMenu)
	end },]]
	{title = "#USE#",desc = _C("door"),think = function(s,p)
		if IsValid(qent) then
			if qent:IsPlayer() then
				s.hidden = false
				if qent:GetNW("JB_Gag") then
					s.title = _C("Ungag")
					s.type = 1
				else
					s.title = _C("Gag")
					s.type = 2
				end
				s.desc = qent:Nick()
				s.dcol = team.GetColor(qent:Team())
			elseif qent:GetClass():find("door") then
				s.hidden = false
				s.title = _C("door")
				s.desc = _C("Open")
				s.dcol = Color(0,200,0)
				s.type = 3
			else
				local gm = GAMEMODE:GetSpecGM()
				if gm.ValidProps[qent:GetClass()] then
					s.hidden = false
					s.title = _C("Remove","")
					s.desc = qent:GetClass()
					s.type = 4
				else
					s.hidden = true
				end
			end
		else
			s.hidden = true
		end
	end,select = function(s,p)
		if s.type == 1 then
			JBCommand("gag",qent:EntIndex(),false)
		elseif s.type == 2 then
			JBCommand("gag",qent:EntIndex(),true)
		elseif s.type == 3 then
			JBCommand("opendoor")
		elseif s.type == 4 then
			JBCommand("remove", qent:EntIndex())
		end
	end},
	})

	--[[local id = #PointMenu
	for i = 1,4 do
		table.insert(PointMenu,{title = "Point " .. i,desc = "Remove",hidden = true,point = i,type = 0,select = pointrem})
	end]]
	GM:PrecacheMenu("SimonMenu", SimonMenu)
	GM:PrecacheMenu("CTMenu", false)
	GM:PrecacheMenu("TMenu", false)
end
GM.HookGamemode("GetQMenuItems",function()
	local t = LocalPlayer():Team()
	if t == TEAM_GUARD then
		if GetGMEntity("JB_Simon") == LocalPlayer() then
			return GAMEMODE.Precache.SimonMenu
		else
			return GAMEMODE.Precache.CTMenu
		end
	elseif t == TEAM_PRISIONER then
		return GAMEMODE.Precache.TMenu
	else
		return GAMEMODE.Precache.TMenu
	end
end)
GM.HookGamemode("ShouldHideEntity",function(e)
	if e:IsPlayer() and e:GetNW("Rebel") then
		return false
	end
end)