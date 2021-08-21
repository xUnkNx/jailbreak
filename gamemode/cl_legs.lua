module("Legs",package.seeall)
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
function Legs:SetUp()
	self.LegEnt = ClientsideModel( GetTranslatedModel(LP), RENDER_GROUP_OPAQUE_ENTITY )
	self.LegEnt:SetNoDraw( true )
	self.LegEnt.LastTick = 0
	SetProperties( LP, self.LegEnt )
end
PlaybackRate,Sequence,Velocity,OldWeapon,HoldType = 1,nil,0,nil,nil
Legs.BoneHoldTypes = { 
["none"] = {
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Upperarm",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Upperarm",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_L_Finger4",
	"ValveBiped.Bip01_L_Finger41",
	"ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0",
	"ValveBiped.Bip01_L_Finger01",
	"ValveBiped.Bip01_L_Finger02",
	"ValveBiped.Bip01_R_Finger4",
	"ValveBiped.Bip01_R_Finger41",
	"ValveBiped.Bip01_R_Finger42",
	"ValveBiped.Bip01_R_Finger3",
	"ValveBiped.Bip01_R_Finger31",
	"ValveBiped.Bip01_R_Finger32",
	"ValveBiped.Bip01_R_Finger2",
	"ValveBiped.Bip01_R_Finger21",
	"ValveBiped.Bip01_R_Finger22",
	"ValveBiped.Bip01_R_Finger1",
	"ValveBiped.Bip01_R_Finger11",
	"ValveBiped.Bip01_R_Finger12",
	"ValveBiped.Bip01_R_Finger0",
	"ValveBiped.Bip01_R_Finger01",
	"ValveBiped.Bip01_R_Finger02",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_Spine2"
}
}
BonesToRemove,BoneMatrix = {},nil
local vector_origin,vector_full,vector_depos = Vector(0,0,0),Vector(1,1,1),Vector(-100,-100,0)
function Legs:WeaponChanged( weap )
	Leg = self.LegEnt
	if Leg then
		for boneId = 0, Leg:GetBoneCount() do
			Leg:ManipulateBoneScale(boneId, vector_full)
			Leg:ManipulateBonePosition(boneId, vector_origin)
		end
	end
end
BreathScale,NextBreath = 0.5,0
function Legs:Think( maxseqgroundspeed )
	local leg = self.LegEnt
	if leg then
		if LP:GetActiveWeapon() ~= self.OldWeapon then
			self.OldWeapon = LP:GetActiveWeapon()
			self:WeaponChanged( self.OldWeapon )
		end
		local mdl = GetTranslatedModel(LP)
		if leg:GetModel() ~= mdl then
			leg:Remove()
			Legs:SetUp()
			return
		end
		BonesToRemove = Legs.BoneHoldTypes["none"]
		for _, v in pairs( BonesToRemove ) do
			local boneId = leg:LookupBone(v)
			if boneId then
				leg:ManipulateBoneScale(boneId, vector_origin)
				leg:ManipulateBonePosition(boneId, vector_depos)
			end
		end
		leg:SetMaterial( LP:GetMaterial() )
		leg:SetSkin( LP:GetSkin() )
		for _, group in pairs(LP:GetBodyGroups()) do
			leg:SetBodygroup(group["id"], LP:GetBodygroup(group["id"])) 
		end
		self.Velocity = LP:GetVelocity():Length2D()
		self.PlaybackRate = 1
		if self.Velocity > 0.5 then
			if maxseqgroundspeed < 0.001 then
				self.PlaybackRate = 0.01
			else
				self.PlaybackRate = self.Velocity / maxseqgroundspeed
				self.PlaybackRate = math.Clamp( self.PlaybackRate, 0.01, 10 )
			end
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
		if NextBreath <= ct then
			NextBreath = ct + 1.95 / BreathScale
			leg:SetPoseParameter( "breathing", BreathScale )
		end
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
hook.Add("InitPostEntity","Legs:InitLP", function() LP = LocalPlayer() end)
local mat = Material( "editor/wireframe" )
RenderAngle,BiaisAngle,RadAngle,RenderPos,RenderColor,ClipVector,ForwardOffset = nil,nil,nil,nil,{},vector_up * -1,-22
local EyePos,EyeAngles,Angle = EyePos,EyeAngles,Angle
local rad,cos,sin = math.rad,math.cos,math.sin
local clipvector = vector_up * -1
hook.Add( "RenderScreenspaceEffects", "Legs:Render", function()
	cam.Start3D(EyePos(),EyeAngles())
		if ShouldDrawLegs() then
			RenderPos = LP:GetPos()
			if LP:InVehicle() then
				RenderAngle = LP:GetVehicle():GetAngles()
				RenderAngle:RotateAroundAxis( RenderAngle:Up(), 90 )
			else
				BiaisAngles = LP:EyeAngles()
				RenderAngle = Angle(0, BiaisAngles.y, 0)
				RadAngle = rad( BiaisAngles.y )
				RenderPos.x = RenderPos.x + cos( RadAngle ) * ForwardOffset
				RenderPos.y = RenderPos.y + sin( RadAngle ) * ForwardOffset
				if LP:GetGroundEntity() == NULL then
					RenderPos.z = RenderPos.z + 8
					if LP:KeyDown( IN_DUCK ) then
						RenderPos.z = RenderPos.z - 28
					end
				end
			end
			local clippos, clipbone = nil, LP:LookupBone("ValveBiped.Bip01_Spine")
			if clipbone then
				local clipbone = LP:GetBoneMatrix(clipbone)
				if clipbone then
					clippos = clipbone:GetTranslation()
				end
			end
			if clippos == nil then
				clippos = LP:EyePos() - Vector(0,0,16)
			end
			RenderColor = LP:GetColor()
			RenderColor.a = 100
			LegEnt:SetColor(RenderColor)
			--local bEnabled = render.EnableClipping(true)
			--render.PushCustomClipPlane(clipvector, clipvector:Dot(clippos))
				--render.SetMaterial( mat )
				--LegEnt:SetMaterial("models/wireframe.vmt")
				LegEnt:SetRenderOrigin(RenderPos)
				LegEnt:SetRenderAngles(RenderAngle)
				LegEnt:SetupBones()
				LegEnt:DrawModel()
				LegEnt:SetRenderOrigin()
				LegEnt:SetRenderAngles()
			--cam.IgnoreZ( false )
			--render.PopCustomClipPlane()
			--render.EnableClipping( oldEC )
			--render.PopCustomClipPlane()
			--render.EnableClipping(bEnabled)
		end
	cam.End3D()
end )