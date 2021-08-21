msgs = msgs or {tbl = {},queue = {},max = 3,icons = {
	["add"] = Material("icon16/attach.png"),
	["error"] = Material("icon16/error.png"),
	["no"] = Material("icon16/cancel.png"),
	["hint"] = Material("icon16/tick.png"),
	["info"] = Material("icon16/information.png"),
	["tips"] = Material("icon16/sound_none.png"),
}}
local function InfoCreate(i,...)
	local frame = vgui.Create("DPanel")
	frame:SetTall(ScreenScale(15))
	frame.Color = Color(220,220,220)
	frame.Icon = msgs.icons[i]
	function frame:Paint(w,h)
		draw.RoundedBox(4,0,0,w,h,color_black)
		draw.RoundedBox(4,2,2,w - 4,h - 4,self.Color)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self.Icon)
		surface.DrawTexturedRect(8,h * .5 - 16,32,32)
	end
	local rich = vgui.Create("RichText",frame)
	rich:Dock(FILL)
	rich:DockMargin(32 + ScreenScale(4),4,0,0)
	local t = {...}
	rich:InsertColorChange(50,50,50,255)
	function rich:PerformLayout()
		rich:SetFontInternal("JBHUDFONT")
	end
	surface.SetFont("JBHUDFONT")
	local totalw = 0
	for k,v in pairs(t) do
		if IsColor(v) or IsSharedColor(v) then
			rich:InsertColorChange(v.r,v.g,v.b,v.a)
		else
			v = tostring(v)
			rich:AppendText(v)
			local sz = surface.GetTextSize(v)
			totalw = totalw + sz
		end
	end
	rich:AppendText("\0")
	rich:SetVerticalScrollbarEnabled(false)
	local ch = rich:GetChild(0)
	if IsValid(ch) then
		totalw = totalw + ch:GetWide()
	end
	frame:SetWide(totalw + ScreenScale(8) + 32)
	local w,h = frame:GetSize()
	frame._x,frame._y = -w,-h
	frame:SetPos(-w,-h)
	frame.goalx = ScrW() * .5-w * .5
	frame.closex = ScrW() + w
	frame:ParentToHUD()
	surface.PlaySound("ambient/levels/canals/drip" .. math.random(1,4) .. ".wav")
	return frame
end
function msgs.Create(i,...)
	if not i or not msgs.icons[string.lower(i)] then
		i = "info"
	else
		i = string.lower(i)
	end
	if #msgs.tbl >= msgs.max then
		table.insert(msgs.queue,{i,...})
		return
	end
	table.insert(msgs.tbl,InfoCreate(i,...))
end
DrawMessage = msgs.Create
hook.Add("Tick", "JBNoteHUD", function()
	for k,v in ipairs(msgs.tbl) do
		if v.Closed then
			v._y = Lerp(0.025, v._y, 0)
			v._x = Lerp(0.025, v._x, v.closex)
			v:SetPos(v._x,v._y)
			if v._x > ScrW() then
				if #msgs.tbl <= msgs.max then
					local i,m = next(msgs.queue)
					if i then
						v:Remove()
						msgs.tbl[k] = InfoCreate(unpack(m))
						msgs.queue[i] = nil
					else
						v:Remove()
						table.remove(msgs.tbl,k)
					end
				else
					table.remove(msgs.tbl,k)
				end
			end
		else
			v._y = Lerp(0.025, v._y, k * ScreenScale(25))
			v._x = Lerp(0.025, v._x, v.goalx)
			v:SetPos(v._x,v._y)
			if v.goalx-v._x < 5 then
				v.Closed = true
			end
		end
	end
end)