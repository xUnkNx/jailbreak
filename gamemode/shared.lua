GM.Name = "Jail Break"
GM.Author = "UnkN"
GM.Email = "helecopr2@mail.ru"
DeriveGamemode( "base" )

GM.Days			= 5		-- Days count
GM.DayTime		= 120	-- Seconds in day
GM.StartPrepare	= 30	-- Time after PvP to start normal round
GM.RoundPrepare	= 3		-- Time before round starts (round beginning)
GM.FDColors		= {
	Vector(1,0.84,0),
	Vector(0,0.49,1),
	Vector(1,0.65,0),
	Vector(0.03,0.15,0.4),
	Vector(1,0.9,0.7)
}
GM.TCT			= 2.5	-- ratio of T to CT. I.E. 1 CT = 2.5 T
GM.RoundsLeft	= 20	-- Rounds before map change
GM.CurrentRound	= 0		-- Current round relative to game start

TEAM_PRISIONER = 2
TEAM_GUARD = 3
TEAM_ATTACKER = 1 -- 1-4 used to SetNoCollideWithTeammates
TEAM_DEFENDER = 4
TEAM_SPECTATOR = 5

Round_Null = 0
Round_Wait = 1
Round_Start = 2
Round_In = 3
Round_End = 4

Point_Here = 0
Point_Follow = 1
Point_Line = 2
Point_Guard = 3
Point_Avoid = 4

GM.Colors = {}
local _sharedColor = {
	__tostring = function()
		return "sharedColor"
	end,
	GetColor = function(self)
		return self
	end
}
function IsSharedColor( obj )
	return getmetatable(obj) == _sharedColor
end
function GM:AddSharedColor(id, Color, global)
	local clr = setmetatable(Color, _sharedColor)
	clr.id = id
	local gm = GAMEMODE or self -- why after reload GAMEMODE != self if them both in initialize func?
	gm.Colors[id] = clr
	if global then
		_G[global] = clr
	end
end
GM:AddSharedColor(1,Color(0,0,0),"colour_black")
GM:AddSharedColor(2,Color(255,0,0),"colour_warn")
GM:AddSharedColor(3,Color(0,200,200),"colour_weapon")
GM:AddSharedColor(4,Color(255,255,255),"colour_notify")
GM:AddSharedColor(5,Color(255,255,0),"colour_message")
GM:AddSharedColor(6,Color(0,255,0),"colour_info")

round_none = 0
round_prepare = 1
round_begin = 2
round_alldead = 3
round_wint = 4
round_winct = 5
round_timeout = 6

round_winzombie = 10
round_winhuman = 11
round_winhider = 12
round_winseeker = 13
round_winassault = 14
round_winguards = 15
round_battleend = 16

GMGlobals = GMGlobals or {}
local Globals = GMGlobals
ReservedGlobals = {}
local keep_kw = "_keep_"
function ReserveGlobal(nm, default)
	ReservedGlobals[nm] = default or keep_kw
end
function ClearGlobals()
	for k,v in pairs(Globals) do
		local res = ReservedGlobals[k]
		if res ~= nil then
			if res ~= keep_kw then
				Globals[k] = res
			end
		else
			Globals[k] = nil
		end
	end
	if SERVER then
		net.Start("GlobalChannel")
			net.WriteUInt(2,2)
		net.Broadcast()
	end
end
--ReserveGlobal("JB_Day")
ReserveGlobal("JB_Round")
--ReserveGlobal("JB_DayTime")
ReserveGlobal("JB_Time")
ReserveGlobal("JB_GM")

if SERVER then
	function AddSHLuaFile( file )
		include( file )
		AddCSLuaFile( file )
	end
	AddCLLuaFile = AddCSLuaFile
else
	AddSHLuaFile = include
	AddCLLuaFile = include
end
function AddDir(dir,func)
	local files, folds = file.Find("jailbreak/gamemode/" .. dir .. "*","LUA")
	for k,v in pairs(files) do
		if string.GetExtensionFromFilename( v ) == "lua" then
			func(dir .. v)
		end
	end
	for k,v in pairs(folds) do
		AddDir(dir .. v .. "/", func)
	end
end
AddDir("gui/",AddCLLuaFile)

function team.GetAlive(t)
	local out,pos = {},1
	for _,p in pairs(player.GetAll()) do
		if p:Team() == t and p:Alive() then
			out[pos] = p
			pos = pos + 1
		end
	end
	return out
end
function team.GetCount(t)
	local i = 0
	for _,p in pairs(player.GetAll()) do
		if p:Team() == t and p:Alive() then
			i = i + 1
		end
	end
	return i
end
-- table.Random returns 2 values instead of 1. Its better than calling select & create local variable to handle.
function GM:TableRandom(tab)
	return tab[math.random(1,#tab)]
end
function GM:CreateTeams()
	team.SetUp( TEAM_PRISIONER, "T", Color( 255, 0, 0 ) )
	team.SetUp( TEAM_GUARD, "CT", Color( 0, 0, 255 ) )
	team.SetUp( TEAM_SPECTATOR, _C("Spectators"), Color( 128, 128, 128 ) )
	team.SetUp( TEAM_ATTACKER, _C("Attackers"), Color( 255, 0, 0 ) )
	team.SetUp( TEAM_DEFENDER, _C("Defenders"), Color( 0, 255, 0 ) )
end
function GM:PlayerFootstep( ply, pos, foot, sound, volume, filter )
	if not ply:Alive() then
		return true
	end
	if ply:KeyDown(IN_WALK) and not ply:KeyDown(IN_SPEED) then
		return true
	end
	return false
end
function GM:EntityEmitSound(t)
	local p = t.Pitch
	if game.GetTimeScale() ~= 1 then p = p * game.GetTimeScale() end
	if p ~= t.Pitch then t.Pitch = math.Clamp( p, 0, 255 ) return true end
	if CLIENT and engine.GetDemoPlaybackTimeScale() ~= 1 then
		t.Pitch = math.Clamp( t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255 )
		return true
	end
end
function GM:Move(pl, move)
	if pl:Team() ~= TEAM_SPECTATOR then
		if move:GetForwardSpeed() < 0 then
			move:SetMaxSpeed(move:GetMaxSpeed() * 0.65)
			move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.65)
		elseif move:GetForwardSpeed() == 0 then
			move:SetMaxSpeed(move:GetMaxSpeed() * 0.85)
			move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.85)
		end
	end
end
function InvertValues(t)
	local out = {}
	for _,v in pairs(t) do
		out[v] = true
	end
	return out
end
GM.NoDropable = InvertValues({"weapon_fist","weapon_zombiefist","weapon_physgun","weapon_medkit"--[[,"weapon_hegrenade","weapon_molotov","weapon_flashbang","weapon_smokegrenade"]]})
GM.WeaponGrenades = {"weapon_molotov","weapon_hegrenade","weapon_smokegrenade","weapon_flashbang"}
GM.WeaponPistols = {"weapon_deagle","weapon_elite","weapon_fiveseven","weapon_glock","weapon_p228","weapon_usp"}
GM.WeaponRifles = {"weapon_ak47","weapon_aug","weapon_awp","weapon_famas",
"weapon_g3sg1","weapon_galil","weapon_m3","weapon_m4a1","weapon_m249","weapon_mac10",
"weapon_mp5navy","weapon_p90","weapon_scout","weapon_sg550","weapon_sg552","weapon_tmp",
"weapon_ump45","weapon_xm1014","weapon_m4a1s"}
GM.WeaponSpecial = {"weapon_ultimax","weapon_awpgn","weapon_fapas"}
GM.WeaponMelee = {"weapon_knife"}
GM.WeaponAll = table.Copy(GM.WeaponPistols)
table.Add(GM.WeaponAll,GM.WeaponRifles)
table.Add(GM.WeaponAll,GM.WeaponMelee)
GM.WeaponDuel = InvertValues(GM.WeaponAll)
table.Add(GM.WeaponAll,GM.WeaponSpecial)

GM.GrenadesKV = InvertValues(GM.WeaponGrenades)
GM.AmmoTable = GM.AmmoTable or {}

GM.CTModels = {{"models/player/urban.mdl","models/player/gasmask.mdl","models/player/riot.mdl","models/player/swat.mdl"},{"models/player/police_fem.mdl"}}
GM.TModels = {{},{}}
for i = 1,8 do
	GM.TModels[1][i] = "models/player/group01/male_0" .. i .. ".mdl"
end
for i = 1,6 do
	GM.TModels[2][i] = "models/player/group01/female_0" .. i .. ".mdl"
end
hook.Add("Initialize","InitDualWeapons",function()
	local duel = {"weapon_awp","weapon_scout","weapon_deagle"}
	for i = 1,3 do
		local b = table.Copy(weapons.GetStored(duel[i]))
		b.Primary.ClipSize = 1
		b.IronSight = false
		b.InfiniteClip = true
		b.UseScope = false
		b.AfterPrimaryAttack = function(self)
			self:SetNextPrimaryFire(0)
			self:Reload()
		end
		local nm = string.sub(duel[i],1,7) .. "duel" .. string.sub(duel[i],8)
		weapons.Register(b,nm)
		GAMEMODE.WeaponDuel[nm] = true
	end
	local t
	for i = 1,2 do
		t = i == 1 and GAMEMODE.CTModels or GAMEMODE.TModels
		for k = 1,2 do
			for v = 1, #t[k] do
				util.PrecacheModel(t[k][v])
			end
		end
	end
end)
--==Other==--
local MAX_SPEED = 500
MAX_SPEED = MAX_SPEED * MAX_SPEED
function GM:OnPlayerHitGround( ply, inWater, onFloater, speed )
	ply:ViewPunch( Angle(math.Rand(0.1, 0.3), 0.1, 0) )
	speed = ply:GetVelocity():Length2DSqr()
	if speed > MAX_SPEED then
		local vel = ply:GetVelocity() * (MAX_SPEED-speed) / speed
		vel.z = 0
		ply:SetVelocity(vel)
	end
end
local PlayMeta = FindMetaTable( "Player" )
PlayMeta.OldAlive = PlayMeta.OldAlive or PlayMeta.Alive
function PlayMeta:Alive()
	if self:Team() == TEAM_SPECTATOR then return false end
	return self:OldAlive()
end
function PlayMeta:IsTeamVoiceEnabled()
	return self.TeamVoice or false
end
function PlayMeta:SetTeamVoice( bool )
	self.TeamVoice = bool
end