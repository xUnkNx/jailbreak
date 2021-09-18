local crclmat = Material("SGM/playercircle")
local spanmenu = Material("vgui/spawnmenu/hover")
local griptex = Material("gui/faceposer_indicator")
local key14txt = Material("sprites/key_14")
local gradient = Material("gui/gradient")
local talkicon = Material("voice/icntlk_sv") -- icon32/unmuted.png
local size = ScrW() * 0.08
local color_white, color_gray, color_lightgray, color_graygreen, color_alphagray = Color(255,255,255), Color(50,50,50), Color(100,100,100), Color(50,255,50), Color(50,50,50,150)
GM:DefineDesign("vanilla",{
	["FreeDayTimer"] = function(expire)
		surface.SetFont( "JBHUDFONT" )
		surface.SetTextPos( ScreenScale(10), ScrH() - ScreenScale(80) )
		surface.SetTextColor(255,255,255,200)
		surface.DrawText( _T("FreedayTimer", MakeTime(math.Round(expire))) )
	end,
	["PickupHistory"] = function(m, cnt, ct)
		local alp = 255 * (m[2]-ct) / 7
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
	end,
	["DeathNotice"] = function(x, y, ct)
		x,y = x * ScrW(),y * ScrH()
		local cnt = 0
		for i, m in pairs(GAMEMODE.DeathsTable) do
			if m[0] < ct then
				GAMEMODE.DeathsTable[i] = nil
			end
			cnt = cnt + 1
			local x1, y1 = m[8], cnt * y
			local alp = 255 * (m[0] - ct) / GAMEMODE.DeathNoticeTime
			local w, h = killicon.GetSize(m[3])
			if not w then continue end
			w = w * .5
			if m[1] then
				m[2].a = alp
				draw.SimpleText(m[1], "JBHUDFONTDEAD", x1-w, y1, m[2], TEXT_ALIGN_RIGHT)
			end
			killicon.Draw( x1, y1, m[3], alp )
			local killwall, killhead = 0, 0
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
	end,
	["PlayerStatus"] = function(ply)
		local curhp = ply:Health() or 0
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
		local curarmor = ply:Armor() or 0
		local maxhp = ply:GetMaxHealth()
		maxhp = maxhp * 0.01
		curhp = math.Clamp(math.Round(curhp / maxhp,1),0,100)
		local hsize = math.Clamp(curhp, 0, 100) / 100 * size
		local zsize = math.Clamp(curarmor, 0, 100) / 100 * size
		draw.RoundedBox(4,ScreenScale(44),ScrH() - size * 0.76,ScreenScale(100), ScreenScale(7),Color(50,50,50,125))
		draw.RoundedBox(4,ScreenScale(54),ScrH() - size * 0.76,zsize * 1.92, ScreenScale(5),Color(64,255,64,175))

		draw.RoundedBox(6, size * 0.5, ScrH() - size * 0.9 - ScreenScale(10), ScreenScale(134), ScreenScale(17), Color(50,50,50,200) )
		draw.RoundedBox(8, size * 0.5 + (size - hsize) * 0.5 + ScreenScale(3), ScrH() - size * 0.88 - ScreenScale(10), hsize * 2.55, ScreenScale(15), Color(0,0,255))
		draw.RoundedBox(8, size * 0.1, ScrH() - size * 1.1 - ScreenScale(10.5), size, size,Color(50,50,50))
		clr = ply:GetPlayerColor()
		clr = Color(clr.x * 255,clr.y * 255,clr.z * 255)
		surface.SetDrawColor(clr)
		surface.DrawRect(size * 0.15, ScrH() - size * 1.05 + size * ((101-curhp) / 115) - ScreenScale(10), size * 0.9, size * 0.0085 * curhp)
		surface.SetMaterial(spanmenu)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect( size * 0.1, ScrH() - size * 1.1 - ScreenScale(10), size, size)
		surface.SetFont( "JBHUDFONTHP" )
		surface.SetTextPos( ScreenScale(55), ScrH() - size * 0.9 - ScreenScale(10) )
		if curhp > 66 then
			surface.SetTextColor(255,255,0,200)
		elseif curhp > 33 then
			surface.SetTextColor(200,200,0,200)
		elseif curhp > 0 then
			surface.SetTextColor(200,0,0,200)
		elseif curhp == 0 then
			surface.SetTextColor(0,0,0,200)
		end
		surface.DrawText( " " .. curhp .. " %" )
	end,
	["SpectatePlayer"] = function(whoreal)
		surface.SetFont( "JBHUDFONT" )
		surface.SetTextPos( ScreenScale(10), ScrH() - ScreenScale(85) )
		surface.SetTextColor(0,90,255,255)
		surface.DrawText( _T("SpectatePlayer", whoreal:Nick()) )
	end,
	["Ammo"] = function(whoreal, SWEP)
		surface.SetFont("JBHUDFONTTIME")
		local ammunition,clip = SWEP:Clip1() or 0,whoreal:GetAmmoCount(SWEP:GetPrimaryAmmoType()) or "∞"
		if SWEP.InfiniteClip then clip = "∞"end
		local adx,ady = surface.GetTextSize(ammunition .. " / " .. clip)
		local x, y, off = size * 0.6 - adx * .5, ScrH() - ScreenScale(5) - ady, ady * 0.05
		draw.RoundedBox(8, x, y, adx + off, ady + off, color_gray)
		--surface.SetMaterial(spanmenu)
		--surface.DrawTexturedRect(ScrW() - size * 0.4 - adx * 1.1,ScrH() - ScreenScale(25) - ady * 1.1,adx * 1.2,ady * 1.2)
		if SWEP.InfiniteAmmo then
			surface.SetTextPos(x + off, y + off)
			surface.SetTextColor(color_white)
			surface.DrawText("∞ / ∞")
		else
			surface.SetTextPos(x + off,y + off)
			surface.SetTextColor(color_white)
			surface.DrawText(ammunition .. " / " .. clip)
		end
	end,
	["Weapon"] = function(whoreal, SWEP)
		if weaponname then
			weaponname:UpdateSWEP(whoreal,SWEP)
			return
		end
		weaponname = vgui.Create("DPanel")
		weaponname:SetPaintBackground(false)
		local weaponbg = vgui.Create("DPanel",weaponname)
		weaponbg:Dock(FILL)
		local weapontext = vgui.Create("DLabel", weaponname)
		weapontext:Dock(FILL)
		weapontext:SetFont("JBHUDITEM")
		weapontext:SetTextColor(color_white)
		weaponbg:SetBackgroundColor(Color(50,50,50,125))
		function weaponbg:Paint(w,h)
			draw.RoundedBox(8, 0, 0, w, h, self:GetBackgroundColor())
		end
		weaponmodel = vgui.Create("DModelPanel")
		weaponmodel:SetPos(size * 0.185, ScrH() - ScreenScale(62.25))
		weaponmodel:SetSize(size - ScreenScale(8), size - ScreenScale(10))
		weaponmodel:SetModel("")
		weaponmodel:SetCamPos(Vector(20, 25, 15))
		weaponmodel:SetLookAt(Vector(4, 0, 6))
		weaponmodel.origfov = 0
		weaponmodel:ParentToHUD()

		function weaponmodel:LayoutEntity( Entity ) return end
		function weaponmodel:Paint()
			local campos = self:GetCamPos()
			local lookat = self:GetLookAt()
			local ang = (lookat - campos):Angle()
			ang.roll = 25 * math.sin(RealTime() * 0.25)
			local fov = self.origfov
			fov = fov * (1 - math.Clamp(math.sin(RealTime() * 0.25), 0, .5))
			local x, y = self:LocalToScreen(0, 0)
			local w, h = self:GetSize()
			cam.Start3D(campos, ang, fov, x, y, w, h, 5, 192)
				render.SuppressEngineLighting(true)
				if IsValid(self.Entity) then
					self.Entity:DrawModel()
				end
				render.SuppressEngineLighting(false)
			cam.End3D()
		end
		function weaponname:UpdateSWEP(ply, SWEP)
			if self.SWEP ~= SWEP then
				self.SWEP = SWEP
				if not IsValid(SWEP) then
					weaponname:SetVisible(false)
					weaponmodel:SetModel("")
					return
				end
				weaponname:SetVisible(true)
				local owner = SWEP.GetRealOwner and SWEP:GetRealOwner()
				if IsValid(owner) then
					local alive = ply:Alive()
					if alive then
						if owner ~= LocalPlayer() then
							weapontext:SetText( owner:Nick() .. "'s > " .. language.GetPhrase(SWEP.PrintName) .. " <" )
						end
					elseif owner ~= LocalPlayer():GetObserverTarget() then
						weapontext:SetText( owner:Nick() .. "'s > " .. language.GetPhrase(SWEP.PrintName) .. " <" )
					end
				else
					weapontext:SetText( "> " .. language.GetPhrase(SWEP.PrintName) .. " <" )
				end
				weapontext:SizeToContents()
				weaponname:SetSize(weapontext:GetSize())
				weaponname:SetPos(size * 1.1, ScrH() - ScreenScale(30))
				if SWEP.WorldModel then
					weaponmodel:SetModel( SWEP.WorldModel )
					if SWEP.ViewModelFOV == 80 then
						weaponmodel:SetFOV(SWEP.ViewModelFOV - 50)
					elseif SWEP.ViewModelFOV == 70 then
						weaponmodel:SetFOV(SWEP.ViewModelFOV - 40)
					elseif SWEP.ViewModelFOV == 65 then
						weaponmodel:SetFOV(SWEP.ViewModelFOV + 5)
						weaponmodel:SetCamPos(Vector(20,25,-10))
					else
						weaponmodel:SetFOV(SWEP.ViewModelFOV - 10)
					end
					--menushkamodel:GetEntity():SetMaterial(SWEP.Mater)
					weaponmodel.origfov = weaponmodel:GetFOV()
				else
					weaponmodel:SetModel( "" )
				end
			end
		end
		weaponname:UpdateSWEP(whoreal, SWEP)
		weaponname:ParentToHUD()
	end,
	["EntityInfo"] = function(ent, tr, whoreal)
		if ent:IsWeapon() and tr.HitPos:DistToSqr(tr.StartPos) < 4096 then
			local plywp,plysl2 = whoreal:GetActiveWeapon(),ent:GetClass()
			local plysl = IsValid(plywp) and plywp:GetClass() or ''
			if ent.Kind and plysl ~= plysl2 then
				local nm,txt = ent.PrintName or plysl2
				if plywp.Kind == ent.Kind then
					txt = _T("GReplaceWeapon", string.upper(GetBindValue("+use")), nm)
				else
					txt = _T("GPickupWeapon", string.upper(GetBindValue("+use")), nm)
				end
				draw.SimpleText(txt, "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.6, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end,
	["PlayerInfo"] = function(ent,fade,tr,pl)
		if IsValid(ent) and fade + 2 > CurTime() then
			local name = ent:Name() or _T("Unknown")
			local col = ent:GetPlayerColor() or Vector()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			col.a = (1 - (CurTime() - fade) * 0.5) * 255
			if ent:Team() <= 4 then
				draw.SimpleText(name, "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(20), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				if ent:Team() ==  TEAM_GUARD then
					if ent == GetGMEntity("JB_Simon") then
						draw.SimpleText(_T("Simon"), "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(30), Color(255,0,0,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						draw.SimpleText(_T("Guard"), "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(30), Color(0,128,255,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				elseif ent:Team() == TEAM_PRISIONER then
					draw.SimpleText(_T("Prisioner"), "JBHUDFONTSM", ScrW() * 0.5, ScrH() * 0.5 + ScreenScale(30), Color(255,255,0,col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end,
	["RoundStatus"] = function(round, realtime)
		if round == Round_Start then
			draw.SimpleText(_T("RoundStarting"), "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(40), color_white, 1, TEXT_ALIGN_CENTER)
		elseif round == Round_End then
			draw.SimpleText(_T("RoundEnded"), "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(40), color_white, 1, TEXT_ALIGN_CENTER)
			local win = GetGMString("EndReason") -- TODO: LANG
			if win then
				draw.SimpleText(win, "JBHUDFONT", ScrW() * 0.5, ScrH() - ScreenScale(20), color_graygreen, 1, TEXT_ALIGN_CENTER)
			end
		elseif round ~= Round_Wait then
			if realtime then
				if realtime < CurTime() then
					local write = ""
					if round == 1 then
						write = _T("PrepareRound")
					elseif round == 3 then
						write = _T("RoundEnded")
					-- else
					--	write = day
					end
					draw.SimpleText(write, "JBHUDFONTTIME", ScrW() * 0.5, ScrH() - ScreenScale(40), color_graygreen, 1, TEXT_ALIGN_CENTER)
				end
				--local asktime = GetGMInt( "JB_Time", CurTime()) 
				--[[if day then
					local ost1,ost2 = math.floor(asktime-CurTime()) + 1,math.floor(realtime-CurTime()) + 1
					
					local txt = "Day " .. day .. "/5 | Time estimated " .. MakeTime(ost2)
					local w,h = surface.GetTextSize(txt)
					draw.RoundedBox(4,ScreenScale(2),ScreenScale(3),w + ScreenScale(6),h + ScreenScale(5),Color(255,255,255))
					draw.RoundedBox(4,ScreenScale(3), ScreenScale(4),w + ScreenScale(4),h + ScreenScale(3),Color(100,100,100))
					draw.SimpleText(txt, "JBHUDFONTTIME", ScreenScale(3), h, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					]]
				surface.SetFont("JBHUDFONTTIME")
				txt = _T("RoundExpire", MakeTime(realtime - CurTime()))
				local w,h = surface.GetTextSize(txt)
				draw.RoundedBox(4,ScreenScale(60),ScrH() - h - ScreenScale(5),w + ScreenScale(6),h + ScreenScale(3),color_white)
				draw.RoundedBox(4,ScreenScale(61),ScrH() - h - ScreenScale(4),w + ScreenScale(4),h + ScreenScale(1),color_lightgray)
				draw.SimpleText(txt, "JBHUDFONTTIME", w * 0.5 + ScreenScale(62), ScrH() - h + ScreenScale(2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end,
	["PlayerOverlay"] = function(ply)
		local plyfd = ply:GetNW( "FreeDayTime", 0)
		if plyfd and plyfd > 0 then
			local offset = Vector( 0, 0, 85 )
			local ang = LocalPlayer():EyeAngles()
			local pos = ply:GetPos() + offset + ang:Up()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
			draw.DrawText( _T("FreedayTimer", MakeTime(math.Round(plyfd - CurTime()))), "JBHUDFONT", 0, 0, team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER )
			cam.End3D2D()
			pos = ply:GetPos() + Vector(0, 0, 2)
			render.SetMaterial(key14txt)
			render.DrawQuadEasy(pos, Vector(0, 0, 1), 64, 64, color_white)
			render.DrawQuadEasy(pos, Vector(0, 0, -1), 64, 64, color_white)
		end
		if GetGMEntity("JB_Simon") == ply then
			local offset = Vector( 0, 0, 85 )
			local ang = LocalPlayer():EyeAngles()
			local pos = ply:GetPos() + offset + ang:Up()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.2 )
			draw.DrawText( _T("Simon"), "JBHUDFONT", 0, ScreenScale(20), team.GetColor( ply:Team() ), TEXT_ALIGN_CENTER )
			cam.End3D2D()
		end
		local who, frag = GetGMEntity("DUELINIT"), GetGMEntity( "DUELFRAG")
		if IsValid(who) and IsValid(frag) and frag:Alive() and who:Alive() then
			render.SetMaterial(crclmat)
			render.DrawQuadEasy(who:GetPos() + Vector(0, 0, 2), Vector(0, 0, 1), 64, 64, team.GetColor(who:Team()))
			render.DrawQuadEasy(frag:GetPos() + Vector(0, 0, 2), Vector(0, 0, 1), 64, 64, team.GetColor(frag:Team()))
		end
	end,
	["PlayerVoice"] = function(ply)
		render.SetMaterial(talkicon)
		--local col = render.ComputeLighting(ply:EyePos(), vector_origin)
		--render.DrawSprite(ply:EyePos(), 12, 12, Color(255, 255, 255, 255))
		local scale = 12 + 12 * ply:VoiceVolume()
		render.DrawSprite(ply:EyePos() + Vector(0,0,16),scale,scale,color_white)
	end,
	["GameStatus"] = function(msg)
		surface.SetFont("JBHUDFONT")
		local w1, w2 = surface.GetTextSize(msg)
		w1 = w1 + ScreenScale(15)
		w2 = w2 + ScreenScale(5)
		draw.RoundedBox(16, ScrW() * .5 - w1 * .5, ScrH() - ScreenScale(20) - w2 * .5, w1, w2, color_alphagray)
		draw.SimpleText(msg, "JBHUDFONT", ScrW() * .5, ScrH() - ScreenScale(20), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
})
include("scoreboard.lua")