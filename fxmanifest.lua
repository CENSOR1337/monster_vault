fx_version "adamant"
game "gta5"
lua54 "yes"
name "Monster Vault"
description "An Vault script built for Monster ESX Framework - A Monster ESX Framework built for MonsterSrRP NOHD Nightmare"
author "TaerAttO"
version "v1.0.0"
url "https://discord.gg/taeratto"

shared_scripts {
	"@es_extended/imports.lua"
}

server_scripts {
	"@es_extended/locale.lua",
	"@mysql-async/lib/MySQL.lua",
	"locales/en.lua",
	"config.lua",
	"server/main.lua"
}

client_scripts {
	"@es_extended/locale.lua",
	"locales/en.lua",
	"config.lua",
	"client/main.lua"
}

dependencies {
	"es_extended",
	"esx_addonaccount",
	"esx_addoninventory",
	"esx_datastore"
}

exports {
	"getMonsterVaultLicense"
}
