local spawnedVehicles = {}
local npc

function Notify(msg)
    if Config.NotifyMethod == 'esx_notify' then
        ESX.ShowNotification(msg)
    elseif Config.NotifyMethod == 'mythic_notify' then
        exports['mythic_notify']:DoHudText('inform', msg)
    else
        print("Notify: " .. msg)
    end
end

function CreateNPC()
    local npcHash = GetHashKey(Config.NPCPosition.model)
    RequestModel(npcHash)
    
    while not HasModelLoaded(npcHash) do
        Citizen.Wait(0)
    end
    
    npc = CreatePed(4, npcHash, Config.NPCPosition.x, Config.NPCPosition.y, Config.NPCPosition.z, Config.NPCPosition.heading, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local npcCoords = GetEntityCoords(npc)
            local distance = #(playerCoords - npcCoords)
            
            if distance < 20.0 then
                DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "Fahrzeugvermietung")
            end
        end
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 0, 0, 0, 150)
end

RegisterNetEvent('vehicle_rental:spawnVehicle')
AddEventHandler('vehicle_rental:spawnVehicle', function(vehicleModel)
    local playerPed = PlayerPedId()
    local coords = Config.VehicleSpawnLocation
    local vehicleHash = GetHashKey(vehicleModel)

    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Citizen.Wait(0)
    end

    local vehicle = CreateVehicle(vehicleHash, coords.x, coords.y, coords.z, coords.heading, true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetVehicleNumberPlateText(vehicle, "RENTAL")
    table.insert(spawnedVehicles, vehicle)

    Notify("Fahrzeug " .. vehicleModel .. " gemietet!")
end)

RegisterCommand('rentvehicle', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local elements = {}
    for _, vehicle in pairs(Config.Vehicles) do
        table.insert(elements, {label = vehicle .. " - $" .. Config.Prices[vehicle], value = vehicle})
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_rental_menu',
        {
            title = 'Fahrzeug mieten',
            align = 'top-left',
            elements = elements
        },
        function(data, menu)
            local selectedVehicle = data.current.value
            TriggerServerEvent('vehicle_rental:rentVehicle', selectedVehicle)
            menu.close()
        end,
        function(data, menu)
            menu.close()
        end
    )
end, false)

CreateNPC()
