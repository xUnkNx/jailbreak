local function AddSHLuaFile( file )
	include( file )
	AddCSLuaFile( file )
end
AddSHLuaFile( "shared.lua" )
AddSHLuaFile( "sh_rules.lua" )
AddSHLuaFile( "sh_lang.lua" )
AddSHLuaFile( "sh_maps.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_net.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_legs.lua" )

include( "sv_logic.lua" )
include( "sv_hooks.lua" )
include( "sv_commands.lua" )
include( "sv_util.lua" )
include( "sv_gamemodes.lua" )
AddSHLuaFile( "sh_gamemodes.lua" )

local files = file.Find("gamemodes/jailbreak/gamemode/gui/*.lua","GAME")
for k,v in pairs(files) do
	AddCSLuaFile("gui/"..v)
end

function GM:Dissolve(ent)
	ent:Kill()
	ent = ent:GetRagdollEntity()
	if IsValid(ent) then
		ent:SetName("fizzled" .. ent:EntIndex())
		local dissolver = ents.Create( "env_entity_dissolver" )
		if IsValid(dissolver) then
			dissolver:SetPos(ent:GetPos())
			dissolver:SetOwner(ent)
			dissolver:SetKeyValue("target","fizzled" .. ent:EntIndex())
			dissolver:SetKeyValue("magnitude",100)
			dissolver:SetKeyValue("dissolvetype",0)
			dissolver:Fire( "Dissolve" )
			dissolver:Fire( "kill", "", 1)
		end
	end
end
--weapons/fx/rics/arrow_impact_crossbow_heal.wav

function CTeam(t)
	return {team.GetColor(t),team.GetName(t)}
end
local ServerB, Server = "[SERVER]",  "SERVER"
function CServ(bq)
	return {colour_black, bq and ServerB or Server }
end
function GM:ResetFD() -- TODO: Not a base function
	for _,v in pairs(team.GetPlayers(TEAM_PRISIONER)) do
		if v:GetNWInt("FreeDayTime",0) > 0 then
			v:SetGM("FD",nil)
			v:SetNWInt("FreeDayTime", 0)
			v:SetPlayerColor(v:GetGM("DefaultColor"))
			v.NextFD = 200
			LocalMsg(v,colour_notify, GAMEMODE:Phrase("NextDayFD"))
		end
	end
end
function GM:PlayerCanHearPlayersVoice( list, talk ) -- TODO: Not a base function
	local tm,tm1,al,al1,c = list:Team(),talk:Team()
	if tm1 == TEAM_SPECTATOR or tm == TEAM_SPECTATOR then return true end
	if self:GetRound() ~= Round_In then return true end
	al,al1,c = list:Alive(),talk:Alive(),false
	if al == al1 or (al1 and not al) then
		if talk:IsTeamVoiceEnabled() and tm1 == tm then
			return true, true
		end
		if tm1 == TEAM_PRISIONER and GetGMBool("JB_PrisGag") then
			return false
		end
		if talk:GetNWBool("JB_Gag") then
			return false
		end
		local targetsim = GetGMEntity( "JB_Simon" )
		if tm1 == TEAM_GUARD and GetGMBool("JB_GuardGag") and targetsim ~= talk then
			return false
		end
		return true
	end
	return false
end