GM.HookGamemode("HUDPaint",function()
	local ct = CurTime()
	local whoreal = LP:Alive() and LP or LP:GetObserverTarget()
	if IsValid(whoreal) and whoreal:IsPlayer() then
		if whoreal:Team() == TEAM_PRISIONER then
			local plyfd = whoreal:GetNW( "FreeDayTime", 0 )
			if plyfd > 0 then
				GetDesignPart("FreeDayTimer")(plyfd - ct)
			end
			local rebel = whoreal:GetNW("ActiveRebel",0)
			if rebel > 0 then
				surface.SetFont( "JBHUDFONT" )
				surface.SetTextPos( ScreenScale(10), ScrH() - ScreenScale(80) )
				surface.SetTextColor(255,255,255,200)
				surface.DrawText( _T("RebelTimer", MakeTime(math.Round(rebel - ct))) )
			end
		end
		local afk = whoreal:GetNW("AutoSlay",0)
		if afk > 0 then
			surface.SetFont( "JBHUDFONT" )
			surface.SetTextPos( ScreenScale(10), ScrH() - ScreenScale(80) )
			surface.SetTextColor(255,255,255,200)
			surface.DrawText( _T("AutoSlayTimer", MakeTime(math.Round(afk - ct))) )
		end
	end
	if GetGMInt("JB_Round") == Round_In then
		local simon, msg = GetGMEntity( "JB_Simon" ), _C("SimonNot")
		if simon and IsValid(simon) and simon:IsPlayer() then
			msg = _C("SimonIs", simon:Nick())
		end
		local gmtype = GetGMString( "JB_GM", false)
		if gmtype == "FreeDay" then
			local fdtime = GetGMInt( "JB_FDTime", 0)
			if fdtime > CurTime() then
				msg = _C("GlobalFreeday", MakeTime(math.Round(fdtime-CurTime())))
			end
		end
		GetDesignPart("GameStatus")(msg)
	end
end)
local Simon, Guards, Prisioners, GuardsDead, PrisionersDead = _C("Simon"), _C("Guards"), _C("Prisioners"), _C("GuardsDead"), _C("PrisionersDead")
local SimonC, GuardsC, PrisionersC, GuardsDeadC, PrisionerDeadC = Color(50,50,200), Color(100,100,200), Color(200,50,50), Color(150,150,255), Color(200,100,100)
GM.HookGamemode("TabSelectCategory",function(tab, ply)
	if ply:Alive() then
		local tm = ply:Team()
		if tm == TEAM_GUARD then
			if GetGMEntity("JB_Simon") == ply then
				return Simon, -15, SimonC
			else
				return Guards, -10, GuardsC
			end
		elseif tm == TEAM_PRISIONER then
			return Prisioners, -5, PrisionersC
		end
	else
		local t = ply:Team()
		if t == TEAM_GUARD then
			return GuardsDead, 5, GuardsDeadC
		elseif t == TEAM_PRISIONER then
			return PrisionersDead, 10, PrisionerDeadC
		end
	end
end)