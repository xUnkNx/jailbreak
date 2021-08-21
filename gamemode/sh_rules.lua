if SERVER then
	AddCSLuaFile("rules.lua")
	include("rules.lua")
	return
end
include("rules.lua")
local RepTbl = {["CT"] = "<font color=\"#0000FF\">CT</font>",
["T"] = "<font color=\"#FF0000\">T</font>"}
function FormatJB(text)
	text = string.gsub(text,"/(%w-)/",RepTbl)
	return text
end
function FormatHTML(html)
	local res,pos,Replace = html,1,{}
	for i = 1,10 do
		local st,nd,res = string.find(html,"<LUADATA (.-)></LUADATA>",pos)
		if st == nil then break end
		pos = nd
		local kv = string.Split(res," ")
		local params = {}
		for _,k in pairs(kv) do
			local ind,vr = string.match(k,"(%w+)=(.+)")
			if ind and vr then
				params[ind] = string.Replace(vr,"\"","")
			else
				params[ind] = true
			end
		end
		if params.tbl and GM.Data[params.tbl] then
			if params.format == nil then
				params.format = "%s"
			end
			local tb,id,str,c = nil,tonumber(params.id),"",nil
			if id and GM.Data[params.tbl][id] then
				tb = GM.Data[params.tbl][id]
			else
				tb = GM.Data[params.tbl]
			end
			if tb then
				local typ = type(tb)
				if typ == "table" then
					c = #tb
					local d = string.find(params.format,"%d",1,true) ~= nil
					for i = 1,c do
						str = str .. string.format(params.format,d and i or tb[i],d and nil or tb[i]) .. (i == c - 1 and "" or "\n")
					end
					table.insert(Replace,{st - 1,nd + 1,str})
				elseif typ == "string" then
					table.insert(Replace,{st - 1,nd + 1,string.format(params.format,tb)})
				end
			end
		end
	end
	if #Replace > 0 then
		local lo = 0
		for i = 1,#Replace do
			local t = Replace[i]
			res = string.sub(res,1,t[1] + lo) .. t[3] .. string.sub(res,t[2] + lo)
			lo = lo + string.len(t[3]) - t[2] + t[1] + 1
		end
	end
	return res
end
GM.HTMLR = FormatJB(FormatHTML(GM.HTMLRules))
GM.HTMLP = FormatJB(FormatHTML(GM.HTMLPravila))
GM.HTMLI = FormatJB(FormatHTML(GM.HTMLInfo))