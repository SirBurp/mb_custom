local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target
local f = require 'modules.functions'

local Vehicle = lib.load('modules.vehicle')
local PartsGenerator = lib.load('modules.parts_generator')
lib.locale()

local Controllers = {}

lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return end

    local state = Entity(vehicle).state
    if state.vehicleParts then return end

    if not state.vehicleParts then
        print('Request vehicle parts for netId ', NetworkGetNetworkIdFromEntity(vehicle), ' entity ', vehicle)
        local props = lib.getVehicleProperties(vehicle)
        local parts = PartsGenerator.GenerateVehicleParts(vehicle)

        PartsGenerator.applyIVHandling(vehicle)

        TriggerServerEvent('mb_custom:requestVehicleParts', NetworkGetNetworkIdFromEntity(vehicle), parts)
    end
end)

AddStateBagChangeHandler('vehicleParts', nil, function(bagName, key, parts)
    local entity = GetEntityFromStateBagName(bagName)
    if not entity or GetEntityType(entity) ~= 2 then return end

    local net = NetworkGetNetworkIdFromEntity(entity)
    local controller = Controllers[net]
    if not controller then
        controller = Vehicle:new(entity)
        Controllers[net] = controller
        print('Created Vehicle controller for netId ', net)
    end
    print('tyres:', json.encode(parts.wheels.tyres, {indent = true}))
    controller:SetParts(parts)
    controller:ApplyPartsHandling()
end)


Citizen.CreateThread(function()
    Wait(500)
    local mechanicStations = {}
    local functions = f:new('functions')
    ox_target:addGlobalVehicle({
        {
            name = 'mb_custom:VehicleParts',
            icon = 'fa-solid fa-wrench',
            label = locale('vehicle_parts'),
            distance = 2.5,
            canInteract = function(entity)
                if GetVehicleDoorLockStatus(entity) ~= 1 then return false end
                return true
            end,
            onSelect = function(data)
                require 'modules.menu.menu_vehiclepart'(data.entity)                
            end
        },
        {
            name = 'mb_custom:VehicleInspect',
            icon = 'fa-solid fa-car',
            label = 'Inspect vehicle',
            distance = 2.5,
            canInteract = function(entity)
                --if GetVehicleDoorLockStatus(entity) ~= 1 then return false end
                return true
            end,
            onSelect = function(data)
                local properties = lib.getVehicleProperties(data.entity)
                print(json.encode(properties, {indent = true}))              
            end
        },
        {
            name = 'mb_customs:VehicleHandlings',
            icon = 'fa-solid fa-cogs',
            label = 'Show Vehicle Handlings',
            distance = 2.5,
            canInteract = function(entity)
                --if GetVehicleDoorLockStatus(entity) ~= 1 then return false end
                return true
            end,
            onSelect = function(data)
                require 'modules.menu.menu_handling'(data.entity)
                --local handling = functions:GetVehicleHandlings(data.entity)
                --print(json.encode(handling, {indent = true}))              
            end
        }
    })

end)