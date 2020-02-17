ESX             = nil
local policeshopItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM policeshop LEFT JOIN items ON items.name = policeshop.item', {}, function(policeshopResult)
		for i=1, #policeshopResult, 1 do
			if policeshopResult[i].name then
				if policeshopItems[policeshopResult[i].store] == nil then
					policeshopItems[policeshopResult[i].store] = {}
				end

				if policeshopResult[i].limit == -1 then
					policeshopResult[i].limit = 30
				end

				table.insert(policeshopItems[policeshopResult[i].store], {
					label = policeshopResult[i].label,
					item  = policeshopResult[i].item,
					price = policeshopResult[i].price,
					limit = policeshopResult[i].limit
				})
			else
				print(('esx_policeshop: invalid item "%s" found!'):format(policeshopResult[i].item))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_policeshop:requestDBItems', function(source, cb)
	cb(policeshopItems)
end)

RegisterServerEvent('esx_policeshop:buyItem')
AddEventHandler('esx_policeshop:buyItem', function(itemName, amount, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	amount = ESX.Math.Round(amount)

	-- is the player trying to exploit?
	if amount < 0 then
		print('esx_policeshop: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
		return
	end

	-- get price
	local price = 0
	local itemLabel = ''

	for i=1, #policeshopItems[zone], 1 do
		if policeshopItems[zone][i].item == itemName then
			price = policeshopItems[zone][i].price
			itemLabel = policeshopItems[zone][i].label
			break
		end
	end

	price = price * amount

	-- can the player afford this item?
	if xPlayer.getMoney() >= price then
		-- can the player carry the said amount of x item?
		if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('player_cannot_hold'), length = 5000})
		else
			xPlayer.removeMoney(price)
			xPlayer.addInventoryItem(itemName, amount)
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'success', text = _U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)), length = 5000})
		end
	else
		local missingMoney = price - xPlayer.getMoney()
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('not_enough', ESX.Math.GroupDigits(missingMoney)), length = 5000})
	end
end)
