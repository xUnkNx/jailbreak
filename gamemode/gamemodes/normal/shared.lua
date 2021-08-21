local gm = GM:AddGamemode(
	"Normal",
	{
		Usable = false,
		AdditionalRespawnTime = 15,
		ShouldGag = true,
		UngagTime = 30
	}
)
if SERVER then
	include("init.lua")
end
--[[gm.Spawnable = {}
local function PropSpawned(self)
	self.Entity:SetModel(self.Model)
	constraint.Keepupright(self.Entity, Angle(), 0, 999999 )
end
function AddSpawnableProp(prop)
	local p = {
		type = "prop_physics",
		model = "models/props_borealis/bluebarrel001.mdl",
		func = PropSpawned
	}
	table.insert(gm.Spawnable, p)
	return p
end
function AddSpawnableEntity(ent)
	local e = {
		type = ent,
		func = EntitySpawned
	}
	table.insert(gm.Spawnable, e)
	return e
end]]