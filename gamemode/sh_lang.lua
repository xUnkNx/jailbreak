GM.Languages = {}
function GM:LoadLanguage(name)
	local path = "languages/" .. name .. ".lua"
	local LANG = include(path)
	if SERVER then AddCSLuaFile(path) end
	self.Languages[name] = LANG
	return LANG
end
local baselang = GM:LoadLanguage("russian") -- base lang
local function countpattern(str)
	local off, count = 0, 0
	repeat
		local a,b = string.find(str, "%%[a-zA-Z]",off)
		if b then
			off = b
			count = count + 1
		end
	until b == nil
	return count
end
function GM.FormatPhrase(phrase,...)
	if type(phrase) == "string" then
		-- If just string, return formatted string
		local result, args = {}, {...}
		for k,v in pairs(args) do
			if type(v) == "table" and v.r and v.b then
				table.remove(args, k)
				table.insert(result, v) -- check for colors
			end
		end
		if #result > 0 then -- if contain colors then return table otherwise string
			table.insert(result, string.format(phrase, unpack(args)))
			return result
		else
			return string.format(phrase, unpack(args))
		end
	end
	local args, result, counter = {...}, {}, 1
	-- If args list then it should contain colors and strings(numbers)
	for k,arg in pairs(args) do
		local tp = type(arg)
		if tp == "table" then
			if arg.r and arg.b then -- is color
				table.insert(result, arg)
				local phrs = phrase[counter] -- check next arg is word, cuz no reason to put 2 colors consistently
				if type(phrs) == "string" and not string.find(phrs,"%%[a-zA-Z]") then
					counter = counter + 1
					table.insert(result, phrs) -- if it is, add like word
				end
			end
		elseif tp == "string" or tp == "number" or tp == "boolean" then
			for i = counter, #phrase do -- there can be much words without pattern and colors, so cycle them until end or find pattern
				local phrs = phrase[i]
				counter = i + 1
				if type(phrs) == "function" then -- if custom function then use it instead of format
					table.insert(result, phrs(arg))
					break
				else
					if countpattern(phrs) > 0 then -- if string contains patterns, format it
						table.insert(result, string.format(phrs, arg))
						break
					else
						table.insert(result, phrs) -- else just add
					end
				end
			end
		end
	end
	for i = counter, #phrase do
		table.insert(result, phrase[i])
	end
	return result
end
if SERVER then
	function GM.Phrase(phrase,...)
		--ServerLog(self:FormatPhrase(baselang[phrase], ...))
		return {phrase, ...}
	end
else
	function GM.Phrase(phrase,...)
		return GAMEMODE.FormatPhrase(baselang[phrase] or phrase, ...)
	end
end
_T = GM.Phrase