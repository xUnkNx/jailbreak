hook.Add("InitPostEntity","BuyMenuCreate",function()
	local info = {
		[_T("Pistols")] = {
			["weapon_usp"] = 500,
			["weapon_glock"] = 400,
			["weapon_deagle"] = 700,
			["weapon_p228"] = 600,
			["weapon_elite"] = 800,
			["weapon_fiveseven"] = 750
		},
		[_T("SemiAuto")] = {
			["weapon_tmp"] = 1250,
			["weapon_mac10"] = 1400,
			["weapon_mp5navy"] = 1500,
			["weapon_ump"] = 1700,
			["weapon_p90"] = 2350
		},
		[_T("Shotguns")] = {
			["weapon_m3"] = 2700,
			["weapon_xm1014"] = 2500
		},
		[_T("Rifles")] = {
			["weapon_famas"] = 2250,
			["weapon_m4a4"] = 3100,
			["weapon_m4a1s"] = 2700,
			["weapon_aug"] = 3500,
			["weapon_galil"] = 2000,
			["weapon_ak47"] = 2500,
			["weapon_sg552"] = 3500
		},
		[_T("Snipers")] = {
			["weapon_scout"] = 2750,
			["weapon_awp"] = 4750,
			["weapon_g3sg1"] = 5000,
			["weapon_sg550"] = 4200
		},
		[_T("MachineGuns")] = {
			["weapon_m249"] = 4000
		},
		[_T("Grenades")] = {
			["weapon_flashbang"] = 200,
			["weapon_smokegrenade"] = 300,
			["weapon_hegrenade"] = 300,
			["weapon_molotov"] = 500
		},
		[_T("Others")] = {
			["item_kevlar"] = 1500,
			["item_assaultsuit"] = 3000,
			["weapon_c4_explosive"] = 1000
		}
	}
	local Menu = {}
	local buyfunc = function(s)
		JBCommand("buy", s.weapon)
	end
	local menuselect = function(s)
		GAMEMODE:OpenQMenu(s.submenu)
	end
	for category, cat in pairs(info) do
		local SubMenu = {}
		for wpn, price in pairs(cat) do
			local wep = weapons.GetStored(wpn) or scripted_ents.Get(wpn)
			if wep then
				table.insert(SubMenu, {
					title = language.GetPhrase(wep.PrintName),
					-- desc = price .. "$",
					weapon = wpn,
					select = buyfunc
				})
			end
		end
		if #SubMenu == 1 then
			table.insert(Menu, SubMenu[1])
		else
			table.insert(Menu, {
				title = category,
				submenu = RegisterMenu(SubMenu),
				select = menuselect
			})
		end
	end
	GAMEMODE:PrecacheMenu("BuyMenu",RegisterMenu(Menu))
end)