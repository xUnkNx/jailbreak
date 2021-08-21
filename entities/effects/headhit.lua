function EFFECT:Init(a)
	local b = a:GetOrigin()
	local c = a:GetNormal()
	local d = EffectData()
	d:SetOrigin(b)
	d:SetNormal(c)
	util.Effect("stunstickimpact",d,true,true)
	sound.Play("player/bhit_helmet-1.wav",b,77,math.random(90,110))
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
end