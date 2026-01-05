local ox_inventory = exports.ox_inventory
local functions = require 'modules.functions'

exports('VehiclePart', function(data, slot)
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 2.0, 0, 70)
    if not vehicle then 
        ox_inventory:notify({text = locale('no_vehicle_nearby')}) return
    end
    if GetVehicleDoorLockStatus(vehicle) ~= 1 then
        ox_inventory:notify({text = locale('unable_mod_vehicle')}) return
    end
    local meta = slot.metadata
    if GetEntityModel(vehicle) ~= meta.model then 
        ox_inventory:notify({text = locale('no_maching_model')}) return 
    end
    local v_mod
    if meta.mod <= 48 then
        v_mod = GetVehicleMod(vehicle, meta.mod) + 1
    elseif meta.mod == 100 then
        v_mod = GetVehicleNumberPlateTextIndex(vehicle)
    elseif meta.mod == 102 then
        v_mod = GetVehicleWindowTint(vehicle)
    elseif meta.mod == 103 then
        v_mod = functions:GetAnyNeonEnabled(vehicle) and 1 or 0
    end
    if v_mod >= 1 then ox_inventory:notify({text = locale('part_already_installed')}) return end
    functions:SetVehicleModKit(vehicle)
    ox_inventory:useItem(data, function(data)
        if not data then return end
        if meta.mod == 22 then
            SetVehicleMod(vehicle, 22, 1, false)
            SetVehicleXenonLightsColour(vehicle, meta.lvl)
        elseif meta.mod == 48 then
            SetVehicleMod(vehicle, 48, meta.lvl, false)
            SetVehicleLivery(vehicle, meta.lvl)
        elseif meta.mod == 100 then
            SetVehicleNumberPlateTextIndex(vehicle, meta.lvl)
            --SetVehicleNumberPlateText(vehicle, meta.plateText)
        elseif meta.mod == 102 then
            SetVehicleWindowTint(vehicle, meta.lvl)
        elseif meta.mod == 103 then
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(vehicle, i, true)
            end
            SetVehicleNeonLightsColour(vehicle, meta.lvl.x, meta.lvl.y, meta.lvl.z)
        else
            SetVehicleMod(vehicle, meta.mod, meta.lvl, false)
        end
        ox_inventory:notify({text = locale('vehicle_part_menu_installed', meta.label)})
    end)
end)

exports('VehiclePaint', function(data, slot)
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 2.0, 0, 70)
    if not vehicle then 
        ox_inventory:notify({text = locale('no_vehicle_nearby')}) return
    end
    if GetVehicleDoorLockStatus(vehicle) ~= 1 then
        ox_inventory:notify({text = locale('unable_mod_vehicle')}) return
    end
    local meta = slot.metadata
    local primary, secondary = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)
    functions:SetVehicleModKit(vehicle)
    ox_inventory:useItem(data, function(data)
        if not data then return end
        if meta.zone == 'Primary' and not meta.rgb then
            ClearVehicleCustomPrimaryColour(vehicle)
            SetVehicleColours(vehicle, meta.index, secondary)
        elseif meta.zone == 'Secondary' and not meta.rgb then
            ClearVehicleCustomSecondaryColour(vehicle)
            SetVehicleColours(vehicle, primary, meta.index)
        elseif meta.zone == 'Primary' and meta.rgb then
            SetVehicleCustomPrimaryColour(vehicle, meta.rgb.x, meta.rgb.y, meta.rgb.z)
        elseif meta.zone == 'Secondary' and meta.rgb then
            SetVehicleCustomSecondaryColour(vehicle, meta.rgb.x, meta.rgb.y, meta.rgb.z)
        elseif meta.zone == 'Pearl' then
            SetVehicleExtraColours(vehicle, meta.index, wheel)
        elseif meta.zone == 'Wheel' then
            SetVehicleExtraColours(vehicle, pearl, meta.index)
        end
        ox_inventory:notify({text = locale('vehicle_paint_menu_applied', locale('labels_paint_'..meta.zone))})
    end)
end)

