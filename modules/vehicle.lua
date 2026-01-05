---@class Vehicle : OxClass
local Vehicle = lib.class('Vehicle')
local handlingData = lib.load('config.handlingdata')


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
    local data = handlingData.model[model] ~= nil and handlingData.model[model] or 
        handlingData.class[class] ~= nil and handlingData.class[class] or handlingData.default
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

function Vehicle:ApplyPartsHandling(vehicle)
    local baseHandling = self.private.handlingD
    local parts = self.private.parts
    local final = {}
    for _, part in pairs(parts) do
        if part.ComputeHandling then
            local partHandling = part:ComputeHandling(part)
            for field, mult in pairs(partHandling) do
                final[field] = (final[field] or 1.0) * mult
            end
        end
    end
    for field, mult in pairs(final) do
        if baseHandling[field] then
            print('Applying handling ', field, ' with base ', baseHandling[field],
            ' and multiplier ', mult, ' and final ', baseHandling[field] * mult)
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, baseHandling[field] * mult)
        end
    end
    return final
end


---@return table TyreData
---@param tyreData.grade string
---@param tyreData.health number
---@param tyreData.presure number
---@param tyreData.tread number
---@return number globalTyreHealth
function Vehicle:GetVehicleTyres()
    if not DoesEntityExist(self.entity) then return false end
    local tyres = self.private.parts.wheels.tyres
    local tyresHandling = self.private.handlingD['wheels']
    local globalHealth = 0.0
    for k, v in pairs(tyres) do
        if not DoesVehicleTyreExist(self.entity, k) then v = nil end
        v.health = GetTyreHealth(self.entity, k)
        v.presure = IsVehicleTireBurst(self.entity, k, false) and 0.0 or v.presure
        v.tread = IsVehicleTireBurst(self.entity, k, true) and 0.0 or (8.0 * v.health / 1000.0)
        globalHealth += v.health
    end
    for k, v in pairs(tyresHandling) do
        v.value = (self.private.handlingV[k] * v.multiplier + 0.0) * (globalHealth / (#tyres * 1000))
    end

    return tyres, globalHealth
end

---@param tyres TyreData
---@return table TyreData
function Vehicle:SetVehicleTyres(tyres)
    if not DoesEntityExist(self.entity) then return false end
    local globalHealth = 0.0
    for k, v in pairs(tyres) do
        if not DoesVehicleTyreExist(self.entity, k) then v = nil end
        local tyre = self.private.parts.wheels.tyres[k]
        tyre.grade = v.grade and v.grade or tyre.grade
        tyre.health = v.health and v.health or tyre.health
        tyre.presure = v.presure and v.presure or tyre.presure
        tyre.tread = v.tread and v.tread or tyre.tread
        self.private.parts.wheels.tyres[k] = tyre
    end
    local tyreHandling = self.private.handlingD['wheels']
    for k, v in pairs(tyreHandling) do
        v.value = (self.private.handlingV[k] * v.multiplier + 0.0) * (globalHealth / (#tyres * 1000))
    end

    return self.private.parts.tyres
end



return Vehicle