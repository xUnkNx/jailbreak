local a, IsValid, c, d = CurTime, IsValid, Vector, Sound
AddCSLuaFile()
SWEP.PrintName = "Руки"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.DrawAmmo = false

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 52
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawWeaponInfoBox = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DefaultDamage = 10
SWEP.UppercutDamage = 15

local e = d("weapons/slam/throw.wav")
local f = d("Flesh.ImpactHard")
SWEP.HitDistance = 48
function SWEP:Initialize()
	self:SetHoldType"normal"
	self:SetHide(true)
end
function SWEP:PreDrawViewModel(h, i, j)
	h:SetMaterial"engine/occlusionproxy"
end
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Hide")
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Float", 2, "NextHide")
	self:NetworkVar("Int", 0, "Combo")
end
function SWEP:UpdateNextIdle()
	local h = self.Owner:GetViewModel()
	self:SetNextIdle(a() + h:SequenceDuration())
end
function SWEP:PrimaryAttack(h)
	if not self:GetHide() then
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		local i = "fists_left"
		if h then
			i = "fists_right"
		end
		if self:GetCombo() >= 2 then
			i = "fists_uppercut"
		end
		local j = self.Owner:GetViewModel()
		local seq = j:LookupSequence(i)
		j:SendViewModelMatchingSequence(seq)
		self:EmitSound(e)
		self:UpdateNextIdle()
		self:SetNextMeleeAttack(a() + .2)
		local k = a() + .9
		self:SetNextHide(k)
		self:SetNextPrimaryFire(k)
		self:SetNextSecondaryFire(k)
		return j:SequenceDuration(seq)
	end
end
function SWEP:SecondaryAttack()
	self:PrimaryAttack(true)
end
function SWEP:PhysHit(tr,dmg)
	local i = tr.Entity:GetPhysicsObject()
	if IsValid(i) then
		i:ApplyForceOffset(dmg:GetDamageForce(), tr.HitPos)
	end
end
-- https://github.com/VSES/SourceEngine2007/blob/43a5c90a5ada1e69ca044595383be67f40b33c61/src_main/game/shared/takedamageinfo.cpp#L312-L324
local physman = 75 * 4 * 50
function SWEP:Hit(h)
	local i = false
	if IsValid(h.Entity) then
		if SERVER then
			local dmg = DamageInfo()
			local own = self.Owner
			if not IsValid(own) then
				own = self
			end
			dmg:SetAttacker(own)
			dmg:SetInflictor(self)
			dmg:SetDamage(self.DefaultDamage + math.random(-2, 2))
			dmg:SetDamageBonus(math.random(13, 17))
			dmg:SetDamagePosition(h.HitPos)

			if (anim == "fists_left") then
				--j:SetDamageForce(k:GetRight() * 4912 + k:GetForward() * 9998)
			elseif (anim == "fists_right") then
				--j:SetDamageForce(k:GetRight() * -4912 + k:GetForward() * 9989)
			elseif (anim == "fists_uppercut") then
				--j:SetDamageForce(k:GetUp() * 5158 + k:GetForward() * 10012)
				dmg:SetDamage(self.UppercutDamage + math.random(-2, 2))
			end

			local force = own:EyeAngles():Forward()
			force = force * dmg:GetDamage() * physman
			dmg:SetDamageForce(force)

			SuppressHostEvents( NULL ) -- Let the breakable gibs spawn in multiplayer on client
			h.Entity:TakeDamageInfo(dmg)
			SuppressHostEvents(own)

			self:PhysHit(h,dmg)
		end
		return true
	end
end

function SWEP:DealDamage()
	if self.Hided then return end
	local h = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())
	self.Owner:LagCompensation(true)
	local i = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner
	})
	if not IsValid(i.Entity) then
		i = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = c(-10, -10, -8),
			maxs = c(10, 10, 8)
		})
	end
	if i.Hit and not (game.SinglePlayer() and CLIENT) then
		self:EmitSound(f, 75, math.random(80, 110))
	end
	local j = self:Hit(i)
	if j and h ~= "fists_uppercut" then
		self:SetCombo(self:GetCombo() + 1)
	else
		self:SetCombo(0)
	end
	self.Owner:LagCompensation(false)
end
function SWEP:OnRemove()
	if (IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer()) then
		local h = self.Owner:GetViewModel()
		if (IsValid(h)) then
			h:SetMaterial""
		end
	end
	return true
end

function SWEP:OnDrop()
	self:Remove()
end
function SWEP:Holster()
	self:OnRemove()
	return true
end
function SWEP:Deploy()
	local h = self.Owner:GetViewModel()
	h:SendViewModelMatchingSequence(h:LookupSequence"fists_draw")
	self:UpdateNextIdle()
	self:SetCombo(0)
	local i = a() + .5
	self:SetNextHide(i)
	self:SetNextPrimaryFire(i)
	self:SetNextSecondaryFire(i)
	return true
end
SWEP.CPos = c(0, -.82, -5)
SWEP.CAng = c(-30.247, 0, 0)
local g = .5
function SWEP:GetViewModelPosition(h, i)
	if not self.CPos then return h, i end
	local j, k = self:GetHide(), a()
	if j ~= self.bLastC then
		self.bLastC = j
		self.fCTime = k
	end
	local l = self.fCTime or 0
	if not j and l < k - g then return h, i end
	local m = 1.0
	if l > k - g then
		m = math.Clamp((k - l) / g, 0, 1)
		if not j then
			m = 1 - m
		end
	end
	local n = self.CPos
	if self.CAng then
		i = i * 1
		i:RotateAroundAxis(i:Right(), self.CAng.x * m)
		i:RotateAroundAxis(i:Up(), self.CAng.y * m)
		i:RotateAroundAxis(i:Forward(), self.CAng.z * m)
	end
	local o = i:Right()
	local p = i:Up()
	local q = i:Forward()
	h = h + n.x * o * m
	h = h + n.y * q * m
	h = h + n.z * p * m
	return h, i
end
function SWEP:ChangeHideMode(h)
	local i = a() + .9
	self:SetNextHide(i)
	self:SetHide(h)
	self:SetNextPrimaryFire(i)
	self:SetNextSecondaryFire(i)
	if h then
		self:SetHoldType"normal"
		self:SetNextMeleeAttack(0)
		self:SetNextIdle(0)
	else
		self:SetHoldType"fist"
	end
end
function SWEP:Reload()
	if self:GetNextHide() > a() then return end
	self:ChangeHideMode(not self:GetHide())
end
function SWEP:Think()
	if self:GetHide() then return end
	local h, i = self.Owner:GetViewModel(), a()
	local j = self:GetNextIdle()
	if j > 0 and i > j then
		h:SendViewModelMatchingSequence(h:LookupSequence("fists_idle_0" .. math.random(1, 2)))
		self:UpdateNextIdle()
	end
	local k = self:GetNextMeleeAttack()
	if k > 0 and i > k then
		self:DealDamage()
		self:SetNextMeleeAttack(0)
	end
	if SERVER and i > self:GetNextPrimaryFire() + .1 then
		self:SetCombo(0)
	end
end