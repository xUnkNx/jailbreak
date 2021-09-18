PointQueue = PointQueue or {}
local laser = Material("trails/physbeam")
function ColorRandLight()
	return Color(math.random(192,256),math.random(192,256),math.random(192,256),255)
end
local cross = Material("sprites/animglow02")
Points = Points or {PixVis = {},Circles = {},Colors = {}}
for i = 1,4 do
	Points.PixVis[i] = util.GetPixelVisibleHandle()
	Points.Colors[i] = ColorRandLight()
end
local griptex = Material("gui/faceposer_indicator")
local trail,cable,normal,key,rock = Material("trails/electric"),Material("cable/new_cable_lit"),Vector(0,0,1),Material("sprites/key_11"),Material("gui/workshop_rocket.png")
local le_id = 0
GM.HookGamemode("PostDrawTranslucentRenderables",function()
	local ppos = LocalPlayer():GetPos()
	for i = 0,4 do
		local pos = GetGMVector("Point" .. i)
		if pos then
			local aang = ((ppos -pos):Angle())
			local ang = Angle(0,aang.y + 90,0)
			local dist = pos:Distance(LocalPlayer():GetPos())
			local text = math.Round(dist * 0.01)
			cam.Start3D2D(pos + Vector(0, 0, 0.1), ang, 1 + math.sin(RealTime() * 2) * 0.05)
				surface.SetMaterial(griptex)
				surface.SetDrawColor(dist > 100 and Color(180,180,180,255) or color_white)
				surface.DrawTexturedRect(-128, -128, 256, 256)
				draw.DrawText(i, "JBHUDFONTBOLD", 0, - 8, Points.Colors[i], TEXT_ALIGN_CENTER )
			cam.End3D2D()
			cam.IgnoreZ(true)
			if dist > 100 then
				ang.r = ang.r + 90
				cam.Start3D2D(pos + Vector(0, 0, 36 + math.cos(RealTime() * 2) * 8), ang, math.min(2,dist * 0.001))
					surface.SetDrawColor(color_white)
					surface.SetMaterial(key)
					surface.DrawTexturedRectRotated(-10,-50,100,100,90)
					draw.DrawText( _C("PointX", i, text), "DermaLarge",0,0, Points.Colors[i], 1 )
				cam.End3D2D()
			end
			cam.IgnoreZ(false)
		end
	end
	for i = 1,2 do
		local pos,ang = GetGMVector("PointL" .. i)
		if pos then
			ang,v1,v2,sz = GetGMInt("PointLA" .. i,0),GetGMVector("PointLS" .. i),GetGMVector("PointLE" .. i),GetGMInt("PointLZ" .. i)
			if v1 then
				render.SetMaterial(cable)
				render.DrawQuadEasy(pos, normal, 15, sz, Points.Colors[i], ang )
				--render.DrawWireframeBox(pos,Angle(0,0,0),v1-pos,v2-pos,color_white)
				--render.DrawLine(v1,v2,color_white)
				local x0,y0,x1,x2,y1,y2,dist = ppos.x,ppos.y,v1.x,v2.x,v1.y,v2.y
				local ldist = math.abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
				local dist = math.sqrt((pos.x - x0) * (pos.x-x0) + (pos.y-y0) * (pos.y-y0))
				if (ldist > 50 or dist > sz * .5) or ppos.z-pos.z > 80 then 
					--render.SetMaterial(rock)
					--render.DrawQuadEasy(pos, normal, 50, 50, Points.Colors[i], ang)
					local aang = ((pos - ppos):Angle())
					ang = Angle(0,aang.y > 180 and ang + 180 or ang,90)
					cam.Start3D2D(pos + Vector(0, 0, 48 + math.cos(RealTime() * 2) * 8), ang, 0.5)
						cam.IgnoreZ(true)
							surface.SetDrawColor(color_white)
							surface.SetMaterial(key)
							surface.DrawTexturedRectRotated(-10,-50,100,100,90)
							draw.TextShadow({text = _C("LineUpX"), font = "DermaLarge", pos = {0,0}, color = Points.Colors[i], xalign = TEXT_ALIGN_CENTER}, 1, 200 )
						cam.IgnoreZ(false)
					cam.End3D2D()
				end
			end
		end
	end
	for i = 1,4 do
		local pos = GetGMVector("PointC" .. i)
		if pos and Points.Circles[i] then
			render.SetMaterial(trail)
			render.StartBeam(73)
			for g = 1,73 do
				render.AddBeam(Points.Circles[i][g],20,20,Points.Colors[i])
			end
			render.EndBeam()
			local aang = ((ppos -pos):Angle())
			local ang = Angle(0,aang.y + 90,0)
			local dist = pos:Distance(LocalPlayer():GetPos())
			local text = math.Round(dist * 0.01)
			cam.Start3D2D(pos + Vector(0, 0, 0.1), ang, 1 + math.sin(RealTime() * 2) * 0.05)
				draw.DrawText(i, "JBHUDFONTBOLD", 0, - 8, Points.Colors[i], TEXT_ALIGN_CENTER )
			cam.End3D2D()
		end
	end
	local ct = CurTime()
	for k,v in pairs(PointQueue) do
		if v[1] < ct then
			PointQueue[k] = nil
			continue
		end
		if v[3] > 1 then
			render.SetMaterial(laser)
			render.StartBeam(v[3])
			for i, j in pairs(v[2]) do
				render.AddBeam(j[2], 50, 25, j[3])
			end
			render.EndBeam()
			--render.DrawBeam(v[2], v[3], 15, 0, 128, color_white )
			--render.DrawWireframeBox(v[2],a,mn,mx,color_white,true)
		end
	end
	local e1 = GetGMEntity("JB_Simon")
	if IsValid(e1) then
		if not e1:GetNW("Tracer",false) then
			if e1.LastTrace then
				le_id = #PointQueue + 1
				e1.LastTrace = nil
			end
			return
		end
		if not e1.LastTrace or e1.LastTrace < ct then
			e1.LastTrace = ct + 0.05
			local tr = e1:GetEyeTrace()
			local tab = PointQueue[le_id]
			if not tab then
				tab = { ct + 10, {}, 0}
				PointQueue[le_id] = tab
			end
			local cr = tab[3] == 0
			if not cr then
				local dist = tr.HitPos:DistToSqr(tab[2][ tab[3] ][1])
				if dist < 250 then
					if e1 == LP and GetGMVector("JB_Point0",vector_origin):DistToSqr(tr.HitPos) > 1000 then
						if (LP.TraceCounter or 0) > 10 then
							JBCommand("point", 1, 1, 1)
							LP.TraceCounter = 0
						else
							LP.TraceCounter = (LP.TraceCounter or 0) + 1
						end
					else
						LP.TraceCounter = nil
					end
				else
					cr = true
					LP.TraceCounter = nil
				end
			else
				LP.TraceCounter = nil
			end
			if cr then
				--tab[1] = ct + 10
				tab[3] = tab[3] + 1
				tab[2][ tab[3] ] = {tr.HitPos, tr.HitPos + tr.HitNormal * 3, Color(math.random(0,255),math.random(0,255),math.random(0,255))}
			end
		end
		render.SetMaterial(laser)
		local tr = e1:GetEyeTrace()
		if LocalPlayer() ~= e1 then
			local bp, bone = tr.StartPos, e1:LookupBone("ValveBiped.Bip01_R_Hand")
			if bone then
				local matrix = e1:GetBoneMatrix(bone)
				if matrix then
					bp = matrix:GetTranslation()
					if bp == e1:GetPos() then
						bp = tr.StartPos
					end
				end
			end
			bp = bp + e1:EyeAngles():Forward() * 32
			render.DrawBeam(bp, tr.HitPos, 15, 0, 128, color_white )
		end
		render.SetMaterial(cross)
		render.DrawQuadEasy(tr.HitPos, tr.HitNormal, 10, 10, color_white )
	end
end)
GM.HookGamemode("GlobalVarChanged",function(var,old,new)
	if string.sub(var,1,5) == "Point" then
		if string.sub(var,6,7) == "LA" then
			local i = tonumber(string.sub(var,8,8))
			if i and new then
				local sz, ang, p, s, e = team.GetCount(TEAM_PRISIONER) + 1,Angle(0,new,0),GetGMVector("PointL" .. i,vector_origin)
				s = p-ang:Forward() * sz * .5 * 50
				e = p + ang:Forward() * sz * .5 * 50
				SetGMVector("PointLS" .. i,s)
				SetGMVector("PointLE" .. i,e)
				SetGMInt("PointLZ" .. i,sz * 50 * 2)
			end
		elseif string.sub(var,6,6) == "C" then
			local i = tonumber(string.sub(var,7,7))
			if i and new then
				local t,d,n = {},150,1
				for g = 0,360,5 do
					t[n] = Vector(new.x + math.cos(math.rad(g)) * d,new.y + math.sin(math.rad(g)) * d,new.z + 24)
					n = n + 1
				end
				Points.Circles[i] = t
			end
		end
	end
end)
--[[function GM:OnImpactEffect(tr,dmg,wep,own)
	if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC()) then
		return
	end
	--util.Decal("Cross",tr.HitPos-tr.HitNormal,tr.HitPos+tr.HitNormal)
	--PointQueue[#PointQueue+1]={CurTime()+10,tr.HitPos,tr.HitPos+tr.HitNormal*3,Color(math.random(0,255),math.random(0,255),math.random(0,255))}
end
hook.Add("KeyPress","IMPACT",function(ply,key)
	if key==IN_USE then
		local tr=ply:GetEyeTrace()
		PointQueue[#PointQueue+1]={CurTime()+10,tr.HitPos,tr.HitPos+tr.HitNormal*3,Color(math.random(0,255),math.random(0,255),math.random(0,255))}
	end
end)]]