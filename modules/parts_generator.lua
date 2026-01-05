local PartsGenerator = {}

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

return PartsGenerator