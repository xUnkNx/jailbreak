local GMLIST = {
	["FreeDay"] = _C("Freeday"),
	["ZFD"] = _C("ZombieFD"),
	["Defense"] = _C("Defense"),
	["Hide&Seek"] = _C("HideNSeek"),
	["TeamWar"] = _C("TeamWars")
}
local JailsOpened = 0
local setpnt = function(s)
	smmn:Close()
	pointsel(s)
end
local rempnt = function(s)
	smmn:Close()
	JBCommand("point",s.id,false,s.type)
end
local split = function(s)
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:Close()
		JBCommand("splitteam",s.bl,s.cnt)
	end
end
local function t_Add(t,a)
	local i = #t
	for k,v in pairs(a) do
		i = i + 1
		t[i] = k
	end
	return t
end
local afn,fn,bs,vce,spl,pn,dpn,dcr,dln = _C("AdditionalFuncs"),_C("MainFuncs"),_C("BasicFuncs"),_C("ToggleVoiceChat"),_C("PrisSplit"),_C("Point"),_C("Remove",_C("Point")),_C("Remove",_C("Circle")),_C("Remove",_C("LineUp"))
local SimonMenu = {{_C("TeamManagement"),
function()
	if player.GetCount() > 1 then
		local ct,t,lp = {},{},LocalPlayer()
		for k,v in pairs(player.GetAll()) do
			if v == lp or not v:Alive() then
				continue
			end
			if v:Team() == TEAM_GUARD then
				ct[v] = _C("ChangeTeam", team.GetName(TEAM_PRISIONER), v:Nick())
			elseif v:Team() == TEAM_PRISIONER then
				t[v] = _C("ChangeTeam", team.GetName(TEAM_GUARD), v:Nick())
			end
		end
		local sort = t_Add({},ct)
		t_Add(sort,t)
		table.Merge(ct,t)
		Select(_C("TeamManagement"),ct,function(k,v)
			JBCommand("changeteam",k:EntIndex())
		end,sort)
	end
end,bs},
{_C("FreedayMenu"),
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		local tk,gv = {},{}
		for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
			if not v:Alive() then continue end
			if v:GetNW("FreeDayTime",0) > 0 then
				tk[v] = _C("GiveFD",0,v:Nick())
			else
				gv[v] = _C("GiveFD",1,v:Nick())
			end
		end
		local sort = t_Add({},tk)
		t_Add(sort,gv)
		table.Merge(tk,gv)
		Select(_C("FreedayMenu"),tk,function(k,v)
			JBCommand("givefd", k:EntIndex(), v:GetNW("FreeDayTime",0) <= 0)
		end,sort)
	end
end,bs},
{_C("AlterSelectMenu"),
function()
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
end,bs},
{_C("TeamsCnt",2),split,spl,bl = true,cnt = 2},
{_C("TeamsCnt",3),split,spl,bl = true,cnt = 3},
{_C("TeamsCnt",4),split,spl,bl = true,cnt = 4},
{_C("Remove"),split,spl,bl = false,cnt = 2},
{_C("Point"),setpnt,pn,type = 1,pref = "",max = 4},
{_C("Circle"),setpnt,pn,type = 2,pref = "C",max = 4},
{_C("LineUp"),setpnt,pn,type = 3,pref = "L",max = 2},
{team.GetName(TEAM_GUARD),
function()
	if team.GetCount(TEAM_GUARD) > 1 then
		smmn:SetVisible(false)
		JBCommand("guardgag",not GetGMBool("JB_GuardGag"))
	end
end,vce},
{team.GetName(TEAM_PRISIONER),
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:SetVisible(false)
		JBCommand("prisgag",not GetGMBool("JB_PrisGag"))
	end
end,vce},
{_C("PlayerGag"),function(s)
	local tk,gv = {},{}
	for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
		if not v:Alive() then continue end
		if v:GetNW("JB_Gag",0) then
			tk[v] = _C("PlayerGagFlag",0,v:Nick())
		else
			gv[v] = _C("PlayerGagFlag",1,v:Nick())
		end
	end
	local sort = t_Add({},tk)
	t_Add(sort,gv)
	table.Merge(tk,gv)
	Select(_C("PlayerGagMenu"),tk,function(k,v)
		JBCommand("gag", k:EntIndex(), v:GetNW("JB_Gag",0) == 0)
	end,sort)
end,vce},
{_C("Cells"),
function()
	if JailsOpened < CurTime() then
		smmn:SetVisible(false)
		JBCommand("opencells",not GetGMBool("JB_Jails"))
	end
end,fn},
{_C("Boxing"),
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:SetVisible(false)
		JBCommand("box",not GetGMBool("JB_Box"))
	end
end,fn},
{_C("Collisions"),
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:SetVisible(false)
		JBCommand("collision",not GetGMBool("JB_Collision"))
	end
end,fn},
{_C("Bhop"),
function()
	smmn:SetVisible(false)
	JBCommand("bhop",not GetGMBool("JB_Bhop"))
end,fn},
{_C("GameModes"),
function()
	if (team.GetCount(TEAM_PRISIONER) + team.GetCount(TEAM_GUARD)) > 1 then
		Select(_C("GameModes"),GMLIST,function(k,v)
			JBCommand("startgm",k)
		end)
	end
end,afn},
{_C("Open",_C("door")),
function()
	smmn:SetVisible(false)
	JBCommand("opendoor")
end,afn},
{_C("Point",1),rempnt,dpn,id = 1,type = 1},
{_C("Point",2),rempnt,dpn,id = 2,type = 1},
{_C("Point",3),rempnt,dpn,id = 3,type = 1},
{_C("Point",4),rempnt,dpn,id = 4,type = 1},
{_C("Circle",1),rempnt,dcr,id = 1,type = 2},
{_C("Circle",2),rempnt,dcr,id = 2,type = 2},
{_C("Circle",3),rempnt,dcr,id = 3,type = 2},
{_C("Circle",4),rempnt,dcr,id = 4,type = 2},
{_C("LineUp",1),rempnt,dln,id = 1,type = 3},
{_C("LineUp",2),rempnt,dln,id = 2,type = 3},
}
function mksmmn()
	if ButtonCD > CurTime() then return end
	ButtonCD = CurTime() + ButtonDelay * 2
	if IsValid(smmn) then
		if smmn:IsVisible() then
			smmn:Close()
		else
			smmn:SetVisible(true)
		end
		return
	end
	smmn = vgui.Create("Jailbreak_Main")
	smmn:SetSize(ScreenScale(250),ScreenScale(220))
	smmn:SetTitle(_C("SimonMenu"))
	smmn:SetDeleteOnClose(false)
	smmn:SetDraggable(true)
	smmn:MakePopup()
	GenMenu(SimonMenu,smmn)
	smmn:Center()
	function smmn:OnClose()
		CloseDermaMenus()
	end
	function smmn:OnKeyCodePressed(key)
		if key == KEY_F3 then
			mksmmn()
		end
	end
end