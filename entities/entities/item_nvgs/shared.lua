AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Kevlar"
ENT.Author = "UnkN"
function ENT:Initialize()
	self:SetModel"models/xqm/boxfull.mdl"
	self:SetModelScale(.5, 0)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetTrigger(true)
		local a = self:GetPhysicsObject()
		if IsValid(a) then
			a:Sleep()
			a:EnableMotion(false)
		end
		self.RemoveNextFrame = false
	end
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end