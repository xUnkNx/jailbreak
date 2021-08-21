PointQueue = PointQueue or {}
local laser = Material("trails/laser")
function ColorRandLight()
	return Color(math.random(128,256),math.random(128,256),math.random(128,256),255)
end
local cross = Material("sprites/animglow02")
Points = Points or {PixVis = {},Circles = {},Colors = {}}
for i = 1,4 do
	Points.PixVis[i] = util.GetPixelVisibleHandle()
	Points.Colors[i] = ColorRandLight()
end
local griptex = Material("gui/faceposer_indicator")
local trail,cable,normal,key,rock = Material("trails/electric"),Material("cable/new_cable_lit"),Vector(0,0,1),Material("sprites/key_11"),Material("gui/workshop_rocket.png")
hook.Add("PostDrawTranslucentRenderables","Test",function()
	local ppos = LocalPlayer():GetPos()
	for i = 1,4 do
		local pos = GetGMVector("Point" .. i)
		if pos then
			local dist = pos:Distance(LocalPlayer():GetPos())
			local text = math.Round(dist * 0.01)
			cam.Start3D2D(pos + Vector(0, 0, 0.1), Angle(0, 0, 0), 0.5 + math.sin(RealTime() * 2) * 0.05)
				surface.SetMaterial(griptex)
				surface.SetDrawColor(dist > 100 and Color(180,180,180,255) or color_white)
				surface.DrawTexturedRect(-256, -256, 512, 512)
			cam.End3D2D()
			cam.IgnoreZ(true)
			local ang = LocalPlayer():EyeAngles()
			ang = Angle(0, ang.y + 270, 90)
			if dist > 100 then
				cam.Start3D2D(pos + Vector(0, 0, 36 + math.cos(RealTime() * 2) * 8), ang, math.min(2,dist * 0.001))
					surface.SetDrawColor(color_white)
					surface.SetMaterial(key)
					surface.DrawTexturedRectRotated(-10,-50,100,100,90)
					draw.DrawText("Точка " .. i .. "\n" .. text .. " м.", "DermaLarge",0,0, Points.Colors[i], 1 )
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
				--render.DrawWireframeBox(pos,Angle(0,0,0),v1-pos,v2-pos,color_white)
				--render.DrawLine(v1,v2,color_white)
				local x0,y0,x1,x2,y1,y2,dist = ppos.x,ppos.y,v1.x,v2.x,v1.y,v2.y
				local ldist = math.abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
				local dist = math.sqrt((pos.x - x0) * (pos.x-x0) + (pos.y-y0) * (pos.y-y0))
				if (ldist > 50 or dist > sz / 2) or ppos.z-pos.z > 80 then 
					render.SetMaterial(rock)
					render.DrawQuadEasy(pos, normal, 50, 50, Points.Colors[i], ang)
					cam.IgnoreZ(true)
					local ang = LocalPlayer():EyeAngles()
					ang = Angle(0, ang.y + 270, 90)
					cam.Start3D2D(pos + Vector(0, 0, 36 + math.cos(RealTime() * 2) * 8), ang, 0.5)
						surface.SetDrawColor(color_white)
						surface.SetMaterial(key)
						surface.DrawTexturedRectRotated(-10,-50,100,100,90)
						draw.TextShadow({text = "Выстроиться тут!", font = "DermaLarge", pos = {0,0}, color = Points.Colors[i], xalign = TEXT_ALIGN_CENTER}, 1, 200 )
					cam.End3D2D()
					cam.IgnoreZ(false)
				end
				render.SetMaterial(cable)
				render.DrawQuadEasy(pos, normal, 5, sz, Points.Colors[i], ang )
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
		end
	end
end)
hook.Add("GlobalVarChanged","PointsCompute",function(var,old,new)
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
function GM:PostDrawTranslucentRenderables()
	--[[local ct=CurTime()
	render.SetMaterial(laser)
	local cnt=#PointQueue
	if cnt>0 then
		render.StartBeam(cnt)
		for k,v in pairs(PointQueue) do
			if v[1] < CurTime() then
				PointQueue[k]=nil
				continue
			end
			render.AddBeam(v[3],50,25,v[4])
			
			--render.DrawBeam(v[2], v[3], 15, 0, 128, color_white )
			--render.DrawWireframeBox(v[2],a,mn,mx,color_white,true)
		end
		render.EndBeam()
	end]]
	local e1 = GetGMEntity("JB_Simon")
	if IsValid(e1) and e1:GetNW2Bool("Tracer",false) then
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
end
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