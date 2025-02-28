local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
	ESX.PlayerData = xPlayer
end)

local vaultType = {}
local CreatedEntities = {}

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
	ESX.PlayerData.job = job
end)

function OpenVaultInventoryMenu(data)
	if data.job == ESX.PlayerData.job.name or data.job == "vault" then
		vaultType = data
		ESX.TriggerServerCallback("monster_vault:getVaultInventory", function(inventory)
			if not inventory then
				Config.ClientNotification({ text = "Not have license card" })
				ESX.UI.Menu.CloseAll()
				local elements = {
					{
						label = "ยืนยัน",
						value = true
					},
					{
						label = "ยกเลิก",
						value = false
					}
				}
				ESX.UI.Menu.Open("default", GetCurrentResourceName(), "confirm_rent_vault", {
					title = "ต้องใช้เสียเงินเพื่อใช้ตู้เซฟใช่หรือไม่",
					align = "center",
					elements = elements
				}, function(menuData, menu)
					local value = menuData.current.value
					if (value) then
						ESX.TriggerServerCallback("monster_vault:rental", function(bSuccess)
							if (bSuccess) then
								OpenVaultInventoryMenu(data)
							end
						end, data.id)
					end
					menu.close()
				end, function(menuData, menu)
					menu.close()
				end)
			else
				TriggerEvent("monster_inventoryhud:openVaultInventory", inventory)
			end
		end,
			data
		)
	else
		Config.ClientNotification({ text = "you not have permission for this job" })
		Citizen.Wait(8000)
	end
end

Citizen.CreateThread(function()
	while ESX == nil or ESX.PlayerData == nil or ESX.PlayerData.job == nil do
		Citizen.Wait(1000)
	end
	for _, v in pairs(Config.Vault) do
		ESX.Game.SpawnLocalObject(v.model, v.coords, function(obj)
			SetEntityHeading(obj, v.coords.w)
			FreezeEntityPosition(obj, true)
			table.insert(CreatedEntities, obj)
		end)
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		for k, v in pairs(Config.Vault) do
			local dist = GetDistanceBetweenCoords(coords, v.coords, true)
			if dist < 2 then
				ESX.ShowHelpNotification("Press E to open vault")

				if IsControlJustReleased(0, Keys["E"]) then
					OpenVaultInventoryMenu({ id = k, job = v.type, needItemLicense = v.needItemLicense, InfiniteLicense = v.InfiniteLicense })
				else
					break
				end
			end
		end

	end
end)

function getMonsterVaultLicense()
	return vaultType
end

AddEventHandler("onResourceStop", function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(CreatedEntities) do
			DeleteEntity(v)
		end
	end
end)

RegisterNetEvent("monster_vault:notifications", Config.ClientNotification)
