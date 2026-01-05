local ox_inventory = exports.ox_inventory

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
    print('Request vehicle parts for netId ', netId, ' entity ', vehicle)
    print('Parts :', json.encode(parts, {indent = true}))
    if not vehicle or vehicle == 0 then return end

    local state = Entity(vehicle).state
    if state.vehicleParts then return end

    
    Entity(vehicle).state:set('vehicleParts', parts, true)
end)