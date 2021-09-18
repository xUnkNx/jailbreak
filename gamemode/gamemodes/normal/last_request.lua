local function selectct(w)
	Select(_T("SelectGuard"),team.GetAlive(TEAM_GUARD),function(k,v)
		JBCommand("duel",v:EntIndex(),w)
	end)
end
local LastRequest = {
{_T("KillGuards"),function()
	lrmn:Close()
	JBCommand("killct")
end},
{_T("TakeFreeday"),function()
	lrmn:Close()
	JBCommand("nextfd")
end},
{_T("DuelWith","DEagle"),function()
	selectct("weapon_dueldeagle")
end},
{_T("DuelWith","Scout"),function()
	selectct("weapon_duelscout")
end},
{_T("DuelWith","AWP"),function()
	selectct("weapon_duelawp")
end},
{_T("DuelWith",_T("DuelAny")),function()
	selectct("random")
end},
{_T("LastWar"),function()
	lrmn:Close()
	JBCommand("lastwar")
	LocalPlayer().AlreadyChoose = true
end},
{_T("DuelWith","Knife"),function()
	selectct("melee")
end}}
function mklrmn()
	if IsValid(lrmn) then
		if not lrmn:IsVisible() then
			lrmn:SetVisible(true)
		end
		return
	end
	lrmn = vgui.Create("Jailbreak_Main")
	lrmn:SetPos(0, 0)
	lrmn:SetSize(ScreenScale(160),ScreenScale(150))
	lrmn:SetTitle(_T("LRMenu"))
	lrmn:MakePopup()
	GenMenu(LastRequest,lrmn)
	lrmn:Center()
end