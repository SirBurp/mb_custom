local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

local Vehicle = lib.load('modules.vehicle')
local PartsGenerator = lib.load('modules.parts.parts_generator')
local Config = lib.load('config.main')
lib.locale()

local Controllers = {}

lib.onCache('vehicle', function(vehicle, oldValue)
    -- When leaving vehicle: stop odometer loop if we had a controller
    if not vehicle and oldValue then
        local net = NetworkGetNetworkIdFromEntity(oldValue)
        local controller = Controllers[net]
        if controller and type(controller.StopOdometerLoop) == 'function' then
            controller:StopOdometerLoop()
        end
        return
    end

    if not vehicle then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return end

    local state = Entity(vehicle).state
    if state.vehicleParts then return end

    if not state.vehicleParts then
        lib.print.debug('Request vehicle parts for netId', NetworkGetNetworkIdFromEntity(vehicle), 'entity', vehicle)
        local props = lib.getVehicleProperties(vehicle)
        local parts = PartsGenerator.GenerateVehicleParts(vehicle)

        

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
		PartsGenerator.applyIVHandling(entity)
        lib.print.debug('Created Vehicle controller for netId', net)
    end
    lib.print.debug('tyres:', json.encode(parts.wheels.tyres, {indent = true}))
    controller:SetParts(parts)
    controller:ApplyPartsHandling()

    -- Start odometer monitoring only if player is driver
    if GetPedInVehicleSeat(entity, -1) == cache.ped and controller and type(controller.StartOdometerLoop) == 'function' then
        controller:StartOdometerLoop()
    end
end)




Citizen.CreateThread(function()
    Wait(500)
    local mechanicStations = {}
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
        }
    })

    -- If tests are enabled, delegate registration to the test runner (it will register targets/commands based on config)
    if Config and Config.tests and Config.tests.enabled then
        local runner = require 'tests.runner'
        runner.init()
    end
end)