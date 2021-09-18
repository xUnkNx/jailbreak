module("unet",package.seeall)
local Clamp, Round = math.Clamp, math.Round
function WriteFloat(float)
	if current.Min then
		local data = Clamp(float, current.Min, current.Max)
		if current.partial then
			net.WriteUInt(Round(data - current.Min) / current.cel, current.pow)
			return
		end
	end
	net.WriteFloat(data)
end
function WriteBool(bool)
	net.WriteBit(tobool(bool) and 1 or 0)
end
function WriteInt(integer)
	local func, data = net.WriteInt, Round(Clamp(integer, current.Min, current.Max))
	if current.unsigned then
		func = net.WriteUInt
	end
	if current.bit then
		func(data - current.Min, current.bit)
	else
		func(data, 8)
	end
end
local function NetworkVar()
end
function DefineDT()
end
function SetGlobalVariable(variable, value)
end