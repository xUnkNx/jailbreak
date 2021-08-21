GM:InitGamemode(function(self, params)
	self:ResetFD()
	self:TimerRemove("JB_Simon")
	if not self.Opened then
		self:JBRun("opencells", NULL, true)
	end
	SetGMFloat("JB_FDTime", math.min(self:GetRoundTime(), CurTime() + 3 * self.Daytime))
	GlobalMsg(_T("FD_Begin", colour_message))
end)