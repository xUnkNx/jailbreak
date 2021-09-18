GM:AddGamemode(
	"FreeDay", {
		Usable = true,
		MinPlayers = 5,
		RoundDelay = 3,
		Name = _C("Freeday")
	},
	"Normal"
)
if SERVER then
	include("init.lua")
end