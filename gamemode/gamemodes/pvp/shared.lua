GM:AddGamemode(
	"PvP",
	{
		Usable = false
	}
)
if SERVER then
	include("init.lua")
end