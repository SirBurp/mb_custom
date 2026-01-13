local functions = require 'modules.functions'
local vehiclemods = require 'config.vehiclemods'
local mods, vanity = vehiclemods[1], vehiclemods[2]
local modData = lib.load('config.mods')
local estetics, especial = modData.estetics, modData.especial



local function getModLevelLabel(vehicle, modIndex)
    local vehicleMod = GetVehicleMod(vehicle, modIndex)
    local lvl_label = GetModTextLabel(vehicle, modIndex, vehicleMod)
    if lvl_label ~= 'NULL' and vehicleMod ~= -1 then
        lvl_label = GetLabelText(lvl_label)
    elseif vehicleMod == -1 then
        lvl_label = locale('vehicle_part_menu_default')
    else
        lvl_label = mods[modIndex].label .. ' ' .. (vehicleMod + 1)
    end
    return lvl_label
end

local function removeVehicleMod(vehicle, mod, lvl)
    SetEntityAsMissionEntity(vehicle, true, true)
    NetworkRequestControlOfEntity(vehicle)
    functions:SetVehicleModKit(vehicle)
    local meta = {
        mod = mod,
        lvl = lvl,
        model = GetEntityModel(vehicle),
        model_label = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
    }

    if mod.index == 22 then                      -- Xenon Color
        SetVehicleXenonLightsColour(vehicle, 255)
        SetVehicleMod(vehicle, 22, -1, false)
    elseif mod.index == 100 then                 -- Plate Style
        meta.plateText = GetVehicleNumberPlateText(vehicle)
        SetVehicleNumberPlateTextIndex(vehicle, 0)
    elseif mod.index == 102 then                 -- Window Tint
        SetVehicleWindowTint(vehicle, 0)
    elseif mod.index == 103 then                 -- Neon Color
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, false)
        end
    else                                        -- Regular Mods
        SetVehicleMod(vehicle, mod.index, -1, false)
    end
    TriggerServerEvent('mb_custom:GiveVehiclePart', meta)
end

local function getVehicleModMenu(vehicle)
    local main, secondarys = {}, {}
    for _, mod in pairs(mods) do
        if GetVehicleMod(vehicle, mod.index) == -1 then goto continue end
        if main[mod.category] == nil and secondarys[mod.category] == nil then
            secondarys[mod.category] = {}
            main[mod.category] = {
                title = mod.category,
                arrow = true,
                menu = 'vehicle_mods_'..mod.category,
                description = locale('vehicle_part_menu_category', mod.category),
            }
        end
        mod.lvl_label = getModLevelLabel(vehicle, mod.index)
        secondarys[mod.category][#secondarys[mod.category]+1] = {
            title = mod.label,
            arrow = true,
            description = locale('vehicle_part_menu_remove', mod.lvl_label),
            args = {vehicle = vehicle, mod = mod, lvl = GetVehicleMod(vehicle, mod.index)},
            onSelect = function(args)
                removeVehicleMod(args.vehicle, args.mod, args.lvl)
            end
        }
        ::continue::
    end
    
    secondarys['Vanity'] = {}
    if GetVehicleMod(vehicle, 48) ~= -1 then                -- Livery
        lib.print.debug('Livery Found')
        local mod = vanity[48]
        local lvl = GetVehicleMod(vehicle, 48)
        mod.lvl_label = GetLiveryName(vehicle, lvl) 
            and GetLabelText(GetLiveryName(vehicle, lvl)) or (mod.label ..': '.. (lvl + 1))
        secondarys['Vanity'][#secondarys['Vanity']+1] = {
            title = mod.label,
            arrow = true,
            description = locale('vehicle_part_menu_remove', mod.lvl_label),
            args = {vehicle = vehicle, mod = mod, lvl = lvl},
            onSelect = function(args)
                removeVehicleMod(args.vehicle, args.mod, args.lvl)
            end
        }
    end
    if GetVehicleXenonLightsColour(vehicle) ~= 255 then     -- Xenon Color
        lib.print.debug('Xenon Color Found')
        local mod = vanity[22]
        local color = GetVehicleXenonLightsColour(vehicle)
        mod.lvl_label = color 
            and mod.label .. ': ' .. locale('labels.xenon_color.'..color) or mod.label
        secondarys['Vanity'][#secondarys['Vanity']+1] = {
            title = mod.label,
            arrow = true,
            description = locale('vehicle_part_menu_remove', mod.lvl_label),
            args = {vehicle = vehicle, mod = mod, lvl = color},
            onSelect = function(args)
                removeVehicleMod(args.vehicle, args.modIndex, args.lvl)
            end
        }
    end
    if GetVehicleNumberPlateTextIndex(vehicle) ~= 0 then    -- Plate Style
        local mod = vanity[100]
        local index = GetVehicleNumberPlateTextIndex(vehicle)
        mod.lvl_label = mod.label .. ': ' .. locale('labels.plate_style.'..index)
        secondarys['Vanity'][#secondarys['Vanity']+1] = {
            title = mod.label,
            arrow = true,
            description = locale('vehicle_part_menu_remove', mod.lvl_label),
            args = {vehicle = vehicle, mod = mod, lvl = index},
            onSelect = function(args)
                removeVehicleMod(args.vehicle, args.mod, args.lvl)
            end
        }
    end
    if GetVehicleWindowTint(vehicle) > 0 then             -- Window Tint
        lib.print.debug('Window Tint Found', GetVehicleWindowTint(vehicle))
        local mod = vanity[102]
        local tint = GetVehicleWindowTint(vehicle)
        mod.lvl_label = mod.label .. ': ' .. locale('labels.window_tint.'..tint)
        secondarys['Vanity'][#secondarys['Vanity']+1] = {
            title = mod.label,
            arrow = true,
            description = locale('vehicle_part_menu_remove', mod.lvl_label),
            args = {vehicle = vehicle, mod= mod, lvl = tint},
            onSelect = function(args)
                removeVehicleMod(args.vehicle, args.mod, args.lvl)
            end
        }
    end
    if functions:GetAnyNeonEnabled(vehicle) then         -- Neon Color
        lib.print.debug('Neon Color Found')
        local r, g, b = GetVehicleNeonLightsColour(vehicle)
        local mod = vanity[103]
        mod.lvl_label = mod.label .. ': (' ..r.. ', ' ..g.. ', ' ..b.. ')'
        secondarys['Vanity'][#secondarys['Vanity']+1] = {
            title = mod.label,
            arrow = true,
            description = locale('vehicle_part_menu_remove', mod.lvl_label),
            args = {vehicle = vehicle, mod = mod, lvl = vector3(r, g, b)},
            onSelect = function(args)
                removeVehicleMod(args.vehicle, args.mod, args.lvl)
            end
        }
    end
    
    if #secondarys['Vanity'] > 0 then
        main['Vanity'] = {
            title = 'Vanity',
            arrow = true,
            menu = 'vehicle_mods_Vanity',
            description = locale('vehicle_part_menu_category', 'Vanity'),
        }
    else secondarys['Vanity'] = nil end

    return main, secondarys
end

local function generateMenuOption(title, description, args)
    return {
        title = title,
        arrow = true,
        description = locale('vehicle_part_menu_remove', description), 
        args = args,
        onSelect = function(args)
            removeVehicleMod(args.vehicle, args.mod, args.value)
        end
    }
end

local function getVehicleEstetics(vehicle)
    local props = lib.getVehicleProperties(vehicle)
    local main, secondarys = {}, {}
    for k, v in pairs(estetics) do
        if not props[k] or props[k] == false or props[k] == -1 then goto skip end
        if main[v.category] == nil and secondarys[v.category] == nil then
            secondarys[v.category] = {}
            main[v.category] = {
                title = v.category,
                arrow = true,
                menu = 'vehicle_estetics_' .. v.category,
                description = locale('vehicle_part_menu_category', v.category),
            }
        end
        v.lvl_label = getModLevelLabel(vehicle, v.index)
        secondarys[v.category][#secondarys[v.category]+1] = 
            generateMenuOption(v.label, v.lvl_label, 
                {vehicle = vehicle, mod = v, value = props[k]})
        
        ::skip::
    end
    
    -- Check especial estetics and add category if any found
    if props.modLibery or props.modXenon or props.plateIndex or props.windowTint or props.neonEnabled  then
        secondarys[especial.category] = {}
        main[especial.category] = {
            title = especial.category,
            arrow = true,
            menu = 'vehicle_estetics_' .. especial.category,
            description = locale('vehicle_part_menu_category', especial.category),
        }
    end

    if props.modLivery ~= -1 then
        local mod = especial.modLivery
        mod.lvl_label = GetLiveryName(vehicle, props.modLivery) 
            and GetLabelText(GetLiveryName(vehicle, props.modLivery)) or (mod.label ..': '.. (props.modLivery + 1))
        secondarys[especial.category][#secondarys[especial.category]+1] = 
            generateMenuOption(mod.label, mod.lvl_label, 
                {vehicle = vehicle, mod = mod, value = props.modLivery})
    end
    if props.modXenon ~= -1 then
        local mod = especial.modXenon
        mod.lvl_label = mod.label .. ': ' .. locale('labels.xenon_color.'..props.xenonColor)
        secondarys[especial.category][#secondarys[especial.category]+1] = 
            generateMenuOption(mod.label, mod.lvl_label, 
                {vehicle = vehicle, mod = mod, value = props.modXenon})
    end
    if props.plateIndex ~= -1 then
        local mod = especial.plateIndex
        mod.lvl_label = mod.label .. ': ' .. locale('labels.plate_style.'..props.plateIndex)
        secondarys[especial.category][#secondarys[especial.category]+1] = 
            generateMenuOption(mod.label, mod.lvl_label, 
                {vehicle = vehicle, mod = mod, value = props.plateIndex})
    end
    if props.windowTint ~= 0 then
        local mod = especial.windowTint
        mod.lvl_label = mod.label .. ': ' .. locale('labels.window_tint.'..props.windowTint)
        secondarys[especial.category][#secondarys[especial.category]+1] = 
            generateMenuOption(mod.label, mod.lvl_label, 
                {vehicle = vehicle, mod = mod, value = props.windowTint})
    end
    if props.neonEnabled then
        local mod = especial.neonEnabled
        local r,g,b = table.unpack(props.neonColor)
        mod.lvl_label = mod.label .. ': (' ..r.. ', ' ..g.. ', ' ..b.. ')'
        secondarys[especial.category][#secondarys[especial.category]+1] = 
            generateMenuOption(mod.label, mod.lvl_label, 
                {vehicle = vehicle, mod = mod, value = vector3(r, g, b)})
    end
    return main, secondarys
end

local function openVehiclePartsMenu(vehicle)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end

    local modable = functions:SetVehicleModKit(vehicle)
    --if not modable then lib.notify({title = locale('vehicle_parts'), description = locale('unable_mod_vehicle'), type = 'error'}) return end
    local main, secondarys = getVehicleModMenu(vehicle) --getVehicleModMenu(vehicle)
    
    for k, v in pairs(secondarys) do
        lib.registerContext({
            id = 'vehicle_mods_' .. k,
            title = k .. locale('vehicle_parts'),
            onExit = function() end,
            menu = 'vehicle_parts_main',
            options = v
        })
    end
    lib.registerContext({
        id = 'vehicle_parts_main',
        title = locale('vehicle_parts'),
        onExit = function() end,
        options = main
    })
    lib.showContext('vehicle_parts_main')
end

return openVehiclePartsMenu