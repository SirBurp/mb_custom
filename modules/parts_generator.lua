local PartsGenerator = {}
local handling = lib.load('config.handlingdata')
local Wheels = lib.load('modules.wheels')


local wheelIndex = {
    [0] = 'wheel_lf',
    [1] = 'wheel_rf',
    [2] = 'wheel_lm1',    
    [3] = 'wheel_rm1',
    [4] = 'wheel_lf',
    [5] = 'wheel_rr',
    [6] = 'wheel_lm2',
    [7] = 'wheel_rm2'
}

function GetModLabelText(vehicle, modType, modIndex)
    local modTextHash = GetModTextLabel(vehicle, modType, modIndex)
    if modTextHash ~= nil and modTextHash ~= 'NULL' then
        return GetLabelText(modTextHash)
    end
    return 'Default'
end

function PartsGenerator.GenerateVehicleParts(vehicle)
    if not DoesEntityExist(vehicle) then return end
    if not IsEntityAVehicle(vehicle) then return end
    local class = GetVehicleClass(vehicle)
    local isBike = GetVehicleClass(vehicle) == 8
    local wheelCount = GetVehicleNumberOfWheels(vehicle) > 2 and GetVehicleNumberOfWheels(vehicle) or 4
    local props = lib.getVehicleProperties(vehicle)
    local parts = {
        
        wheels = {
            style = props.wheels,
            index = isBike and props.modBackWheels or props.modFrontWheels,
            label = isBike and GetModLabelText(vehicle, 23, props.modBackWheels) or
                GetModLabelText(vehicle, 23, props.modFrontWheels),
            tyres = {},
            tyreCount = wheelCount,
            globalHealth = 0.0
        }
    }
    -- Populate tyres data
    for i = 0, wheelCount+1 do
        local boneIndex = GetEntityBoneIndexByName(vehicle, wheelIndex[i])
        if boneIndex ~= -1 then
            --print('Wheel', i, ':', GetTyreHealth(vehicle, i))
            parts.wheels.tyres[i] = { health = GetTyreHealth(vehicle, i) }
            parts.wheels.globalHealth = parts.wheels.globalHealth + GetTyreHealth(vehicle, i)
        end
    end
    return parts
end

function PartsGenerator.applyIVHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end
    local multipliers = handling.default
	local class = GetVehicleClass(vehicle)
	local model =  GetEntityModel(vehicle)
	
	if handling.class[class] ~= nil and #handling.class[class] > 0 then 
        multipliers = handling.class[class] print('Class', class) end
	if handling.model[model] ~= nil and #handling.model[model] > 0 then 
        multipliers = handling.model[model] print('Model', model) end
		
    print('Applying IV handling multipliers')
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