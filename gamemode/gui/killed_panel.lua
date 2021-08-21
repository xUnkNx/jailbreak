local gradient = Material("gui/gradient")
net.Receive("KilledBy", function(len)
	local killer,inf,stats,mystats,killby,wpnby = net.ReadEntity(),net.ReadEntity(),net.ReadTable(),net.ReadTable(),"",nil
	if not IsValid(killer) then
		killby = "Вы были убиты"
		wpnby = "миром"
	elseif killer == LocalPlayer() then
		killby = "Вы совершили суицид"
	else
		if killer:IsPlayer() then
			killby = killer:Nick()
		else
			killby = language.GetPhrase(killer:GetClass())
		end
		killby = "Вас убил игрок " .. killby
	end
	if not wpnby then
		if not IsValid(inf) then
			if killer == LocalPlayer() then
				wpnby = ""
			else
				wpnby = "мира"
			end
		else
			if inf:IsWeapon() then
				wpnby = "из " .. (inf.PrintName or language.GetPhrase(inf:GetClass()))
			elseif inf == LocalPlayer() then
				wpnby = ""
			elseif inf:IsPlayer() then
				local wep = inf:GetActiveWeapon()
				if IsValid(wep) then
					wpnby = "с помощью " .. (wep.PrintName or language.GetPhrase(wep:GetClass()))
				else
					wpnby = "из непонятно чего"
				end
				inf = wep
			else
				wpnby = language.GetPhrase(inf:GetClass())
				wpnby = "с помощью " .. wpnby
			end
		end
	end
	if IsValid(killpanel) then
		killpanel:Remove()
	end
	if IsValid(killpanelavatar) then
		killpanelavatar:Remove()
	end
	killpanelavatar = vgui.Create("AvatarImage")
	killpanelavatar:SetPos(ScrW() * .2,ScrH() * .675)
	killpanelavatar:SetSize(ScrW() * .125,ScrW() * .125)
	if IsValid(killer) and killer:IsPlayer() then
		killpanelavatar:SetPlayer(killer,184)
	else
		killpanelavatar:SetPlayer(LocalPlayer(),184)
	end
	killpanelavatar:ParentToHUD()
	killpanel = vgui.Create("DPanel")
	killpanel:SetPos(ScrW() * .325,ScrH() * .675)
	killpanel:SetSize(ScrW() * .5,ScrH() * .2)
	function killpanel:Paint(w,h)
		surface.SetDrawColor(team.GetColor(LocalPlayer():Team()))
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0,0,w,h)
	end
	if IsValid(inf) and inf.WorldModel then
		local w,h = killpanel:GetSize()
		local killpanelwpn = vgui.Create("DModelPanel",killpanel)
		killpanelwpn:SetPos(0,0)
		killpanelwpn:SetSize(killpanel:GetSize())
		killpanelwpn:SetModel(inf.WorldModel)
		killpanelwpn:SetCamPos(Vector(0,15,20))
		killpanelwpn:SetLookAt(Vector(10,0,10))
		killpanelwpn:SetFOV(130)
		killpanelwpn.oldpaint = killpanelwpn.Paint
		killpanelwpn:SetLookAng(Angle(45,270,0))
		if inf.Mater and IsValid(killpanelwpn.Entity) then
			killpanelwpn.Entity:SetMaterial(inf.Mater)
		end
		killpanelwpn.oldangle = 0
		function killpanelwpn:LayoutEntity( ent )
			if killpanelwpn.oldangle < 360 then
				killpanelwpn.oldangle = killpanelwpn.oldangle + 1
			else
				killpanelwpn.oldangle = 0
			end
			self.Entity:SetAngles(Angle(0,killpanelwpn.oldangle,45))
		end
	end
	killpanel:ParentToHUD()
	local killpanelchild = vgui.Create("DPanel",killpanel)
	killpanelchild:SetPos(0,0)
	killpanelchild:SetSize(killpanel:GetSize())
	killpanelchild.killby = killby
	killpanelchild.wpnby = wpnby
	if type(stats) == "table" and table.Count(stats) > 0 then
		for k,v in pairs(stats) do
			stats[k] = language.GetPhrase(k) .. " = " .. v[1] .. " (x" .. v[2] .. ")"
		end
		killpanelchild.deathstats = stats
	end
	if type(mystats) == "table" and table.Count(mystats) > 0 then
		for k,v in pairs(mystats) do
			mystats[k] = language.GetPhrase(k) .. " = " .. v[1] .. " (x" .. v[2] .. ")"
		end
		killpanelchild.killstats = mystats
	end
	function killpanelchild:Paint(w,h)
		draw.RoundedBox(4,0,0,w,h,Color(50,50,50,200))
		draw.SimpleText(self.killby .. " " .. self.wpnby,"JBHUDFONTDEAD",w * .5,h * .1,Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self.deathstats then
			local pos = 0
			surface.SetFont("JBHUDFONTMINI")
			surface.SetDrawColor(255,255,255)
			surface.SetTextPos(w * .1,h * .2)
			surface.DrawText("Урон получен:")
			for atk,dmg in pairs(self.deathstats) do
				surface.SetTextPos(w * .15,h * .3 + h * .1 * pos)
				surface.DrawText(dmg)
				pos = pos + 1
			end
		end
		if self.killstats then
			local pos = 0
			surface.SetFont("JBHUDFONTMINI")
			surface.SetDrawColor(255,255,255)
			surface.SetTextPos(w * .45,h * .2)
			surface.DrawText("Урон нанесён:")
			for atk,dmg in pairs(self.killstats) do
				surface.SetTextPos(w * .5,h * .3 + h * .1 * pos)
				surface.DrawText(dmg)
				pos = pos + 1
			end
		end
	end
	timer.Simple(math.Rand(5,10),function()
		if IsValid(killpanel) then
			killpanel:Remove()
		end
		if IsValid(killpanelavatar) then
			killpanelavatar:Remove()
		end
	end)
end)