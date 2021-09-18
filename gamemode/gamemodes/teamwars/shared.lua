local gm = GM:AddGamemode("TeamWar",{
		Usable = true,
		MinPlayers = 4,
		RoundDelay = 3,
		Name = _C("TeamWars")
	}
)
gm.TeamColors = {
	[1] = {"red", Vector(1, 0, 0), _T("Red")},
	[2] = {"blue", Vector(0, 0, 1), _T("Blue")},
	[3] = {"yellow", Vector(1, 1, 0), _T("Yellow")},
	[4] = {"green", Vector(0, 1, 0), _T("Green")}
}
if SERVER then
	include("init.lua")
end

local TabColors = {}
for k,v in pairs(gm.TeamColors) do
	local str = v[3]
	if type(str) == "table" then
		str = table.concat(str, "")
	end
	TabColors[k] = {str, v[2]:ToColor()}
end
local Prisioners, Dead = _C("Prisioners"), _C("Dead")
local PrisionersC, DeadC = Color(200, 50, 50), Color(100, 100, 100)
GM.HookGamemode("TabSelectCategory",function(tab, ply)
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:Alive() then
		local split = ply:GetNW("SplitTeam", 1)
		if split then
			return TabColors[split][1], split, TabColors[split][2]
		else
			return Prisioners, 5, PrisionersC
		end
	else
		return Dead, 10, DeadC
	end
end)
GM.HookGamemode("HUDPaint",function(w,h)
	if GetGMInt("JB_Round") == Round_In then
		GetDesignPart("GameStatus")(_C("TeamWars"))
	end
end)