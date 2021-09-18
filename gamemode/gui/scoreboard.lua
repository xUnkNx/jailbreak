function GM:ScoreboardShow()
	GetDesignPart("ScoreboardShow")()
end
function GM:ScoreboardHide()
	GetDesignPart("ScoreboardHide")()
end
local Spectators, Unknown = _C("Spectators"), _C("Unknown")
function GM:TabSelectCategory(panel, ply)
	if ply:Team() == TEAM_SPECTATOR then
		return Spectators, 50
	else
		return Unknown, 100
	end
end