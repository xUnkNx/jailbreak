GM:AddGamemode(
	"ZFD",
	{
		Usable = true,
		MinPlayers = 5,
		RoundDelay = 3
	}
)
include((SERVER and "init" or "cl_init") .. ".lua")
AddCSLuaFile("cl_init.lua")
local ZombieAttackSequences = {
	"zombie_attack_01",
	"zombie_attack_02",
	"zombie_attack_03",
	"zombie_attack_04",
	"zombie_attack_05",
	"zombie_attack_06"
}
function DoZombieAttackAnim(ply, rand)
	local seq = ZombieAttackSequences[rand]
	if seq then
		local seqid = ply:LookupSequence(seq)
		if seqid > 0 then
			ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, seqid, 0, true)
			return ply:SequenceDuration(seqid)
		end
	end
	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
	return false
end
local fastspeed = 375 * 375
local normalspeed = 275 * 275
GM.HookGamemode("CalcMainActivity",function(pl, velocity)
	if pl:Team() ~= TEAM_ATTACKER then return end
	if pl:GetNW2Bool("Climbing") then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end
	if pl:WaterLevel() >= 3 then
		pl:SetPlaybackRate(1)
		return ACT_HL2MP_SWIM_PISTOL, -1
	end
	local speed = velocity:Length2DSqr()
	if speed <= 1 then
		if pl:Crouching() and pl:OnGround() then
			pl:SetPlaybackRate(1)
			return ACT_HL2MP_IDLE_CROUCH_ZOMBIE, -1
		end
		pl:SetPlaybackRate(1)
		return ACT_HL2MP_IDLE_ZOMBIE, -1
	end
	if pl:Crouching() and pl:OnGround() then
		pl:SetPlaybackRate(1)
		return ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 - 1 + math.ceil((CurTime() / 4 + pl:EntIndex()) % 3), -1
	end
	pl:SetPlaybackRate(math.min(3, speed * 0.01))
	if speed > fastspeed then
		return ACT_HL2MP_RUN_ZOMBIE_FAST, -1
	elseif speed > normalspeed then
		return ACT_HL2MP_RUN_ZOMBIE, -1
	else
		return ACT_HL2MP_WALK_ZOMBIE_01 - 1 + math.ceil((CurTime() / 3 + pl:EntIndex()) % 3), -1
	end
end)