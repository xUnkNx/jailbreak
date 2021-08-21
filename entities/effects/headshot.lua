function EFFECT:Init(eff)
	local origin = eff:GetOrigin()
	local normal = eff:GetNormal()
	sound.Play("player/headshot" .. math.random(1,2) .. ".wav",origin,77,math.Rand(80,120))
	sound.Play("physics/body/body_medium_break" .. math.random(2,4) .. ".wav",origin,77,math.Rand(90,110))
	local h = Vector(3,3,3)
	local i = h * -1 for j = 1,math.random(5,8) do
		local k = (normal * 2 + VectorRand()) / 3
		k:Normalize()
		local l = ClientsideModel("models/props_junk/Rock001a.mdl",RENDERGROUP_OPAQUE)
		if l:IsValid() then
			l:SetMaterial("models/flesh")
			l:SetModelScale(math.Rand(.2,.5),0)
			l:SetPos(origin + k * 6)
			l:PhysicsInitBox(i,h)
			l:SetCollisionBounds(i,h)
			local m = l:GetPhysicsObject()
			if m:IsValid() then
				m:SetMaterial("zombieflesh")
				m:ApplyForceOffset(normal + VectorRand() * 5, k * math.Rand(300,800))
			end
			SafeRemoveEntityDelayed(l,math.Rand(6,10))
		end
	end
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
end