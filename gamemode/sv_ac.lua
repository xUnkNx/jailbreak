BlockedList = BlockedList or {}
local function Block(atk,inf,bool)
	if atk == inf then return end
	--local bool = not atk:TestPVS(inf) -- its working fine, but after some time start to throttle cpu speed. Its a bug, there should be a special module to complete this.
	if BlockedList[atk][inf] then
		if bool then
			BlockedList[atk][inf] = nil
		else
			return
		end
	else
		if bool then
			return
		else
			BlockedList[atk][inf] = true
		end
	end
	if hook.Run("PlayerCanBlockPlayer", inf, atk, bool) then
		--print(atk,bool and "blocked" or "unblocked",inf)
		atk:SetPreventTransmit(inf,bool)
		if bool then -- no reason to show them again, they will be rendered with player
			for k,ent in pairs(inf:GetChildren()) do
				ent:SetPreventTransmit(atk,bool)
			end
		end
	end
end
function GM:PlayerCanBlockPlayer(rec, send, bool)
	--print(rec,send,bool, send:GetGM("ForceVisible"))
	if send:GetGM("ForceVisible") then
		return false
	end
	return true
end
function GM:SetForceVisible(ply, bool)
	ply:SetGM("ForceVisible", bool)
	if bool then
		for k,v in pairs(player.GetAll()) do
			ply:SetPreventTransmit(v, false)
		end
	end
end
hook.Add("PlayerDisconnected","CleanACFilter",function(ply)
	BlockedList[ply] = nil
	for k,v in pairs(BlockedList) do
		v[ply] = nil
	end
end)
hook.Add("PlayerInitialSpawn","AddACFilter",function(ply)
	BlockedList[ply] = {}
end)
hook.Add("WeaponEquip","AC",function(wep,own)
	for k,v in pairs(BlockedList[own]) do
		wep:SetPreventTransmit(k,true)
	end
end)
hook.Add("PlayerDroppedWeapon","AC",function(own,wep)
	for k,v in pairs(player.GetAll()) do
		wep:SetPreventTransmit(v,false)
	end
end)
timer.Create("ACAntiPlayerWH",0.1,0,function()
	local plrs, plrc = player.GetAll(), {}
	for k,v in pairs(plrs) do
		plrc[v] = k
	end
	for ply in pairs(plrc) do
		local recip = RecipientFilter()
		recip:AddPVS(ply:EyePos())
		local plrc1 = table.Copy(plrc)
		for _,j in pairs(recip:GetPlayers()) do
			Block(ply, j, false)
			plrc1[j] = nil
		end
		for inf in pairs(plrc1) do
			if inf:Alive() then
				Block(ply, inf, true)
			end
		end
	end
end)