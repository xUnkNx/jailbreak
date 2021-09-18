local PANEL = {}
function PANEL:Init()
	self:DockPadding( 2, 2, 2, 2 )
	self:SetSize(ScrW() * .6, ScrH() * .6)
	self:SetPos(ScrW() * .2, ScrH() * .2)
	self.Scroll = 0
	self.Players = {}
	self.Groups = {}

	local mh = vgui.Create("DPanel", self)
	mh:Dock(TOP)
	mh:SetTall(ScrH() * .06)
	mh:DockMargin(0,0,0,8)
	function mh:Paint(w,h)
		surface.SetDrawColor(200,200,200,150)
		surface.DrawRect(0,0,w,h)
		draw.DrawText( GetHostName(), "JBHUDFONT", w * .5, h * .25, color_white, TEXT_ALIGN_CENTER )
		draw.DrawText( _C("CurrentMap", game.GetMap()), "JBHUDFONTNANO", 0, h * .75, color_white, TEXT_ALIGN_LEFT )
		draw.DrawText( _C("CurrentOnline", player.GetCount(), game.MaxPlayers()), "JBHUDFONTNANO", w, h * .75, color_white, TEXT_ALIGN_RIGHT )
	end
	mh:SetZPos(-32000)
end
local HEIGHT = 32
function PANEL:Paint( w, h )
	surface.SetDrawColor( 100, 100, 100, 255 )
	surface.DrawRect( 0, 0, w, h )
end
function PANEL:Think()
	for k,v in pairs(player.GetAll()) do
		if self.Players[v] == nil then
			local pnl = vgui.Create( "VanillaSC_Player", self )
			pnl:SetPlayer( v )
			pnl:Dock( TOP )
			pnl.Canvas = self
			self.Players[v] = pnl
		end
	end
end
function PANEL:SetGroup(p, old, new, prior, color)
	if IsValid(self.Groups[old]) then
		self.Groups[old]:RemovePlayer(p.Player)
	end
	if IsValid(self.Groups[new]) then
		self.Groups[new]:AddPlayer(p.Player, p)
	else
		local gr = vgui.Create( "VanillaSC_Group", self )
		gr:Dock(TOP)
		gr:SetGroup(new, prior, color)
		self.Groups[new] = gr
		gr:AddPlayer(p.Player, p)
	end
end
function PANEL:PerformLayout( w, h )
	self:SizeToChildren( false, true )
	if self:GetTall() > ScrH() * .6 then
		self:SetTall(ScrH() * .6)
	end
end
vgui.Register( "VanillaSC", PANEL, "DScrollPanel" )

local PANEL = {}
function PANEL:Init()
	self:DockPadding( 0, 0, 0, 2 )
	self:SetPaintBackground(false)
	self.Players = {}
	self.Group = "Unknown"
	self:SetPaintBackground( false )

	local header = vgui.Create( "DPanel", self )
	header.Text = self.Group
	header:Dock( TOP )
	header:DockPadding( 2, 0, 2 + 64, 0 )
	header:SetTall( 22 )
	header.Color = Color(100, 100, 100, 155)
	self.Header = header

	function header:Paint( w, h )
		draw.RoundedBox( 2, 0, 0, w * .3, h, self.Color )
		draw.DrawText( self.Text, "TargetID", 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	header.Ping = vgui.Create( "DLabel", header )
	header.Ping:SetTextColor( color_black )
	header.Ping:SetText( _C("Ping") )
	header.Ping:SetWide( 64 )
	header.Ping:SetContentAlignment( 5 )
	header.Ping:Dock( RIGHT )

	header.Deaths = vgui.Create( "DLabel", header )
	header.Deaths:SetTextColor( color_black )
	header.Deaths:SetText( _C("Deaths") )
	header.Deaths:SetWide( 64 )
	header.Deaths:SetContentAlignment( 5 )
	header.Deaths:Dock( RIGHT )

	header.Score = vgui.Create( "DLabel", header )
	header.Score:SetTextColor( color_black )
	header.Score:SetText( _C("Score") )
	header.Score:SetWide( 64 )
	header.Score:SetContentAlignment( 5 )
	header.Score:Dock( RIGHT )
end
function PANEL:Think() end
function PANEL:CountChanged()
	self.Header.Text = self.Group .. " (" .. table.Count( self.Players ) .. ")"
	self:InvalidateLayout(true)
end
function PANEL:PerformLayout()
	if self:ChildCount() <= 1 then
		self:Remove()
	else
		self:SizeToChildren( false, true )
		self:InvalidateParent()
	end
end
function PANEL:AddPlayer( ply, pnl )
	if not IsValid(pnl) then
		return
	end
	pnl:SetParent(self)
	pnl:Dock(TOP)
	self.Players[ ply ] = pnl
	self:CountChanged()
end
function PANEL:RemovePlayer( ply )
	self.Players[ ply ] = nil
	self:CountChanged()
end
function PANEL:OnChildRemoved( pnl )
	self.Players[ pnl.Player ] = nil
	self:CountChanged()
end
function PANEL:SetGroup( group, prior, col )
	if group then
		self.Group = group
		self.Header.Text = self.Group .. " (" .. table.Count( self.Players ) .. ")"
	end
	if col then
		self.Header.Color = col
	end
	self:SetZPos(prior or 0)
end
vgui.Register( "VanillaSC_Group", PANEL, "DPanel" )

local PANEL = {}
function PANEL:Init()
	self:SetTall( HEIGHT )
	self:DockPadding( 1, 1, 1, 1 )
	self:DockMargin( 8, 2, 4, 0 )
	self:SetMouseInputEnabled( true )
	self.Group = "Unknown"

	local avatar = vgui.Create( "DPanel", self )
	avatar:Dock( LEFT )
	avatar:DockPadding( 1, 1, 1, 1 )
	avatar:SetMouseInputEnabled( false )
	avatar.Avatar = vgui.Create( "AvatarImage", avatar )
	avatar.Avatar:Dock( FILL )
	function avatar:PerformLayout( w, h )
		self:SetWide( self:GetTall() )
	end
	local pcolor = Color( 32, 95, 132, 150 )
	function avatar:Paint( w, h )
		surface.SetDrawColor( pcolor )
		surface.DrawRect( 0, 0, w, h )
	end
	function avatar:SetPlayer( ply )
		self.Avatar:SetPlayer( ply )
	end
	self.Avatar = avatar

	local name = vgui.Create("DLabel", self)
	name:Dock(LEFT)
	name:SetWide( 256 )
	name:SetTextInset( 8, 0 )
	name:SetContentAlignment( 4 )
	function name:PlayerThink(ply)
		self:SetText( ply:Nick() )
	end
	self.Name = name

	local mute = self:Add( "DImageButton" )
	mute:SetSize( 32, 32 )
	mute:Dock( RIGHT )
	function mute:DoClick()
		self.Player:SetMuted( not self.Muted )
		self:PlayerThink(self.Player)
	end
	function mute:PlayerThink( ply )
		if ( self.Muted == nil or self.Muted ~= self.Player:IsMuted() ) then
			self.Muted = self.Player:IsMuted()
			if ( self.Muted ) then
				self:SetImage( "icon32/muted.png" )
			else
				self:SetImage( "icon32/unmuted.png" )
			end
		end
	end
	function mute:SetPlayer(ply)
		self.Player = ply
		self:PlayerThink(ply)
	end
	function mute:OnMouseWheeled( delta )
		self.Player:SetVoiceVolumeScale( self.Player:GetVoiceVolumeScale() + ( delta * .05 ) )
		self.LastTick = CurTime()
	end
	function mute:PaintOver( w, h )
		local a = 255 - math.Clamp( CurTime() - ( self.LastTick or 0 ), 0, 3 ) * 255
		if ( a <= 0 ) then return end
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, a * 0.75 ) )
		draw.SimpleText( math.ceil( self.Player:GetVoiceVolumeScale() * 100 ) .. "%", "DermaDefaultBold", w / 2, h / 2, Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.Mute = mute

	local ping = vgui.Create( "DLabel", self )
	ping:Dock(RIGHT)
	function ping:PlayerThink(ply)
		self:SetText(ply:Ping())
	end
	self.Ping = ping

	local deaths = vgui.Create( "DLabel", self )
	deaths:Dock(RIGHT)
	function deaths:PlayerThink(ply)
		self:SetText(ply:Deaths())
	end
	self.Deaths = deaths

	local score = vgui.Create( "DLabel", self )
	score:Dock(RIGHT)
	function score:PlayerThink(ply)
		self:SetText(ply:Frags())
	end
	self.Score = score
end
local clr = Color(60,60,60)
function PANEL:Paint( w, h )
	surface.SetDrawColor( clr )
	surface.DrawRect( 0, 0, w, h )
end
function PANEL:Think()
	local ply = self.Player
	if not IsValid( ply ) then
		self:Remove()
		return
	end
	self.Name:PlayerThink( ply )
	self.Ping:PlayerThink( ply )
	self.Deaths:PlayerThink( ply )
	self.Score:PlayerThink( ply )

	local group, prior, color = hook.Run("TabSelectCategory", self, ply)
	if group and self.Group ~= group then
		self.Group = group
		self.Canvas:SetGroup(self, self.Group, group, prior, color)
	end
end
function PANEL:DoClick()
	local menu = DermaMenu( self )
	RegisterDermaMenuForClose(menu)
	menu:AddOption( _C("CopySteamID"), function()
		SetClipboardText( self.Player:SteamID() )
		chat.PlaySound()
	end ):SetImage( "icon16/book_go.png" )
	menu:AddOption( _C("CopyNickName"), function()
		SetClipboardText( tostring(self.Player:Nick()) )
		print("Nickname for copying: \"" .. tostring(self.Player:Nick()) .. "\" (without quotes)")
		chat.PlaySound()
	end ):SetImage( "icon16/user_go.png" )
	menu:AddOption( _C("ShowProfile"), function()
		self.Player:ShowProfile()
	end ):SetImage( "icon16/information.png" )
	menu:Open()
end
function PANEL:OnMousePressed( key )
	self:MouseCapture( true )
end
function PANEL:OnMouseReleased( key )
	self:MouseCapture( false )
	if self:IsHovered() then
		if key == MOUSE_LEFT and self.DoClick then
			self:DoClick()
		elseif key == MOUSE_RIGHT and self.DoRightClick then
			self:DoRightClick()
		end
	end
end
function PANEL:SetPlayer( ply )
	self.Player = ply
	self.Avatar:SetPlayer( ply )
	self.Mute:SetPlayer(ply)
end
vgui.Register( "VanillaSC_Player", PANEL, "DPanel" )

Scoreboard = Scoreboard
GM:AppendDesign("vanilla",{
	["ScoreboardShow"] = function()
		if not IsValid(Scoreboard) then
			Scoreboard = vgui.Create( "VanillaSC" )
		end
		Scoreboard:SetVisible( true )
		gui.EnableScreenClicker( true )
	end,
	["ScoreboardHide"] = function()
		CloseDermaMenus()
		gui.EnableScreenClicker( false )
		Scoreboard:SetVisible( false )
	end,
})