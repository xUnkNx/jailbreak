GM.DeathNoticeTime = 10
GM.DeathsTable = GM.DeathsTable or {}
function GM:AddDeathNotice(vic,vict,inf,atk,atkt,headshot,wallkill)
	if not killicon.Exists(inf) then
		local tab = weapons.Get(inf)
		if tab then
			inf = tab.PrintName
		else
			inf = string.Replace( inf, "weapon_", "" )
			--inf = string.Replace( inf, "_", " " )
		end
	end
	if vict then
		vict = table.Copy(team.GetColor(vict))
	end
	if atkt then
		atkt = table.Copy(team.GetColor(atkt))
	end
	local w = killicon.GetSize(inf)
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
	table.insert(self.DeathsTable,{[0] = CurTime() + self.DeathNoticeTime,atk,atkt,inf,vic,vict,headshot,wallkill,ScrW() - w})
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
		GAMEMODE:AddDeathNotice("#" .. a, -1, i, p:Nick(), p:Team())
	end
end
net.Receive( "PlayerKilled", RecvPlayerKilledByPlayer )
hook.Add("CalcView","JB_DeathView",function(ply)
	if not ply:Alive() then
		local rag,at = ply:GetRagdollEntity()
		if ply:GetObserverTarget() == rag and ply:GetObserverMode() == OBS_MODE_IN_EYE and IsValid(rag) then
			at = rag:LookupAttachment( "eyes" )
			if at then
				at = rag:GetAttachment( at )
				return {origin = at.Pos + at.Ang:Forward() * 10, angles = at.Ang, fov = 90, znear = 1}
			end
		end
	end
end)