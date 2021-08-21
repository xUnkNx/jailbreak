include("shared.lua")
function ENT:PlayerCanPickup(a)
	if a.GetGM and a:GetGM("NVGS") then return false end
	local b = hook.Run("PlayerCanPickupItem", a, self)
	if b == false then return b end
	return true
end
ENT.Pickup = Sound"HL2Player.PickupWeapon"
function ENT:Rem()
	if self.RemoveNextFrame then
		self:Remove()
	end
end
function ENT:Touch(a)
	if self.RemoveNextFrame ~= true and IsValid(a) and a:IsPlayer() and self:PlayerCanPickup(a) then
		self.RemoveNextFrame = true
		self.Think = self.Rem
		a:SetGM("NVGS", true)
		self:EmitSound(self.Pickup)
	end
end