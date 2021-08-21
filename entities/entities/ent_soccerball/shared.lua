AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Soccer ball"
ENT.Author = "UnkN"
function ENT:Initialize()
	self:SetModel"models/props_phx/misc/soccerball.mdl"
	if SERVER then
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		local a = self:GetPhysicsObject()
		if IsValid(a) then
			a:SetMaterial"metal_bouncy"
			a:Sleep()
			a:EnableMotion(false)
			self.PhysDisabled = true
			a:AddGameFlag(bit.bor(FVPHYSICS_NO_IMPACT_DMG, FVPHYSICS_NO_NPC_IMPACT_DMG))
			a:SetBuoyancyRatio(.2)
		end
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.NextTouch = 0
	end
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetSolidFlags(FSOLID_NOT_STANDABLE)
end