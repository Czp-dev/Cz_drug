local isBusy = false
local isReady = false

local recolteCoords = {
    lsd = vector3(2712.8542, 4140.0190, 43.9894),
    weed = vector3(5401.0615, -5268.8418, 35.7079),
    cocaine = vector3(-840.5034, 5763.6455, 4.9950),
    meth = vector3(2194.3843, 5595.6807, 53.7594)
}

local traitementCoords = {
    lsd = vector3(-326.7500, -1356.434, 31.295),
    weed = vector3(146.71100, -1701.907, 29.291),
    cocaine = vector3(-1262.992, -1123.942, 7.6170),
    meth = vector3(578.09400, -423.0649, 24.730)
}

function recolteDrug(name)
    TriggerServerEvent('collectItem', name)
end

function processItem(name, tName)
    TriggerServerEvent('processItem', name, tName)
end

RegisterCommand('drogues', function()
    isReady = not isReady
    ESX.ShowNotification("Mode vente : " .. (isReady and "ACTIVÉ" or "DÉSACTIVÉ"))
end)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for drug, coords in pairs(recolteCoords) do
            if #(playerCoords - coords) < 15.0 then
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour récolter ' .. drug)
                if IsControlJustReleased(0, 38) and not isBusy then
                    isBusy = true
                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                    Citizen.SetTimeout(5000, function()
                        recolteDrug(drug)
                        ClearPedTasks(playerPed)
                        isBusy = false
                    end)
                end
            end
        end

        for drugt, coords in pairs(traitementCoords) do
            if #(playerCoords - coords) < 15.0 then
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour traiter ' .. drugt)
                if IsControlJustReleased(0, 38) and not isBusy then
                    isBusy = true
                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
                    Citizen.SetTimeout(5000, function()
                        local processedName = 'processed_' .. drugt
                        processItem(drugt, processedName)
                        ClearPedTasks(playerPed)
                        isBusy = false
                    end)
                end
            end
        end

        Citizen.Wait(0)
    end
end)

exports.ox_target:addGlobalPed({
    {
        name = 'sell_drugs',
        icon = 'fas fa-cannabis',
        label = 'Vendre de la drogue',
        canInteract = function(entity, distance, coords, name)
            return distance < 4.0
        end,
        onSelect = function(data)
            if not isReady then
                ESX.ShowNotification("La vente est désactivée ! Activez-la avec /drogues")
                return
            end

            local playerPed = PlayerPedId()
            local closestPed = lib.getClosestPed(GetEntityCoords(playerPed), 2)

            if closestPed and DoesEntityExist(closestPed) then
                local drugItems = {
                    { name = 'processed_lsd', label = 'LSD Raffiné' },
                    { name = 'processed_weed', label = 'Marijuana' },
                    { name = 'processed_cocaine', label = 'Cocaïne Pure' },
                    { name = 'processed_meth', label = 'Crystal Meth' }
                }

                local menuOptions = {}

                for _, drug in pairs(drugItems) do
                    table.insert(menuOptions, {
                        title = 'Vendre ' .. drug.label,
                        icon = 'fas fa-dollar-sign',
                        onSelect = function()
                            if math.random(1, 2) == 1 then
                                TaskReactAndFleePed(closestPed, playerPed)
                            else
                                TriggerServerEvent('sellDrug', drug.name)
                            end
                        end
                    })
                end

                lib.registerContext({
                    id = 'drug_sell_menu',
                    title = 'Vente de Drogues',
                    options = menuOptions
                })

                lib.showContext('drug_sell_menu')
            else
                ESX.ShowNotification('Aucun client à proximité.')
            end
        end
    }
})
