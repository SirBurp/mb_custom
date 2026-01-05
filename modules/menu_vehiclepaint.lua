local paints = require 'config.vehiclepaints'


local function registerColorMenu(tpe, zone)
    local opt = {}
    for k, v in pairs(paints[tpe]) do
        opt[#opt+1] = {
            title = k,
            description = locale('labels_paint_'..tpe) .. ': ' .. k,
            args = {
                label = locale('labels_item_paint', k)
                zone = zone,
                index = v,
                rgb = false,
                description = locale('labels_item_paint', locale('labels_paint_'..tpe)..': ' .. k)
            },
            onSelect = function(args)
                TriggerServerEvent('mb_custom:GiveVehiclePaint', args)
            end
        }
    end
    lib.registerContext({
        id = 'mb_custom:vehicle_paint_' .. tpe .. '_menu',
        title = locale('labels_paint_' .. tpe) .. ' - ' .. locale('vehicle_paints'),
        onExit = function() end,
        menu = 'mb_custom:vehicle_paint_'..zone..'_menu',
        options = opt
    })
    lib.showContext('mb_custom:vehicle_paint_' .. tpe .. '_menu')
end

local function registerColorTypeMenu(tpe)
    local opt = {
        {           --- Metallic
            title = locale('labels_paint_Metallic'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Metallic')),
            args = {zone = tpe},
            onSelect = function(args)
                registerColorMenu('Metallic', args.zone)
            end
        },
        {           --- Matte
            title = locale('labels_paint_Matte'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Matte')),
            args = {zone = tpe},
            onSelect = function(args)
                registerColorMenu('Matte', args.zone)
            end
        },
        {           --- Metal
            title = locale('labels_paint_Metal'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Metal')),
            args = {zone = tpe},
            onSelect = function(args)
                registerColorMenu('Metal', args.zone)
            end
        },
        {           --- Chamaleon
            title = locale('labels_paint_Chamaleon'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Chamaleon')),
            args = {zone = tpe},
            onSelect = function(args)
                registerColorMenu('Chamaleon', args.zone)
            end
        }
    }
    lib.registerContext({
        id = 'mb_custom:vehicle_paint_' .. tpe .. '_menu',
        title = locale('labels_paint_' .. tpe) .. ' - ' .. locale('vehicle_paints'),
        onExit = function() end,
        menu = 'mb_custom:vehicle_paint_menu',
        options = opt
    })
    lib.showContext('mb_custom:vehicle_paint_' .. tpe .. '_menu')
end

local function openVehiclePaintMenu()
    local opt = {
        {           -- Primary Color
            title = locale('vehicle_paints') .. ' - ' .. locale('labels_paint_Primary'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Primary')),
            onSelect = function(args)
                registerColorTypeMenu('Primary')
            end
        },
        {           -- Secondary Color
            title = locale('vehicle_paints') .. ' - ' .. locale('labels_paint_Secondary'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Secondary')),
            onSelect = function(args)
                registerColorTypeMenu('Secondary')
            end
        },
        {           -- Pearlescent Color
            title = locale('vehicle_paints') .. ' - ' .. locale('labels_paint_Pearl'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Pearl')),
            onSelect = function(args)
                registerColorTypeMenu('Pearl')
            end
        },
        {           -- Wheel Color
            title = locale('vehicle_paints') .. ' - ' .. locale('labels_paint_Wheel'),
            arrow = true,
            description = locale('vehicle_paint_menu_category', locale('labels_paint_Wheel')),
            onSelect = function(args)
                registerColorTypeMenu('Wheel')
            end
        }
    }
    lib.registerContext({
        id = 'mb_custom:vehicle_paint_menu',
        title = locale('vehicle_paints'),
        onExit = function() end,
        options = opt
    })
    lib.showContext('mb_custom:vehicle_paint_menu')
end

return openVehiclePaintMenu