local sin,cos,rad,pi,atan2 = math.sin,math.cos,math.rad,math.pi,math.atan2
local qcx,qcy,qcs,qct,qoff,qsq
ButtonCD,ButtonDelay = 0,0.05
local function nang(ang)
	if ang > 360 then
		return nang(ang-360)
	elseif ang < 0 then
		return nang(ang + 360)
	end
	return ang
end
local function qmenusettings()
	local w,h = ScrW(),ScrH()
	qcx,qcy,qcs,qct,qoff = w * .5, h * .5, h * .10, h * .45, 0
	qsq = qcs * qcs
end
qmenusettings()
local qstrtbl,qtext,qlines,qpoly,qang,qcnt,qselect,qent
local function qmenucalc(cnt)
	qtext,qlines,qpoly,qang,qcnt,qselect = {},{},{},{},cnt-1,nil
	local cx,cy,cs,ct,sa,off = qcx,qcy,qcs,qct,360 / cnt,qoff
	local ln,st,suv,uv,sah,sc,ss,sv = qlines,qtext,1 / (ct * 2 + cs),{},sa * .5
	sa1 = ScrH() * .4
	for i = 0,cnt do
		sv = sa * i + off
		sc,ss = cos(rad(sv)),sin(rad(sv))
		ln[i] = {cx + sc * cs,cy + ss * cs,cx + sc * ct,cy + ss * ct}
		uv[i] = {(ln[i][1] - cx) * suv + .5,(ln[i][2] - cy) * suv + .5,(ln[i][3] - cx) * suv + .5,(ln[i][4] - cy) * suv + .5}
		st[i] = sv
	end
	local ni
	for i = 0,cnt do
		if i ~= cnt then
			qang[i] = {math.NormalizeAngle(sa * i + off),math.NormalizeAngle(sa * i + off + sa)}
			sv = st[i] + sah
			sc,ss = cos(rad(sv)),sin(rad(sv))
			local ft,ft1 = ct-draw.GetFontHeight(qstrtbl[i + 1].tfont)
			ft1 = ft-draw.GetFontHeight(qstrtbl[i + 1].dfont)
			local tcy = cy + ss * ft
			local xx,yy = cx + sc * cs,cy + ss * cs
			if tcy < qcy then
				st[i] = {sv, xx, yy, cx + sc * ft, tcy, cx + sc * ft1, cy + ss * ft1}
			else
				st[i] = {sv, xx, yy, cx + sc * ft1, cy + ss * ft1, cx + sc * ft,tcy}
			end
		end
		ni = i == cnt and 0 or i + 1
		qpoly[i] = {{x = ln[i][1],y = ln[i][2],u = uv[i][1],v = uv[i][2]},
		{x = ln[i][3],y = ln[i][4],u = uv[i][3],v = uv[i][4]},
		{x = ln[ni][3],y = ln[ni][4],u = uv[ni][3],v = uv[ni][4]},
		{x = ln[ni][1],y = ln[ni][2],u = uv[ni][1],v = uv[ni][2]}}
	end
end
local MenuBase = {title = "", tcol = color_white, tfont = "JBHUDFONT", desc = "", dcol = color_white, dfont = "JBHUDFONT", think = nil, select = nil}
function RegisterMenu(menu)
	for k,v in pairs(menu) do
		for i,j in pairs(MenuBase) do
			if v[i] == nil then
				v[i] = j
			end
		end
	end
	return menu
end
function GM:GetQMenuItems()
	local t = LocalPlayer():Team()
	if t == TEAM_GUARD then
		if GetGMEntity("JB_Simon") == LocalPlayer() then
			return self.Precache.SimonMenu
		else
			return self.Precache.CTMenu
		end
	elseif t == TEAM_PRISIONER then
		return self.Precache.TMenu
	else
		return self.Precache.TMenu
	end
end
hook.Add("PlayerButtonDown","Q_Menu",function(ply,bn)
	if qmenuactive then
		if bn == MOUSE_LEFT or bn == MOUSE_RIGHT then
			local i,tb = qselect
			if i then
				tb = qstrtbl[i + 1]
				if tb and tb.select and not tb.hidden then
					GAMEMODE:CloseQMenu()
					tb.select(tb,LocalPlayer())
					return true
				end
			end
		else
			local ct = CurTime()
			if ButtonCD > ct then return end
			local a,b,tb = (bn >= KEY_0 and bn <= KEY_9),bn - KEY_0
			if not a then
				a,b = (bn >= KEY_PAD_0 and bn <= KEY_PAD_9),bn - KEY_PAD_0
				if not a then return end
			end
			if b == 0 then b = 10 end
			ButtonCD = ct + ButtonDelay
			tb = qstrtbl[b]
			if tb and tb.select and not tb.hidden then
				GAMEMODE:CloseQMenu()
				tb.select(tb,LocalPlayer())
				return true
			end
		end
	end
end)
function GM:PlayerBindPress(ply,bind,pr)
	if qmenuactive and bind:find("slot") then
		return true
	end
end
function GM:OpenQMenu(menu)
	if not menu then
		return
	end
	qstrtbl = menu
	local cnt = #qstrtbl
	if cnt == 1 then
		return qstrtbl[1]:select(LocalPlayer())
	end
	if cnt < 4 then
		qmenucalc(4)
		qcnt = cnt - 1
	else
		qmenucalc(cnt)
	end
	self:UpdateQMenu()
	qmenuactive = true
	input.SetCursorPos(ScrW() * .5,ScrH() * .5)
	gui.EnableScreenClicker(true)
end
function GM:CloseQMenu()
	qmenuactive = false
	gui.EnableScreenClicker(false)
end
local mins,maxs = Vector( -10, -10, -10 ),Vector( 10, 10, 10 )
function GM:GetTraceEnt()
	local lp,tr = LocalPlayer()
	tr = lp:GetEyeTrace()
	if tr.Hit and tr.Entity then
		return tr.Entity
	else
		local tr = util.TraceHull( {start = lp:GetShootPos(),endpos = lp:GetShootPos() + lp:GetAimVector() * 1024,filter = self.Owner,mins = mins,maxs = maxs,mask = MASK_SHOT_HULL})
		if tr.Hit and tr.Entity then
			return tr.Entity
		end
	end
	return nil
end
function GM:OnSpawnMenuOpen()
	qent = self:GetTraceEnt()
	qstrtbl = self:GetQMenuItems()
	self:OpenQMenu(qstrtbl)
end
GM.OnSpawnMenuClose = GM.CloseQMenu
local grad = Material("gui/npc.png")
local function qmenuthink()
	local x,y = input.GetCursorPos()
	qselect = nil
	local dx,dy,dist = x-qcx,y-qcy
	dist = dx * dx + dy * dy
	if dist < qsq then
		return
	end
	local grad,a1,a2 = atan2(dy,dx) / pi * 180
	for i = 0,qcnt do
		a1,a2 = qang[i][1],qang[i][2]
		if (grad > a1 and grad < a2) or (a2 < a1 and ((grad > a1 and grad < 180) or (a2 > -180 and grad < a2))) then
			qselect = i
		end
	end
end
function surface.DrawTextRotatedQ(x,y,ang,text,col,font)
	surface.SetFont(font)
	surface.SetTextColor(col)
	surface.SetTextPos(0,0)
	local tw,th = surface.GetTextSize(text)
	tw,th = tw * .5,th * .5
	local rd,m,dw = -rad(ang),Matrix()
	if y > qcy then
		ang = nang(ang + 180)
		dw,dy = -cos(rd) * - tw + sin(rd) * th * 3,sin(rd) * -tw + cos(rd) * th * 3
	else
		dw,dy = -cos(rd) * tw + sin(rd) * th,sin(rd) * tw + cos(rd) * th
	end
	x,y=x + dw,y + dy
	m:SetAngles(Angle(0,ang,0))
	m:SetTranslation(Vector(x,y,0))
	cam.PushModelMatrix(m)
		surface.DrawText(text)
	cam.PopModelMatrix()
end
hook.Add("HUDPaint","DrawQMenu",function()
	if qmenuactive then
		qmenuthink()
		local st = qlines
		for i = 0,qcnt do
			local info = qstrtbl[i + 1]
			surface.SetDrawColor(255,255,255,50)
			surface.DrawLine(st[i][1],st[i][2],st[i][3],st[i][4])
			surface.SetFont("JBHUDFONTSM")
			if i < 10 then
				local t,w,h
				if i == 9 then
					t = "0"
				else
					t = tostring(i+1)
				end
				w,h = surface.GetTextSize(t)
				surface.SetTextColor(255,255,255,100)
				surface.SetTextPos(qtext[i][2] - w * .5,qtext[i][3] - h * .5)
				surface.DrawText(t)
			end
			if not info or info.hidden then continue end
			if qselect == i then
				surface.SetDrawColor(100,100,255,150)
			else
				surface.SetDrawColor(100,100,100,50)
			end
			draw.NoTexture()
			surface.DrawPoly(qpoly[i])
		end
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
		for i = 0,qcnt do
			local info = qstrtbl[i + 1]
			if not info or info.hidden then continue end
			surface.DrawTextRotatedQ(qtext[i][4],qtext[i][5],nang(qtext[i][1] + 90),info.title,info.tcol,info.tfont)
			surface.DrawTextRotatedQ(qtext[i][6],qtext[i][7],nang(qtext[i][1] + 90),info.desc,info.dcol,info.dfont)
		end
		render.PopFilterMag()
		render.PopFilterMin()
	end
end)
function GM:UpdateQMenu()
	local lp = LocalPlayer()
	for k,v in pairs(qstrtbl) do
		if v.think then
			v:think(lp)
		end
	end
end