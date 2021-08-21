include("shared.lua")
ENT.ArmorCount = 30
ENT.Pickup = Sound("HL2Player.PickupWeapon")
function ENT:PlayerCanPickup(a)
	if a:Armor() >= self.ArmorCount then return false end
	local b = hook.Run("PlayerCanPickupItem", a, self)
	if b == false then return b end
	return true
end
function ENT:Rem()
	if self.RemoveNextFrame then
		self:Remove()
	end
end
function ENT:Touch(a)
	if self.RemoveNextFrame ~= true and IsValid(a) and a:IsPlayer() and self:PlayerCanPickup(a) then
		a:SetArmor(self.ArmorCount)
		self:EmitSound(self.Pickup)
		self.RemoveNextFrame = true
		self.Think = self.Rem
	end
end