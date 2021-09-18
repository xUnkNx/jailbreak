
--[[local pmeta = FindMetaTable("Player")
eyepos = eyepos or pmeta.EyePos
function pmeta:EyePos()
	return self:GetAttachment(self:LookupAttachment("eyes")).Pos
end]]
if true then return end
module("Legs",package.seeall)
if IsValid(LegEnt) then
	LegEnt:Remove()
end
LegEnt,LP,EnabledVar = nil,LocalPlayer(),CreateConVar( "cl_legs", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the legs" )
local GetViewEntity,pairs,IsValid = GetViewEntity,pairs,IsValid
function ShouldDrawLegs()
	return EnabledVar:GetBool() and LegEnt and LP:Alive() and GetViewEntity() == LP and
			not LP:ShouldDrawLocalPlayer() and
			LP:GetObserverTarget() == NULL
end
function GetPlayerLegs( ply )
	return ply and ply ~= LP and ply or (ShouldDrawLegs() and LegEnt or LP)
end
function GetTranslatedModel(self)
	return string.Replace(self:GetModel(),"models/humans/","models/")
end
function SetProperties( self, ent )
	if not IsValid( ent ) then return end
	ent.GetPlayerColor = function() return self:GetPlayerColor() end
	ent:SetMaterial( self:GetMaterial() )
	ent:SetSkin( self:GetSkin() )
	for i = 0,self:GetNumBodyGroups() do
		ent:SetBodygroup(i,self:GetBodygroup(i))
	end
end
local vector_origin = Vector(0,0,0)
local function CollapseScale(ent, boneid, pos)
	local bones = ent:GetChildBones(boneid)
	if next(bones) ~= nil then
		for k,v in pairs(bones) do
			local vm1 = ent:GetBoneMatrix(v)
			CollapseScale(ent, v, pos)
			vm1:SetTranslation(pos)
			vm1:SetScale(vector_origin)
			ent:SetBoneMatrix(v, vm1)
		end
	end
	local vm = ent:GetBoneMatrix(boneid)
	return vm:GetTranslation()
end
local function CollapseBones(ent, bones)
	for k,v in pairs(bones) do
		local boneid = ent:LookupBone(v)
		if boneid then
			local vm = ent:GetBoneMatrix(boneid)
			if vm then
				CollapseScale(ent,boneid,vm:GetTranslation())
			end
		end
	end
end
local function Collapse(ent)
	if ent.HoldType == "normal" then
		CollapseBones(ent,{"ValveBiped.Bip01_Neck1"})
	else
		CollapseBones(ent,{"ValveBiped.Bip01_Neck1","ValveBiped.Bip01_L_UpperArm","ValveBiped.Bip01_R_UpperArm"})
	end
end
function Legs:SetUp()
	self.LegEnt = ClientsideModel( GetTranslatedModel(LP), RENDER_GROUP_OPAQUE_ENTITY )
	self.LegEnt.LastTick = 0
	self.LegEnt:DrawShadow(true)
	SetProperties( LP, self.LegEnt )
	self.LegEnt:SetNoDraw(true)
	self.LegEnt:SetupBones()
	self.LegEnt:InvalidateBoneCache()
	self.LegEnt:AddCallback("BuildBonePositions",Collapse)
end
hook.Add("InitPostEntity","Legs:InitLP", function() LP = LocalPlayer() end)

PlaybackRate,Sequence,Velocity,OldWeapon,HoldType = 1,nil,0,nil,nil
BreathScale,NextBreath = 0.5,0
function Legs:Think( maxseqgroundspeed )
	local leg = self.LegEnt
	if leg then
		local mdl = GetTranslatedModel(LP)
		if leg:GetModel() ~= mdl then
			leg:Remove()
			Legs:SetUp()
			return
		end
		--LegEnt:SetPos(LP:GetPos())
		--LegEnt:SetAngles(Angle(0,LP:GetAngles().y,0))
		local wep = LP:GetActiveWeapon()
		if wep ~= NULL and leg.HoldType ~= wep:GetHoldType() then
			leg.HoldType = wep:GetHoldType()
			leg:SetupBones()
		end
		leg:SetMaterial( LP:GetMaterial() )
		leg:SetSkin( LP:GetSkin() )
		for _, group in pairs(LP:GetBodyGroups()) do
			leg:SetBodygroup(group["id"], LP:GetBodygroup(group["id"]))
		end
		leg:SetPlaybackRate(LP:GetPlaybackRate())
		self.Sequence = LP:GetSequence()
		if leg.Anim ~= self.Sequence then
			leg.Anim = self.Sequence
			leg:ResetSequence( self.Sequence )
		end
		local ct = CurTime()
		leg:FrameAdvance(ct - leg.LastTick )
		leg.LastTick = ct
		leg:SetPoseParameter( "breathing", LP:GetPoseParameter("breathing") )
		leg:SetPoseParameter( "move_x", (LP:GetPoseParameter( "move_x" ) * 2 ) - 1 )
		leg:SetPoseParameter( "move_y", (LP:GetPoseParameter( "move_y" ) * 2 ) - 1 )
		leg:SetPoseParameter( "move_yaw", (LP:GetPoseParameter( "move_yaw" ) * 360 ) - 180 )
		leg:SetPoseParameter( "body_yaw", (LP:GetPoseParameter( "body_yaw" ) * 180 ) - 90 )
		leg:SetPoseParameter( "spine_yaw",(LP:GetPoseParameter( "spine_yaw" ) * 180 ) - 90 )
		if LP:InVehicle() then
			leg:SetColor( color_transparent )
			leg:SetRenderMode( RENDERMODE_TRANSALPHA )
			leg:SetPoseParameter( "vehicle_steer", (LP:GetVehicle():GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 )
		end
	end
end
hook.Add( "UpdateAnimation", "Legs:UpdateAnimation", function( ply, velocity, maxseqgroundspeed )
	if ply == LP then
		if IsValid( LegEnt ) then
			Legs:Think( maxseqgroundspeed )
		else
			Legs:SetUp()
		end
	end
end)
-- from https://github.com/elizagamedev/gmod-enhanced-camera/blob/master/lua/autorun/client/enhanced_camera.lua#L334-L356
function Legs:GetOffset()
	local leg = self.LegEnt
	if leg.HoldType == "normal" or leg.HoldType == "camera" or leg.HoldType == "fist" or
		leg.HoldType == "dual" or leg.HoldType == "passive" or leg.HoldType == "magic" then
		offset = Vector(-10, 0, -5)
	elseif leg.HoldType == "melee" or leg.HoldType == "melee2" or
		leg.HoldType == "grenade" or leg.HoldType == "slam" then
		offset = Vector(-10, 0, -5)
	elseif leg.HoldType == "knife" then
		offset = Vector(-6, 0, -5)
	elseif leg.HoldType == "pistol" or leg.HoldType == "revolver" then
		offset = Vector(-10, 0, -5)
	elseif leg.HoldType == "smg" or leg.HoldType == "ar2" or leg.HoldType == "rpg" or
		leg.HoldType == "shotgun" or leg.HoldType == "crossbow" or leg.HoldType == "physgun" then
		offset = Vector(-10, 4, -5)
	else
		offset = Vector(0, 0, 0)
	end
	return offset
end
local RenderAngle,RenderPos,RenderColor = nil,nil,{}
local EyePos,EyeAngles,Angle = EyePos,EyeAngles,Angle
hook.Add( "PreDrawEffects", "Legs:Render", function()
	--cam.Start3D(EyePos(),EyeAngles())
		if ShouldDrawLegs() then
			RenderPos = LP:GetPos()
			if LP:InVehicle() then
				RenderAngle = LP:GetVehicle():GetAngles()
				RenderAngle:RotateAroundAxis( RenderAngle:Up(), 90 )
			else
				RenderAngle = Angle(0, EyeAngles().y, 0)
				if LP:GetGroundEntity() == NULL then
					RenderPos.z = RenderPos.z
					if LP:KeyDown( IN_DUCK ) then
						RenderPos.z = RenderPos.z
					end
				end
				local off = Legs:GetOffset()
				off:Rotate(RenderAngle)
				RenderPos = RenderPos
			end
			--[[local clippos, clipbone = nil, LP:LookupBone("ValveBiped.Bip01_Spine")
			if clipbone then
				local clipbone = LP:GetBoneMatrix(clipbone)
				if clipbone then
					clippos = clipbone:GetTranslation()
				end
			end
			if clippos == nil then
				clippos = LP:EyePos() - Vector(0,0,16)
			end]]
			--local bEnabled = render.EnableClipping(true)
			--render.PushCustomClipPlane(clipvector, clipvector:Dot(clippos))
			--render.SetMaterial( mat )
			--LegEnt:SetMaterial("models/wireframe.vmt")
			LegEnt:SetPos(RenderPos)
			LegEnt:SetAngles(RenderAngle)
			--LegEnt:SetupBones()
			LegEnt:DrawModel()
			--LegEnt:SetRenderOrigin()
			--LegEnt:SetRenderAngles()
			--cam.IgnoreZ( false )
			--render.PopCustomClipPlane()
			--render.EnableClipping( oldEC )
			--render.PopCustomClipPlane()
			--render.EnableClipping(bEnabled)
		end
	--cam.End3D()
end )
function Legs:FindOrigin(client)
	--local pos = client:GetBonePosition(client:LookupBone("ValveBiped.Bip01_Neck1"))
	local att = client:GetAttachment(client:LookupAttachment("eyes"))
	local offset = self:GetOffset()
	offset:Rotate(LP:EyeAngles())
	return {Pos = att.Pos - offset}
end--[[
function GM:CalcView(client, origin, angles, fov, znear, zfar)
	if client:Alive() and client:GetObserverMode() == OBS_MODE_NONE then
		local view = {origin = origin,angles = angles,fov = fov,znear = znear,zfar = zfar,drawviewer = false}
		local att = Legs:FindOrigin(client)
		if att then
			--view.angles.pitch = math.Clamp(angles.pitch + att.Ang.pitch * 0.65,-90,90)
			--view.angles.roll = att.Ang.roll * 0.4
			view.origin = att.Pos
			--view.angles = att.Ang
			--view.fov = att.fov
			local normal = client:GetAimVector()
			local endpos = att.Pos + normal * 10

			debugoverlay.Line( client:EyePos(), endpos, 10 )
			--debugoverlay.Sphere(endpos,1)
			if client:GetMoveType() ~= MOVETYPE_NOCLIP then
				local tr = util.TraceLine( {
					start = client:EyePos(),
					endpos = endpos,
					mask = MASK_SHOT_HULL,
					filter = client
				})
				if ( tr.Hit ) then
					debugoverlay.Sphere(tr.HitPos, 1)
					view.origin = tr.HitPos - (endpos-client:EyePos()):GetNormal() * 5
				end
			end
		end
		return view
	end
end
function GM:CalcViewModelView( Weapon, ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
	if ( not IsValid( Weapon ) ) then return end
	local ply = ViewModel:GetOwner()
	local att = Legs:FindOrigin(ply)
	OldEyePos, EyePos = att.Pos, att.Pos
	local vm_origin, vm_angles = EyePos, EyeAng

	-- Controls the position of all viewmodels
	local func = Weapon.GetViewModelPosition
	if ( func ) then
		local pos, ang = func( Weapon, EyePos * 1, EyeAng * 1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end

	-- Controls the position of individual viewmodels
	func = Weapon.CalcViewModelView
	if ( func ) then
		local pos, ang = func( Weapon, ViewModel, OldEyePos * 1, OldEyeAng * 1, EyePos * 1, EyeAng * 1 )
		vm_origin = pos or vm_origin
		vm_angles = ang or vm_angles
	end

	return vm_origin, vm_angles
end]]