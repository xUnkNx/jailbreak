local Sound, CurTime, IsValid, AccessorFunc, IsFirstTimePredicted = Sound, CurTime, IsValid, AccessorFunc, IsFirstTimePredicted
AddCSLuaFile()
SWEP.Base = "weapon_fist"
SWEP.PrintName = "???"
SWEP.Spawnable = false
SWEP.DefaultDamage = 20
SWEP.UppercutDamage = 30

local f = Sound"npc/zombie/claw_miss1.wav"
local g = Sound"npc/zombie/claw_miss1.wav"
local h = Sound"npc/zombie/claw_strike1.wav"
local i = Sound"npc/zombie/claw_strike2.wav"
local j = Sound"npc/zombie/claw_strike3.wav"
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Hide")
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Float", 2, "NextPain")
	self:NetworkVar("Int", 0, "Combo")
end
function SWEP:Initialize()
	self:SetHoldType("fist")
	AccessorFunc(self, "m_Hide", "Hide")
	AccessorFunc(self, "m_NextHide", "NextHide")
	self.NextStep = 0
end
function SWEP:SecondaryAttack()
	self:Pain()
end
function SWEP:Pain()
	local ct, pl = CurTime(), self.Owner
	if IsFirstTimePredicted() and IsValid(pl) and self:GetNextPrimaryFire() < ct and self:GetNextPain() < ct then
		local tm = ct + math.Rand(3,7)
		self:SetNextPain(tm)
		self:SetNextPrimaryFire(ct + math.Rand(1.75,2.25))
		if SERVER then
			pl:SetHealth(math.min(pl:Health() + pl:GetMaxHealth() * math.Rand(0.15,0.25),pl:GetMaxHealth()))
		end
		pl:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
		pl:EmitSound("npc/zombie/zombie_alert1.wav")
	end
end
function SWEP:PhysHit(tr,dmg)
	local phent = tr.Entity
	local phobj = phent:GetPhysicsObject()
	if IsValid(phobj) then
		if (phent:GetClass() == "prop_door_rotating" or phent:GetClass() == "func_door" or phent:GetClass() == "func_door_rotating") or phent:GetClass() == "prop_physics" then
			if phent.ZMHT == nil then
				phent.ZMHT = phent:GetClass() == "prop_physics" and math.random(6,12) or math.random(2, 4)
			else
				phent.ZMHT = phent.ZMHT - 1
			end
			phent:EmitSound(math.random(1,2) == 1 and "ambient/materials/door_hit1.wav" or "ambient/materials/clang1.wav")
			local n = phent.ZMHT * 25.5
			phent:SetColor(Color(n, n, n, 255))
			if phent.ZMHT == 0 then
				if phent:GetClass() == "prop_physics" then
					phent:Remove()
					return
				end
				phent:Fire("open")
				phent:Fire("unlock")
				local ppos, angls, model, skin = phent:GetPos(), phent:GetAngles(), phent:GetModel(), phent:GetSkin()
				local eff = EffectData()
				eff:SetOrigin(ppos)
				util.Effect("effect_smokedoor", eff)
				phent:SetNotSolid(true)
				phent:SetNoDraw(true)
				SafeRemoveEntity(phent)
				local t = (tr.HitPos - tr.StartPos):GetNormalized() * 1000
				local ent = ents.Create("prop_physics")
				ent:SetPos(ppos)
				ent:SetAngles(angls)
				ent:SetModel(model)
				if skin then
					ent:SetSkin(skin)
				end
				ent:Spawn()
				local phy = ent:GetPhysicsObject()
				if IsValid(phy) then
					phy:ApplyForceCenter(t * (phy:GetMass() > 0 and phy:GetMass() or 1))
				end
			end
		else
			phobj:ApplyForceCenter(dmg:GetDamageForce() * 2)
		end
	end
end
function SWEP:Deploy()
	local k = self.Owner:GetViewModel()
	k:SendViewModelMatchingSequence(k:LookupSequence("fists_draw"))
	self:UpdateNextIdle()
	self:SetCombo(0)
	local l = CurTime() + 1.5
	self:SetNextPrimaryFire(l)
	self:SetNextSecondaryFire(l)
	if self.FirstInit == nil then
		self.FirstInit = true
		k:SendViewModelMatchingSequence(k:LookupSequence("seq_admire"))
	else
		k:SendViewModelMatchingSequence(k:LookupSequence("fists_draw"))
	end
	return true
end
function SWEP:Reload()
	self:Pain()
end
function SWEP:PrimaryAttack()
	local id = math.Round(util.SharedRandom("zf" .. self.Owner:EntIndex(),1,6,CurTime()))
	local seqdur = self.BaseClass.PrimaryAttack(self, id % 3 == 1)
	if seqdur then
		local dur = DoZombieAttackAnim(self.Owner, id)
		self.Owner:GetViewModel():SetPlaybackRate(seqdur / dur * .75)
		self:SetNextMeleeAttack(CurTime() + dur * 0.5)
		if dur then
			self:SetNextPrimaryFire(CurTime() + dur + 0.1)
		end
	end
end
local steps = {"Zombie.FootstepLeft","Zombie.ScuffLeft","Zombie.FootstepRight","Zombie.ScuffRight"}
function SWEP:Think()
	self.BaseClass.Think(self)
	if self.Owner:KeyDown(IN_USE) then
		local tr = self.Owner:GetEyeTraceNoCursor()
		if tr.Hit and tr.Fraction < 0.001525 then
			self.Owner:SetNW("Climbing",true)
			self.Owner:SetVelocity(Vector(0,0,20))
			if self.NextStep < CurTime() then
				self:EmitSound(steps[math.random(1,4)])
				self.NextStep = CurTime() + 0.4
			end
		else
			self.Owner:SetNW("Climbing",false)
		end
	else
		self.Owner:SetNW("Climbing",false)
	end
end