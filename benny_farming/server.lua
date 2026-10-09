local collectingPlayers = {}

RegisterNetEvent('benny_farming:startCollect', function()
    local src = source
    collectingPlayers[src] = true
    TriggerClientEvent('benny_farming:collectLoop', src)
end)

RegisterNetEvent('benny_farming:stopCollect', function()
    local src = source
    collectingPlayers[src] = nil
end)

RegisterNetEvent('benny_farming:collect', function(amount)
    local src = source
    if not collectingPlayers[src] then return end
    local success = exports.ox_inventory:AddItem(src, Config.MetalScrapItem, amount)
    if not success then
        collectingPlayers[src] = nil
        TriggerClientEvent('ox_lib:notify', src, { title = 'Farming', description = Config.Notify.noSpace, type = 'error' })
        TriggerClientEvent('benny_farming:stopCollecting', src)
    end
end)

RegisterNetEvent('benny_farming:craft', function()
    local src = source
    local count = exports.ox_inventory:Search(src, 'count', Config.MetalScrapItem)
    if count >= 10 then
        exports.ox_inventory:RemoveItem(src, Config.MetalScrapItem, 10)
        local success = exports.ox_inventory:AddItem(src, Config.IronItem, 1)
        if success then
            TriggerClientEvent('ox_lib:notify', src, { title = 'Farming', description = Config.Notify.craftSuccess, type = 'success' })
        else
            exports.ox_inventory:AddItem(src, Config.MetalScrapItem, 10)
            TriggerClientEvent('ox_lib:notify', src, { title = 'Farming', description = Config.Notify.noSpace, type = 'error' })
            TriggerClientEvent('benny_farming:stopCrafting', src)
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Farming', description = Config.Notify.craftFailed, type = 'error' })
        TriggerClientEvent('benny_farming:stopCrafting', src)
    end
end)