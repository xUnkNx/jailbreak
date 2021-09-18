GM:InitGamemode(function(self, params)
	self:ResetFD()
	if not self.Opened then
		self:JBRun("opencells", NULL, true)
	end
	SetGMFloat("JB_FDTime", math.min(self:GetRoundTime(),
		CurTime() + math.ceil(#team.GetAlive(TEAM_PRISIONER) / 7) * self.DayTime ) )
	GlobalMsg(_T("FD_Begin", colour_message))
end)