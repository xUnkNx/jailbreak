function GM:RoundStatus(st)
	SetGMInt("JB_RoundStatus",st)
end
function GM:StartRound()
	hook.Run("OnRoundStarting")
	ClearGlobals()
	self:ResetTimers()
	self:SetRoundTime(CurTime() + self.Days * self.Daytime + 3)
	self.Opened = false
	game.CleanUpMap()
	self.CurrentRound = self.CurrentRound + 1
	game.SetTimeScale(1)
	self.RoundsLeft = self.RoundsLeft - 1
	self:SetGamemode("Normal")
	hook.Run("OnRoundStart")
end
GM.Timers = GM.Timers or {}
function GM:TimerThink(ct)
	for i,v in pairs(self.Timers) do
		if v[1] < ct then
			self:TimerExecute(i)
		end
	end
end
function GM:Timer(name,time,rep,func,...)
	self.Timers[name] = {CurTime() + time,time,rep == 0 and -1 or rep,func,{...}}
end
function GM:TimerSimple(time,func,...)
	local di = tostring(func)
	self:Timer("simple_" .. di,time,1,func,...)
end
function GM:TimerExists(name)
	if self.Timers[name] then
		return true
	end
	return false
end
function GM:ResetTimers()
	self.Timers = {}
end
function GM:TimerRemove(nm)
	self.Timers[nm] = nil
end
function GM:TimerExecute(i)
	local v = self.Timers[i]
	if v then
		if v[3] > 1 then
			v[3] = v[3] - 1
			v[1] = CurTime() + v[2]
		elseif v[3] == -1 then
			v[1] = CurTime() + v[2]
		else
			self.Timers[i] = nil
		end
		v[4](v[5] and unpack(v[5]))
	end
end
function GM:Tick()
	local ct = CurTime()
	self:RoundThink(ct)
	self:TimerThink(ct)
	--[[for k,v in pairs(self.PosBack) do
		self.PosBack[k] = nil
		k = v[1]
		if IsValid(k) then
			if v[2] then
				k:SetPos(v[2])
				k:SetAngles(v[3])
			end
			k:SetCollisionGroup(v[4])
			k:SetMoveType(v[5])
		end
	end]]
end
function GM:RoundThink(ct)
	if self.PrepareTime >= ct then
		return
	end
	if self:GetRound() == Round_Null then
		self:SetRound(Round_Wait)
		self:SetRoundTime(0)
		self:SetGamemode("PvP")
	end
	if self:GetRound() == Round_Wait then
		--self:SetRound( Round_Start )
	elseif self:GetRound() == Round_Start then
		if self:GetRoundTime() <= ct then
			self:StartRound()
			self:TimerSimple(3, function()
				self:SetRound( Round_In )
			end)
		end
	elseif self:GetRound() == Round_In then
		if self:GetRoundTime() <= CurTime() then
			if not hook.Run("OnTimeout",self:GetSpecGM()) then
				self:SetRound( Round_End, round_timeout)
			end
		else
			if self:GetDayTime() <= ct and self:GetDay() + 1 <= self.Days then
				self:SetDay(self:GetDay() + 1)
				self:SetDayTime(ct + self.Daytime)
			end
			hook.Run("RoundTick",ct)
		end
	elseif self:GetRound() == Round_End then
		if self:GetRoundTime() <= ct then
			self:SetRound( Round_Start )
		end
	else
		if self:GetRound() ~= Round_Null then
			self:SetRound( Round_Null )
		end
	end
end
function GM:GetRoundTime()
	return GetGMInt("JB_Time") or CurTime()
end
function GM:SetRoundTime( secs )
	SetGMInt("JB_Time", secs)
end
function GM:SetRound(round, reason, data)
	SetGMInt("JB_Round", round)
	if round == Round_End then
		self:SetRoundTime(CurTime() + math.random(5,15))
		SetGMBool("JB_Box", true)
		if reason == nil then
			reason = round_none
		end
		self:RoundStatus(reason)
		hook.Call("OnRoundEnd",self,reason,data)
		local randomg = math.Rand(0.1,0.5)
		game.SetTimeScale(randomg + 0.5)
		self:Timer("GAMEMODERESERVE0", 10 * randomg, 1, function()
			game.SetTimeScale(1)
		end)
	end
end
function GM:GetRound()
	return GetGMInt("JB_Round") or Round_Null
end
function GM:GetDay()
	return GetGMInt("JB_Day") or 0
end
function GM:SetDay(day)
	SetGMInt("JB_Day", day)
end
function GM:GetDayTime()
	return GetGMInt("JB_DayTime") or CurTime()
end
function GM:SetDayTime(time)
	SetGMInt("JB_DayTime",time)
end
function GM:GetRoundsLeft()
	return self.RoundsLeft
end