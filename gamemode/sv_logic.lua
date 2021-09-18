function GM:RoundStatus(st)
	SetGMInt("JB_RoundStatus",st)
end
function GM:StartRound()
	hook.Run("OnRoundStarting")
	ClearGlobals()
	self:ResetTimers()
	self:ResetGMode()
	game.SetTimeScale(1)
	if not self:CheckPVPState() then
		game.CleanUpMap()
		self.CurrentRound = self.CurrentRound + 1
		self.RoundsLeft = self.RoundsLeft - 1
		self:SetGamemode("Normal")
		if self:GetRoundTime() <= CurTime() then
			self:SetRoundTime(CurTime() + self.Days * self.DayTime + self.RoundPrepare)
		end
		self:TimerSimple(self.RoundPrepare, function()
			self:SetRound( Round_In )
			SetGMInt("JB_StartedTime", CurTime())
			hook.Run("OnRoundStart")
			self:CheckPlayState()
		end)
	end
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
	self.Timers[name] = {CurTime() + time, time, rep == 0 and -1 or rep, func, {...} }
end
function GM:TimerSimple(time,func,...)
	local di = "simple_" .. tostring(func)
	self:Timer(di,time,1,func,...)
	return di
end
function GM:TimerExists(name)
	if self.Timers[name] then
		return true
	end
	return false
end
function GM:ResetTimers()
	local t = self.Timers
	for k, v in next, t do
		t[k] = nil
	end
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
		pcall(v[4],unpack(v[5]))
	end
end
function GM:TimerAdjust(name,time,rep,func,...)
	local tmr = self.Timers[name]
	if tmr then
		if time then
			if time > 0 then
				tmr[1] = tmr[1] - tmr[2] + time
				tmr[2] = time
			else
				tmr[1] = tmr[1] - time
				tmr[2] = tmr[2] - time
			end
		end
		if rep then
			if rep > 0 then
				tmr[3] = tmr[2] + rep
			else
				tmr[3] = -1
			end
		end
		if func then
			tmr[4] = func
		end
		local varg = {...}
		if #varg > 0 then
			tmr[5] = varg
		end
	end
end
function GM:TimerLeft(nm)
	return self.Timers[nm] and self.Timers[nm][1] or 0
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
function GM:EnablePVP()
	if self:GetRound() ~= Round_Wait then
		self.PrepareTime = CurTime() + self.StartPrepare
		self:SetRound(Round_Wait)
		self:SetRoundTime(0)
		self:SetGamemode("PvP")
		self:ResetTimers()
	end
end
function GM:CheckPVPState()
	local g, p = false, false
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_GUARD then
			g = true
			if p then
				break
			end
		elseif v:Team() == TEAM_PRISIONER then
			p = true
			if g then
				break
			end
		end
	end
	if g and p then
		if self:GetRound() == Round_Wait then
			self:SetRound( Round_Start )
			self.PrepareTime = CurTime() + self.StartPrepare / 2
		end
		return false
	end
	self:EnablePVP()
	return true
end
function GM:CheckPlayState()
	local rnd = self:GetRound()
	if rnd == Round_Wait then
		self:CheckPVPState()
	elseif rnd == Round_In then
		hook.Run("CountPlayers")
	end
end
function GM:RoundThink(ct)
	if self.PrepareTime >= ct then
		return
	end
	local round = self:GetRound()
	--[[if round == Round_Wait then
		--self:SetRound( Round_Start )
	else]]if round == Round_Start then
		if self:GetRoundTime() <= ct then
			self:StartRound()
		end
	elseif round == Round_In then
		if self:GetRoundTime() <= CurTime() then
			if not hook.Run("OnTimeout",self:GetSpecGM()) then
				self:SetRound( Round_End, round_timeout)
			end
		else
			--[[if self:GetDayTime() <= ct and self:GetDay() + 1 <= self.Days then
				self:SetDay(self:GetDay() + 1)
				self:SetDayTime(ct + self.DayTime)
			end]]
			hook.Run("RoundTick",ct)
		end
	elseif round == Round_End then
		if self:GetRoundTime() <= ct then
			self:SetRound( Round_Start )
		end
	end
end
function GM:GetRoundTime()
	return GetGMInt("JB_Time", CurTime())
end
function GM:GetRoundStartTime()
	return GetGMInt("JB_StartedTime", CurTime())
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
		hook.Call("OnRoundEnd",self, reason, data)
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
--[[function GM:GetDay()
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
end]]
function GM:GetRoundsLeft()
	return self.RoundsLeft
end

function InsertionSort(arr)
	local i, icnt = 1, #arr
	while i <= icnt do
		local j = i
		while j > 1 and arr[j - 1] < arr[j] do
			local tmp = arr[j]
			arr[j] = arr[j - 1]
			arr[j - 1] = tmp
			j = j - 1
		end
		i = i + 1
	end
	return arr
end
--[[local tab = {[1]=123,[2]=456,[3]=10,[4]=2,[5]=245}
local t = SysTime()
for i = 1, 10000 do
	table.sort(table.Copy(tab))
end
print("lua C sort",SysTime() - t)
t = SysTime()
for i = 1, 10000 do
	InsertionSort(table.Copy(tab))
end
print("Insertion lua sort", SysTime() - t)
lua C sort	0.017887100000735
Insertion lua sort	0.015089300000909
lua C sort	0.026216199999908
Insertion lua sort	0.013947100000223
lua C sort	0.24717520000013
Insertion lua sort	0.15494910000052
]]