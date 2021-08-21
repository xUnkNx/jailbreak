GM:AddGamemode(
	"Hide&Seek",
	{
		Usable = true,
		MinPlayers = 5,
		RoundDelay = 3
	}
)
if SERVER then
	include("init.lua")
end