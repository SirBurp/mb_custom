---@class Vehicle : OxClass
local Vehicle = lib.class('Vehicle')
local handlingData = lib.load('config.handlingdata')

local Parts = {
    Wheels = require 'modules.wheels'
}


function Vehicle:constructor(vehicle)
    self:RegisterVehicle(vehicle)
end

---@param vehicle entity
function Vehicle:RegisterVehicle(vehicle)
    self.private.entity = vehicle
    self.private.netID = NetworkGetNetworkIdFromEntity(vehicle)

    local props = lib.getVehicleProperties(vehicle)

    self.private.model = props.model
    self.private.displayName = GetDisplayNameFromVehicleModel(props.model)
    self.private.class = GetVehicleClass(vehicle)
    self.private.plate = props.plate

    self.private.handlingV = self:GetOriginalHandlings(vehicle)
    self.private.handlingD = self:GenerateIVHandlings()
    --self.private.parts = self:GenerateParts(vehicle, props)
end

---@param vehicle entity
---@return table<string, number|vector3>
function Vehicle:GetOriginalHandlings(vehicle)
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

---@param original table<string, number|vector3>
---@param class number
---@param model string
---@return table<string, number|vector3>
function Vehicle:GenerateIVHandlings(original, class, model)
    local original = original or self.private.handlingV
    local class = class or self.private.class
    local model = model or self.private.displayName
    local h = {}
    local data =  handlingData.default
    if handlingData.class[class] ~= nil and #handlingData.class[class] > 0 then 
        data = handlingData.class[class] print('Class', class) end
	if handlingData.model[model] ~= nil and #handlingData.model[model] > 0 then 
        data = handlingData.model[model] print('Model', model) end


    for k, v in pairs(data) do
        if handlingData.default[k].type == 'float' then
            h[k] = original[k] * v.defaultMultiplier
        elseif handlingData.default[k].type == 'vector3' then
            h[k] = vector3(
                original[k].x * v.defaultOffset.x,
                original[k].y * v.defaultOffset.y,
                original[k].z * v.defaultOffset.z
            )
        end
    end
    return h
end

function Vehicle:SetParts(parts)
    self.private.parts = parts
end

function Vehicle:ApplyPartsHandling()
    local vehicle = self.private.entity
    local baseHandling = self.private.handlingD
    local parts = self.private.parts
    local final = {}
    if parts.wheels then
        print('Applying wheels handling')
        local wheelHandling = Parts.Wheels.ComputeHandling(parts.wheels)
        --print('Wheel handling:', json.encode(wheelHandling, {indent = true}))
        for field, mult in pairs(wheelHandling) do
            final[field] = (final[field] or 1.0) * mult
        end
    end
    for field, mult in pairs(final) do
        if baseHandling[field] and mult ~= 1.0 then
            print('Applying handling ', field, ' with base ', baseHandling[field],
            ' and multiplier ', mult, ' and final ', baseHandling[field] * mult)
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, baseHandling[field] * mult)
        end
    end
    return final
end

function Vehicle:GetHandling()
    print('Getting IV handling ', self.private.handlingD)
    local handlingD = self.private.handlingD
    return handlingD
end


return Vehicle