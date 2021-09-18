GM.HookGamemode("PlayerFootstep", function(pl, vFootPos, left)
	if pl:Team() ~= TEAM_ATTACKER then return end
	if left == 0 then
		pl:EmitSound(math.random(1,10) == 1 and "Zombie.ScuffLeft" or "Zombie.FootstepLeft")
	else
		pl:EmitSound(math.random(1,10) == 1 and "Zombie.ScuffRight" or "Zombie.FootstepRight")
	end
	return true
end)
GM.HookGamemode("PlayerStepSoundTime", function(pl, iType, bWalking)
	if pl:Team() ~= TEAM_ATTACKER then return end
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 625 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 600
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 750
	end
	return 450
end)
GM.HookGamemode("DoAnimationEvent",function(pl,event,data)
	if pl:Team() ~= TEAM_ATTACKER then return end
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		DoZombieAttackAnim(pl, math.Round(util.SharedRandom("zf" .. pl:EntIndex(),1,6,CurTime())))
		return ACT_INVALID
	end
end)
net.Receive("EntityChannel",function(len)
	local id, ent = net.ReadUInt(4), net.ReadEntity()
	if not ent then return end
	if id == 0 then
		local func = net.ReadString()
		if IsValid(ent) and func and ent[func] then
			ent[func](ent)
		end
	end
end)
local mat, HaloLast = Material( "effects/select_ring" ), Color(255,0,0)
GM.HookGamemode("PreDrawHalos",function()
	if LocalPlayer():Team() ~= TEAM_ATTACKER then return end
	local ent = GetGMEntity("ZFD_LastSurvivorP")
	if ent then
		halo.Add( {ent}, HaloLast, 2, 2, 1, true, true )
	end
end)
GM.HookGamemode("PostDrawOpaqueRenderables",function()
	if LocalPlayer():Team() ~= TEAM_ATTACKER then return end
	render.DepthRange( 0, 0.01 )
	local clr = Color(0, 255, 0, 255)
	for k,v in pairs(team.GetAlive(TEAM_DEFENDER)) do
		local sz, sz1 = LocalPlayer():GetPos():DistToSqr(v:GetPos()) * 0.0001
		if sz < 300 then
			clr.a = math.Clamp(sz, 0, 255)
			sz1 = math.Clamp(sz, 16, 64)
			render.SetMaterial( mat )
			render.DrawSprite( v:EyePos() - Vector(0,0,16), sz1, sz1, clr)
		end
	end
	render.DepthRange( 0, 1 )
end)
GM.HookGamemode("ShouldHideEntity",function(e)
	if e:IsPlayer() and e:Team() == TEAM_DEFENDER then
		return false
	end
end)
local Survivors, Zombies, Dead = _C("Survivors"), _C("Zombies"), _C("Dead")
local SurvivorsC, ZombiesC, DeadC = Color(50,50,200), Color(200,50,50), Color(100,200,100)
GM.HookGamemode("TabSelectCategory",function(tab, ply)
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:Alive() then
		if ply:Team() == TEAM_ATTACKER then
			return Zombies, -5, ZombiesC
		elseif ply:Team() == TEAM_DEFENDER then
			return Survivors, -10, SurvivorsC
		end
	else
		return Dead, 10, DeadC
	end
end)
GM.HookGamemode("HUDPaint",function(w,h)
	if GetGMInt("JB_Round") == Round_In then
		GetDesignPart("GameStatus")(_C("ZombieFreeday"))
	end
end)