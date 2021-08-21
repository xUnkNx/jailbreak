local PANEL = {}
function PANEL:Init()
	self.Into = false
	self.Pressed = false
	self.Color = Color(255,255,255)
	self.TextColor = Color(0,0,0)
	self.Font = "JBHUDFONTMINI"
	self.Text = ""
	self.ColorSize = 2
end
local PrechachedMat = Material("gui/gradient_down")
function PANEL:Paint(w, h)
	if self.Into then
		surface.SetDrawColor( self.Color )
	else
		local cl = self.Color
		surface.SetDrawColor( cl.r - 128 , cl.g - 128, cl.b - 128, cl.a )
	end
	local sz = self.ColorSize
	if self.Pressed then
		surface.SetMaterial(PrechachedMat)
		surface.DrawTexturedRect(sz,sz,w - sz * 2,h - sz * 2)
	else
		surface.DrawOutlinedRect(sz * 0.5,sz * 0.5,w - sz,h - sz)
	end
	surface.SetFont(self:GetFont())
	surface.SetTextColor(self:GetTextColor())
	local txt = self:GetText()
	local x,y = surface.GetTextSize(txt)
	surface.SetTextPos(w * 0.5 - x * 0.5,h * 0.5 - y * 0.5)
	surface.DrawText(txt)
end
function PANEL:OnCursorEntered()
	self.Into = true
	self:SetCursor( "hand" )
end
function PANEL:OnCursorExited()
	self.Into = false
	self.Pressed = false
	self:SetCursor( "none" )
end
function PANEL:DoClick()
end
function PANEL:OnMousePressed( mousecode )
	self.Pressed = true
end
function PANEL:OnMouseReleased( mousecode )
	self.Pressed = false
	self:DoClick()
end
function PANEL:GetTextColor()
	return self.TextColor
end
function PANEL:GetColorSize()
	return self.ColorSize
end
function PANEL:GetColor()
	return self.Color
end
function PANEL:GetText()
	return self.Text
end
function PANEL:GetFont()
	return self.Font
end
function PANEL:SetTextColor(clr)
	if not IsColor(clr) then return end
	self.TextColor = clr
end
function PANEL:SetColorSize(num)
	if not isnumber(clr) then return end
	self.ColorSize = num
end
function PANEL:SetColor(clr)
	if not IsColor(clr) then return end
	self.Color = clr
end
function PANEL:SetText(txt)
	if not isstring(txt) then return end
	self.Text = txt
end
function PANEL:SetFont(font)
	if not isstring(txt) then return end
	self.Font = font
end
vgui.Register( "Jailbreak_Button", PANEL )
------------------------------------------
PANEL = {}
function PANEL:Init()
	self.OutlineColor = Color(0,0,0)
	self.Color = Color(255,255,255)
	self:InvalidateLayout( true )
	local pn = vgui.Create("DPanel",self)
	pn:Dock(TOP)
	pn:SetTall(12)
	pn.Paint = nil
end
function PANEL:FitY()
	local total = 0
	for k,v in pairs(self:GetChildren()) do
		local a,b,c,d = v:GetDockMargin()
		total = total + v:GetTall() - b - d
	end
	self:InvalidateLayout(true)
	self:SizeToChildren(false,true)
	self:SetTall(self:GetTall() + ScreenScale(2.5))
end
function PANEL:FitW()
	local total = 0
	for k,v in pairs(self:GetChildren()) do
		total = total + v:GetWide()
	end
	self:SetWide(total)
end
function PANEL:Paint(w, h)
	local maincolor,outline = self.Color,self:GetOutlineColor()
	local ph = ScreenScale(3)
	surface.SetDrawColor(outline)
	local h1,h2 = 24
	h2 = h - h1
	surface.DrawRect(0, 0, w, h1)
	surface.SetDrawColor( maincolor )
	surface.DrawOutlinedRect(0, 0, w, h1)
	surface.SetDrawColor( maincolor.r - 55, maincolor.g - 55, maincolor.b - 55, maincolor.a )
	surface.DrawRect(ph, h1, w-ph * 2, h)
	surface.SetDrawColor( outline )
	surface.DrawOutlinedRect(ph, h1, w-ph * 2, h2)
	surface.SetDrawColor(Color(128,128,128))
	surface.SetMaterial(PrechachedMat)
	surface.DrawTexturedRect(ph,h1,w-ph * 2,h1)
end
function PANEL:DoClick()
end
function PANEL:GetOutlineColor()
	return self.OutlineColor
end
function PANEL:GetColor()
	return self.Color
end
function PANEL:SetOutlineColor(clr)
	if not IsColor(clr) then return end
	self.OutlineColor = clr
end
function PANEL:SetColor(clr)
	if not IsColor(clr) then return end
	self.Color = clr
end
vgui.Register( "Jailbreak_Main", PANEL, "DFrame" )