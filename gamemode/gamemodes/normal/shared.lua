local gm = GM:AddGamemode(
	"Normal",
	{
		Usable = false,
		AdditionalRespawnTime = 15,
		ShouldGag = true,
		UngagTime = 20,
		AutoOpenCells = true,
		AutoOpenTime = 60,
		RandomWeapon = true, -- give random weapon at round start?
		RandomWeaponCounter = 0.125, -- each 8 prisioner will have random weapon
		KillAFK = true, -- should afk players die?
		KillTime = 60, -- time before auto-slay if player is away
		MarkAsPassive = true, -- should prisioners be marked as rebel if they don't near simon and doesn't attack CT (anti camp system)
		CheckTime = 15, -- each X seconds system will check each prisioner to be near simon
		RebelTime = 120, -- time to mark prisioner as rebel, he will be drawn throught walls
		MarkAsActive = true, -- should prisioner be marked as active rebel if he didn't does much damage to CT (anti camp system)
		AdditionalActiveTime = 15, -- prisioner should damage CT every X time, otherwise will be marked as rebel
		MinimumActiveDamage = 25, -- minimal damage that should deal prisioner to prevent marking
		SimonMaxProps = 50, -- maximal count of spawnable props / ents for simon
	}
)
if SERVER then
	include("init.lua")
end
AddCLLuaFile("cl_init.lua")
AddCLLuaFile("cl_hud.lua")
AddCLLuaFile("points.lua")
AddCLLuaFile("simon_menu.lua")
AddCLLuaFile("last_request.lua")
AddCLLuaFile("halo_controller.lua")

local maxspeed = 300 * 300
GM.HookGamemode("OnPlayerHitGround", function(p) -- anti bhop to prevent speed approaching
	if not GetGMBool("JB_Bhop") then
		local cv = p:GetVelocity()
		local speed = cv:Length2DSqr()
		if speed > maxspeed then
			local newSpeed = - ((speed - maxspeed) / speed) * cv
			newSpeed.z = 0
			p:SetVelocity( newSpeed )
		end
	end
end)
ReserveGlobal("JB_Avoidness", true)
gm.Spawnable = {}
local function PropSpawned(self, owner)
	constraint.Keepupright(self, Angle(), 0, 360 )
end
local function EntitySpawned(self, owner)
end
gm.ValidProps = {
	["prop_physics"] = true,
	["func_physbox"] = true,
	["ent_soccerball"] = true,
	["ent_basketball"] = true
}
function AddSpawnableProp(name, prop)
	local p = {
		name = name,
		type = "prop_physics",
		model = prop,
		func = PropSpawned
	}
	table.insert(gm.Spawnable, p)
	return p
end
function AddSpawnableEntity(name, ent)
	local e = {
		name = name,
		type = ent,
		func = EntitySpawned
	}
	table.insert(gm.Spawnable, e)
	return e
end
cleanup.Register("Spawnable")
AddSpawnableProp(_C("E_BlueBarrel"), "models/props_borealis/bluebarrel001.mdl")
AddSpawnableProp(_C("E_WoodCrate"), "models/props_junk/wood_crate001a.mdl")
AddSpawnableProp(_C("E_ExplosiveBarrel"), "models/props_c17/oildrum001_explosive.mdl")
AddSpawnableProp(_C("E_Bathtub"), "models/props_c17/FurnitureBathtub001a.mdl")
AddSpawnableProp(_C("E_Stove"), "models/props_c17/furnitureStove001a.mdl")
AddSpawnableProp(_C("E_Fridge"), "models/props_c17/FurnitureFridge001a.mdl")
AddSpawnableProp(_C("E_Couch"), "models/props_interiors/Furniture_Couch01a.mdl")
AddSpawnableProp(_C("E_Bigcouch"), "models/props_interiors/Furniture_Couch02a.mdl")
AddSpawnableEntity(_C("E_Soccerball"), "ent_soccerball")
AddSpawnableEntity(_C("E_Basketball"), "ent_basketball")