local dphalo = CreateClientConVar( "jb_duelplayerhalo", 1, true, false )
local phalo = CreateClientConVar( "jb_playerhalo", 1, true, false )
local fdhalo = CreateClientConVar( "jb_freedayhalo", 1, true, false )
local color_yellow,color_blue,color_yel,color_green = Color(255,255,0),Color(0,255,255),Color(255,128,0),Color(0,255,0)
function GM:PreDrawHalos( )
	if phalo:GetBool() then
		local t,c,tbl,ren
		if LocalPlayer():Team() == TEAM_PRISIONER then
			t,c = TEAM_PRISIONER,color_yellow
		elseif LocalPlayer():Team() == TEAM_GUARD then
			t,c = TEAM_GUARD,color_blue
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
				halo.Add( ren, c, 1, 1, 2, true, false )
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
				halo.Add( tbl, color_yel, 1, 1, 2, true, true )
			end
		end
	end
	if fdhalo:GetBool() and LocalPlayer():Team() == TEAM_GUARD then
		local tbl = {}
		for _,v in pairs(team.GetAlive(TEAM_PRISIONER)) do
			if v:GetNWInt("FreeDayTime",0) >= CurTime() then
				table.insert(tbl,v)
			end
		end
		if #tbl > 0 then
			halo.Add( tbl, color_green, 1, 1, 2, true, false )
		end
	end
end