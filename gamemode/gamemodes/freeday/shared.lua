GM:AddGamemode(
	"FreeDay", {
		Usable = true,
		MinPlayers = 5,
		RoundDelay = 3
	},
	"Normal"
)
if SERVER then
	include("init.lua")
end