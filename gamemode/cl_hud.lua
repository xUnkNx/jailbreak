local crclmat = Material("SGM/playercircle")
local spanmenu = Material("vgui/spawnmenu/hover")
local griptex = Material("gui/faceposer_indicator")
local key14txt = Material("sprites/key_14")
local gradient = Material("gui/gradient")
local Color,Lerp = Color,Lerp
function LerpColor(t,a,b)
	return Color(Lerp(t,a.r,b.r),Lerp(t,a.g,a.g),Lerp(t,a.b,a.b))
end
local modf = math.modf
function MakeTime( seconds )
	if seconds < 0 then return "0:00" end
	local m,s = modf(seconds / 60)
	s = math.Round(s * 60)
	return (m < 10 and "0" .. m or m) .. ":" .. (s < 10 and "0" .. s or s)
end

local files = file.Find("jailbreak/gamemode/gui/*.lua","LUA")
for k,v in pairs(files) do
	include("gui/" .. v)
end

GM.DeathsTable = {}
GM.DPY = ScreenScale(5)
GM.DPX = ScreenScale(20)
GM.PickupHistory = {}
function GM:HUDWeaponPickedUp( wep )
	if IsValid(wep) and wep:IsWeapon() then
		--local val = (wep.GetPrintName and wep:GetPrintName()) or wep:GetClass()
		table.insert(self.PickupHistory,{v or wep:GetClass(),CurTime() + 7, wep:GetClass()})
		LocalPlayer():EmitSound("items/itempickup.wav")
	end
end
function GM:HUDAmmoPickedUp(am)
end
local function GetBindValue(inp)
	local ret = input.LookupBinding(inp) or "<Нет кнопки>"
	return ret
end

function GM:HUDPaint()
	local cnt = 0
	for i, m in pairs(self.PickupHistory) do
		if m[2] <= CurTime() then
			self.PickupHistory[i] = nil
		end
		cnt = cnt + 1
		if cnt > 10 then
			self.PickupHistory[i] = nil
		end
		local alp = 255 * (m[2]-CurTime()) / 7
		local w,h
		if killicon.Exists(m[3]) then
			w,h = killicon.GetSize(m[3])
			killicon.Draw(ScrW() - w,ScrH() * 0.25-ScreenScale(30) + cnt * ScreenScale(20),m[3],alp)
		else
			surface.SetFont("JBHUDFONTDEAD")
			w,h = surface.GetTextSize(m[1])
			w = w + ScreenScale(10)
			surface.SetDrawColor(Color(255,255,255,alp))
			surface.SetMaterial(gradient)
			surface.DrawTexturedRect(ScrW() - w,ScrH() * 0.25-ScreenScale(20) + cnt * ScreenScale(20) - h * 0.5,w,h)
			draw.SimpleText(m[1],"JBHUDFONTDEAD",ScrW() - w,ScrH() * 0.25-ScreenScale(20) + cnt * ScreenScale(20) - h * 0.5,Color(0,0,0,alp),TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT,2,Color(50,50,50,alp))
		end
	end
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )
	local ply,whospec,whoreal = LocalPlayer()
	if ply:Alive() then
		whoreal = ply
	else
		whospec = ply:GetObserverTarget()
		if IsValid(whospec) and whospec:IsPlayer() and whospec:Alive() and whospec ~= ply then
			numka = whospec:Alive() and whospec:Health() or 0
			whoreal = whospec
		end
	end
	if whoreal and IsValid(whoreal) and whoreal:IsPlayer() then
		local numka = whoreal:Health() or 0
		--[[if lasthp ~= numka then
			local a,b=numka - (lasthp or 0),Color(255,50,50)
			lasthp=numka
			if a>0 then
				a,b="+"..a,Color(50,255,50)
			end
			hphist[#hphist+1]={a, b, ScreenScale(15), ScrH() - ScreenScale(50), ScrH()-ScreenScale(200)}
		end]]
		--[[for k,v in pairs(hphist) do
			v[2].a=math.max(0,v[2].a-1)
			surface.SetTextColor(v[2])
			surface.SetFont("JBHUDFONTHP")
			surface.SetTextPos(v[3],v[4])
			surface.DrawText(v[1])
			v[4]=v[4]-1
			if v[4] < v[5] then
				hphist[k]=nil
			end
		end]]
		local numlo = whoreal:Armor() or 0
		local numfu = whoreal:GetMaxHealth()
		local size = ScrW() * 0.08
		numfu = numfu * 0.01
		numka = math.Clamp(math.Round(numka / numfu,1),0,100)
		local hsize = math.Clamp(numka, 0, 100) / 100 * size
		local zsize = math.Clamp(numlo, 0, 100) / 100 * size
		draw.RoundedBox(4,ScreenScale(44),ScrH() - size * 0.66,ScreenScale(100), ScreenScale(7),Color(50,50,50,125))
		draw.RoundedBox(4,ScreenScale(54),ScrH() - size * 0.66,zsize * 1.92, ScreenScale(5),Color(64,255,64,175))

		draw.RoundedBox( 6, size * 0.5, ScrH() - size * 0.8 - ScreenScale(10), ScreenScale(134), ScreenScale(17), Color(50,50,50,200) )
		draw.RoundedBox( 8,size * 0.5 + (size - hsize) * 0.5 + ScreenScale(2), ScrH() - size * 0.78 + ScreenScale(1) - ScreenScale(10), hsize * 2.55, ScreenScale(15), Color(0,0,255))
		draw.RoundedBox(8, size * 0.1, ScrH() - size * 1.1 - ScreenScale(10.5), size, size,Color(50,50,50))
		clr = whoreal:GetPlayerColor()
		clr = Color(clr.x * 255,clr.y * 255,clr.z * 255)
		surface.SetDrawColor(clr)
		surface.DrawRect(size * 0.15, ScrH() - size * 1.05 + size * ((101-numka) / 115) - ScreenScale(10), size * 0.9, size * 0.0085 * numka)
		surface.SetMaterial(spanmenu)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect( size * 0.1, ScrH() - size * 1.1 - ScreenScale(10), size, size)
		surface.SetFont( "JBHUDFONTHP" )
		surface.SetTextPos( ScreenScale(55), ScrH() - size * 0.8 - ScreenScale(10) ) 
		if numka > 66 then
			surface.SetTextColor(255,255,0,200)
		elseif numka > 33 then
			surface.SetTextColor(200,200,0,200)
		elseif numka > 0 then
			surface.SetTextColor(200,0,0,200)
		elseif numka == 0 then
			surface.SetTextColor(0,0,0,200)
		end
		surface.DrawText( " " .. numka .. " %" )
		if whoreal ~= ply then
			surface.SetFont( "JBHUDFONT" )
			surface.SetTextPos( ScreenScale(10), ScrH() - ScreenScale(85) )
			surface.SetTextColor(0,90,255,255)
			surface.DrawText( "Наблюдение за: " .. whoreal:Nick() .. "" )
		end
		local SWEP = whoreal:GetActiveWeapon()
		if SWEP and IsValid(SWEP) and SWEP.PrintName then
			if SWEP.DrawAmmo and whoreal == ply then
				surface.SetFont("JBHUDFONTTIME")
				local ammunition,clip = SWEP:Clip1() or 0,whoreal:GetAmmoCount(SWEP:GetPrimaryAmmoType()) or "∞"
				if SWEP.InfiniteClip then clip = "∞"end
				local adx,ady = surface.GetTextSize(ammunition .. " / " .. clip)
				draw.RoundedBox(8,ScrW() - size * 0.4 - adx,ScrH() - ScreenScale(25) - ady,adx,ady,Color(50,50,50))
				surface.SetMaterial(spanmenu)
				surface.DrawTexturedRect(ScrW() - size * 0.4 - adx * 1.1,ScrH() - ScreenScale(25) - ady * 1.1,adx * 1.2,ady * 1.2)
				if SWEP.InfiniteAmmo then
					surface.SetTextPos(ScrW() - size * 0.4 - adx,ScrH() - ScreenScale(25) - ady)
					surface.SetTextColor(Color(255,255,255))
					surface.DrawText("\t\t∞")
				else
					surface.SetTextPos(ScrW() - size * 0.4-adx,ScrH() - ScreenScale(25) - ady)
					surface.SetTextColor(Color(255,255,255))
					surface.DrawText(ammunition .. " / " .. clip)
				end
			end
			if CurSwep ~= SWEP then
				CurSwep = SWEP
				if menushka then
					menushka:Remove()
					if menushkamodel then
						menushkamodel:Remove()
					end
				end
				menushka = vgui.Create("DPanel")
				local menufka = vgui.Create("DPanel",menushka)
				menushka:SetPos(ScrW(), ScrH() * 0.95 )
				function menushka:Paint(w,h)
					draw.RoundedBox(8,0,0,w,h,Color(50,50,50,100))
				end
				local menushkabold = vgui.Create("DLabel", menushka)
				menushkabold:SetPos(ScreenScale(5),0)
				menushkabold:SetFont("JBHUDITEM")
				menushkabold:SetTextColor(Color(255,255,255))
				menushkabold:SetText( "> " .. SWEP.PrintName .. " <" )
				local owner = SWEP.GetRealOwner and SWEP:GetRealOwner()
				if IsValid(owner) then
					local alive = ply:Alive()
					if alive then
						if owner ~= LocalPlayer() then
							menushkabold:SetText( owner:Nick() .. "'s > " .. SWEP.PrintName .. " <" )
						end
					elseif owner ~= LocalPlayer():GetObserverTarget() then
						menushkabold:SetText( owner:Nick() .. "'s > " .. SWEP.PrintName .. " <" )
					end
				end
				local x,y = menushka:GetPos()
				surface.SetFont("JBHUDITEM")
				menushka:SetPos(x - surface.GetTextSize(" " .. menushkabold:GetText() .. "  ") - ScreenScale(10),y)
				menushkabold:SizeToContents()
				menushka:SetSize(menushkabold:GetWide() + ScreenScale(10),menushkabold:GetTall())
				menufka:SetPos(ScreenScale(1), ScreenScale(1) )
				menufka:SetSize(menushkabold:GetWide() + ScreenScale(8),menushkabold:GetTall() - ScreenScale(2))
				local colors = {Color(0,255,255),Color(255,255,0),Color(255,0,0),Color(0,255,0),Color(0,0,255),Color(0,0,0)}
				local time = math.floor( CurTime() )
				local frac = CurTime()
				local a = colors[ time % #colors + 1 ]
				local b = colors[ ( time - 1 ) % #colors + 1 ]
				local drcl = LerpColor( frac, a, b )
				menufka:SetBackgroundColor(Color(drcl.r,drcl.g,drcl.b,150))
				menushkabold.DrawColor = Color(drcl.r,drcl.g,drcl.b,75)
				if SWEP.WorldModel then
					menushkamodel = vgui.Create("DModelPanel")
					menushkamodel:SetModel( SWEP.WorldModel )
					menushkamodel:SetPos(size * 0.185, ScrH() - ScreenScale(62.25))
					menushkamodel:SetSize(size-ScreenScale(8),size - ScreenScale(10))
					menushkamodel:SetCamPos(Vector(20,25,15))
					menushkamodel:SetLookAt(Vector(4,0,6))
					if SWEP.ViewModelFOV == 80 then
						menushkamodel:SetFOV(SWEP.ViewModelFOV - 50)
					elseif SWEP.ViewModelFOV == 70 then
						menushkamodel:SetFOV(SWEP.ViewModelFOV - 40)
					elseif SWEP.ViewModelFOV == 65 then
						menushkamodel:SetFOV(SWEP.ViewModelFOV + 5)
						menushkamodel:SetCamPos(Vector(20,25,-10))
					else
						menushkamodel:SetFOV(SWEP.ViewModelFOV - 10)
					end
					menushkamodel.origfov = menushkamodel:GetFOV()
					if SWEP.Mater and IsValid(menushkamodel.Entity) then
						menushkamodel.Entity:SetMaterial(SWEP.Mater)
					end
					function menushkamodel:LayoutEntity( Entity ) return end
					function menushkamodel:Paint()
						local SWEP = LocalPlayer():GetActiveWeapon()
						if IsValid(SWEP) and SWEP.Scoped then return end
						local campos = self:GetCamPos()
						local lookat = self:GetLookAt()
						local ang = (lookat - campos):Angle()
						ang.roll = 25 * math.sin(RealTime() * 0.25)
						local fov = self.origfov
						fov = fov * (1-math.Clamp(math.sin(RealTime() * 0.25),0,.5))
						local x, y = self:LocalToScreen(0, 0)
						local w, h = self:GetSize()
						cam.Start3D(campos, ang, fov, x, y, w, h, 5, 4096)
							render.SuppressEngineLighting(true)
							if IsValid(self.Entity) then
								self.Entity:DrawModel()
							end
							render.SuppressEngineLighting(false)
						cam.End3D()
					end
				end
			end
		else
			if menushka then
				menushka:Remove()
				if menushkamodel then
					menushkamodel:Remove()
				end
			end
		end
		local plyfd = tonumber(whoreal:GetNWInt( "FreeDayTime" ))
		if whoreal:Team() == TEAM_PRISIONER and plyfd and plyfd > 0 then
			surface.SetFont( "JBHUDFONT" )
			surface.SetTextPos( ScreenScale(10), ScrH() - ScreenScale(80) )
			surface.SetTextColor(255,255,255,200)
			surface.DrawText( "Фридей (" .. MakeTime(math.Round(plyfd - CurTime())) .. ")" )
		end
	else
		if menushka then
			menushka:Remove()
		end
		if menushkamodel then
			menushkamodel:Remove()
		end
	end
	if ply:Alive() then
		--[[if not dphalo:GetBool() then
			local who, frag, show = GetGMEntity("DUELINIT"), GetGMEntity( "DUELFRAG")
			if who == ply then
				show = frag
			elseif frag == ply then
				show = who
			end
			if show then
				local x1,y1,x2,y2 = GetCoord(show)
				local edgesize = 8
				local cl = team.GetColor(show:Team())
				surface.SetDrawColor(cl)
				surface.DrawLine(x1,y1,math.min(x1 + edgesize,x2),y1)
				surface.DrawLine(x1,y1,x1,math.min(y1 + edgesize,y2))
				surface.DrawLine(x2,y1,math.max(x2 - edgesize,x1),y1)
				surface.DrawLine(x2,y1,x2,math.min(y1 + edgesize,y2))
				surface.DrawLine(x1,y2,math.min(x1 + edgesize,x2),y2)
				surface.DrawLine(x1,y2,x1,math.max(y2 - edgesize,y1))
				surface.DrawLine(x2,y2,math.max(x2 - edgesize,x1),y2)
				surface.DrawLine(x2,y2,x2,math.max(y2 - edgesize,y1))
				draw.SimpleText(show:Nick(), "JBHUDFONTNANO", x1,y1,cl , TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			end
		end]]
		for _, v in pairs(player.GetAll()) do
			if v:Alive() and v ~= LocalPlayer() then
				local distance = LocalPlayer():GetPos():Distance( v:GetPos() )
				if distance <= 32 then
					local color = ply:GetColor()
					v:SetRenderMode(4)
					v:SetColor( Color(color.r, color.g, color.b, 0) )
				else
					v:SetRenderMode(0)
				end
			end
		end
		local tr = ply:GetEyeTraceNoCursor()
		local ent = tr.Entity
		if IsValid(ent) then
			if ent:IsPlayer() and tr.HitPos:DistToSqr(tr.StartPos) < 262144 then
				self.LastLooked = ent
				self.LookedFade = CurTime()
			else
				if ent:IsWeapon() and tr.HitPos:DistToSqr(tr.StartPos) < 4096 then
					local plywp,plysl2 = ply:GetActiveWeapon(),ent:GetClass()
					local plysl = IsValid(plywp) and plywp:GetClass() or ''
					if ent.Kind and plysl ~= plysl2 then
						local nm,txt = ent.PrintName or plysl2
						if plywp.Kind == ent.Kind then
							txt = "[" .. string.upper(GetBindValue("+use")) .. "] Заменить на "
						else
							txt = "[" .. string.upper(GetBindValue("+use")) .. "] Подобрать "
						end
						draw.SimpleText(txt .. nm, "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.6, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end
			end
		end
		if IsValid(self.LastLooked) and self.LookedFade + 2 > CurTime() then
			local name = self.LastLooked:Name() or "Неизвестный"
			local col = self.LastLooked:GetPlayerColor() or Vector()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			col.a = (1 - (CurTime() - self.LookedFade) * 0.5) * 255
			if self.LastLooked:Team() < 4 then
				draw.SimpleText(name, "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(20), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				if self.LastLooked:Team() ==  TEAM_GUARD then
					if self.LastLooked == GetGMEntity("JB_Simon") then
						draw.SimpleText("Командир", "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(30), Color(255,0,0,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText("Охранник", "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(30), Color(0,128,255,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				elseif self.LastLooked:Team() == TEAM_PRISIONER then
					--local klikuha = tostring(self.LastLooked:GetNWString("Klichka") or "")
					--draw.SimpleText(klikuha, "JBHUDFONTSM", ScrW() / 2, ScrH() / 2 + 80, Color(255,255,255,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					draw.SimpleText("Заключённый", "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(30), Color(255,255,0,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	else
		for _, v in pairs(player.GetAll()) do
			local color = v:GetColor()
			if color.a ~= 255 then
				v:SetRenderMode(4)
				v:SetColor( Color(color.r, color.g, color.b, 255) )
			end
		end
	end
	local round = GetGMInt( "JB_Round", 0 )
	if round ~= Round_Noone then
		local realtime = GetGMInt( "JB_DayTime",CurTime() )
		local day = GetGMInt( "JB_Day" ) or 0
		if round > Round_Start and round < Round_End then
			if simonka and simonkabold then
				local simon = GetGMEntity( "JB_Simon" )
				if simon and IsValid(simon) and simon:IsPlayer() then
					simonkabold:SetText( "Командир: " .. simon:Nick() .. "." )
					simonkabold:SizeToContents()
					simonka:SetSize(simonkabold:GetWide() + ScreenScale(10),simonkabold:GetTall() + ScreenScale(10))
					simonka:SetPos(ScrW() * 0.5-simonka:GetWide() * 0.5,ScrH() - ScreenScale(20) )
				else
					simonkabold:SetText( "Командира нет." )
					simonkabold:SizeToContents()
					simonka:SetSize(simonkabold:GetWide() + ScreenScale(10),simonkabold:GetTall() + ScreenScale(10))
					simonka:SetPos(ScrW() * 0.5-simonka:GetWide() * 0.5,ScrH() - ScreenScale(20) )
				end
				local gmtype,tpcd = GetGMString( "JB_GM", false)
				if gmtype then
					if gmtype == "FreeDay" then
						local fdtime = GetGMInt( "JB_FDTime", 0)
						if fdtime > CurTime() then
							tpcd = "Свободный день! " .. MakeTime(math.Round(fdtime-CurTime())) .. " до конца"
						end
					elseif gmtype == "ZFD" then
						tpcd = "Зомби фридей"
					elseif gmtype == "Defense" then
						tpcd = "Оборона"
					elseif gmtype == "Hide&Seek" then
						tpcd = "Прятки"
					end
					if tpcd then
						simonkabold:SetText( tpcd )
						simonkabold:SizeToContents()
						simonka:SetSize(simonkabold:GetWide() + ScreenScale(10),simonkabold:GetTall() + ScreenScale(10))
						simonka:SetPos(ScrW() * 0.5-simonka:GetWide() * 0.5,ScrH() - ScreenScale(20) )
					end
				end
			else
				simonka = vgui.Create("DPanel")
				simonka:SetPos(ScrW() * 0.5-simonka:GetWide() * 0.5,ScrH() - ScreenScale(20) )
				function simonka:Paint(w,h)
					draw.RoundedBox(16,0,0,w,h,Color(50,50,50,200))
				end
				simonkabold = vgui.Create("DLabel", simonka)
				simonkabold:SetPos(ScreenScale(5),ScreenScale(5))
				simonkabold:SetFont("JBHUDFONT")
				simonkabold:SetTextColor(Color(255,255,255))
			end
		else
			if IsValid(simonka) then
				simonka:Remove()
				simonka = nil
			end
			if IsValid(simonkabold) then
				simonkabold:Remove()
				simonkabold = nil
			end
		end
		if round == Round_Wait then
			--draw.SimpleText("Извините, игроков не достаточно для начала игры.", "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(0.5*40), Color(200,200,200), 1, TEXT_ALIGN_CENTER)
		elseif round == Round_Start then
			draw.SimpleText("Раунд начинается", "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(40), Color(255,255,255), 1, TEXT_ALIGN_CENTER)
		elseif round == Round_End then
			draw.SimpleText("Раунд завершён", "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(40), Color(255,255,255), 1, TEXT_ALIGN_CENTER)
			local win = GetGMString("EndReason")
			if win then
				draw.SimpleText(win, "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(20), Color(50,255,50), 1, TEXT_ALIGN_CENTER)
			end
		else
			if realtime then
				if realtime < CurTime() then
					local write = ""
					if round == 1 then
						write = "Подготовка к началу игры!"
					elseif round == 3 then
						write = "Раунд завершён!"
					else
						write = "День закончился!"
					end
					draw.SimpleText(write, "JBHUDFONTTIME", ScrW() * 0.5, ScrH() - ScreenScale(40), Color(0,255,0), 1, TEXT_ALIGN_CENTER)
				end
				local asktime = GetGMInt( "JB_Time", CurTime()) 
				if day then
					local ostatok1,ostatok2 = math.floor(asktime-CurTime()) + 1,math.floor(realtime-CurTime()) + 1
					surface.SetFont("JBHUDFONTTIME")
					local txt = "День " .. day .. "/5 | До конца " .. MakeTime(ostatok2)
					local w,h = surface.GetTextSize(txt)
					draw.RoundedBox(4,ScreenScale(2),ScreenScale(3),w + ScreenScale(6),h + ScreenScale(5),Color(255,255,255))
					draw.RoundedBox(4,ScreenScale(3), ScreenScale(4),w + ScreenScale(4),h + ScreenScale(3),Color(100,100,100))
					draw.SimpleText(txt, "JBHUDFONTTIME", ScreenScale(3), h, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					txt = "До конца раунда " .. MakeTime(ostatok1)

					w,h = surface.GetTextSize(txt)
					draw.RoundedBox(4,ScreenScale(7),ScrH() - h - ScreenScale(5),w + ScreenScale(6),h + ScreenScale(3),Color(255,255,255))
					draw.RoundedBox(4,ScreenScale(8),ScrH() - h - ScreenScale(4),w + ScreenScale(4),h + ScreenScale(1),Color(100,100,100))
					draw.SimpleText(txt, "JBHUDFONTTIME", w * 0.5 + ScreenScale(10), ScrH() - h + ScreenScale(2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	else
		draw.SimpleText("Подготовка к игре.", "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(20), Color(200,200,50), 1, TEXT_ALIGN_CENTER)
	end
end

function GM:GlobalVarChanged(nm,old,new)
	if nm == "JB_RoundStatus" then
		local txt = nil
		if new == round_alldead then
			txt = "Все игроки мертвы - Ничья"
		elseif new == round_wint then
			txt = "Охрана была устранена"
		elseif new == round_winct then
			txt = "Заключённые не сумели сбежать"
		elseif new == round_timeout then
			txt = "Время вышло"
		elseif new == round_winzombie then
			txt = "Зомби захватили мир"
		elseif new == round_winhuman then
			txt = "Люди уничтожили инфекцию"
		elseif new == round_winhider then
			txt = "Спрятаться удалось"
		elseif new == round_winseeker then
			txt = "Всех нашли"
		elseif new == round_winassault then
			txt = "Оборона не удалась"
		elseif new == round_winguards then
			txt = "Оборона цели удалась"
		end
		SetGlobal("EndReason",txt)
		if txt then
			DrawMessage("info",txt .. "!")
		end
	end
end


--[[local function CalcOffset(pos,ang,off)
	return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z
end]]
local talkicon = Material("voice/icntlk_sv") -- icon32/unmuted.png
local clientModels = {}
function GM:PostPlayerDraw( ply )
	local weps = ply:GetWeapons()
	for k, v in pairs(weps) do
		if v.Kind == 1 then
			if ply:GetActiveWeapon() == v then
				break
			end
			local class,mdl = v:GetClass()
			mdl = clientModels[class]
			if mdl == nil then
				local model = v.WorldModel or (v.GetModel and v:GetModel())
				mdl = ClientsideModel(model,RENDERGROUP_OPAQUE)
				if IsValid(mdl) then
					clientModels[class] = mdl
					mdl:SetNoDraw(true)
					mdl.class = class
				end
			else
				mdl:SetMaterial(v.Mater)
				local boneindex = ply:LookupBone("ValveBiped.Bip01_Spine2")
				if boneindex then
					local pos, ang = ply:GetBonePosition(boneindex)
					ang:RotateAroundAxis(ang:Forward(),0)
					mdl:SetRenderOrigin(pos + (ang:Right() * 4) + (ang:Up() * - 7) + (ang:Forward() * 6))
					ang:RotateAroundAxis(ang:Right(),-15)
					mdl:SetRenderAngles(ang)
					mdl:DrawModel()
				end
			end
		end
	end
	if ply:IsSpeaking() then
		render.SetMaterial(talkicon)
		--local col = render.ComputeLighting(ply:EyePos(), vector_origin)
		--render.DrawSprite(ply:EyePos(), 12, 12, Color(255, 255, 255, 255))
		local scale = 12 + 12 * ply:VoiceVolume()
		render.DrawSprite(ply:EyePos() + Vector(0,0,16),scale,scale,color_white)
	end
	if ( ply == LocalPlayer() ) then return end
	local Distance = LocalPlayer():GetPos():Distance( ply:GetPos() )
	if ( Distance < 1000 ) then
		local plyfd = tonumber(ply:GetNWInt( "FreeDayTime" ))
		if plyfd and plyfd > 0 then
			local offset = Vector( 0, 0, 85 )
			local ang = LocalPlayer():EyeAngles()
			local pos = ply:GetPos() + offset + ang:Up()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
			draw.DrawText( "Фридей (" .. MakeTime(math.Round(plyfd - CurTime())) .. ")", "JBHUDFONT", 0, 0, team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER )
			cam.End3D2D()
			pos = ply:GetPos() + Vector(0, 0, 2)
			render.SetMaterial(key14txt)
			render.DrawQuadEasy(pos, Vector(0, 0, 1), 64, 64, Color(255,255,255))
			render.DrawQuadEasy(pos, Vector(0, 0, -1), 64, 64, Color(255,255,255))
		end
		if GetGMEntity("JB_Simon") == ply then
			local offset = Vector( 0, 0, 85 )
			local ang = LocalPlayer():EyeAngles()
			local pos = ply:GetPos() + offset + ang:Up()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.2 )
			draw.DrawText( "Командир", "JBHUDFONT", 0, ScreenScale(20), team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER )
			cam.End3D2D()
		end
		local who, frag = GetGMEntity("DUELINIT"), GetGMEntity( "DUELFRAG")
		if IsValid(who) and IsValid(frag) and frag:Alive() and who:Alive() then
			render.SetMaterial(crclmat)
			render.DrawQuadEasy(who:GetPos() + Vector(0, 0, 2), Vector(0, 0, 1), 64, 64, team.GetColor(who:Team()))
			render.DrawQuadEasy(frag:GetPos() + Vector(0, 0, 2), Vector(0, 0, 1), 64, 64, team.GetColor(frag:Team()))
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