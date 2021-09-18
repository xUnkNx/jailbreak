AddCSLuaFile()
ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "#WeaponBox"
ENT.Spawnable 			= true
ENT.AdminOnly			= true
function ENT:Initialize()
	if SERVER then
		self:SetModel("models/items/cs_gift.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetBuoyancyRatio(0)
		end
		self:DropToFloor()
	else
		self.CSEnt = ClientsideModel("models/items/cs_gift.mdl")
		self.zoff = 0
		self.dir = true
		self.Angle = Angle()
	end
	self:EmitSound("items/gift_drop.wav")
end
function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Weapon" )
end
local funcrem = function(self)
	self:Remove()
end
--[[local chngdmgtype = function(atk, tr, dmginfo)
	dmginfo:SetDamageBonus(10)
	dmginfo:SetDamage(10)
	print(dmginfo)
end
local funcchng = function(self,bullet)
	bullet.Callback = chngdmgtype
end]] -- BUG: Gmod doesn't handle damagebonus in bullets
function ENT:Use(activator,caller,useType,value)
	if activator:IsPlayer() and not activator:HasWeapon(self:GetWeapon()) then
		local wep = activator:Give(self:GetWeapon())
		wep.PickedUp = true
		wep.AfterOnDrop = funcrem
		wep.AfterShootBullet = funcchng
		wep.SpecialGun = true -- let set special flag to mark weapon as safe
		self:EmitSound("items/gift_pickup.wav")
	end
end
if CLIENT then

function ENT:OnRemove()
	self.CSEnt:Remove()
end
function ENT:Draw()
	if self.WeaponName == nil then
		local wep = self:GetWeapon()
		if wep then
			local wpn = weapons.Get(wep)
			if wpn then
				self.WeaponName = wpn.PrintName
			end
		end
	end
	local off = self.zoff
	if off < 10 then
		self.dir = true
	elseif off > 30 then
		self.dir = false
	end
	off = off + (self.dir and 0.025 or -0.025)
	local pos = self:GetPos()
	pos.z = pos.z + off
	self.zoff = off
	self.Angle.y = math.NormalizeAngle(self.Angle.y + 3)
	self.CSEnt:SetPos(pos)
	self.CSEnt:SetAngles(self.Angle)
	self.CSEnt:DrawModel()
end

end