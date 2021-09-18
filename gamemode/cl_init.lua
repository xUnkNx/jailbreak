include( "sh_lang.lua" )
include( "shared.lua" )
include( "sh_maps.lua" )
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
surface.CreateFont("CSKillIcons", {
	font = "csd",
	size = ScreenScale(30),
	weight = 500,
	additive = true
})
surface.CreateFont("CSSIcons", {
	font = "csd",
	size = ScreenScale(60),
	weight = 500,
	additive = true
})
surface.CreateFont("HL2Icons", {
	font = "halflife2",
	size = ScreenScale(60),
	weight = 500,
	additive = true
})

language.Add("trigger_hurt", _T("hurt"))
language.Add("env_explosion", _T("explosion"))
language.Add("worldspawn", _T("worldhurt"))
language.Add("func_movelinear", _T("balk"))
language.Add("func_physbox", _T("box"))
language.Add("func_rotating", _T("rotating"))
language.Add("func_door", _T("door"))
language.Add("func_door_rotating", _T("box"))
language.Add("func_physbox_multiplayer", _T("crate"))
language.Add("entityflame", _T("fire"))
language.Add("prop_physics", _T("box"))
language.Add("env_laser", _T("laser"))
language.Add("prop_physics_multiplayer", _T("box"))
language.Add("env_fire", _T("fire"))
language.Add("ATK_PRISIONER", _T("Prisiner"))
language.Add("Kevlar", _T("Kevlar"))
language.Add("KevlarHelm", _T("KevlarHelm"))
language.Add("Hands", _T("Hands"))

killicon.AddFont("headshot", "CSKillIcons", "D", Color(255, 80, 0, 255))
killicon.AddFont("weapon_fist", "CSKillIcons", "p", Color(255, 80, 0, 255))
killicon.AddFont("weapon_zombiefist", "CSKillIcons", "D", Color(255, 0, 0, 255))
killicon.AddFont("wallkill", "HL2MPTypeDeath", "7", Color(255, 80, 0, 255))
killicon.AddFont("weapon_medkit", "HL2MPTypeDeath", "5", Color(80, 255, 80, 255))

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
function GM:InitPostEntity()
	LP = LocalPlayer()
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
function GM:PlayerButtonDown(ply,bn)
	if bn == KEY_F2 then
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
function Select(title,list,suc,sort)
	gui.EnableScreenClicker(true)
	local mn = DermaMenu()
	RegisterDermaMenuForClose(mn)
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
	function mn:OnRemove()
		gui.EnableScreenClicker(false)
	end
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
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if hitgroup == HITGROUP_HEAD then
		local arm = ply:Armor()
		if arm > 65 then
			return true
		end
	end
end
local HUDHide = {
	["CHudHealth"] = true,
	["CHudSuitPower"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true
}
function GM:HUDShouldDraw( No )
	if HUDHide[No] then return false end
	return true
end
function GM:ShouldHideEntity(ent)
	return true
end
function GM:NotifyShouldTransmit(pl,bl)
	if not hook.Run("ShouldHideEntity", pl, bl) then
		return
	end
	local bl1 = not bl
	if pl:IsPlayer() then
		pl:SetPredictable(bl1)
	end
	pl:SetNoDraw(bl1)
	if bl1 then
		pl:AddEFlags(EFL_DORMANT)
		pl:SetPos(VectorRand() * 10000)
	else
		pl:RemoveEFlags(EFL_DORMANT)
	end
end
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
local kv = {
	["$basetexture"] = "models/shadertest/shader5",
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
}
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