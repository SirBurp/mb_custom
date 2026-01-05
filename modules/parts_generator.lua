local PartsGenerator = {}
local handling = lib.load('config.handlingdata')

function PartsGenerator.GenerateVehicleParts(vehicle)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end
    local class = GetVehicleClass(vehicle)
    local isBike = GetVehicleClass(vehicle) == 8
    
    local props = lib.getVehicleProperties(vehicle)
    local parts = {
        
        wheels = {
            style = props.wheels,
            index = isBike and props.modBackWheels or props.modFrontWheels,
            label = isBike and GetLabelText(GetModTextLabel(vehicle, 24, props.modBackWheels)) or
                GetLabelText(GetModTextLabel(vehicle, 23, props.modFrontWheels)),
            tyres = {},
            tyreCount = 0,
            globalHealth = 0.0
        }
    }

    -- Populate tyres data
    for i = 0, 7 do
        if DoesVehicleTyreExist(vehicle, i) then
            parts.wheels.tyres[i] = { health = GetTyreHealth(vehicle, i) }
            parts.wheels.globalHealth = parts.wheels.globalHealth + GetTyreHealth(vehicle, i)
            parts.wheels.tyreCount = parts.wheels.tyreCount + 1
        end
    end

    return parts
end

function PartsGenerator.applyIVHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end
    local multipliers = handling.model[GetEntityModel(vehicle)] and handling.model[GetEntityModel(vehicle)] or
        handling.class[GetVehicleClass(vehicle)] and handling.class[GetVehicleClass(vehicle)] or handling.default
    print('Applying IV handling multipliers:', json.encode(multipliers, {indent = true}))
    for handlingField, values in pairs(multipliers) do
        if values.defaultMultiplier then
            local currentValue = GetVehicleHandlingFloat(vehicle, 'CHandlingData', handlingField)
            local newValue = currentValue * values.defaultMultiplier
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', handlingField, newValue)
        elseif values.defaultOffset then
            local currentValue = GetVehicleHandlingVector(vehicle, 'CHandlingData', handlingField)
            local newValue = vector3(
                currentValue.x + values.defaultOffset.x,
                currentValue.y + values.defaultOffset.y,
                currentValue.z + values.defaultOffset.z
            )
            SetVehicleHandlingVector(vehicle, 'CHandlingData', handlingField, newValue)
        end
    end
end

return PartsGenerator