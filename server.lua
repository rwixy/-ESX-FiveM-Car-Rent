RegisterNetEvent('vehicle_rental:rentVehicle')
AddEventHandler('vehicle_rental:rentVehicle', function(vehicleModel)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.Prices[vehicleModel]

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('vehicle_rental:spawnVehicle', source, vehicleModel)
    else
        TriggerClientEvent('vehicle_rental:notify', source, 'Nicht genug Geld!')
    end
end)
