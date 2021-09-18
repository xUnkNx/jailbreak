local types = {"Angle","Bool","Entity","Number","String","Vector"}
function net.ReadNumber()
	local b = net.ReadBool()
	if b then
		return net.ReadFloat()
	end
	return net.ReadInt(16)
end
EVars = EVars or {}
hook.Add("EntityRemoved","CLR_EVARS", function(e)
	EVars[e:EntIndex()] = nil
end)
net.Receive("GlobalChannel",function(len)
	local cn = net.ReadUInt(2)
	local ent = net.ReadUInt(16)
	if cn == 0 then
		local nm = net.ReadString()
		local value = net.ReadType()
		if ent == 0 then
			if hook.Run("GlobalVarChanged", nm, GMGlobals[nm], value) then
				return
			end
			GMGlobals[nm] = value
		else
			if hook.Run("EntityVarChanged", ent, nm, EVars[ent] and EVars[ent][nm], value) then
				return
			end
			if EVars[ent] == nil then
				EVars[ent] = {[nm] = value}
			else
				EVars[ent][nm] = value
			end
		end
	elseif cn == 1 then
		local tb = net.ReadTable()
		for k,v in pairs(tb) do
			if hook.Run("GlobalVarChanged", k, GMGlobals[k], v) then
				continue
			end
			GMGlobals[k] = v
		end
	elseif cn == 2 then
		ClearGlobals()
		EVars = {}
	end
end)
local mt = FindMetaTable("Entity")
function mt:GetNW(var,def)
	local eid = self:EntIndex()
	return EVars[eid] and EVars[eid][var] or def
end
function mt:SetNW(var,val)
	local eid = self:EntIndex()
	if EVars[eid] == nil then
		Evars[eid] = {[var] = val}
	else
		EVars[eid][var] = val
	end
end
function SetGlobal(nm,var)
	GMGlobals[nm] = var
end
for k,v in pairs(types) do
	_G["GetGM" .. v] = function(s,d)
		return GMGlobals[s] or d
	end
	_G["SetGM" .. v] = function(s,v)
		GMGlobals[s] = v
	end
end
_G.GetGMInt,_G.GetGMFloat,_G.SetGMInt,_G.SetGMFloat = _G.GetGMNumber,_G.GetGMNumber,_G.SetGMNumber,_G.SetGMNumber
net.Receive("CMDNET",function(len)
	local arg = net.ReadUInt(4)
	if arg == 1 then
		local wp = net.ReadString()
		input.SelectWeapon(wp)
	end
end)
local STRTSND = {["warn"] = Sound("buttons/button2.wav"),
["info"] = {"ambient/water/drip1.wav","ambient/water/drip2.wav","ambient/water/drip3.wav","ambient/water/drip4.wav"}}
local function readarg(args,mn)
	if mn == 0 then
		return false
	end
	if mn == 1 then
		local id = net.ReadUInt(8)
		table.insert(args,id)
	elseif mn == 2 then
		local id = net.ReadUInt(8)
		if GAMEMODE.Colors[id] then
			table.insert(args,GAMEMODE.Colors[id])
		end
	elseif mn == 3 then
		table.insert(args,Color(net.ReadUInt(8),net.ReadUInt(8),net.ReadUInt(8)))
	elseif mn == 4 then
		local phrase = {}
		for i = 1,50 do
			if not readarg(phrase,net.ReadUInt(3)) then
				break
			end
		end
		local k,v = next(phrase)
		if type(v) ~= "string" then
			for k,v in pairs(phrase) do
				if type(v) == "string" then
					table.insert(args, _T(v))
				else
					table.insert(args,v)
				end
			end
		else
			local phr = _T(unpack(phrase))
			if type(phr) == "string" then
				table.insert(args,phr)
			elseif type(phr) == "table" then
				table.Add(args,phr)
			end
		end
	elseif mn == 5 then
		local str = net.ReadString()
		if string.sub(str,1,4) == "SND:" then
			str = string.sub(str,5)
			if type(STRTSND[str]) == "table" then
				surface.PlaySound(gm:TableRandom(STRTSND[str]))
			elseif type(STRTSND[str]) == "string" then
				surface.PlaySound(STRTSND[str])
			end
			return true
		end
		table.insert(args,str)
	elseif mn == 6 then
		local bool = net.ReadBool()
		table.insert(args,bool)
	end
	return true
end
net.Receive("TextChannel",function(len)
	local args,tp = {},net.ReadUInt(2)
	for i = 1,50 do
		if not readarg(args,net.ReadUInt(3)) then
			break
		end
	end
	if tp == 0 then
		chat.AddText(unpack(args))
	elseif tp == 1 then
		DrawMessage(unpack(args))
	elseif tp == 2 then
		table.insert(args, "\n")
		MsgC(color_white, unpack(args))
	end
end)
net.Receive("SoundChannel",function(len)
	local t = net.ReadUInt(3)
	local s = net.ReadString()
	if t == 0 then
		local world = game.GetWorld()
		if g_SurfaceSound ~= nil then
			g_SurfaceSound:Stop()
		end
		g_SurfaceSound = CreateSound(world,s)
		if g_SurfaceSound then
			g_SurfaceSound:SetSoundLevel( 0 )
			g_SurfaceSound:Play()
		end
	end
end)