AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Basket ball"
ENT.Author = "UnkN"
function ENT:Initialize()
	self:SetModel"models/dav0r/hoverball.mdl"
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		local a = self:GetPhysicsObject()
		if IsValid(a) then
			a:SetMaterial"gmod_bouncy"
			a:EnableMotion(false)
			a:Sleep()
			self.PhysDisabled = true
			a:AddGameFlag(bit.bor(FVPHYSICS_NO_IMPACT_DMG, FVPHYSICS_NO_NPC_IMPACT_DMG))
		end
		self:SetUseType(SIMPLE_USE)
	end
	self:SetMaterial"orange"
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolidFlags(FSOLID_NOT_STANDABLE)
end
if CLIENT then
	function ENT:ImpactTrace()
		return true
	end
end