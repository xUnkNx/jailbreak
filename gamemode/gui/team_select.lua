local RandomTypes = {227,12,228,4,21,208,226,10,6,77,251,108,219,222,234,69,229,85,236,231,235,232,255,230,23,235,271,11,237,221}
function createtmmn()
	if IsValid(frameteam) then
		frameteam:Remove()
	end
	frameteam = vgui.Create("DFrame")
	frameteam:SetPos(0,0)
	frameteam:SetSize(ScrW(),ScrH())
	frameteam:SetTitle("")
	frameteam:SetVisible(true)
	frameteam:ShowCloseButton(false)
	frameteam:MakePopup()
	function frameteam:Paint(w, h)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0, 0, w, h)
	end
	local guardss = vgui.Create( "DModelPanel", frameteam )
	guardss:SetPos(ScreenScale(9),ScreenScale(15))
	guardss:SetSize(ScrW() / 3,ScrH() * 0.8)
	guardss:SetModel( "models/player/police.mdl" )
	guardss:SetAnimated( true )
	guardss:GetEntity():SetSequence( table.Random(RandomTypes) )
	function guardss:LayoutEntity( ent )
		self:RunAnimation()
		return false
	end
	function guardss.Entity:GetPlayerColor()
		return Vector(0,0,1)
	end
	local teambut = vgui.Create("DButton", guardss)
	teambut:SetSize(ScrW() / 3,ScrH() * .8)
	teambut:SetText("")
	function teambut:Paint(w, h)
		if self.Into then
			surface.SetDrawColor( 0, 255, 255, 200)
		else
			surface.SetDrawColor( 0, 128, 255, 200)
		end
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetFont("JBHUDFONTBOLD")
		surface.SetTextColor(color_white)
		surface.SetTextPos(w * .5-surface.GetTextSize(_T("Guards")) * .5,h * .8)
		surface.DrawText(_C("Guards"))
	end
	function teambut:DoClick()
		frameteam:Remove()
		frameteam = nil
		net.Start("SelectTeam")
		net.WriteUInt(1,4)
		net.SendToServer()
	end
	function teambut:OnCursorEntered()
		self.Into = true
	end
	function teambut:OnCursorExited()
		self.Into = false
	end
	local zekss = vgui.Create( "DModelPanel", frameteam )
	zekss:SetPos(ScrW() - ScrW() / 2.8,ScreenScale(15))
	zekss:SetSize(ScrW() * .33,ScrH() * .8)
	zekss:SetModel( "models/player/Group01/male_04.mdl" )
	zekss:SetAnimated( true )
	zekss:GetEntity():SetSequence( table.Random(RandomTypes) )
	function zekss:LayoutEntity( ent )
		self:RunAnimation()
		return false
	end
	function zekss.Entity:GetPlayerColor() return Vector ( 1, 0, 0 ) end
	local teambut2 = vgui.Create("DButton", zekss)
	teambut2:SetSize(ScrW() * .33,ScrH() * .8)
	teambut2:SetText("")
	function teambut2:Paint(w, h)
		if self.Into then
			surface.SetDrawColor( 255, 255, 0, 200)
		else
			surface.SetDrawColor( 128, 128, 0, 200)
		end
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetFont("JBHUDFONTBOLD")
		surface.SetTextColor(color_white)
		surface.SetTextPos(w * .5-surface.GetTextSize(_T("Prisioners")) * .5,h * .8)
		surface.DrawText(_C("Prisioners"))
	end
	function teambut2:DoClick()
		frameteam:Remove()
		frameteam = nil
		net.Start("SelectTeam")
		net.WriteUInt(2,4)
		net.SendToServer()
	end
	function teambut2:OnCursorEntered()
		self.Into = true
	end
	function teambut2:OnCursorExited()
		self.Into = false
	end
	if LocalPlayer():IsAdmin() then
		local ghost = vgui.Create( "DModelPanel", frameteam )
		ghost:SetPos(ScrW() / 2.7, ScreenScale(15))
		ghost:SetSize(ScrW() / 4, ScrH() * 0.8)
		ghost:SetModel( "models/props_c17/gravestone003a.mdl" )
		function ghost:LayoutEntity( ent )
			return false
		end
		local teambut3 = vgui.Create("DButton", ghost)
		teambut3:SetSize(ScrW() / 4,ScrH() * 0.8)
		teambut3:SetText("")
		function teambut3:Paint(w, h)
			if self.Into then
				surface.SetDrawColor( 255, 255, 255, 200)
			else
				surface.SetDrawColor( 128, 128, 128, 200)
			end
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("JBHUDFONTBOLD")
			surface.SetTextColor(color_white)
			surface.SetTextPos(w * .5-surface.GetTextSize(_T("Spectators")) * .5,h * .8)
			surface.DrawText(_C("Spectators"))
		end
		function teambut3:DoClick()
			frameteam:Remove()
			frameteam = nil
			net.Start("SelectTeam")
			net.WriteUInt(3,8)
			net.SendToServer()
		end
		function teambut3:OnCursorEntered()
			self.Into = true
		end
		function teambut3:OnCursorExited()
			self.Into = false
		end
	end
	local teambut4 = vgui.Create("DButton",frameteam)
	teambut4:SetText("")
	teambut4:SetPos((ScrW() - ScrW() / 1.2) * .5,ScrH() * .92)
	teambut4:SetSize(ScrW() / 1.2,ScrH() * .05)
	teambut4.DoClick = function()
		frameteam:Remove()
		frameteam = nil
	end
	function teambut4:Paint(w,h)
		if self.Into then
			surface.SetDrawColor( 255, 255, 255, 200)
		else
			surface.SetDrawColor( 128, 128, 128, 200)
		end
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetFont("JBHUDFONTBOLD")
		surface.SetTextColor(color_white)
		surface.SetTextPos(w * .5-surface.GetTextSize(_C("Close")) * .5,h * .2)
		surface.DrawText(_C("Close"))
	end
	function teambut4:OnCursorEntered()
		self.Into = true
	end
	function teambut4:OnCursorExited()
		self.Into = false
	end
end