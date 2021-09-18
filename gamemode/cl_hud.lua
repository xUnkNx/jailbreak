local Color,Lerp = Color,Lerp
function LerpColor(t,a,b)
	return Color(Lerp(t,a.r,b.r),Lerp(t,a.g,a.g),Lerp(t,a.b,a.b))
end
local modf, round = math.modf, math.Round
function MakeTime( seconds )
	if seconds < 0 then return "0:00" end
	local m,s = modf(seconds / 60)
	s = round(s * 60)
	return (m < 10 and "0" .. m or m) .. ":" .. (s < 10 and "0" .. s or s)
end
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
function GetBindValue(inp)
	return input.LookupBinding(inp) or _T("NotBound")
end
hook.Add("InitPostEntity", "!IFHOOKCRASHED", function()
	LP = LocalPlayer()
end)
function GM:HUDPaint()
	local ct = CurTime()
	local cnt = 0
	for i, m in pairs(self.PickupHistory) do
		if m[2] <= ct then
			self.PickupHistory[i] = nil
		end
		cnt = cnt + 1
		if cnt > 10 then
			self.PickupHistory[i] = nil
		end
		GetDesignPart("PickupHistory")(m, cnt, ct)
	end
	GetDesignPart("DeathNotice")(0.85, 0.04, ct)
	local ply,whospec,whoreal = LP
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
		GetDesignPart("PlayerStatus")(whoreal)
		if whoreal ~= ply then
			GetDesignPart("SpectatePlayer")(whoreal)
		end
		local SWEP = whoreal:GetActiveWeapon()
		if IsValid(SWEP) and SWEP.DrawAmmo and whoreal == ply then
			GetDesignPart("Ammo")(whoreal, SWEP)
		end
		GetDesignPart("Weapon")(whoreal, SWEP)
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
			if v:Alive() and v ~= LP then
				local distance = LP:GetPos():DistToSqr( v:GetPos() )
				if distance <= 1024 and not v.Hidden then
					v.Hidden = true
					local color = ply:GetColor()
					v:SetRenderMode(RENDERMODE_TRANSCOLOR)
					v:SetColor( Color(color.r, color.g, color.b, 0) )
				elseif v.Hidden then
					v.Hidden = nil
					local color = ply:GetColor()
					v:SetRenderMode(RENDERMODE_NORMAL)
					v:SetColor( Color(color.r, color.g, color.b, 255) )
				end
			end
		end
		local tr = ply:GetEyeTraceNoCursor()
		local ent = tr.Entity
		if IsValid(ent) then
			if ent:IsPlayer() then
				if tr.HitPos:DistToSqr(tr.StartPos) < 262144 then
					GAMEMODE.LastLooked = ent
					GAMEMODE.LookedFade = CurTime()
				end
			else
				GetDesignPart("EntityInfo")(ent, tr, ply)
			end
		end
		GetDesignPart("PlayerInfo")(GAMEMODE.LastLooked, GAMEMODE.LookedFade, tr, ply)
	end
	local round = GetGMInt("JB_Round",0)
	GetDesignPart("RoundStatus")(round, GetGMInt("JB_Time",0))
end
function GM:GlobalVarChanged(nm,old,new)
	if nm == "JB_RoundStatus" then
		local txt = nil
		if new == round_alldead then
			txt = _C("R_alldead")
		elseif new == round_wint then
			txt = _C("R_wint")
		elseif new == round_winct then
			txt = _C("R_winct")
		elseif new == round_timeout then
			txt = _C("R_timeout")
		elseif new == round_winzombie then
			txt = _C("R_winzombie")
		elseif new == round_winhuman then
			txt = _C("R_winhuman")
		elseif new == round_winhider then
			txt = _C("R_winhider")
		elseif new == round_winseeker then
			txt = _C("R_winseeker")
		elseif new == round_winassault then
			txt = _C("R_winassault")
		elseif new == round_winguards then
			txt = _C("R_winguards")
		elseif new == round_battleend then
			txt = _C("R_battleend")
		elseif new == round_begin then
			txt = _C("RoundStarting")
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
		GetDesignPart("PlayerVoice",ply)
	end
	if ply == LP then return end
	local Distance = LP:GetPos():DistToSqr( ply:GetPos() )
	if ( Distance < 1000000 ) then
		GetDesignPart("PlayerOverlay", ply)
	end
end