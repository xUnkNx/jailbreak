function CNick(pl)
	return IsValid(pl) and pl:CNick() or CServ()
end
local E = {
	player = 1, entity = 2,int = 3,bool = 4,string = 5,playerornull = 6,angle = 7,vector = 8,null = 9,color = 10,float = 11}
GM.TypeEnum = E
GM.TypeCheck = {[E.player] = function(p) return isentity(p) and p:IsPlayer() end,
[E.playerornull] = function(p) return IsValid(p) and p:IsPlayer() or p == NULL end,
[E.entity] = function(e) return isentity(e) and not e:IsPlayer() and not e:IsNPC() end,
[E.null] = function(e) return e == NULL end,[E.int] = tonumber,[E.float] = tonumber,
[E.bool] = isbool,[E.string] = isstring,[E.angle] = isangle,[E.vector] = isvector,[E.color] = IsColor}
local function ToCAV(v)
	if not isstring(v) then
		return false, _T("RequireNumbers")
	end
	local st = string.Split(v," ")
	if #st ~= 3 then
		return false, _T("NotEnoughtNumbers")
	end
	local vec = {}
	for i = 1,3 do
		local n = tonumber(st[i])
		if not n then
			return false, _T("StringNumbers")
		end
		vec[i] = n
	end
	return true,vec
end
GM.TypeConv = {[E.player] = function(str)
	local id = tonumber(str)
	if id then
		local ent,status = GAMEMODE.TypeConv[E.entity](str)
		if not ent then
			return false,status
		end
		if not status:IsPlayer() then
			return false, _T("EntityNotFound")
		end
		return true,status
	end
	str = string.lower(str)
	local part,tab = string.Split(str,' '),player.GetAll()
	for i = 1,#part do
		if #tab == 0 then
			return false, _T("PlayerNotFound")
		end
		local nt = {}
		for k,v in pairs(tab) do
			if v:Nick():lower():find(part[i]) then
				nt[k] = v
			end
		end
		if #tab ~= #nt then
			break
		end
		tab = nt
	end
	local k,v = next(tab)
	if k == nil then
		return false, _T("PlayerNotFound")
	end
	if k and next(tab,k) == nil then
		return true,v
	else
		return false, _T("FoundMultiplyPl")
	end
end,
[E.int] = function(i)
	i = tonumber(i)
	if not i then
		return false, _T("NotNumber")
	end
	return true,math.Round(i)
end,
[E.float] = function(i)
	i = tonumber(i)
	if not i then
		return false, _T("NotNumber")
	end
	return true,i
end,
[E.bool] = function(b)
	return true,tobool(b)
end,
[E.entity] = function(e)
	e = tonumber(e)
	if not e then
		return false, _T("EntIndexNotify")
	end
	e = Entity(e)
	if IsValid(e) then
		return true, e
	else
		return false, _T("EntityNotFound")
	end
end,
[E.string] = function(s)
	if not s then
		return false, _T("NotString")
	end
	return true,tostring(s)
end,
[E.null] = function(e)
	return false
end,
[E.vector] = function(v)
	local b,vec = ToCAV(v)
	if not b then
		return false,vec
	end
	return true,Vector(vec[1],vec[2],vec[3])
end,
[E.angle] = function(v)
	local b,ang = ToCAV(v)
	if not b then
		return false,ang
	end
	return true,Angle(ang[1],ang[2],ang[3])
end,
[E.color] = function(v)
	local b,col = ToCAV(v)
	if not b then
		return false,col
	end
	return true,Color(col[1],col[2],col[3])
end
}
GM.TypeConv[E.playerornull] = function(p)
	return p == NULL or GAMEMODE.TypeConv[E.player]
end
GM.Actions = {}
function GM:JBCommand(name,team,types,func)
	self.Actions[name] = {team,types,func}
end
function GM:JBRun(name,...)
	if not name then return false end
	local a = self.Actions[name]
	if a[3] then
		local t,arg = a[2],{...}
		for i = 1,#t do
			local b = self.TypeCheck[t[i]](arg[i])
			if not b then
				return false, _T("ArgumentException", i, _T("WrongType"))
			end
		end
		local --[[ok,]]var,why = a[3](...) -- pcall
		--if ok then
			if not var then
				return false, why
			end
			return true
		--[[else
			ErrorNoHalt("JBRun(" .. name .. ") failed. Error: " .. var .. ".\n")
			return false, _T("CMDError")
		end]]
	end
	return false
end
local function CommandLogic(ply,args)
	local t,a = args[1]
	if t then
		a = GAMEMODE.Actions[t]
		if not a then
			return true, _T("NoCommand")
		end
		local f = a[2]
		if IsValid(ply) then
			if not a[1] then
				return false, _T("ArgumentException", 1, _T("ConsoleOnly"))
			else
				local b,why = a[1](ply)
				if not b then
					return false, why and _T("ArgumentException", 1, why)
				end
			end
			if f[1] == E.null then
				return false, _T("ArgumentException", 1, _T("ConsoleOnly"))
			end
		else
			if f[1] == E.player then
				return false, _T("ArgumentException", 1, _T("PlayersOnly"))
			end
		end
		local res = {ply}
		if args[2] then
			for i = 2,#f do
				local suc,cast = GAMEMODE.TypeConv[f[i]](args[i])
				if not suc then
					return false, cast and _T("ArgumentException",  i-1, cast)
				end
				res[#res + 1] = cast
			end
		end
		local bl,why = GAMEMODE:JBRun(t,unpack(res))
		if not bl then
			return false,why
		end
		return true
	end
	return true, _T("NoCommand")
end
concommand.Add("jb",function(ply,cmd,args,argstr)
	local sc,why = CommandLogic(ply,args)
	if not sc then
		why = why or _T("Unavailable")
		if ply == NULL then
			MsgC(why)
		else
			LocalMsg(ply, "SND:warn", colour_warn, why)
			--PConsoleMsg(ply,why)
		end
	end
end)
function StripArgs(str)
	local s,l,ql,st,ou = nil,#str,ql,"",{}
	for i = 0,l do
		s = str[i]
		if s == '"' or s == "'" then
			ql = not ql
		elseif s == ' ' and not ql then
			table.insert(ou,st)
			st = ""
		else
			st = st .. str[i]
		end
	end
	if string.len(st) > 0 then
		table.insert(ou,st)
	end
	return ou
end
function GM:PlayerSay(ply,txt)
	local normaltxt = txt
	txt = string.lower(txt)
	local ssub = string.sub(txt,1,1)
	if ssub == "`" or ssub == "!" then
		txt = string.sub(txt,2)
		local args = StripArgs(txt)
		local s,w = CommandLogic(ply,args)
		if not s and w ~= "" then
			LocalMsg(ply, "SND:warn", colour_warn, w and w or _T("TempUnavail"))
		end
		return ""
	else
		return normaltxt
	end
end