local Blacklisted = {}
local VaultRentalRemaining = {}

for key, _ in pairs(Config.Vault) do
	VaultRentalRemaining[key] = {}
end

for key, namelist in pairs(Config.Blacklisted) do
	local tableEntry = Blacklisted[key]
	if not (tableEntry) then
		tableEntry = {}
		Blacklisted[key] = tableEntry
	end
	for _, name in pairs(namelist) do
		tableEntry[name] = true
	end
end

RegisterServerEvent("monster_vault:getItem")
AddEventHandler("monster_vault:getItem", function(--[[owner,--]] job, type, item, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(xPlayer.identifier)

	if (Blacklisted[type] and Blacklisted[type][item]) then
		return
	end
	if type == "item_standard" then
		local sourceItem = xPlayer.getInventoryItem(item)

		if xPlayer.job.name == job then
			TriggerEvent("esx_addoninventory:getSharedInventory", "society_" .. job, function(inventory)
				local inventoryItem = inventory.getItem(item)
				if count > 0 and inventoryItem.count >= count then
					if not (xPlayer.canCarryItem(item, count)) then
						print("notify: player cannot hold")
						TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("player_cannot_hold"), length = 5500 })
					else
						inventory.removeItem(item, count)
						xPlayer.addInventoryItem(item, count)
						TriggerClientEvent("monster_vault:notifications", _source, { type = "success", text = _U("have_withdrawn", count, inventoryItem.label), length = 7500 })
					end
				else
					print("not enough in vault")
					TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("not_enough_in_vault"), length = 5500 })
				end
			end)
		elseif job == "vault" then
			TriggerEvent("esx_addoninventory:getInventory", "vault", xPlayerOwner.identifier, function(inventory)
				local inventoryItem = inventory.getItem(item)

				if count > 0 and inventoryItem.count >= count then
					if not (xPlayer.canCarryItem(item, count)) then
						TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("player_cannot_hold"), length = 5500 })
					else
						inventory.removeItem(item, count)
						xPlayer.addInventoryItem(item, count)
						TriggerClientEvent("monster_vault:notifications", _source, { type = "success", text = _U("have_withdrawn", count, inventoryItem.label), length = 8500 })
					end
				else
					TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("not_enough_in_vault"), length = 5500 })
				end
			end)
		else
			print("notify: not permission for this job")
		end

	elseif type == "item_account" then
		if xPlayer.job.name == job then
			TriggerEvent("esx_addonaccount:getSharedAccount", "society_" .. job .. "_" .. item, function(account)
				local policeAccountMoney = account.money

				if policeAccountMoney >= count then
					account.removeMoney(count)
					xPlayer.addAccountMoney(item, count)
				else
					TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("amount_invalid"), length = 5500 })
				end
			end)
		elseif job == "vault" then
			TriggerEvent("esx_addonaccount:getAccount", "vault_" .. item, xPlayerOwner.identifier, function(account)
				local roomAccountMoney = account.money

				if roomAccountMoney >= count then
					account.removeMoney(count)
					xPlayer.addAccountMoney(item, count)
				else
					TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("amount_invalid"), length = 5500 })
				end
			end)
		else
			TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = "You not have permission", length = 5500 })
		end
	elseif type == "item_weapon" then
		if xPlayer.job.name == job then
			TriggerEvent("esx_datastore:getSharedDataStore", "society_" .. job, function(store)
				local storeWeapons = store.get("weapons") or {}
				local weaponName = nil
				local ammo = nil

				for i = 1, #storeWeapons, 1 do
					if storeWeapons[i].name == item then
						weaponName = storeWeapons[i].name
						ammo = storeWeapons[i].ammo

						table.remove(storeWeapons, i)
						break
					end
				end

				store.set("weapons", storeWeapons)
				xPlayer.addWeapon(weaponName, ammo)
			end)
		elseif job == "vault" then
			TriggerEvent("esx_datastore:getDataStore", "vault", xPlayerOwner.identifier, function(store)
				local storeWeapons = store.get("weapons") or {}
				local weaponName = nil
				local ammo = nil

				for i = 1, #storeWeapons, 1 do
					if storeWeapons[i].name == item then
						weaponName = storeWeapons[i].name
						ammo = storeWeapons[i].ammo

						table.remove(storeWeapons, i)
						break
					end
				end

				store.set("weapons", storeWeapons)
				xPlayer.addWeapon(weaponName, ammo)
			end)
		else
			TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = "You not have permission", length = 5500 })
		end
	end

end)

RegisterNetEvent("monster_vault:putItem", function(--[[owner,--]] job, type, item, count)
	local _source = source
	if not (Config.ServerIsVaultable(_source, type, item, count)) then
		TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("item_is_not_vaultable"), length = 5500 })
		return
	end
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(xPlayer.identifier)
	if (Blacklisted[type] and Blacklisted[type][item]) then
		TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("item_on_blacklisted"), length = 5500 })
		return
	end

	if type == "item_standard" then
		local playerItemCount = xPlayer.getInventoryItem(item).count

		if playerItemCount >= count and count > 0 then
			if xPlayer.job.name == job then
				TriggerEvent("esx_addoninventory:getSharedInventory", "society_" .. job, function(inventory)
					xPlayer.removeInventoryItem(item, count)
					inventory.addItem(item, count)
					TriggerClientEvent("monster_vault:notifications", _source, { type = "success", text = _U("have_deposited", count, inventory.getItem(item).label), length = 7500 })
				end)
			elseif job == "vault" then
				TriggerEvent("esx_addoninventory:getInventory", "vault", xPlayerOwner.identifier, function(inventory)
					xPlayer.removeInventoryItem(item, count)
					inventory.addItem(item, count)
					TriggerClientEvent("monster_vault:notifications", _source, { type = "success", text = _U("have_deposited", count, inventory.getItem(item).label), length = 7500 })
				end)
			else
				TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = "You not have permission for this job!", length = 5500 })
			end
		else
			TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("invalid_quantity"), length = 5500 })
		end

	elseif type == "item_account" then
		local playerAccountMoney = xPlayer.getAccount(item).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(item, count)
			if xPlayer.job.name == job and job == "police" then
				TriggerEvent("esx_addonaccount:getSharedAccount", "society_" .. job .. "_" .. item, function(account)
					account.addMoney(count)
				end)
			elseif job == "vault" then
				TriggerEvent("esx_addonaccount:getAccount", "vault_" .. item, xPlayerOwner.identifier, function(account)
					account.addMoney(count)
				end)
			else
				xPlayer.addAccountMoney(item, count)
				TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = "This job not allow for black money", length = 5500 })
			end

		else
			TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = _U("amount_invalid"), length = 5500 })
		end

	elseif type == "item_weapon" then
		if xPlayer.job.name == job then
			TriggerEvent("esx_datastore:getSharedDataStore", "society_" .. job, function(store)
				local storeWeapons = store.get("weapons") or {}

				table.insert(storeWeapons, {
					name = item,
					count = count
				})

				xPlayer.removeWeapon(item)
				store.set("weapons", storeWeapons)

			end)
		elseif job == "vault" then
			TriggerEvent("esx_datastore:getDataStore", "vault", xPlayerOwner.identifier, function(store)
				local storeWeapons = store.get("weapons") or {}

				table.insert(storeWeapons, {
					name = item,
					ammo = count
				})

				xPlayer.removeWeapon(item)
				store.set("weapons", storeWeapons)

			end)
		else
			TriggerClientEvent("monster_vault:notifications", _source, { type = "error", text = "You not have permission", length = 5500 })
		end
	end

end)

ESX.RegisterServerCallback("monster_vault:getVaultInventory", function(source, cb, item, refresh)
	local playerSource = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem
	if item.needItemLicense ~= "" or item.needItemLicense ~= nil then
		xItem = xPlayer.getInventoryItem(item.needItemLicense)
	else
		xItem = nil
	end

	local refresh = refresh or false

	local blackMoney = 0
	local items = {}
	local weapons = {}


	local timeRental = VaultRentalRemaining[item.id][xPlayer.identifier]
	local bRentalActive = timeRental and timeRental >= os.time()
	if not (bRentalActive) then
		VaultRentalRemaining[item.id][xPlayer.identifier] = nil
		timeRental = nil
	end

	if not (bRentalActive) then
		if not refresh and (item.needItemLicense ~= "" or item.needItemLicense ~= nil) and xItem ~= nil and xItem.count < 1 then
			cb(false)
		elseif not item.InfiniteLicense and not refresh and xItem ~= nil and xItem.count > 0 then
			xPlayer.removeInventoryItem(item.needItemLicense, 1)
		end
	else
		TriggerClientEvent("monster_vault:notifications", playerSource, { type = "error", text = _U("time_remain", (timeRental - os.time()) / 60), length = 5500 })
	end

	local typeVault = ""
	local society = false
	if string.find(item.job, "vault") then
		typeVault = item.job
	else
		typeVault = "society_" .. item.job
		society = true
	end

	if society then
		if item.job == "police" then
			TriggerEvent("esx_addonaccount:getSharedAccount", typeVault .. "_black_money", function(account)
				blackMoney = account.money
			end)
		else
			blackMoney = 0
		end
		TriggerEvent("esx_addoninventory:getSharedInventory", typeVault, function(inventory)
			items = inventory.items
		end)
		TriggerEvent("esx_datastore:getSharedDataStore", typeVault, function(store)
			weapons = store.get("weapons") or {}
		end)
		cb({
			blackMoney = blackMoney,
			items      = items,
			weapons    = weapons,
			job        = item.job
		})
	else
		TriggerEvent("esx_addonaccount:getAccount", typeVault .. "_black_money", xPlayer.identifier, function(account)
			blackMoney = account.money
		end)

		TriggerEvent("esx_addoninventory:getInventory", typeVault, xPlayer.identifier, function(inventory)
			items = inventory.items
		end)

		TriggerEvent("esx_datastore:getDataStore", typeVault, xPlayer.identifier, function(store)
			weapons = store.get("weapons") or {}
		end)

		cb({
			blackMoney = blackMoney,
			items      = items,
			weapons    = weapons,
			job        = item.job
		})
	end
end)

ESX.RegisterServerCallback("monster_vault:rental", function(source, cb, vaultId)
	local vaultInfo = Config.Vault[vaultId]
	if not (vaultInfo and VaultRentalRemaining[vaultId]) then
		return
	end
	local xPlayer = ESX.GetPlayerFromId(source)
	local bSuccess = false
	if (xPlayer) then
		local rentPrice = vaultInfo.rental.price
		local bHashEnoughMoney = xPlayer.getAccount("money").money >= rentPrice
		if (bHashEnoughMoney) then
			xPlayer.removeAccountMoney("money", rentPrice)
			VaultRentalRemaining[vaultId][xPlayer.identifier] = os.time() + vaultInfo.rental.time
			bSuccess = true
		end
	end
	cb(bSuccess)
end)
