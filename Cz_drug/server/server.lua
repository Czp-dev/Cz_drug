
RegisterServerEvent('collectItem')
AddEventHandler('collectItem', function(name)
    local source = source
    local number = math.random(1, 3)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.canCarryItem(name, 1) then 
        xPlayer.addInventoryItem(name, number)
        ESX.ShowHelpNotification('Vous avez récolté '..number .. name)
    end
end)

RegisterServerEvent('processItem')
AddEventHandler('processItem', function(name, tName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getInventoryItem(name).count >= 1 then 
        xPlayer.removeInventoryItem(name, 1)
        xPlayer.addInventoryItem(tName, 1)
    end
end)

ESX.RegisterServerCallback('getPlayerDrugs', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local drugs = {}

    for _, drug in pairs({'weed', 'cocaine', 'meth', 'lsd'}) do
        local count = xPlayer.getInventoryItem(drug).count
        if count > 0 then
            drugs[drug] = count
        end
    end

    cb(drugs)
end)

RegisterNetEvent('sellDrug')
AddEventHandler('sellDrug', function(drug)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(drug)

    if item.count > 0 then
        xPlayer.removeInventoryItem(drug, 1)
        local price = math.random(50, 200)  
        xPlayer.addMoney(price)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez vendu 1 ' .. drug .. ' pour $' .. price)
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez plus de ' .. drug)
    end
end)
