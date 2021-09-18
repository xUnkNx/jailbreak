util.AddNetworkString("SoundChannel")
util.AddNetworkString("TextChannel")
util.AddNetworkString("GlobalChannel")
util.AddNetworkString("EntityChannel")
function PlaySurfaceSound( path , arg1 )
	net.Start("SoundChannel")
	net.WriteUInt(arg1 or 0,3)
	net.WriteString(path)
	net.Broadcast()
end
function PlaySingleSound( ply, path, arg1 )
	net.Start("SoundChannel")
	net.WriteUInt(arg1 or 0,3)
	net.WriteString(path)
	net.Send(ply)
end
local function sWrite(v)
	local tp = TypeID(v)
	if tp == TYPE_NUMBER then
		net.WriteUInt(1,3)
		net.WriteUInt(v,8)
		--print(":SEND NUMBER",v)
	elseif tp == TYPE_TABLE then
		if IsSharedColor(v) then
			net.WriteUInt(2,3)
			net.WriteUInt(v.id,8)
			--print(":SEND SHARED COLOR", v)
		elseif IsColor(v) then
			net.WriteUInt(3,3)
			net.WriteUInt(v.r,8)
			net.WriteUInt(v.g,8)
			net.WriteUInt(v.b,8)
			--print(":SEND COLOR",v)
		else
			net.WriteUInt(4,3)
			--print(":START SEND TABLE",v)
			for _, k in pairs(v) do
				sWrite(k)
			end
			--print(":END SEND TABLE",v)
			net.WriteUInt(0,3)
		end
	elseif tp == TYPE_STRING then
		net.WriteUInt(5,3)
		net.WriteString(v)
		--print(":SEND STRING",v)
	elseif tp == TYPE_BOOL then
		net.WriteUInt(6,3)
		net.WriteBool(v)
		--print(":SEND BOOLEAN",v)
	end
end
local function sMsg(tp,to,...)
	net.Start("TextChannel")
	net.WriteUInt(tp,2)
	for _, v in pairs({...}) do
		sWrite(v)
	end
	net.WriteUInt(0,3)
	net.Send(to)
end
function LocalMsg(ply,...)
	sMsg(0,ply,...)
end
function GlobalMsg(...)
	sMsg(0,player.GetAll(),...)
end
function PInfoMsg(ply,...)
	sMsg(1,ply,...)
end
function InfoMsg(...)
	sMsg(1,player.GetAll(),...)
end
function ConsoleMsg(...)
	sMsg(2,player.GetAll(),...)
end
function PConsoleMsg(ply,...)
	sMsg(2,ply,...)
end
function net.WriteNumber(v)
	local a,b = math.modf(v)
	if b ~= 0 then
		net.WriteBool(false)
		net.WriteInt(v,16)
	else
		net.WriteBool(true)
		net.WriteFloat(v)
	end
end
OQueue = OQueue or {}
local function QueueValue(id, s, vr, to)
	OQueue[#OQueue + 1] = {id, s, vr, to}
end
local types = {"Angle","Bool","Entity","Number","String","Vector"}
for k,v in pairs(types) do
	_G["GetGM" .. v] = function(s,d)
		return GMGlobals[s] or d
	end
	_G["SetGM" .. v] = function(s,vr,force)
		if not force and GMGlobals[s] == vr then
			return
		end
		GMGlobals[s] = vr
		QueueValue(0, s, vr)
	end
end
_G.GetGMInt,_G.GetGMFloat,_G.SetGMInt,_G.SetGMFloat = _G.GetGMNumber,_G.GetGMNumber,_G.SetGMNumber,_G.SetGMNumber
function _G.SetGMNil(s)
	if not force and GMGlobals[s] == nil then
		return
	end
	GMGlobals[s] = nil
	QueueValue(0, s, nil)
end
function SetGlobal(nm,var)
	GMGlobals[nm] = var
end
function _G.GetGMTable(s)
	local vr = GMGlobals[s]
	if not vr then
		vr = {}
		GMGlobals[s] = vr
	end
	return vr
end
local next,pairs,IsValid = next,pairs,IsValid
hook.Add("Tick","Networking",function()
	local i,m = next(OQueue)
	if i ~= nil then
		OQueue[i] = nil
		net.Start("GlobalChannel")
			net.WriteUInt(0, 2)
			net.WriteUInt(m[1], 16)
			net.WriteString(m[2])
			net.WriteType(m[3])
		if m[4] then
			net.Send(m[4])
		else
			net.Broadcast()
		end
	end
end)
hook.Add("PlayerFullLoad","NW3",function(ply)
	net.Start("GlobalChannel")
		net.WriteUInt(1, 2)
		net.WriteUInt(0, 16)
		net.WriteTable(GMGlobals)
	net.Send(ply)
	for k,v in pairs(player.GetAll()) do
		if v == ply then continue end
		if v.NWVars and next(v.NWVars) ~= nil then
			net.Start("GlobalChannel")
				net.WriteUInt(1, 2)
				net.WriteUInt(v:EntIndex(), 16)
				net.WriteTable(v.NWVars)
			net.Send(ply)
		end
	end
end)
--==Other==--
util.AddNetworkString("SelectTeam")
util.AddNetworkString("KilledBy")
util.AddNetworkString("CMDNET")
net.Receive("SelectTeam", function(length, ply)
	local numb = net.ReadUInt(4)
	if numb == 1 then
		if ply:Team() ~= TEAM_GUARD then
			if type(ply.demoted) == "number" then
				LocalMsg(ply,colour_warn, _T("Balance","YouDemoted"))
				return
			end
			if hook.Run("PlayerCanJoinTeam", ply, TEAM_GUARD) then
				ply:KillSilent()
				ply:SetTeam(TEAM_GUARD)
				if GAMEMODE:GetRound() < Round_In then
					ply:Spawn()
				end
				GAMEMODE:CheckPlayState()
			else
				LocalMsg(ply, "SND:warn", colour_warn, { _T("Balance", colour_notify), _T("MuchGuards", colour_warn) })
			end
		end
	elseif numb == 2 then
		if ply:Team() == TEAM_PRISIONER then
			LocalMsg(ply, colour_warn, _T("NotT"))
			return
		end
		ply:SetTeam(TEAM_PRISIONER)
		ply:KillSilent()
		if GAMEMODE:GetRound() < Round_In then
			ply:Spawn()
		end
		GAMEMODE:CheckPlayState()
	elseif numb == 3 then
		if not ply:IsAdmin() then
			LocalMsg(ply,colour_warn, _T("AdminOnly"))
			return
		end
		ply:SetTeam(TEAM_SPECTATOR)
		ply:RSpawn()
		GAMEMODE:CheckPlayState()
	end
end)
net.Receive("CMDNET", function(length, ply)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and hook.Run("CanDropWeapon",ply,wep) then
		ply:DropWeapon(wep)
	end
end)
--==Player==--
local PlayMeta = FindMetaTable( "Player" )
PlayMeta.oldSpectateEntity = PlayMeta.oldSpectateEntity or PlayMeta.SpectateEntity
function PlayMeta:SpectateEntity(ent)
	self:oldSpectateEntity(ent)
	if IsValid(ent) and ent:IsPlayer() then
		self:SetupHands(ent)
		local hands = self:GetHands()
		if IsValid(hands) then
			hands:SetOwner(ent)
		end
	end
end
local oldUnSpectate = oldUnSpectate or PlayMeta.UnSpectate
function PlayMeta:UnSpectate()
	oldUnSpectate(self)
	local hands = self:GetHands()
	if IsValid(hands) then
		hands:SetOwner(self)
	end
end
function PlayMeta:RSpawn()
	if self:Alive() then
		self:KillSilent()
	end
	GAMEMODE:TimerSimple(0,function()
		if IsValid(self) then
			self:Spawn()
		end
	end)
end
function PlayMeta:ResetWeapons()
	self.Weapons = {}
	self.Slots = {}
end
PlayMeta.OldStripWeapons = PlayMeta.OldStripWeapons or PlayMeta.StripWeapons
function PlayMeta:StripWeapons()
	self:ResetWeapons()
	return self.OldStripWeapons(self)
end
function PlayMeta:CNick()
	return {team.GetColor(self:Team()),self:Nick()}
end
function GM:PrePlayerInitialize(ply)
	ply.GMVars = {}
	ply.SHVars = {}
	hook.Add( "SetupMove", ply, function( self, ply, _, cmd )
		if self == ply and not cmd:IsForced() then
			hook.Remove( "SetupMove", self )
			hook.Run( "PlayerFullLoad", self )
		end
	end )
end
function PlayMeta:SetGM(var,val)
	self.GMVars[var] = val
end
function PlayMeta:SetNW(var, val, plrs)
	if self.SHVars[var] ~= val then
		self.SHVars[var] = val
		QueueValue(self:EntIndex(), var, val, plrs)
	end
end
function PlayMeta:ClearGM()
	self.GMVars = {}
	self.SHVars = {}
end
function PlayMeta:GetGM(var,def,sync)
	return self.GMVars[var] or def
end
function PlayMeta:GetNW(var,def)
	return self.SHVars[var] or def
end
concommand.Add("jb_teamchat",function(ply,args)
	ply:SetTeamVoice(args[1] == 1 or false)
end)
function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

local pentime = 30
local mt = FindMetaTable"CMoveData"
local SysTime,Origin,Angles,Buttons = SysTime,mt.GetOrigin,mt.GetAngles,mt.GetButtons
hook.Add("PlayerTick","AFK",function(ply,mv)
	if not ply:Alive() then return end
	local afkt = ply.AFKT
	if afkt == nil then
		ply.AFKT = { Origin(mv), Angles(mv), Buttons(mv) }
	else
		local origin, angles, buttons = Origin(mv), Angles(mv), Buttons(mv)
		if (afkt[1] ~= origin or afkt[2] ~= angles) and afkt[3] ~= buttons then
			if ply.AFK then
				ply.AFK = nil
				if ply.IsAFK then
					ply.IsAFK = false
					hook.Run("PlayerChangePlayState", ply, false)
				end
			end
		else
			if ply.AFK == nil then
				ply.AFK = SysTime()
			else
				if SysTime() - ply.AFK > pentime and not ply.IsAFK then
					ply.IsAFK = true
					hook.Run("PlayerChangePlayState", ply, true)
				end
			end
		end
		afkt[1] = Origin(mv)
		afkt[2] = Angles(mv)
		afkt[3] = Buttons(mv)
	end
end)
hook.Add("PlayerSpawn","AFK",function(ply)
	hook.Run("PlayerChangePlayState", ply, ply.IsAFK)
end)