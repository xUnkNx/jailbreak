GM.Designs = GM.Designs or {}
function GM:DefineDesign(name,design)
	self.Designs[name] = design
end
local CurDesign = {}
local des = CreateClientConVar( "jb_huddesign", "vanilla", true, false )
function GM:SelectDesign(name)
	CurDesign = self.Designs[name] or {}
end
function GM:AppendDesign(name,design)
	if not self.Designs[name] then
		self.Designs[name] = design
		return
	end
	for k,v in pairs(design) do
		self.Designs[name][k] = v
	end
end
cvars.AddChangeCallback( "jb_huddesign", function(c,o,n)
	GAMEMODE:SelectDesign(n)
end)
local emptyfunc = function() end
function GetDesignPart(part)
	return CurDesign[part] or emptyfunc
end
local _, folds = file.Find("jailbreak/gamemode/gui/design/*","LUA")
for k,v in pairs(folds) do
	include(v .. "/cl_init.lua")
end
GM:SelectDesign(des:GetString())