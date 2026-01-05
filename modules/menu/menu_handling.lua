local config = lib.load('config.handling')

local originalHandling = {}

function SetHandlingValue(veh, field, value)
    local handlingType = type(value)
    
    if handlingType == 'number' then
        SetVehicleHandlingFloat(veh, 'CHandlingData', field, value)
    elseif handlingType == 'vector3' then
        SetVehicleHandlingVector(veh, 'CHandlingData', field, value.x, value.y, value.z)
    end
end

function SaveOriginal(veh, field)
   if originalHandling[field] then return end

   local val = GetVehicleHandlingFloat(veh, 'CHandlingData', field)
   if val then 
       originalHandling[field] = val 
       return
   end
   val = GetVehicleHandlingVector(veh, 'CHandlingData', field)
   if val then
       originalHandling[field] = val
       return
   end
end

function ModifyHandling(veh, field, newValue)
    if not veh then return end
    SaveOriginal(veh, field)
    SetHandlingValue(veh, field, newValue)
end

function ResetHandling(veh, field)
    if not veh then return end

    local val = originalHandling[field]
    if not val then return end
    SetHandlingValue(veh, field, val)
    originalHandling[field] = nil
end

function GenerateMenus(entity)
    local mainOptions = {}
    local veh = entity
    if not veh then return end
    
    
    for categoryId, category in pairs(config) do

        local submenuId = 'handling_' .. categoryId
        local submenuOptions = {}

        for _, param in ipairs(category.params) do
            if param.type == "float" and categoryId ~= "SubHandling" then
                local val = GetVehicleHandlingFloat(veh, 'CHandlingData', param.field)
                submenuOptions[#submenuOptions + 1] = {
                    title = param.label,
                    description = param.field .. ': ' .. val,
                    metadata = {{ label = param.description} },
                    onExit = function()
                    end,
                    onSelect = function()
                        local dialog = lib.inputDialog(param.label, {
                            { type = 'slider', label = param.field, default = lib.math.round(val, 2), min = param.min, max = param.max, step = param.step }
                        })
                        if not dialog then ResetHandling(veh, param.field) return end
                        ModifyHandling(veh, param.field, dialog[1])
                    end
                }
            elseif param.type == "int" then
                local val = GetVehicleHandlingInt(veh, 'CHandlingData', param.field)
                submenuOptions[#submenuOptions + 1] = {
                    title = param.label,
                    description = param.field .. ': ' .. val,
                    metadata = {{ label = param.description} },
                    onExit = function()
                    end,
                    onSelect = function()
                        local dialog = lib.inputDialog(param.label, {
                            { type = 'slider', label = param.field, default = val, min = param.min, max = param.max, step = 1 }
                        })
                        if not dialog then ResetHandling(veh, param.field) return end
                        ModifyHandling(veh, param.field, dialog[1])
                    end
                }
            elseif param.type == "flags" then
                local val = GetVehicleHandlingInt(veh, 'CHandlingData', param.field)
                submenuOptions[#submenuOptions + 1] = {
                    title = param.label,
                    description = param.field .. ': ' .. val,
                    metadata = {{ label = param.description} },
                    onExit = function()
                    end,
                    onSelect = function()
                        
                    end
                }
            end
        end
        lib.registerContext({
            id = submenuId,
            menu = 'handling',
            title = category.title,
            options = submenuOptions
        })
        mainOptions[#mainOptions + 1] = {
            title = category.title,
            menu = submenuId
        }
    end

    lib.registerContext({
        id = 'handling',
        title = 'Handling',
        options = mainOptions
    })
    lib.showContext('handling')
end

return GenerateMenus