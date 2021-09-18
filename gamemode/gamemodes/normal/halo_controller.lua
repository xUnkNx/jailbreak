local dphalo = CreateClientConVar( "jb_duelplayerhalo", 1, true, false )
local phalo = CreateClientConVar( "jb_playerhalo", 1, true, false )
local fdhalo = CreateClientConVar( "jb_freedayhalo", 1, true, false )
local color_yellow,color_blue,color_yel,color_green,color_red = Color(255,255,0),Color(0,255,255),Color(255,128,0),Color(0,255,0),Color(200,50,50)
GM.HookGamemode("PreDrawHalos",function()
	if phalo:GetBool() then
		local t,c,tbl,ren
		if LocalPlayer():Team() == TEAM_PRISIONER then
			t,c = TEAM_PRISIONER, color_yellow
		elseif LocalPlayer():Team() == TEAM_GUARD then
			t,c = TEAM_GUARD, color_blue
		end
		tbl = team.GetAlive(t)
		if #tbl > 1 then
			ren = {}
			for _, v in pairs(tbl) do
				local distance = LocalPlayer():GetPos():DistToSqr(v:GetPos())
				if distance < 1024 and v:Alive() and v ~= LocalPlayer() then
					table.insert(ren,v)
				end
			end
			if #ren > 0 then
				halo.Add( ren, c, 2, 2, 1, true, false )
			end
		end
	end
	if dphalo:GetBool() then
		local who, frag, ply = GetGMEntity("DUELINIT", NULL), GetGMEntity( "DUELFRAG"),LocalPlayer()
		if IsValid(who) and IsValid(frag) then
			local tbl = {}
			if who == ply and frag:Alive() then
				table.insert(tbl,frag)
			elseif frag == ply and who:Alive() then
				table.insert(tbl,who)
			end
			if #tbl > 0 then
				halo.Add( tbl, color_yel, 2, 2, 1, true, true )
			end
		end
	end
	if fdhalo:GetBool() and LocalPlayer():Team() == TEAM_GUARD then
		local fds,rbls = {}, {}
		for _,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
			if v:GetNW("FreeDayTime",0) >= CurTime() then
				fds[#fds + 1] = v
			end
			if v:GetNW("Rebel") then
				rbls[#rbls + 1] = v
			end
		end
		if #fds > 0 then
			halo.Add( fds, color_green, 2, 2, 1, true, true )
		end
		if #rbls > 0 then
			halo.Add( rbls, color_red, 2, 2, 1, true, true )
		end
	end
end)