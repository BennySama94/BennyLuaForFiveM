-- One table describes everything about each job: spot, texts, animation, prop and reward
local JOBS = {
    collect = {
        coords = Config.CollectCoords, markerType = 0, markerOffset = 1.0,
        blip = { sprite = 618, colour = 5, name = 'Metallreste' },
        text = { '[E] Metallteile sammeln', '[E] Sammeln stoppen' },
        serverEvents = { 'benny_farming:startCollect', 'benny_farming:stopCollect' }, -- server answers with collectLoop
        animDict = 'melee@large_wpn@streamed_core', animClip = 'ground_attack_on_spot', rewardInterval = 3000,
        prop = { model = 'prop_tool_pickaxe', bone = 57005, position = vec3(0.09, 0.03, -0.02), rotation = vec3(-80.0, 0.0, 0.0) },
        giveReward = function() TriggerServerEvent('benny_farming:collect', 1) end,
    },
    craft = {
        coords = Config.CraftingCoords, markerType = 1, markerOffset = -1.0,
        blip = { sprite = 618, colour = 5, name = 'Metalschmelze' },
        text = { '[E] Eisen schmelzen aus 10 Metallteilen', '[E] Schmelzen stoppen' },
        animDict = 'amb@world_human_welding@male@base', animClip = 'base', rewardInterval = 3000,
        prop = { model = 'prop_weld_torch', bone = 28422, position = vec3(0, 0, 0), rotation = vec3(0, 0, 0) },
        giveReward = function() TriggerServerEvent('benny_farming:craft') end,
    },
}

-- Plays the animation, holds the prop and gives a reward every interval until job.isActive is false
local function work(job)
    if job.isBusy then return end
    job.isBusy = true
    local playerPed, prop = PlayerPedId(), job.prop
    lib.requestAnimDict(job.animDict)
    lib.requestModel(prop.model)
    job.propObject = CreateObject(prop.model, GetEntityCoords(playerPed), true, true, false)
    AttachEntityToEntity(job.propObject, playerPed, GetPedBoneIndex(playerPed, prop.bone),
        prop.position.x, prop.position.y, prop.position.z,
        prop.rotation.x, prop.rotation.y, prop.rotation.z, true, true, false, true, 1, true)

    local nextRewardTime = GetGameTimer() + job.rewardInterval
    while job.isActive do
        if not IsEntityPlayingAnim(playerPed, job.animDict, job.animClip, 3) then
            TaskPlayAnim(playerPed, job.animDict, job.animClip, 8.0, -8.0, -1, 1, 0, false, false, false) -- -1 = forever, 1 = loop
        end
        if GetGameTimer() >= nextRewardTime then
            nextRewardTime = GetGameTimer() + job.rewardInterval
            job.giveReward()
        end
        Wait(0)
    end
    ClearPedTasks(playerPed)
    DeleteObject(job.propObject)
    job.isBusy = false
end

for _, job in pairs(JOBS) do
    CreateBlip(job.coords, job.blip)

    -- Press E inside the zone to start / stop
    lib.zones.sphere({
        coords = job.coords, radius = Config.CollectSettings.radius,
        onExit = function() job.isActive = false; lib.hideTextUI() end,
        inside = function()
            lib.showTextUI(job.isActive and job.text[2] or job.text[1])
            if not IsControlJustReleased(0, 38) then return end
            job.isActive = not job.isActive
            if job.serverEvents then
                TriggerServerEvent(job.serverEvents[job.isActive and 1 or 2])
            elseif job.isActive then
                CreateThread(function() work(job) end)
            end
        end
    })
end

RegisterNetEvent('benny_farming:collectLoop', function() work(JOBS.collect) end)

-- Server tells the client to stop (e.g. inventory full / out of scrap)
for eventName, jobName in pairs({ stopCollecting = 'collect', stopCrafting = 'craft' }) do
    RegisterNetEvent('benny_farming:' .. eventName, function()
        JOBS[jobName].isActive = false
        ClearPedTasks(PlayerPedId())
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, job in pairs(JOBS) do
        if job.propObject then DeleteObject(job.propObject) end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        for _, job in pairs(JOBS) do
            local coords = job.coords
            DrawMarker(job.markerType, coords.x, coords.y, coords.z + job.markerOffset, 0, 0, 0, 0, 0, 0,
                2.0, 2.0, 1.5, 0, 255, 255, 220, false, true, 2, nil, nil, false)
        end
    end
end)