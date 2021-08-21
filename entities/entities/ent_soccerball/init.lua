local a = IsValid
include"shared.lua"
ENT.Bounce = Sound"Rubber.BulletImpact"
local b = .5
function ENT:StartTouch(c)
	if self.PhysDisabled then
		self.PhysDisabled = false
		local f = self:GetPhysicsObject()
		if a(f) then
			f:EnableMotion(true)
		end
	end
	if c:IsPlayer() then
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	else
		return
	end
	local d = CurTime()
	if self.NextTouch > d then return end
	local e = self:GetPhysicsObject()
	if a(e) then
		self.NextTouch = d + .1
		local f = (self:WorldSpaceCenter() - c:GetPos()):GetNormal()
		local g = math.max(50, c:GetVelocity():Length())
		g = math.Rand(g * .25, g)
		self:EmitSound(self.Bounce)
		e:SetVelocity(e:GetVelocity() + f * g * e:GetMass() * b)
	end
end
function ENT:EndTouch(c)
	if c:IsPlayer() then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
end
function ENT:PhysicsCollide(c, d)
	if c.Speed > 100 then
		local e = d:GetVelocity() * b
		e.z = e.z * .25
		d:SetVelocity(e)
		if c.DeltaTime > .2 then
			self:EmitSound(self.Bounce)
		end
	elseif c.Speed < 10 then
		d:AddAngleVelocity(-d:GetAngleVelocity())
	end
end
function ENT:PhysicsSimulate()
	return SIM_NOTHING
end