GM:AddGamemode(
	"Defense",{
		Usable = true,
		MinPlayers = 5,
		RoundDelay = 3,
		Name = _C("Defense")
	},
	"Normal"
)
if SERVER then
	include("init.lua")
end

local Defenders, Attackers, Dead = _C("Defenders"), _C("Attackers"), _C("Dead")
local DefendersC, AttackersC, DeadC = Color(50,50,200), Color(200,50,50), Color(100,200,100)
GM.HookGamemode("TabSelectCategory",function(tab, ply)
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:Alive() then
		if ply:Team() == TEAM_GUARD then
			return Defenders, -10, DefendersC
		elseif ply:Team() == TEAM_PRISIONER then
			return Attackers, -5, AttackersC
		end
	else
		return Dead, 10, DeadC
	end
end)
GM.HookGamemode("HUDPaint",function(w,h)
	if GetGMInt("JB_Round") == Round_In then
		GetDesignPart("GameStatus")(_C("Defense"))
	end
end)