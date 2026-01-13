local ox_inventory = exports.ox_inventory
local handling = lib.load('config.handlingdata')

exports('VehiclePart', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        return
    end
end)

exports('VehiclePaint', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        return
    end
end)

---@param data table{mod: table, lvl: int|vector3, model:string, model_label:string}
RegisterNetEvent('mb_custom:GiveVehiclePart', function(data)
    local _s = source
    local mod = data.mod
    local metadata = {
        label = data.model_label .. ': ' .. mod.lvl_label,
        image = mod.image ~= '' and mod.image or 'veh_armor', --mod.image,
        type = mod.label,
        weight = mod.weight and mod.weight or 4000,
        model = data.model,
        lvl = data.lvl,
        mod = mod.index,
        prop = mod.label,
        plateText = data.plateText,
        description = data.model_label .. ': ' .. mod.lvl_label,
    }
    if data.plateText ~= nil then metadata.description = metadata.description .. '\nPlate: ' .. data.plateText end
    ox_inventory:AddItem(_s, 'vehicle_parts', 1, metadata, false)
end)

RegisterNetEvent('mb_custom:GiveVehiclePaint', function(args)
    local _s = source
    local metadata = {
        label = data.label,
        type = data.type,
        rgb = data.rgb,
        index = data.index,
        description = data.description    
    }
    ox_inventory:AddItem(_s, 'vehicle_paint', 1, metadata, false)
end)

RegisterNetEvent('mb_custom:requestVehicleParts', function(netId, parts)
    local _s = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    lib.print.debug('Request vehicle parts for netId', netId, 'entity', vehicle)
    if not vehicle or vehicle == 0 then return end

    local state = Entity(vehicle).state
    if state.vehicleParts or parts == nil then return end
    if parts and parts.wheels and parts.wheels.tyres then
        for k, v in pairs(parts.wheels.tyres) do
            v.grade = v.grade or 'street'
            v.pressure = (handling.parts and handling.parts.wheels.defaultPressure) or 2.2
            v.health = v.health < 1000.0 and v.health or 1000.0
        end
    end


    Entity(vehicle).state:set('vehicleParts', parts, true)
end)

-- Server-side state for last distance reports (per vehicle netId)
local lastDistanceReport = {}
local pendingReports = {}
local Odometer = lib.load('modules.parts.odometer')

lib.callback.register('mb_custom:reportDistance', function(source, netId, deltaMeters)
    local _s = source
    if type(netId) ~= 'number' or type(deltaMeters) ~= 'number' then
        lib.print.error('Invalid reportDistance args from', _s)
        return { ok = false, reason = 'invalid_args' }
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then
        lib.print.error('reportDistance: invalid vehicle netId', netId)
        return { ok = false, reason = 'invalid_vehicle' }
    end

    local state = Entity(vehicle).state
    local parts = state.vehicleParts
    if not parts then
        lib.print.error('reportDistance: no parts for vehicle', netId)
        return { ok = false, reason = 'no_parts' }
    end

    local last = lastDistanceReport[netId]

    -- Server-side validation
    local cfg = handling.parts and handling.parts.odometer and handling.parts.odometer.default or {}
    local maxMetersPerSecond = cfg.maxMetersPerSecond or 45.0
    local throttleSeconds = cfg.reportThrottleSeconds or 5
    local now = os.time()

    if type(deltaMeters) ~= 'number' or deltaMeters <= 0 then
        return { ok = false, reason = 'invalid_delta' }
    end

    if last then
        local elapsed = now - last
        if elapsed < throttleSeconds then
            return { ok = false, reason = 'throttle' }
        end
        local maxAllowed = maxMetersPerSecond * math.max(1, elapsed)
        if deltaMeters > maxAllowed * 1.5 then
            return { ok = false, reason = 'exceeds_max_allowed' }
        end
    else
        -- first report: cap using throttleSeconds window
        local maxAllowed = maxMetersPerSecond * throttleSeconds
        if deltaMeters > maxAllowed * 2 then
            return { ok = false, reason = 'exceeds_initial_max' }
        end
    end

    -- Mark pending and return success; client will compute wear in the callback and submit candidate
    pendingReports[netId] = { source = _s, delta = deltaMeters, ts = now }
    lib.print.debug(('reportDistance accepted prelim for netId %s, awaiting candidate from client'):format(netId))
    return { ok = true, ts = now }
end)

-- Handler for client submitting computed parts after local wear application
RegisterNetEvent('mb_custom:submitPartsUpdate', function(netId, candidateParts, deltaMeters, ts)
    local _s = source
    if type(netId) ~= 'number' or type(deltaMeters) ~= 'number' then
        lib.print.error('Invalid submitPartsUpdate args from', _s)
        return
    end

    local pr = pendingReports[netId]
    if not pr then
        lib.print.warn(('submitPartsUpdate: no pending report for netId %s from %s'):format(tostring(netId), tostring(_s)))
        return
    end
    if pr.source ~= _s or pr.delta ~= deltaMeters or pr.ts ~= ts then
        lib.print.warn(('submitPartsUpdate: mismatch or replay for netId %s from %s'):format(tostring(netId), tostring(_s)))
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then
        lib.print.error('submitPartsUpdate: invalid vehicle netId', netId)
        pendingReports[netId] = nil
        return
    end

    local state = Entity(vehicle).state
    local parts = state.vehicleParts
    if not parts then
        lib.print.error('submitPartsUpdate: no parts for vehicle', netId)
        pendingReports[netId] = nil
        return
    end

    -- Basic validation: odometer increased by delta and tyre health reductions are within tolerance
    local cfg = handling.parts and handling.parts.odometer and handling.parts.odometer.default or {}
    local wearPerKm = cfg.wearPerKm or 0.0
    local expectedDamage = (deltaMeters or 0) / 1000.0 * (wearPerKm or 0)
    local tolerance = 2.0 -- health units tolerance

    -- verify odometer total
    local prevTotal = (parts.odometer and parts.odometer.totalMeters) or 0
    local newTotal = (candidateParts.odometer and candidateParts.odometer.totalMeters) or 0
    if math.abs(newTotal - (prevTotal + deltaMeters)) > 1e-6 then
        lib.print.warn(('submitPartsUpdate: odometer mismatch for netId %s from %s (prev=%s new=%s delta=%s)'):format(tostring(netId), tostring(_s), tostring(prevTotal), tostring(newTotal), tostring(deltaMeters)))
        pendingReports[netId] = nil
        return
    end

    -- verify tyres health reductions
    for idx, tyre in pairs(parts.wheels and parts.wheels.tyres or {}) do
        local prevHealth = tyre.health or 0
        local candTyre = candidateParts.wheels and candidateParts.wheels.tyres and candidateParts.wheels.tyres[idx]
        if not candTyre then
            lib.print.warn(('submitPartsUpdate: missing tyre %s for netId %s from %s'):format(tostring(idx), tostring(netId), tostring(_s)))
            pendingReports[netId] = nil
            return
        end
        local candHealth = candTyre.health or 0
        local actualReduction = prevHealth - candHealth
        if actualReduction + tolerance < expectedDamage or actualReduction - tolerance > expectedDamage then
            lib.print.warn(('submitPartsUpdate: tyre health change outside expected range for idx %s netId %s from %s (expected=%s got=%s)'):format(tostring(idx), tostring(netId), tostring(_s), tostring(expectedDamage), tostring(actualReduction)))
            pendingReports[netId] = nil
            return
        end
    end

    -- All good: persist and broadcast
    Entity(vehicle).state:set('vehicleParts', candidateParts, true)
    lastDistanceReport[netId] = ts
    pendingReports[netId] = nil
    lib.print.debug(('submitPartsUpdate accepted for netId %s from %s, applied %s meters'):format(tostring(netId), tostring(_s), tostring(deltaMeters)))
end)