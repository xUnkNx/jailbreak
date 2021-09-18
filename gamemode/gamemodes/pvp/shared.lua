GM:AddGamemode(
	"PvP",
	{
		Usable = false
	}
)
if SERVER then
	include("init.lua")
end
local Players, Dead = _C("Players"), _C("Dead")
local PlayersC, DeadC = Color(50,200,50), Color(100,200,100)
GM.HookGamemode("TabSelectCategory",function(tab, ply)
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:Alive() then
		return Players, 5, PlayersC
	else
		return Dead, 10, DeadC
	end
end)