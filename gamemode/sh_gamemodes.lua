GM.SpecDays = {}
local curspec,gm = '', GM or GAMEMODE
function GM:AddGamemode(name, params, base)
	curspec = name
	if base and gm.SpecDays[base] then
		gm.SpecDays[name] = table.Copy(gm.SpecDays[base])
		if params then
			table.Merge(gm.SpecDays[name][2], params)
		end
	else
		if gm.SpecDays[name] then
			if params then
				table.Merge(gm.SpecDays[name][2], params)
			end
		else
			gm.SpecDays[name] = {
				nil,
				params
			}
		end
	end
	return gm.SpecDays[name][2]
end
function GM:InitGamemode(initfunc)
	gm.SpecDays[curspec][1] = initfunc
	return gm.SpecDays[curspec][2]
end
function GM.HookGamemode(name,func)
	gm.SpecDays[curspec][2][name] = func
end
function GM:GetSpecGM()
	local tb = self.SpecDays[GetGMString("JB_GM")]
	if tb ~= nil then
		return tb[2]
	end
end
GM.ActiveHooks = GM.ActiveHooks or {}
function GM:SetGamemode(name,refresh)
	local spec = self.SpecDays[name]
	if spec then
		if SERVER then
			SetGMString("JB_GM",name)
		end
		for hk,fn in pairs(self.ActiveHooks) do
			hook.Remove(hk,"JBGM")
		end
		for hk,fn in pairs(spec[2]) do
			self.ActiveHooks[hk] = fn
			hook.Add(hk,"JBGM",fn)
		end
		if not refresh and spec[1] then
			spec[1](self,spec[2])
		end
	end
end
if CLIENT then
	hook.Add("GlobalVarChanged","SetGamemode",function(var, old, new)
		if var == "JB_GM" then
			GAMEMODE:SetGamemode(new)
		end
	end)
end
function GM:LoadGamemode(name)
	local path = "gamemodes/" .. name .. "/shared.lua"
	include(path)
	AddCSLuaFile(path)
end

GM:LoadGamemode("normal")
GM:LoadGamemode("pvp")
GM:LoadGamemode("freeday")
GM:LoadGamemode("hidenseek")
GM:LoadGamemode("teamwars")
GM:LoadGamemode("zombiefd")
GM:LoadGamemode("defense")

GM:SetGamemode(GetGMString("JB_GM",""),true)