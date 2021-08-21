local curang,curvec,tarang,tarvec = Angle( 0, 0, 0 ),Vector( 0, 0, 0 ),Angle( 0, 0, 0 ),Vector( 0, 0, 0 )
local floor,Clamp,abs,cos,sin,CurTime,Rand,LerpAngle,LerpVector,FrameTime = math.floor,math.Clamp,math.abs,math.cos,math.sin,CurTime,math.Rand,LerpAngle,LerpVector,FrameTime
function CalculateAdv(pl,v)
	local ft,ct = FrameTime(),CurTime()
	local vel,runspeed,walkspeed = floor( pl:GetVelocity():Length() - 1 ),pl:GetRunSpeed(),pl:GetWalkSpeed()	
	if pl:OnGround() then
		if vel > walkspeed + 5 then
			local perc = vel / runspeed * 100
			perc = Clamp( perc, .5, 6 )
			tarang = Angle(abs(cos(ct * (runspeed / 40)) * 1.5 * perc) - perc, sin(ct * (runspeed / 40)) * .2 * perc,0)
			tarvec = Vector(0,0,sin(ct * (runspeed / 30)) * .4 * perc)
		else
			local perc = vel / walkspeed * 100
			perc = Clamp( perc / 30, .5, 4 )
			tarang = Angle(cos(ct * 4) * .3 *  perc, 0, 0 )
			tarvec = Vector(0,0,sin(ct * 3) * .3 * perc)
		end
	else
		if pl:WaterLevel() >= 2 then
			tarvec = Vector( 0, 0, 0 )
			tarang = Angle( 0, 0, 0 )
		else
			vel = abs(pl:GetVelocity().z)
			local af = 0
			perc = Clamp(vel / 200,.1, 8 )
			if perc > 1 then
				af = perc
			end
			tarang = Angle(cos(ct * 15) * 2 * perc + Rand(-af * 2, af * 2), sin(ct * 15) * 2 * perc + Rand(-af * 2, af * 2),Rand(-af * 5, af * 5))
			tarvec = Vector(cos(ct * 15) * .5 * perc,sin(ct * 15) * .5 * perc, 0)
		end
	end
	curang = LerpAngle(ft * 10, curang, tarang)
	curvec = LerpVector(ft * 10, curvec, tarvec)
	v.angles = v.angles + curang
	v.origin = v.origin + curvec
	v.fov = v.fov
	return v
end
local DELTA_SPEED = 0
local function CreateClampClientConVar(str,default,savecl,savesv,min,max)
	local cvar = CreateClientConVar(str,default,savecl,savesv)
	cvars.AddChangeCallback( str, function(cmd, old, new)
		new = tonumber(new)
		if not new then
			return
		elseif new < min then
			RunConsoleCommand( str, min )
		elseif new > max then
			RunConsoleCommand( str, max )
		end
	end)
	return cvar
end
local adv,cadv,shake = CreateClampClientConVar( "thirdperson_advance", 0, true, false, 0, 1 ),CreateClampClientConVar( "thirdperson_camadvance", 0, true, false, 0, 1 ),CreateClampClientConVar( "thirdperson_camshake", 0, true, false, 0, 1 )
hook.Add("ShouldDrawLocalPlayer","NewTHirdperson",function(ply)
	if adv:GetBool() then
		return true
	end
end)
local Approach = math.Approach
function CalcViewToLP(client, origin, angles, fov, znear, zfar)
	if client:Alive() and client:GetObserverMode() == OBS_MODE_NONE then
		local view = {origin = origin,angles = angles,fov = fov,znear = znear,zfar = zfar,drawviewer = false}
		if shake:GetBool() then
			local velocity,eyeAngles,speed,strafe = client:GetVelocity(),client:EyeAngles()
			speed,strafe = eyeAngles:Forward():Dot(velocity) * 0.01,eyeAngles:Right():Dot(velocity) * 0.01
			DELTA_SPEED = Approach(DELTA_SPEED, speed, 0.005)
			view.angles = view.angles + Angle(speed * 0.6, strafe * -1.2, strafe * 0.7)
			view.fov = view.fov + speed
			if cadv:GetBool() and not adv:GetBool() then
				CalculateAdv(client,view)
			end
		end
		if adv:GetBool() then
			local att = client:GetAttachment(client:LookupAttachment("eyes"))
			if att then
				view.angles.pitch = Clamp(angles.pitch + att.Ang.pitch * 0.65,-90,90)
				view.angles.roll = att.Ang.roll * 0.4
				view.origin = att.Pos
				if cadv:GetBool() then
					CalculateAdv(client,view)
				else
					view.angles = att.Ang
					view.fov = att.fov
				end
				if client:GetMoveType() ~= MOVETYPE_NOCLIP then
					local tr = util.TraceHull( {
					start = att.Pos,
					endpos = att.Pos + client:GetAimVector() * 4,
					mask = MASK_SHOT_HULL,
					filter = client})
					if ( tr.Hit ) then
						view.origin = tr.HitPos - client:GetAimVector() * 64
					end
				end
				view.drawviewer = true
			end
			return view
		end
	end
end
hook.Add("CalcView","RecalcPos",CalcViewToLP)