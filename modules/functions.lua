---@class VehicleFunctions : OxClass
local VehicleFunctions = lib.class('VehicleFunctions')
local handlingData = require 'config.handlingdata'

function VehicleFunctions:constructor(name)
    self.name = name or 'VehicleFunctions'
end

---@param vehicle entity
---@return boolean
function VehicleFunctions:SetVehicleModKit(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    if not IsEntityAVehicle(vehicle) then return false end
    SetEntityAsMissionEntity(vehicle, true, true)
    NetworkRequestControlOfEntity(vehicle)
    SetVehicleModKit(vehicle, 0)
    return GetVehicleModKit(vehicle) == 0
end

---@param vehicle entity
---@return boolean
function VehicleFunctions:GetAnyNeonEnabled(vehicle)
    for i = 0, 3 do
        if IsVehicleNeonLightEnabled(vehicle, i) then
            return true
        end
    end
    return false
end

---@param vehicle entity
---@param ?neon integer|nil
---@return boolean|table<number, boolean>
function VehicleFunctions:GetNeonEnabled(vehicle, neon)
    if neon then
        return GetVehicleNeonLightEnabled(vehicle, neon)
    end
    local enabled = {}
    for i = 0, 3 do
        if GetVehicleNeonLightEnabled(vehicle, i) then
            enabled[i] = true
        end
    end
    return enabled
end

---@param vehicle entity
---@return table<string, number|vector3>
function VehicleFunctions:GetVehicleHandlings(vehicle)
    local handling = {}
    for k, v in pairs(handlingData.default) do
        if v.type == 'float' then
            handling[k] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', k)
        elseif v.type == 'vector3' then
            handling[k] = GetVehicleHandlingVector(vehicle, 'CHandlingData', k)
        end
    end
    return handling
end

---@param vehicle entity
---@param handling table<string, number|vector3>
---@return table<string, number|vector3>
function VehicleFunctions:SetVehicleDefaultHandlings(vehicle, handling)
    local defHandling = {}
    for k, v in pairs(handlingData.default) do
        if v.type == 'float' then
            local defaultValue = handling[k] * v.defaultMultiplier
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', k, defaultValue)
            defHandling[k] = defaultValue
        elseif v.type == 'vector3' then
            local defaultValue = vector3(handling[k].x + v.defaultOffset.x,
                handling[k].y + v.defaultOffset.y,
                handling[k].z + v.defaultOffset.z)
            SetVehicleHandlingVector(vehicle, 'CHandlingData', k, defaultValue)
            defHandling[k] = defaultValue
        end
    end
    return defHandling
end

return VehicleFunctions