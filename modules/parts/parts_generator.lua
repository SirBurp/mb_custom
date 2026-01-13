local PartsGenerator = {}
local handling = lib.load('config.handlingdata')
local Wheels = lib.load('modules.parts.wheels')


local wheelIndex = {
    [0] = 'wheel_lf',
    [1] = 'wheel_rf',
    [2] = 'wheel_lm1',    
    [3] = 'wheel_rm1',
    [4] = 'wheel_lr',
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

function PartsGenerator.SetVehicleModKit(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    if not IsEntityAVehicle(vehicle) then return false end
    SetEntityAsMissionEntity(vehicle, true, true)
    NetworkRequestControlOfEntity(vehicle)
    SetVehicleModKit(vehicle, 0)
    return GetVehicleModKit(vehicle) == 0
end

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
            label = isBike and GetModLabelText(vehicle, 23, props.modBackWheels) or
                GetModLabelText(vehicle, 23, props.modFrontWheels),
            tyres = {},
            tyreCount = 0,
            globalHealth = 0.0
        }
    }
    -- Populate tyres data (iterate defined wheel indices; some vehicles have non-contiguous indices)
    local found = 0
    for i, boneName in pairs(wheelIndex) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIndex ~= -1 then
            local health = GetTyreHealth(vehicle, i)
            parts.wheels.tyres[i] = { health = health }
            parts.wheels.globalHealth = parts.wheels.globalHealth + health
            found = found + 1
            --lib.print.debug('Wheel', i, 'bone', boneName, 'health', health)
        end
    end
    parts.wheels.tyreCount = found
    return parts
end

function PartsGenerator.applyIVHandling(vehicle)
    if not DoesEntityExist(vehicle) then return end
    local multipliers = handling.default
	local class = GetVehicleClass(vehicle)
	local model =  GetEntityModel(vehicle)
	
	if handling.class[class] ~= nil and #handling.class[class] > 0 then 
        multipliers = handling.class[class] lib.print.debug('Class', class) end
	if handling.model[model] ~= nil and #handling.model[model] > 0 then 
        multipliers = handling.model[model] lib.print.debug('Model', model) end
		
    lib.print.debug('Applying IV handling multipliers')
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