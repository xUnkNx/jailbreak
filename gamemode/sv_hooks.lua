function GM:Initialize()
	scripted_ents.Register({Base = "base_point"},"nothing")
	scripted_ents.Alias("info_ladder","nothing")
	scripted_ents.Alias("func_buyzone","nothing")
	scripted_ents.Alias("func_bomb_target","nothing")
	scripted_ents.Alias("func_hostage_rescue","nothing")
	--RunConsoleCommand("sv_sticktoground","0")
	--RunConsoleCommand("sv_accelerate","10")
	--RunConsoleCommand("sv_airaccelerate","100")
	RunConsoleCommand("mp_show_voice_icons","0")
	self.PrepareTime = CurTime() + self.PrepareTime
	--RunConsoleCommand("sv_skyname","sky_day02_01")
	for k,v in pairs(weapons.GetList()) do
		self.AmmoTable[v.ClassName] = v.Primary and v.Primary.Ammo or "smg1"
	end
end
function GM:PostPlayerDeath(ply)
	if IsValid(ply) then
		ply:Freeze(false)
		ply:SetGM("NextSpawnTime",CurTime() + 4)
		ply:SetGM("NextSpawnKey",ply:GetGM("NextSpawnTime"))
		ply:ResetWeapons()
	end
	self:CheckPlayState()
end
function GM:PlayerDisconnected(ply)
	self:CheckPlayState()
end
function GM:PlayerSpawn( ply )
	if ply:Team() == TEAM_SPECTATOR then
		ply:KillSilent(true)
		return
	end
	if ply:Team() == TEAM_UNASSIGNED then
		ply:SetTeam(TEAM_PRISIONER)
		self:CheckPlayState()
	end
	ply:UnSpectate()
	ply:StripWeapons()
	ply:ClearGM()
	ply:SetGM("DamageGet",{})
	ply:SetGM("DamageGiven",{})
	ply:ResetWeapons()
	ply:SetNoDraw(false)
	ply:GodDisable()
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)

	hook.Run( "PlayerSetModel", ply )
	hook.Run( "PlayerLoadout", ply )

	ply:SetupHands()
end
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	local arm = ply:Armor()
	if ( hitgroup == HITGROUP_HEAD ) then
		if arm > 65 then
			dmginfo:ScaleDamage(math.Rand(0.5,1.5))
			local effectdata = EffectData()
			effectdata:SetOrigin( dmginfo:GetDamagePosition() )
			local ang = ply:EyeAngles()
			ang.yaw = ang.yaw - 180
			effectdata:SetNormal( ang:Forward() )
			util.Effect( "headhit", effectdata, true, true )
		elseif arm > 0 then
			dmginfo:ScaleDamage(math.Rand(1.5,3))
		else
			dmginfo:ScaleDamage(math.Rand(3,4))
		end
	elseif (hitgroup == HITGROUP_STOMACH or hitgroup == HITGROUP_GENERIC) then
		if arm > 0 then
			dmginfo:ScaleDamage(math.Rand(0.7,0.9))
		else
			dmginfo:ScaleDamage(math.Rand(1,1.3))
		end
	elseif (hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM) then
		if arm > 0 then
			dmginfo:ScaleDamage(math.Rand(0.5,0.8))
		else
			dmginfo:ScaleDamage(math.Rand(0.6,0.9))
		end
	elseif (hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR ) then
		if arm > 0 then
			dmginfo:ScaleDamage(math.Rand(0.3,0.5))
		else
			dmginfo:ScaleDamage(math.Rand(0.5,0.7))
		end
	end
end
function GM:EntityTakeDamage( ent, dmginfo )
	if not ent:IsPlayer() and dmginfo:GetDamageBonus() > 0 then
		dmginfo:SetDamage( dmginfo:GetDamage() + dmginfo:GetDamageBonus() )
	end
end
function GM:HandleEntityDamage( vict, dmginfo )
	local dmg = dmginfo:GetDamage()
	local atk = dmginfo:GetAttacker()
	if vict:IsPlayer() then
		local dmg1 = math.Round(dmg)
		if dmg1 > 0 then
			local atkname = atk:IsPlayer() and atk:Nick() or atk:GetClass()
			local victdmg = vict:GetGM("DamageGet")[atkname]
			if victdmg then
				victdmg[1] = victdmg[1] + dmg1
				victdmg[2] = victdmg[2] + 1
			else
				vict:GetGM("DamageGet")[atkname] = {dmg1, 1}
			end
		end
		if IsValid(atk) and atk:IsPlayer() and atk:Alive() then
			local victname = vict:IsPlayer() and vict:Nick() or vict:GetClass()
			local atkdmg = atk:GetGM("DamageGiven")[victname]
			if atkdmg then
				atkdmg[1] = atkdmg[1] + dmg1
				atkdmg[2] = atkdmg[2] + 1
			else
				atk:GetGM("DamageGiven")[victname] = {dmg1, 1}
			end
		end
	end
end
-- https://github.com/VSES/SourceEngine2007/blob/43a5c90a5ada1e69ca044595383be67f40b33c61/src_main/game/shared/cstrike/weapon_csbase.cpp#L1564-L1567
function EnginePickupWeapon(ply,wep)
	wep:SetName("")
	ply:PickupWeapon(wep)
end
-- https://github.com/VSES/SourceEngine2007/blob/43a5c90a5ada1e69ca044595383be67f40b33c61/src_main/game/shared/takedamageinfo.cpp#L312-L324
GM.PostEntityTakeDamage = GM.HandleEntityDamage
function GM:PlayerUse( ply, ent )
	if not ply:Alive() then return false end
	--[[if IsValid(tr) and IsValid(tr.Entity) && (tr.Entity:GetClass() == "func_breakable" || tr.Entity:GetClass() == "func_breakable_surf") && tr.HitPos:Distance(tr.StartPos) < 50 then
		local dmg = DamageInfo()
		dmg:SetAttacker(game.GetWorld())
		dmg:SetInflictor(game.GetWorld())
		dmg:SetDamage(10)
		dmg:SetDamageType(DMG_BULLET)
		dmg:SetDamageForce(ply:GetAimVector() * 500)
		dmg:SetDamagePosition(tr.HitPos)
		tr.Entity:TakeDamageInfo(dmg)
	end]]
	if not IsValid(ent) or not ent:IsWeapon() then
		return true
	end
	if ply:GetGM("NextPickup",0) > CurTime() then
		return false
	end
	if ent.Kind then
		local slot = ent.Kind
		local rep = nil
		for k,v in pairs(ply:GetWeapons()) do
			if v.Kind == slot then
				rep = v
				break
			end
		end
		if rep ~= nil then
			ply:SetGM("NextPickup", CurTime() + 1)
			if rep:GetClass() == ent:GetClass() then
				return false
			end
			ply:DropWeapon(rep)
			if hook.Run("PlayerCanEquipWeapon", ply, ent ) then
				local p1,a1 = rep:GetPos(),rep:GetAngles()
				local pos,ang,mv,ph1,col = ent:GetPos(),ent:GetAngles(),ent:GetMoveType(),ent:GetPhysicsObject(),ent:GetCollisionGroup()
				rep:SetPos(pos)
				rep:SetAngles(ang)
				rep:SetCollisionGroup(col)
				rep:SetMoveType(mv)
				if IsValid(ph1) then
					local ph2 = rep:GetPhysicsObject()
					if IsValid(ph2) then
						ph2:SetVelocity(ph1:GetVelocity())
						ph2:Sleep()
						if ent:HasSpawnFlags(1) then
							local flags = rep:GetSpawnFlags()
							local newflags = bit.bor(flags, 1)
							rep:SetKeyValue("spawnflags", newflags)
							rep:Fire("SetParent","ConstraintPhysic")
							--[[local Constraint = ents.Create( "phys_constraint" )
							Constraint:SetPhysConstraintObjects(ph2, WorldPhy)
							Constraint:Spawn()
							Constraint:Activate()]]--
						end
					end
					ph1:SetVelocity(vector_origin)
					ph1:Sleep()
				end

				ply:SetGM("NextPickup", CurTime() + 1)
				ent.PickedUp = ply
				EnginePickupWeapon(ply,ent)
			else
				rep.PickedUp = ply
				EnginePickupWeapon(ply,rep)
			end
			return false
		end
	end
	if hook.Run("PlayerCanEquipWeapon", ply, ent ) then
		ply:SetGM("NextPickup", CurTime() + 1)
		EnginePickupWeapon(ply, ent)
	end
	return false
end
function GM:CanPickupAmmo(ply,ent)
	for k,v in pairs(ply.Weapons) do
		if self.AmmoTable[k] == ent.AmmoType then
			return true
		end
	end
end
function GM:WeaponEquip(wep,ply)
	ply.Weapons[wep:GetClass()] = wep
	if wep.Kind then
		ply.Slots[wep.Kind] = wep
		if wep.PickedUp then
			wep.PickedUp = nil
			ply:SetGM("SwitchWeapon", wep)
		elseif wep.Kind == 1 or wep.Kind == 2 then
			local cur = ply:GetActiveWeapon()
			if IsValid(cur) and cur.Weight and wep.Weight then
				if cur.Weight == 5 or wep.Weight > cur.Weight then
					ply:SetGM("SwitchWeapon",wep)
				end
			else
				ply:SetGM("SwitchWeapon",wep)
			end
		end
	end
	if wep:HasSpawnFlags(1) then
		local flags = wep:GetSpawnFlags()
		local nfl = bit.band(flags,bit.bnot(1))
		wep:SetKeyValue("spawnflags",nfl)
	end
	if wep:GetNW2Entity("RealOwner",NULL) == NULL then
		wep:SetNW2Entity("RealOwner",ply)
	end
end
function GM:PlayerDamagePlayer(victim,pl)
	return true
end
function GM:PlayerDroppedWeapon(ply,wep)
	ply.Weapons[wep:GetClass()] = nil
	if wep.Kind then
		ply.Slots[wep.Kind] = nil
	end
	wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end
function GM:EntityRemoved(ent)
	if ent:IsWeapon() then
		local o = ent:GetOwner()
		if o == NULL then
			o = ent.LastOwner
		end
		if IsValid(o) and o.Weapons then
			o.Weapons[ent:GetClass()] = nil
			if ent.Kind and o.Slots[ent.Kind] == ent then
				o.Slots[ent.Kind] = nil
			end
			if not IsValid(o:GetActiveWeapon()) then
				local w,v = next(o.Weapons)
				if w and IsValid(v) then
					o:SetGM("SwitchWeapon",v)
				end
			end
		end
	elseif ent:IsPlayer() then
		self:CheckPlayState()
	end
end
function GM:StartCommand(ply,cmd)
	if ply:Alive() then
		local wp = ply:GetGM("SwitchWeapon")
		if wp and IsValid(wp) then
			ply:SetGM("SwitchWeapon",nil)
			cmd:SelectWeapon(wp)
		end
	end
end
local function HasWeapon(ply,class)
	return ply.Weapons[class] ~= nil
end
function GM:PlayerCanEquipWeapon(ply,ent)
	if HasWeapon(ply,ent:GetClass()) then
		if ent.Primary and ent.Primary.ClipMax then
			local am = ent:GetPrimaryAmmoType()
			if ply:GetAmmoCount(am) < ent.Primary.ClipMax and ent:EquipAmmo(ply) then
				return true
			end
		end
		return false
	end
	local slot = ent.Kind
	if not slot then
		return true
	end
	if ply.Slots[slot] ~= nil then
		return false
	end
	return true
end
function SelectPlayer( ply, targ, dir )
	local plrs = {}
	for k,v in pairs(ply:Team() == TEAM_SPECTATOR and player.GetAll() or team.GetPlayers(ply:Team())) do
		if v:Alive() then
			plrs[#plrs + 1] = v
		end
	end
	if #plrs == 0 then return nil end
	if not IsValid(targ) or not targ:IsPlayer() then return plrs[1] end
	if dir then
		for k,v in pairs(plrs) do
			if v == targ then
				return select(2,next(plrs,k)) or plrs[1]
			end
		end
		return plrs[1]
	else
		local old
		for k,v in pairs(plrs) do
			if v == targ then
				return old or plrs[#plrs]
			end
			old = v
		end
		return plrs[#plrs]
	end
end
local SpecFuncs = {
	[IN_ATTACK] = function( ply )
		local targ = SelectPlayer( ply, ply:GetObserverTarget(), true )
		if IsValid(targ) then
			ply:Spectate( ply:GetGM("SpecMode") == OBS_MODE_CHASE and OBS_MODE_CHASE or OBS_MODE_IN_EYE )
			ply:SpectateEntity( targ )
		end
	end,
	[IN_ATTACK2] = function( ply )
		local targ = SelectPlayer( ply, ply:GetObserverTarget(), false )
		if IsValid(targ) then
			ply:Spectate( ply:GetGM("SpecMode") == OBS_MODE_CHASE and OBS_MODE_CHASE or OBS_MODE_IN_EYE )
			ply:SpectateEntity( targ )
		end
	end,
	[IN_RELOAD] = function( ply )
		if not IsValid(ply:GetObserverTarget()) then return end
		local mode = ply:GetGM("SpecMode")
		if not mode or mode == OBS_MODE_IN_EYE then
			mode = OBS_MODE_CHASE
		elseif mode == OBS_MODE_CHASE then
			mode = OBS_MODE_IN_EYE
		end
		ply:SetGM("SpecMode", mode)
		ply:Spectate( mode )
	end,
	[IN_JUMP] = function( ply )
		if ply:GetMoveType() ~= MOVETYPE_NOCLIP then
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end
	end,
	[IN_DUCK] = function( ply )
		local pos = ply:GetPos()
		local targ = ply:GetObserverTarget()
		if IsValid(targ) then
			pos = targ:GetPos()
		end
		ply:UnSpectate()
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetPos(pos)
	end
}
function PlayerSeeingEntity(ply,ent)
	local p1,p2,a = ply:EyePos(),ent:GetPos(),ply:EyeAngles()
	local a1 = (p2 - p1):Angle()
	a1:Normalize()
	if math.abs(a1.p - a.p) < 15 and math.abs(a1.y - a.y) < 15 then
		return true
	end
	return false
end
function GM:PlayerCanPickupWeapon( ply, ent )
	if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
		if ent:GetPos() == ply:GetPos() then
			return hook.Run("PlayerCanEquipWeapon", ply, ent, true ) -- its ply:Give func. i.e. internal give
		elseif ply:KeyDown(IN_USE) then
			self:PlayerUse(ply, ent)
		end
	end
	return false
end
--local mins,maxs = Vector(-10,-10,-10), Vector(10,10,10)
function GM:KeyPress( ply, key )
	--[[if ply:Alive() then
		if key == IN_USE then
			local tr = util.TraceEntity({start = ply:EyePos(),endpos = ply:OBBCenter() + ply:GetAimVector() * 100}, ply)
			print(tr.Entity)
			if IsValid(tr.Entity) then
				self:PlayerUse(ply,tr.Entity)
			end
		end
	else]]
	if not ply:Alive() and SpecFuncs[key] and (not ply:GetGM("NextSpawnKey") or ply:GetGM("NextSpawnKey") < CurTime()) then
		ply:SetGM("NextSpawnKey",CurTime() + 1)
		SpecFuncs[key](ply)
	end
end
function GM:CanDropWeapon(ply,wep)
	return self.NoDropable[wep:GetClass()] == nil
end
function GM:InitPostEntityAndMapCleanup()
	if not self.JailTriggers then
		local cuc = self.OpenJails[game.GetMap()]
		if cuc then
			self.JailTriggers = {}
			for _, trig in pairs(cuc) do
				self.JailTriggers[trig] = true
			end
			self.AcceptInput = function(self1,ent,input,activator,caller,value)
				if self1.JailTriggers[ent:GetName()] then
					if input == "Open" or input == "Enable" then
						self1.Opened = true
						SetGMBool("JB_Jails",true)
					elseif input == "Close" or input == "Disable" then
						self1.Opened = false
						SetGMBool("JB_Jails",false)
					end
				end
			end
		else
			self.JailTriggers = {}
		end
	end
	local jent,is = {{},{}},false
	local cl,spwns = "",{{},{},{}}
	for _, ent in pairs(ents.GetAll()) do
		if not ent:IsPlayer() and self.JailTriggers[ent:GetName()] then
			table.insert(jent[ent:GetClass() == "func_brush" and 1 or 2],ent)
			is = true
		end
		cl = ent:GetClass()
		if cl == "info_player_counterterrorist" then
			table.insert(spwns[1],ent)
		elseif cl == "info_player_terrorist" then
			table.insert(spwns[2],ent)
		elseif cl == "info_player_start" then
			table.insert(spwns[3],ent)
		elseif cl == "prop_ragdoll" then
			ent:Remove()
		elseif cl == "func_door" or cl == "func_door_rotating" or cl == "prop_door_rotating" then
			ent:Fire("unlock","",0)
		elseif ent:IsWeapon() then
			if ent:HasSpawnFlags(1) then
				ent:SetMoveType(MOVETYPE_NONE)
				ent:SetPos(ent:GetPos() + ent:GetAngles():Forward() * ent:OBBMaxs():Length2D() * .5)
				ent:Fire("SetParent","ConstraintPhysic")
			end
		end
	end
	self.ConstraintPhysic = ents.Create("phys_constraintsystem")
	self.ConstraintPhysic:SetName("ConstraintPhysic")
	if #spwns[1] == 0 then
		spwns[1] = spwns[3]
	end
	if #spwns[2] == 0 then
		spwns[2] = spwns[3]
	end
	if is then
		self.JailEntities = jent
	end
	self.Spawns = spwns
end
function GM:PlayerSetModel( ply )
	local mdl, female, pteam = nil, ply:GetGM("Female"), ply:Team()
	if pteam == TEAM_GUARD or pteam == TEAM_ATTACKER then
		if female then
			mdl = table.Random(self.CTModels[2])
		else
			mdl = table.Random(self.CTModels[1])
		end
	elseif pteam == TEAM_PRISIONER or pteam == TEAM_DEFENDER then
		if female then
			mdl = table.Random(self.TModels[2])
		else
			mdl = table.Random(self.TModels[1])
		end
	end
	if mdl then
		util.PrecacheModel(mdl)
		ply:SetModel(mdl)
		ply:SetGM("OriginalModel",mdl)
	end
end
function GM:PlayerLoadout( ply )
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(300)
	ply:SetCrouchedWalkSpeed(0.4)
	ply:SetGravity(0)
	ply:StripAmmo()
	ply:SetMaxHealth(100)
	ply:SetHealth(ply:GetMaxHealth())
	ply:SetNoCollideWithTeammates( true )
	ply:SetPlayerColor(ply.CustomPlayerColor or Vector(math.Rand(0,1),math.Rand(0,1),math.Rand(0,1)))
	ply:SetGM("DefaultColor",ply:GetPlayerColor())
	ply:SetJumpPower(190)

	local wep = ply:Give( "weapon_fist" )
	ply:SetGM( "SwitchWeapon", wep )
end
function GM:CanBe(ply, tem)
	if tem == TEAM_GUARD then
		if type(ply.demoted) == "number" then
			return false
		end
		local cts,ts = #team.GetPlayers(TEAM_GUARD),#team.GetPlayers(TEAM_PRISIONER)
		if ply:Team() == TEAM_GUARD then
			cts = cts - 1
		elseif ply:Team() == TEAM_PRISIONER then
			ts = ts - 1
		end
		local num = math.ceil(ts / GAMEMODE.TCT)
		if num == 0 or cts < num then
			return true
		else
			return false
		end
	elseif tem == TEAM_PRISIONER then
		return true
	elseif tem == TEAM_SPECTATOR then
		if ply:IsAdmin() then
			return true
		end
		return false
	end
end
function GM:PlayerChangeTeam( v )
	if v:Team() == TEAM_PRISIONER then
		v:SetTeam(TEAM_GUARD)
	elseif v:Team() == TEAM_GUARD then
		v:SetTeam(TEAM_PRISIONER)
	end
	if v:Alive() then
		v:RSpawn()
	end
	self:CheckPlayState()
end
GM.InitPostEntity = GM.InitPostEntityAndMapCleanup
GM.PostCleanupMap = GM.InitPostEntityAndMapCleanup
function GM:Explosion(pos,own,power)
	local explode = ents.Create( "env_explosion" )
	explode:SetPos( pos )
	explode:SetOwner( own or Entity(0) )
	explode:Spawn()
	power = power or 220
	explode:SetKeyValue( "iMagnitude", power )
	explode:Fire( "Explode", 0, 0 )
	explode:EmitSound( "weapon_AWP.Single", power, power )
end
function GM:PlayerKilledByPlayer(ply,inf,atk)
	return true
end
function GM:PlayerDeath(ply,atk,inf)
end
function GM:DoPlayerDeath( ply, attacker, dmginfo )
	ply:CreateRagdoll()
	local e,dr,wp = ply:GetRagdollEntity(),0,NULL
	for k, weapon in pairs(ply:GetWeapons()) do
		wp = weapon:GetClass()
		if hook.Run("CanDropWeapon",ply,weapon) then
			if self.GrenadesKV[wp] then -- TODO: Jailbreak func
				if dr == 1 then
					continue
				end
				dr = dr + 1
			end
			ply:DropWeapon(weapon)
			local phys = weapon:GetPhysicsObject() -- from TTT DampenDrop
			if IsValid(phys) then
				phys:SetVelocityInstantaneous(Vector(0,0,-75) + phys:GetVelocity() * 0.001)
				phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
			end
		end
	end
	ply:StripWeapons()

	if IsValid(e) then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(e)
	else
		ply:Spectate(OBS_MODE_CHASE)
	end
	self:TimerSimple(math.Rand(3,5),function()
		if IsValid(ply) and not ply:Alive() then
			if IsValid(e) and ply:GetObserverTarget() == e and ply:GetObserverMode(OBS_MODE_IN_EYE) then
				if self:GetRound() ~= Round_End and IsValid(attacker) then
					if attacker ~= ply and attacker:IsPlayer() then
						ply:Spectate(OBS_MODE_IN_EYE)
						ply:SpectateEntity(attacker)
					else
						ply:Spectate(OBS_MODE_CHASE)
					end
				else
					ply:Spectate(OBS_MODE_CHASE)
				end
			else
				ply:Spectate(OBS_MODE_CHASE)
			end
		end
	end)
	for k, v in pairs(player.GetAll()) do
		if ply == v then continue end
		local typ = v:GetObserverMode()
		if typ ~= OBS_MODE_ROAMING then
			local ob = v:GetObserverTarget()
			if IsValid(ob) and ob == ply then
				v:Spectate(OBS_MODE_CHASE)
				v:SpectateEntity(e)
			end
		end
	end

	if ply:LastHitGroup() == HITGROUP_HEAD then
		local effectdata = EffectData()
		effectdata:SetOrigin(dmginfo:GetDamagePosition())
		local force = dmginfo:GetDamageForce()
		effectdata:SetMagnitude(force:Length() * 3)
		effectdata:SetNormal(force:GetNormalized())
		effectdata:SetEntity(ply)
		util.Effect("headshot", effectdata, true, true)
	end

	ply:AddDeaths(1)
	if attacker:IsValid() and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end

	net.Start("KilledBy")
	if IsValid(attacker) then
		self:HandleEntityDamage( ply, dmginfo )
		if attacker:IsPlayer() then
			if attacker ~= ply then
				net.WriteEntity(attacker)
				net.WriteEntity(dmginfo:GetInflictor())
			else
				net.WriteEntity(ply)
				net.WriteEntity(dmginfo:GetInflictor())
			end
		else
			net.WriteEntity(NULL)
			net.WriteEntity(dmginfo:GetInflictor())
		end
	else
		net.WriteEntity(NULL)
		net.WriteEntity(dmginfo:GetInflictor())
	end
	net.WriteTable(ply:GetGM("DamageGet"))
	net.WriteTable(ply:GetGM("DamageGiven"))
	net.Send(ply)

	local inflictor = dmginfo:GetInflictor()
	if IsValid( attacker ) then
		if attacker:GetClass() == "trigger_hurt" then
			attacker = ply
		elseif attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
			attacker = attacker:GetDriver()
		end
		if not IsValid(inflictor) then
			inflictor = attacker
		end
		if attacker == ply then
			net.Start( "PlayerKilled" )
				net.WriteUInt(0,2)
				net.WriteEntity( ply )
			net.Broadcast()
			MsgAll( attacker:Nick() .. " умер.\n" )
			return
		end
		if IsValid( inflictor ) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
			inflictor = inflictor:GetActiveWeapon()
			if not IsValid( inflictor ) then
				inflictor = attacker
			end
		end
		if ( attacker:IsPlayer() ) then
			local bl,pl,inf,atk,msg = hook.Run("PlayerKilledByPlayer",ply,inflictor,attacker)
			if bl then
				pl = pl or ply:Nick()
				atk = atk or attacker:Nick()
			else
				return
			end
			local head, wall = ply:LastHitGroup() == HITGROUP_HEAD, bit.band(dmginfo:GetDamageType(), DMG_BUCKSHOT) == DMG_BUCKSHOT
			ConsoleMsg( msg or _T("PlayerKilledPlayer", attacker:CNick(), colour_notify, ply:CNick(), colour_notify, {colour_weapon, inf or inflictor.PrintName or inflictor:GetClass()}, colour_notify, head, wall) )
			net.Start( "PlayerKilled" )
				--if bl then
					net.WriteUInt(1,2)
					net.WriteString( pl )
					net.WriteUInt(ply:Team(), 4)
					net.WriteString( inf or inflictor:GetClass() )
					net.WriteString( atk )
					net.WriteUInt(attacker:Team(), 4)
				--[[else
					net.WriteUInt(2,2)
					net.WriteEntity(ply)
					net.WriteString(inf)
					net.WriteEntity(attacker)
				end]]
				net.WriteBool(head)
				net.WriteBool(wall)
			net.Broadcast()
			return
		end
	end
	net.Start( "PlayerKilled" )
		net.WriteUInt(3,2)
		net.WriteEntity( ply )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )
	net.Broadcast()
	ConsoleMsg( _T("KilledByEntity", ply:Nick(), attacker:GetClass()) )
end
function GM:PlayerSelectSpawn( ply )
	local pos = self:SelectSpawn(ply)
	if pos then
		return pos
	else
		return self.Spawns[3][math.random(1,#self.Spawns[3])]
	end
end
function GM:CanPlayerSuicide(p)
	if p:Alive() and not p:IsFrozen() then
		return true
	end
	return false
end
local fv = 100 / 396
function GM:GetFallDamage(ply, fallSpeed)
	ply:ViewPunch( Angle(math.Rand(2.0, 2.25), 0.1, 0) )
	return (fallSpeed-526.5) * fv
end
function GM:PlayerDeathSound()
	return true
end
function GM:PlayerCanSpawn(ply)
	return self:GetRound() < Round_In
end
function GM:CanRespawn(ply)
	if ply:Team() ~= TEAM_SPECTATOR and hook.Run("PlayerCanSpawn",ply) then
		if ply:GetGM("NextSpawnTime") and ply:GetGM("NextSpawnTime") > CurTime() then
			return false
		end
		if ply:KeyPressed( IN_ATTACK ) or ply:KeyPressed( IN_ATTACK2 ) or ply:KeyPressed( IN_JUMP ) then
			return true
		end
	end
	return false
end
function GM:PlayerDeathThink(ply)
	if self:CanRespawn(ply) then
		ply:Spawn()
	end
end
function GM:PlayerShouldTakeDamage( victim, pl )
	if self:GetRound() ~= Round_In then return true end
	if IsValid(pl) and IsValid(victim) and pl:IsPlayer() then
		if victim == pl then return true end
		return hook.Run("PlayerDamagePlayer",victim,pl)
	end
	return true
end
function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
	if not IsValid(speaker) then return true end
	local tm, tm1 = listener:Team(), speaker:Team()
	if tm == TEAM_SPECTATOR or tm1 == TEAM_SPECTATOR then return true end
	if self:GetRound() ~= Round_In then return true end
	local al, al1 = listener:Alive(), speaker:Alive()
	if al1 == al or (al1 and not al) then
		if teamOnly then return tm == tm1 end
		return true
	end
	return false
end
function GM:PlayerTick(v,mv)
	local ct = CurTime()
	if v:Alive() then
		if v:WaterLevel() >= 3 then
			if v:GetGM("DrownTime") and v:GetGM("Zombie") == nil then
				if v:GetGM("DrownTime") <= ct then
					local dmg = DamageInfo()
					dmg:SetDamageType(DMG_DROWN)
					dmg:SetDamage( math.Rand(7,14) )
					dmg:SetAttacker( game.GetWorld() )
					v:SetGM("DrownDamage",v:GetGM("DrownDamage",0) + dmg:GetDamage())
					dmg:SetDamageForce( Vector( math.Rand(-5,5), math.Rand(-2,3), math.Rand(-10,9) ) )
					v:TakeDamageInfo(dmg)
					PlaySingleSound(v,"player/pl_drown" .. math.random(1,3) .. ".wav")
					v:SetGM("DrownTime", ct + math.Rand(1,3))
				end
			else
				v:SetGM("DrownTime", ct + math.Rand(12,15))
			end
		else
			if v:GetGM("DrownDamage") and v:GetGM("DrownBack",0) <= ct then
				v:SetGM("DrownBack",ct + math.Rand(1,3))
				local hp = v:GetGM("DrownDamage")
				local dmg = math.min(math.Rand(7,14),hp)
				if dmg == hp then
					v:SetGM("DrownDamage", nil)
					v:SetGM("DrownBack", nil)
				else
					v:SetGM("DrownDamage",hp - dmg)
				end
				v:SetHealth(math.min(v:Health() + dmg,v:GetMaxHealth()))
			end
			v:SetGM("DrownTime",nil)
		end
	else
		local targ = v:GetObserverTarget()
		if IsValid(targ) and v:GetGM("NextSpawnKey",ct) < ct then
			v:SetPos(targ:GetPos())
		end
	end
end
function GM:CheckPlayState()
	local b,t1,t2
	if self:GetRound() == Round_In then
		b,t1,t2 = hook.Run("CountPlayers")
	end
	if not b then
		local cts,ts
		if t1 and t2 then
			cts,ts = team.GetPlayers(t1),team.GetPlayers(t2)
		else
			cts,ts = team.GetPlayers(TEAM_GUARD),team.GetPlayers(TEAM_PRISIONER)
		end
		local ccts,tss = #cts,#ts
		if ccts == 0 or tss == 0 then
			if self:GetRound() ~= Round_Wait then
				self:SetRound(Round_Wait)
				self:SetRoundTime(0)
				self:SetGamemode("PvP")
			end
			return
		end
		if self:GetRound() == Round_Wait then
			self:SetRound( Round_Start )
		end
	end
end
function GM:SelectSpawn(ply)
	local t = ply:Team()
	if t == TEAM_GUARD or t == TEAM_DEFENDER then
		if self.Spawns[1] then
			return self.Spawns[1][math.random(1,#self.Spawns[1])]
		end
	elseif t == TEAM_PRISIONER or t == TEAM_ATTACKER then
		if self.Spawns[2] then
			return self.Spawns[2][math.random(1,#self.Spawns[2])]
		end
	end
	return false
end
function GM:PlayerInitialSpawn( ply )
	self:PrePlayerInitialize(ply)
	ply:ResetWeapons()
	ply:SetTeam(TEAM_PRISIONER)
	self:TimerSimple(0,function()
		if IsValid(ply) then
			ply:KillSilent()
		end
		if GAMEMODE:GetRound() < Round_In then
			ply:Spawn()
		end
	end)
	--[[if ply:IsBot() then
		local num=math.ceil((team.GetCount(TEAM_PRISIONER))/GAMEMODE.TCT)
		if team.GetCount(TEAM_GUARD)<num and num>0 or num<1 and team.GetCount(TEAM_PRISIONER)>0 and team.GetCount(TEAM_GUARD)== 0 then
			ply:SetTeam(TEAM_GUARD)
			if GAMEMODE:GetRound()<Round_In then
				ply:Spawn(true)
			end
		else
			ply:SetTeam(TEAM_PRISIONER)
			if GAMEMODE:GetRound()<Round_In then
				ply:RSpawn(true)
			end
		end
	end]]
	self:CheckPlayState()
end