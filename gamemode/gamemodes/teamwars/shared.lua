GM:AddGamemode("TeamWar",{
		Usable = true,
		MinPlayers = 4,
		RoundDelay = 3
	}
)
if SERVER then
	include("init.lua")
end