local M = {}

function M.register(ox_target)
    -- Ejemplo: añade targets de inspección personalizados para pruebas
    ox_target:addGlobalVehicle({
        {
            name = 'mb_custom:TestInspect',
            icon = 'fa-solid fa-magnifying-glass',
            label = 'Test: Inspect vehicle',
            distance = 2.5,
            canInteract = function(entity) return true end,
            onSelect = function(data)
                local properties = lib.getVehicleProperties(data.entity)
                lib.print.debug('[tests.targets] Inspect:', json.encode(properties, {indent = true}))
            end
        },
        {
            name = 'mb_custom:VehicleHandlings',
            icon = 'fa-solid fa-cogs',
            label = 'Show Vehicle Handlings (tests)',
            distance = 2.5,
            canInteract = function(entity) return true end,
            onSelect = function(data)
                require 'modules.menu.menu_handling'(data.entity)
            end
        }
    })
end

return M