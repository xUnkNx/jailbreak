GM:AddGamemode(
	"Hide&Seek",
	{
		Usable = true,
		MinPlayers = 5,
		RoundDelay = 3,
		Name = _C("HideNSeek")
	}
)
if SERVER then
	include("init.lua")
end

local Hiding, Seekers, Dead = _C("Hiding"), _C("Seekers"), _C("Dead")
local HidingC, SeekersC, DeadC = Color(50,50,200), Color(200,50,50), Color(100,200,100)
GM.HookGamemode("TabSelectCategory",function(tab, ply)
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:Alive() then
		if ply:Team() == TEAM_ATTACKER then
			return Seekers, -10, SeekersC
		elseif ply:Team() == TEAM_DEFENDER then
			return Hiding, -5, HidingC
		end
	else
		return Dead, 10, DeadC
	end
end)
GM.HookGamemode("HUDPaint",function(w,h)
	if GetGMInt("JB_Round") == Round_In then
		GetDesignPart("GameStatus")(_C("HideNSeek"))
	end
end)