Config                        = {}
Config.Locale                 = 'en'

Config.VaultBox = 'p_v_43_safe_s'
Config.Vault = {
	vault = {
		coords = vector3(1732.1887, 3314.7129, 41.2235),
		heading = 197.3661,
		needItemLicense = 'taeratto_blackcard', --'licence_vault' -- If you don't want to use items Allow you to leave it blank or needItemLicense = nil
		InfiniteLicense = true -- Should one License last forever?
	},
	police = {
		coords = vector3(219.06, -797.20, 29.75),
		heading = 246.09,
	},
	ambulance = {
		coords = vector3(216.62, -802.72, 29.79),
		heading = 246.09,
	},
	mechanic = {
		coords = vector3(207.83, -798.57, 29.97),
		heading = 70.07,
	}
}

Config.Blacklisted = {
	item_standard = { "phone" },
	item_account = { "money" },
	item_weapon = { "WEAPON_PISTOL" },
}

Config.ClientNotification = function(data) -- {type = 'error', text = _U('player_cannot_hold'), length = 5500}
	TriggerEvent("esx:showNotification", data.text)
end

Config.ServerIsVaultable = function(source, type, item, count)
	return true
end
