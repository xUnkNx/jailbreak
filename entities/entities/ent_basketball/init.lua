local a = IsValid
include("shared.lua")
function ENT:Use(b, c)
	if self:IsPlayerHolding() then
		DropEntityIfHeld(self)
	end
	if b:IsPlayer() then
		if self.PhysDisabled then
			self.PhysDisabled = false
			local d = self:GetPhysicsObject()
			if a(d) then
				d:EnableMotion(true)
			end
		end
		b:PickupObject(self)
	end
end
function ENT:Think()
	self.Think = nil
	for b, c in pairs(self:GetChildren()) do
		if a(c:GetPhysicsObject()) then
			c:SetCollisionBounds(vector_origin, vector_origin)
		else
			c:SetPos(self:GetPos())
		end
	end
end
ENT.Bounce = Sound("Rubber.ImpactHard")
function ENT:PhysicsCollide(b, c)
	if b.Speed > 60 then
		c:SetVelocity(c:GetVelocity() * .85)
		if b.DeltaTime > .2 then
			self:EmitSound(self.Bounce)
		end
	elseif b.Speed < 10 then
		c:SetVelocity(c:GetVelocity() * .5)
		c:AddAngleVelocity(-c:GetAngleVelocity())
	end
end