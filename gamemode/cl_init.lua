include( "shared.lua" )
include( "sh_rules.lua" )
include( "sh_lang.lua" )
include( "cl_net.lua" )
include( "cl_hud.lua" )
include( "cl_legs.lua" )
include( "sh_gamemodes.lua" )

surface.CreateFont("JBHUDFONT", {
	font = "Arial",
	size = ScrH() / 34,
	weight = 600,
	extended = true
})
surface.CreateFont("JBHUDITEM", {
	font = "Monotype Corsiva",
	size = ScrH() / 34,
	weight = 600,
	extended = true
})
surface.CreateFont("JBHUDFONTNANO", {
	font = "Lucida Console",
	size = ScrH() / 70,
	weight = 350,
	extended = true
})
surface.CreateFont("JBHUDFONTHP", {
	font = "Segoe Script",
	size = ScrH() / 25,
	weight = 1000,
	extended = true
})
surface.CreateFont("JBHUDFONTTIME", {
	font = "Lucida Console",
	size = ScrH() / 34,
	weight = 500
})
surface.CreateFont("JBHUDFONTBOLD", {
	font = "Tahoma",
	size = ScrH() / 30,
	weight = 1000,
	extended = true
})
surface.CreateFont("JBHUDFONTSM", {
	font = "Tahoma",
	size = ScrH() / 45,
	weight = 700,
	extended = true
})
surface.CreateFont("JBHUDFONTMINI", {
	font = "Tahoma",
	size = ScrH() / 65,
	weight = 700,
	extended = true
})
surface.CreateFont("JBHUDFONTDEAD", {
	font = "Arial",
	size = ScrH() / 40,
	weight = 1000,
	extended = true
})
surface.CreateFont( "CSKillIcons" , {font = "csd", size = ScreenScale(30), weight = 500, additive = true})
surface.CreateFont( "CSSIcons" , {font = "csd", size = ScreenScale(60), weight = 500, additive = true})
surface.CreateFont( "HL2Icons", {font = "halflife2", size = ScreenScale(60), weight = 500, additive = true})

language.Add("trigger_hurt","кусачка")
language.Add("env_explosion","взрыв")
language.Add("worldspawn","шлепок")
language.Add("func_movelinear","балка")
language.Add("func_physbox","коробка")
language.Add("func_rotating","крутилка")
language.Add("func_door","дверь")
language.Add("func_door_rotating","крутилка")
language.Add("entityflame","огонёк")
language.Add("prop_physics","коробка")
language.Add("env_laser","выжигатель")
language.Add("prop_physics_multiplayer","коробка")
language.Add("env_fire","огонёк")

killicon.AddFont("headshot", "CSKillIcons", "D", Color( 255, 80, 0, 255 ))
killicon.AddFont("weapon_fist", "CSKillIcons", "p", Color( 255, 80, 0, 255 ))
killicon.AddFont("weapon_zombiefist", "CSKillIcons", "D", Color( 255, 0, 0, 255 ))
killicon.AddFont("wallkill", "HL2MPTypeDeath", "7", Color( 255, 80, 0, 255 ))
killicon.AddFont("weapon_medkit", "HL2Icons", "M", Color(80, 255, 80, 255))

local bhstop = 0xFFFF - IN_JUMP
local band = bit.band
function GM:CreateMove( uc )
	local lp = LocalPlayer()
	if GetGMBool("JB_Bhop") and lp:WaterLevel() < 3 and lp:Alive() and lp:GetMoveType() == MOVETYPE_WALK and not lp:InVehicle() and ( band(uc:GetButtons(), IN_JUMP) ) > 0 then
		if lp:IsOnGround() then
			uc:SetButtons( uc:GetButtons() or IN_JUMP )
		else
			uc:SetButtons( band(uc:GetButtons(), bhstop) )
		end
	end
end
function GM:PostDrawViewModel(vm, ply, weapon)
	if weapon.UseHands or not weapon:IsScripted() then
		local hands = ply:GetHands()
		if IsValid( hands ) and IsValid( hands:GetParent() ) then
			if ( not hook.Call( "PreDrawPlayerHands", self, hands, vm, ply, weapon ) ) then
				if ( weapon.ViewModelFlip ) then render.CullMode( MATERIAL_CULLMODE_CW ) end
				hands:DrawModel()
				render.CullMode( MATERIAL_CULLMODE_CCW )
			end
			hook.Call( "PostDrawPlayerHands", self, hands, vm, ply, weapon )
		end
	end
	if ( weapon.PostDrawViewModel == nil ) then return false end
	return weapon:PostDrawViewModel( vm, Wweapon, ply )
end

function JBCommand(cmd,...)
	local args = {}
	for k,v in pairs({...}) do
		args[k] = tostring(v)
	end
	print("jb " .. cmd .. " " .. table.concat(args," "))
	RunConsoleCommand("jb",cmd,unpack(args))
end
local WepColors = {Color(200,0,0),Color(0,200,0),Color(0,0,200),Color(200,200,0),Color(0,200,200),Color(255,255,255)}
GM.Precache = {}
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
do
	local Precache = GM.Precache
	local DropWeapon = {title = "Выбросить",desc = "#CURWPN#",think = function(s,p)
		local w = p:GetActiveWeapon()
		if IsValid(w) then
			if GAMEMODE.NoDropable[w:GetClass()] then
				s.hidden = true
				return
			end
			s.hidden = false
			s.desc = w.PrintName
			s.dcol = WepColors[w.Kind or 6] or color_white
		end
	end,select = function(s,p)
		net.Start("CMDNET")
		net.WriteUInt(1,4)
		net.SendToServer()
	end}
	local SimonMenu = RegisterMenu({
	table.Copy(DropWeapon),
	{title = "Точка",desc = "",select = function(s,p)
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
		GAMEMODE:OpenQMenu(GAMEMODE.Precache.PointMenu)
	end},
	{title = "#USE#",desc = "дверь",think = function(s,p)
		if IsValid(qent) then
			if qent:IsPlayer() then
				s.hidden = false
				if qent:GetNWBool("JB_Gag") then
					s.title = "Размутить"
					s.type = 1
				else
					s.title = "Заглушить"
					s.type = 2
				end
				s.desc = qent:Nick()
				s.dcol = team.GetColor(qent:Team())
			elseif qent:GetClass():find("door") then
				s.hidden = false
				s.title = "Открыть"
				s.desc = "дверь"
				s.dcol = WepColors[2]
				s.type = 3
			else
				s.hidden = true
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
		end
	end},
	{title = "Голос T",desc = "",think = function(s,p)
		if GetGMBool("JB_PrisGag") then
			s.desc = "Включить"
			s.dcol = Color(0,200,0)
			s.type = 1
		else
			s.desc = "Выключить"
			s.dcol = Color(200,0,0)
			s.type = 2
		end
	end,select = function(s,p)
		JBCommand("prisgag",s.type == 2)
	end},
	{title = "Голос CT",desc = "",think = function(s,p)
		if GetGMBool("JB_GuardGag") then
			s.desc = "Включить"
			s.dcol = Color(0,200,0)
			s.type = 1
		else
			s.desc = "Выключить"
			s.dcol = Color(200,0,0)
			s.type = 2
		end
	end,select = function(s,p)
		JBCommand("guardgag",s.type == 2)
	end},
	{title = "Бокс",desc = "",think = function(s,p)
		if GetGMBool("JB_Box") then
			s.desc = "Выключить"
			s.dcol = Color(200,0,0)
			s.type = 1
		else
			s.desc = "Включить"
			s.dcol = Color(0,200,0)
			s.type = 2
		end
	end,select = function(s,p)
		JBCommand("box",s.type == 2)
	end},
	{title = "Столкновения",desc = "",think = function(s,p)
		if GetGMBool("JB_Collision") then
			s.desc = "Выключить"
			s.dcol = Color(200,0,0)
			s.type = 1
		else
			s.desc = "Включить"
			s.dcol = Color(0,200,0)
			s.type = 2
		end
	end,select = function(s,p)
		JBCommand("collision",s.type == 2)
	end},
	{title = "Деление T",desc = "",select = function(s,p)
		GAMEMODE:OpenQMenu(Precache.SplitMenu)
	end},
	{title = "Клетки",desc = "",think = function(s,p)
		if GetGMBool("JB_Jails") then
			s.desc = "Закрыть"
			s.dcol = Color(200,0,0)
			s.type = 2
		else
			s.desc = "Открыть"
			s.dcol = Color(0,200,0)
			s.type = 1
		end
	end,select = function(s,p)
		JBCommand("opencells",s.type == 1)
	end},
	{title = "Распрыжка",desc = "",think = function(s,p)
		if GetGMBool("JB_Bhop") then
			s.desc = "Выключить"
			s.dcol = Color(200,0,0)
			s.type = 1
		else
			s.desc = "Включить"
			s.dcol = Color(0,200,0)
			s.type = 2
		end
	end,select = function(s,p)
		JBCommand("bhop",s.type == 2)
	end}
	})
	Precache.SimonMenu = SimonMenu
	local function pointrem(s,p)
		JBCommand("delpoint")
	end
	local PointMenu = {
		{title = "\"Точка\"",desc = "",type = 1,pref = "",max = 4,select = pointsel},
		{title = "\"Круговой\"",desc = "",type = 2,pref = "C",max = 4,select = pointsel},
		{title = "\"Выстроиться\"",desc = "",type = 3,pref = "L",max = 2,select = pointsel},
		{title = "Убрать",desc = "",select = pointrem},
	}
	local id = #PointMenu
	--Precache.PointTypes=id
	--[[for i=1,4 do
		table.insert(PointMenu,{title="Поинт "..i,desc="Убрать",hidden=true,point=i,type=0,select=pointrem})
	end]]
	Precache.PointMenu = RegisterMenu(PointMenu)
	local function SelSplit(Eb)
		JBCommand("splitteam", true, Eb.count or 2)
	end
	local SplitMenu = RegisterMenu({
		{
			title = "Убрать деление",
			select = function()
				JBCommand("splitteam", false, 0)
			end
		},
		{
			title = "2 команды",
			count = 2,
			select = SelSplit
		},
		{
			title = "3 команды",
			count = 3,
			select = SelSplit
		},
		{
			title = "4 команды",
			count = 4,
			select = SelSplit
		}
	})
	Precache.SplitMenu = SplitMenu
	local CTMenu = RegisterMenu({table.Copy(DropWeapon)})
	Precache.CTMenu = CTMenu
	local TMenu = RegisterMenu({table.Copy(DropWeapon)})
	Precache.TMenu = TMenu
end
function GM:PlayerButtonDown(ply,bn)
	if bn == KEY_F1 then
		InfoMenu()
	elseif bn == KEY_F2 then
		if not IsValid(frameteam) then
			createtmmn()
		end
	elseif bn == KEY_F3 and LocalPlayer():Alive() then
		if LocalPlayer():Team() == TEAM_GUARD then
			if GetGMEntity("JB_Simon") == LocalPlayer() then
				mksmmn()
			else
				RunConsoleCommand("say","!cmd")
			end
		elseif LocalPlayer():Team() == TEAM_PRISIONER then
			if GetGMEntity("JB_LR") == LocalPlayer() then
				mklrmn()
			else
				RunConsoleCommand("say","!lr")
			end
		end
	end
end




-----==MENU==-----
function makeinfo(parent,where)
	local a,b = ScreenScale(2.5),ScreenScale(5)
	local dhtml = vgui.Create( "HTML", parent )
	dhtml:Dock(FILL)
	dhtml:DockMargin(b,a,b,a)
	dhtml:SetHTML(where)
	local relbutton = vgui.Create( "Jailbreak_Button", parent )
	relbutton:Dock(BOTTOM)
	relbutton:DockMargin(a,b,a,b)
	relbutton:SetText("Назад")
	relbutton:SetColor(Color(0,200,0))
	relbutton.DoClick = function()
		dhtml:Remove()
		relbutton:Remove()
		parent:Select(true)
	end
end
function InfoMenu()
	if IsValid(InfoPanel) then
		--InfoPanel:SetVisible(true)
		--return
		InfoPanel:Remove()
	end
	local ip = vgui.Create( "Jailbreak_Main" )
	ip:SetSize( ScreenScale(300), ScreenScale(120) )
	ip:SetTitle( "JailBreak Информация" )
	ip:SetDeleteOnClose(false)
	ip:SetDraggable(true)
	ip:MakePopup()
	ip:Center()
	InfoPanel = ip
	local smmn = vgui.Create("DPanel",ip)
	smmn.Paint = nil
	smmn:Dock(FILL)
	ip.w,ip.h = ip:GetSize()
	function smmn:Select(bl,w,h)
		for k,v in pairs(self.Table) do
			v:SetVisible(bl)
		end
		if bl then
			ip:SetSize(ip.w,ip.h)
		else
			ip:SetSize(w,h)
		end
		ip:Center()
	end
	infoone = vgui.Create("Jailbreak_Button",smmn)
	infoone:SetText("Правила режима")
	function infoone:DoClick()
		smmn:Select(false,ip.w,ip.h * 2)
		makeinfo(smmn,GAMEMODE.HTMLR)
	end
	infotwo = vgui.Create("Jailbreak_Button",smmn)
	infotwo:SetText("Правила сервера")
	function infotwo:DoClick()
		smmn:Select(false,ip.w,ip.h * 2)
		makeinfo(smmn,GAMEMODE.HTMLP)
	end
	infotre = vgui.Create("Jailbreak_Button",smmn)
	infotre:SetText("Информация о режиме")
	function infotre:DoClick()
		smmn:Select(false,ip.w,ip.h * 2)
		makeinfo(smmn,GAMEMODE.HTMLI)
	end
	smmn.Table = {infoone,infotwo,infotre}
	local sz = (ip:GetWide() - ScreenScale(35)) / #smmn.Table
	local marg = ScreenScale(5)
	for k,v in pairs(smmn.Table) do
		v:Dock(LEFT)
		v:DockMargin(marg,marg,marg,marg)
		v:SetWide(sz)
	end
end
local GMLIST = {
	["FreeDay"] = "Фридей",
	["ZFD"] = "\"Атака зомби\"",
	["Defense"] = "\"Оборона\"",
	["Hide&Seek"] = "\"Прятки\"",
	["TeamWar"] = "\"Битва команд\""
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
local afn,fn,bs,vce,spl,pn,dpn,dcr,dln = "Дополнительные функции","Основные функции","Базовые функции","Вкл/Выкл голосового чата у","Деление T","Поинт","Убрать точку","Убрать круг","Убрать линию"
local SimonMenu = {{"Перевод CT/T",
function()
	if player.GetCount() > 1 then
		local ct,t,lp = {},{},LocalPlayer()
		for k,v in pairs(player.GetAll()) do
			if v == lp or not v:Alive() then
				continue
			end
			if v:Team() == TEAM_GUARD then
				ct[v] = string.format("Перевести %s за T",v:Nick())
			elseif v:Team() == TEAM_PRISIONER then
				t[v] = string.format("Перевести %s за CT",v:Nick())
			end
		end
		local sort = t_Add({},ct)
		t_Add(sort,t)
		table.Merge(ct,t)
		Select("Перевод игроков",ct,function(k,v)
			JBCommand("changeteam",k:EntIndex())
		end,sort)
	end
end,bs},
{"Управление FD",
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		local tk,gv = {},{}
		for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
			if not v:Alive() then continue end
			if v:GetNWFloat("FreeDayTime",0) > 0 then
				tk[v] = string.format("Забрать фридей у %s",v:Nick())
			else
				gv[v] = string.format("Выдать фридей %s",v:Nick())
			end
		end
		local sort = t_Add({},tk)
		t_Add(sort,gv)
		table.Merge(tk,gv)
		Select("Управление FD",tk,function(k,v)
			JBCommand("givefd",k:EntIndex(),v:sub(1,2) == "В")
		end,sort)
	end
end,bs},
{"Выбор заместителя",
function()
	if team.GetCount(TEAM_GUARD) > 1 then
		local pl,zam,lp = {},GetGMBool("JB_ZamCmd"),LocalPlayer()
		for k,v in pairs(team.GetAlive(TEAM_GUARD)) do
			if v == lp or not v:Alive() then
				continue
			end
			if zam == v then
				pl[v] = string.format("Снять заместителя %s.",v:Nick())
			else
				pl[v] = v:Nick()
			end
		end
		Select("Выбор заместителя",pl,function(k,v)
			JBCommand("setalter",k:EntIndex())
		end)
	end
end,bs},
{"2 команды",split,spl,bl = true,cnt = 2},
{"3 команды",split,spl,bl = true,cnt = 3},
{"4 команды",split,spl,bl = true,cnt = 4},
{"Убрать",split,spl,bl = false,cnt = 2},
{"\"Точка\"",setpnt,pn,type = 1,pref = "",max = 4},
{"\"Круг\"",setpnt,pn,type = 2,pref = "C",max = 4},
{"\"Выстроиться\"",setpnt,pn,type = 3,pref = "L",max = 2},
{"CT",
function()
	if team.GetCount(TEAM_GUARD) > 1 then
		smmn:SetVisible(false)
		JBCommand("guardgag",not GetGMBool("JB_GuardGag"))
	end
end,vce},
{"T",
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:SetVisible(false)
		JBCommand("prisgag",not GetGMBool("JB_PrisGag"))
	end
end,vce},
{"Игрока",function(s)
	local tk,gv = {},{}
	for k,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
		if not v:Alive() then continue end
		if v:GetNWBool("JB_Gag",0) then
			tk[v] = string.format("Размутить %s",v:Nick())
		else
			gv[v] = string.format("Заглушить %s",v:Nick())
		end
	end
	local sort = t_Add({},tk)
	t_Add(sort,gv)
	table.Merge(tk,gv)
	Select("Управление голосовым чатом игроков",tk,function(k,v)
		JBCommand("gag",k:EntIndex(),v:sub(1,2) == "З")
	end,sort)
end,vce},
{"Клетки",
function()
	if JailsOpened < CurTime() then
		smmn:SetVisible(false)
		JBCommand("opencells",not GetGMBool("JB_Jails"))
	end
end,fn},
{"Бокс",
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:SetVisible(false)
		JBCommand("box",not GetGMBool("JB_Box"))
	end
end,fn},
{"Столкновения",
function()
	if team.GetCount(TEAM_PRISIONER) > 1 then
		smmn:SetVisible(false)
		JBCommand("collision",not GetGMBool("JB_Collision"))
	end
end,fn},
{"Распрыжка",
function()
	smmn:SetVisible(false)
	JBCommand("bhop",not GetGMBool("JB_Bhop"))
end,fn},
{"Тип раунда",
function()
	if (team.GetCount(TEAM_PRISIONER) + team.GetCount(TEAM_GUARD)) > 1 then
		Select("Игровые режимы",GMLIST,function(k,v)
			JBCommand("startgm",k)
		end)
	end
end,afn},
{"Открыть дверь",
function()
	smmn:SetVisible(false)
	JBCommand("opendoor")
end,afn},
{"Точка 1",rempnt,dpn,id = 1,type = 1},
{"Точка 2",rempnt,dpn,id = 2,type = 1},
{"Точка 3",rempnt,dpn,id = 3,type = 1},
{"Точка 4",rempnt,dpn,id = 4,type = 1},
{"Круг 1",rempnt,dcr,id = 1,type = 2},
{"Круг 2",rempnt,dcr,id = 2,type = 2},
{"Круг 3",rempnt,dcr,id = 3,type = 2},
{"Круг 4",rempnt,dcr,id = 4,type = 2},
{"Линия 1",rempnt,dln,id = 1,type = 3},
{"Линия 2",rempnt,dln,id = 2,type = 3},
}
GM.JailsAvailable = true
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
	smmn:SetTitle("Меню командира")
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
function GenMenu(tab,parent)
	local w,h = ScreenScale(1),ScreenScale(9)
	local groups = {}
	for k,v in pairs(tab) do
		local btn
		if v[3] then
			if groups[v[3]] == nil then
				local par = parent
				if type(v[3]) == "string" then
					local head = vgui.Create("DPanel",parent)
					head:Dock(TOP)
					head:SetTall(h * 2)
					head:DockMargin(h,0,h,0)
					local c = ColorRandLight()
					head.Color = c
					function head:Paint(w,h)
						surface.SetDrawColor(self.Color)
						surface.DrawRect(2,2,w-4,h-4)
					end
					local doc = vgui.Create("DPanel",head)
					doc:Dock(TOP)
					doc.Text = v[3]
					doc:SetTall(h * 0.7)
					doc.Color = Color(c.r-128,c.g-128,c.b-128)
					doc.HColor = Color(c.r-64,c.g-64,c.b-64)
					function doc:Paint(w,h)
						local txt = self.Text
						surface.SetFont("JBHUDFONTMINI")
						local w1,h1 = surface.GetTextSize(txt)
						surface.SetTextColor(self.HColor)
						surface.SetTextPos(w * .5-w1 * .5-1,2)
						surface.DrawText(txt)
						surface.SetTextPos(w * .5-w1 * .5,1)
						surface.DrawText(txt)

						surface.SetTextColor(self.Color)
						surface.SetTextPos(w * .5-w1 * .5,2)
						surface.DrawText(txt)
					end
					par = head
				end
				local group = vgui.Create("DPanel",par)
				group:Dock(TOP)
				group:DockMargin(h,w,h,w)
				group:SetTall(h)
				group.Paint = nil
				group.UseGroup = par ~= parent
				groups[v[3]] = group
			end
			btn = vgui.Create("Jailbreak_Button", groups[v[3]])
			btn:Dock(LEFT)
		else
			btn = vgui.Create("Jailbreak_Button", parent)
			btn:Dock(TOP)
			btn:DockMargin(h,w,h,w)
		end
		btn:SetFont("JBHUDFONTNANO")
		btn:SetText(v[1])
		btn:SetTall(h)
		for i,m in pairs(v) do
			if type(i) == "string" then
				btn[i] = m
			end
		end
		btn.DoClick = v[2]
	end
	for k,v in pairs(groups) do
		local ch = v:GetChildren()
		local sz = (parent:GetWide() - h - h) / (#ch + 1)
		local x1,x2,x3,x4 = v:GetDockMargin()
		if v.UseGroup then
			v:DockMargin(sz * .5,x2,x3,x4)
		else
			v:DockMargin(sz * .5 + h * .5,x2,x3,x4)
		end
		for i,m in pairs(ch) do
			m:SetWide(sz)
		end
	end
	parent:FitY()
end
local function selectct(w)
	Select("Выбор CT",team.GetAlive(TEAM_GUARD),function(k,v)
		JBCommand("duel",v:EntIndex(),w)
	end)
end
local LastRequest = {
{"Убить CT",function()
	lrmn:Close()
	JBCommand("killct")
end},
{"Взять фридей",function()
	lrmn:Close()
	JBCommand("nextfd")
end},
{"Битва на Deagle",function()
	selectct("weapon_dueldeagle")
end},
{"Битва на Scout",function()
	selectct("weapon_duelscout")
end},
{"Битва на AWP",function()
	selectct("weapon_duelawp")
end},
{"Битва с любым оружием",function()
	selectct("random")
end},
{"Последний бунт",function()
	lrmn:Close()
	JBCommand("lastwar")
	LocalPlayer().AlreadyChoose = true
end},
{"Дуэль на ножах",function()
	selectct("melee")
end}}
function mklrmn()
	if IsValid(lrmn) then
		if not lrmn:IsVisible() then
			lrmn:SetVisible(true)
		end
		return
	end
	lrmn = vgui.Create("Jailbreak_Main")
	lrmn:SetPos(0, 0)
	lrmn:SetSize(ScreenScale(160),ScreenScale(150))
	lrmn:SetTitle("Меню последнего заключённого")
	lrmn:MakePopup()
	GenMenu(LastRequest,lrmn)
	lrmn:Center()
end
function Select(title,list,suc,sort)
	local mn = DermaMenu()
	local press = function(s)
		suc(s.id,s.var)
	end
	local function gmenu(k,v)
		local opt = mn:AddOption(isentity(v) and v:GetName() or tostring(v),press)
		opt.id = k
		opt.var = v
	end
	if sort then
		local ln = #sort
		for i = 1,ln do
			k = sort[i]
			v = list[k]
			if v then
				gmenu(k,v)
			end
		end
	else
		for k, v in pairs(list) do
			gmenu(k,v)
		end
	end
	local x,y = input.GetCursorPos()
	mn:SetPos(x + 5,y - 5)
	mn:Open()
	--[[if IsValid(SelectPanel) then
		SelectPanel:Remove()
	end
	local SP = vgui.Create("Jailbreak_Main")
	SP:SetSize(ScreenScale(200),ScreenScale(120))
	SP:SetTitle(title)
	SP:MakePopup()
	SP:Center()
	local slc = vgui.Create("DPanelList",SP)
	slc:DockMargin(ScreenScale(5),5,ScreenScale(5),5)
	slc:Dock(FILL)
	slc:EnableVerticalScrollbar(true)
	function slc:Paint(w, h)
		surface.SetDrawColor( 255, 255, 0, 128)
		surface.DrawRect(0, 0, w, h)
	end
	local function gmenu(k,v)
		local label = vgui.Create( "Jailbreak_Button", slcct )
		label:SetFont("JBHUDFONTMINI")
		label.var=v
		label.id=k
		label:SetText(isentity(v) and v:GetName() or tostring(v))
		label:SizeToContents()
		label:SetTall(ScreenScale(12))
		function label:DoClick()
			SP:Remove()
			suc(self.id,self.var)
		end
		slc:AddItem(label)
	end
	if sort then
		local ln=#sort
		for i=1,ln do
			k=sort[i]
			v=list[k]
			if v then
				gmenu(k,v)
			end
		end
	else
		for k, v in pairs(list) do
			gmenu(k,v)
		end
	end]]--
end
-----==MENU==-----
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if hitgroup == HITGROUP_HEAD then
		local arm = ply:Armor()
		if arm > 65 then
			return true
		end
	end
end
local DeathNoticeTime = 10
function GM:DrawDeathNotice(x,y)
	x,y = x * ScrW(),y * ScrH()
	local ct,cnt = CurTime(),0
	for i, m in pairs(self.DeathsTable) do
		if m[0] < ct then
			self.DeathsTable[i] = nil
		end
		cnt = cnt + 1
		local x1,y1 = m[8],cnt * y
		local alp = 255 * (m[0]-ct) / DeathNoticeTime
		local w, h = killicon.GetSize(m[3])
		if not w then continue end
		w = w * .5
		if m[1] then
			m[2].a = alp
			draw.SimpleText(m[1], "JBHUDFONTDEAD", x1-w, y1, m[2], TEXT_ALIGN_RIGHT)
		end
		killicon.Draw( x1, y1, m[3], alp )
		local killwall,killhead = 0,0
		if m[7] then
			killwall = killicon.GetSize("wallkill")
			if killwall then
				killicon.Draw( x1 + w + killwall * .5, y1, "wallkill", alp )
			end
		end
		if m[6] then
			killhead = killicon.GetSize("headshot")
			if killhead then
				killicon.Draw( x1 + w + killwall * .5 + killhead * .5, y1, "headshot", alp )
			end
		end
		if m[4] then
			m[5].a = alp
			draw.SimpleText(m[4], "JBHUDFONTDEAD", x1 + w + killwall * .5 + killhead, y1, m[5], TEXT_ALIGN_LEFT )
		end
	end
	return true
end
GM.DeathsTable = GM.DeathsTable or {}
function GM:AddDeathNotice(vic,vict,inf,atk,atkt,headshot,wallkill)
	if not killicon.Exists(inf) then
		local tab = weapons.Get(inf)
		if tab then
			inf = tab.PrintName
		else
			inf = string.Replace( inf, "weapon_", "" )
			inf = string.Replace( inf, "_", " " )
		end
	end
	if vict then
		vict = table.Copy(team.GetColor(vict))
	end
	if atkt then
		atkt = table.Copy(team.GetColor(atkt))
	end
	local w, h = killicon.GetSize(inf)
	if w then
		if headshot then
			local killhead = killicon.GetSize("headshot")
			w = w + killhead
		end
		if wallkill then
			local killwall = killicon.GetSize("wallkill")
			w = w + killwall * .5
		end
		surface.SetFont("JBHUDFONTDEAD")
		w = w + (vic and surface.GetTextSize(vic) * .5 or 0) + (atk and surface.GetTextSize(atk) * .5 or 0)
	end
	table.insert(self.DeathsTable,{[0] = CurTime() + DeathNoticeTime,atk,atkt,inf,vic,vict,headshot,wallkill,ScrW() - w})
end
local function RecvPlayerKilledByPlayer()
	local t = net.ReadUInt(2)
	if t == 0 then
		local ent = net.ReadEntity()
		GAMEMODE:AddDeathNotice(nil,0,"suicide",ent:Nick(),ent:Team())
	elseif t == 1 then
		GAMEMODE:AddDeathNotice(net.ReadString(),net.ReadUInt(4),net.ReadString(),net.ReadString(),net.ReadUInt(4),net.ReadBool(),net.ReadBool())
	elseif t == 2 then
		local a,i,p = net.ReadEntity(),net.ReadEntity(),net.ReadEntity()
		GAMEMODE:AddDeathNotice(a:Nick(),a:Team(),i:GetClass(),p:Nick(),p:Team(),net.ReadBool(),net.ReadBool())
	elseif t == 3 then
		local p,i,a = net.ReadEntity(),net.ReadString(),net.ReadString()
		GAMEMODE:AddDeathNotice("#" .. a,-1,i,p:Nick(),p:Team())
	end
end
net.Receive( "PlayerKilled", RecvPlayerKilledByPlayer )


hook.Add("CalcView","DeathView",function(ply)
	if not ply:Alive() then
		local rag,at = ply:GetRagdollEntity()
		if ply:GetObserverTarget() == rag and ply:GetObserverMode() == OBS_MODE_IN_EYE and IsValid(rag) then
			at = rag:LookupAttachment( "eyes" )
			if at then
				at = rag:GetAttachment( at )
				return {origin = at.Pos + at.Ang:Forward() * 10,angles = at.Ang,fov = 90,znear = 1}
			end
		end
	end
end)
function CreateTexture(tname,sw,sh,renderfunc)
	local rttex = GetRenderTargetEx(tname,sw,sh,RT_SIZE_OFFSCREEN,MATERIAL_RT_DEPTH_SEPARATE,6,0,IMAGE_FORMAT_BGRA8888)
	local w,h,OldRT = ScrW(),ScrH(),render.GetRenderTarget()
	render.SetRenderTarget(rttex)
	render.SetViewPort(0,0,sw,sh)
		render.Clear(0,0,0,0,true)
		render.SetBlend(1)
		cam.Start2D()
			renderfunc(sw,sh)
		cam.End2D()
	render.SetViewPort(0,0,w,h)
	render.SetRenderTarget(OldRT)
	return rttex
end
local kv = {["$basetexture"] = "models/shadertest/shader5",
["$vertexalpha"] = 1,	["$vertexcolor"] = 1}
TextureQueue = TextureQueue or {}
local function GMPostRender(self)
	local k,v = next(TextureQueue)
	if k then
		TextureQueue[k] = nil
		local rtex = CreateTexture(v[1],v[2],v[3],v[4])
		kv["$basetexture"] = rtex:GetName()
		mat = CreateMaterial(v[1],"UnlitGeneric",kv)
		if v[5] then
			v[5](mat)
		end
	else
		self.PostRender = nil
	end
end
function GM:RenderTexture(name,w,h,renderfunc,callback)
	TextureQueue[#TextureQueue + 1] = {name,w,h,renderfunc,callback}
	self.PostRender = GMPostRender
end

