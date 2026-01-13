---@class Vehicle : OxClass
local Vehicle = lib.class('Vehicle')
local handlingData = lib.load('config.handlingdata')

local Parts = {
    Wheels = lib.load('modules.parts.wheels'),
    Odometer = lib.load('modules.parts.odometer')
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
        data = handlingData.class[class] lib.print.debug('Class', class) end
	if handlingData.model[model] ~= nil and #handlingData.model[model] > 0 then 
        data = handlingData.model[model] lib.print.debug('Model', model) end


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
        lib.print.debug('Applying wheels handling')
        local wheelHandling = Parts.Wheels.ComputeHandling(parts.wheels)
        --lib.print.debug('Wheel handling:', json.encode(wheelHandling, {indent = true}))
        for field, mult in pairs(wheelHandling) do
            final[field] = (final[field] or 1.0) * mult
        end
    end
    for field, mult in pairs(final) do
        if baseHandling[field] and mult ~= 1.0 then
            lib.print.debug('Applying handling', field, 'base', baseHandling[field], 'mult', mult, 'final', baseHandling[field] * mult)
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, baseHandling[field] * mult)
        end
    end
    return final
end

--- Odometer monitoring: start a loop that samples distance and reports to server via lib.callback
function Vehicle:StartOdometerLoop()
    if self._odometerActive then return end
    self._odometerActive = true
    self._odometerAccum = 0.0

    local vehicle = self.private.entity
    local sampleInterval = handlingData.parts.odometer.default.sampleIntervalSeconds or 1
    local minMeters = handlingData.parts.odometer.default.reportMinMeters or 10

    self._odometerThread = Citizen.CreateThread(function()
        local lastPos = GetEntityCoords(vehicle)
        while self._odometerActive and DoesEntityExist(vehicle) do
            Citizen.Wait(math.max(100, math.floor(sampleInterval * 1000)))
            if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then break end
            local pos = GetEntityCoords(vehicle)
            local dx = pos.x - lastPos.x
            local dy = pos.y - lastPos.y
            local dz = pos.z - lastPos.z
            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
            self._odometerAccum = self._odometerAccum + dist
            lastPos = pos

            if self._odometerAccum >= minMeters then
                local toReport = math.floor(self._odometerAccum)
                -- Use async callback pattern: client calls server callback and receives response in the provided function
                lib.callback('mb_custom:reportDistance', false, function(res)
                    if res and res.ok then
                        local parts = Entity(vehicle).state and Entity(vehicle).state.vehicleParts
                        if not parts then
                            lib.print.warn('Odometer callback: no parts for vehicle', tostring(NetworkGetNetworkIdFromEntity(vehicle)))
                            return
                        end

                        local wearPerKm = handlingData.parts.odometer.default.wearPerKm or 0.0
                        parts.wheels = parts.wheels or {}
                        parts = Parts.Odometer.ApplyWearToTyres(parts, toReport, wearPerKm)

                        parts.odometer = parts.odometer or {}
                        parts.odometer.totalMeters = (parts.odometer.totalMeters or 0) + toReport
                        parts.odometer.lastReported = res.ts

                        TriggerServerEvent('mb_custom:submitPartsUpdate', NetworkGetNetworkIdFromEntity(vehicle), parts, toReport, res.ts)
                        lib.print.debug('Odometer callback: submitted updated parts for netId', NetworkGetNetworkIdFromEntity(vehicle), 'delta', toReport)
                        lib.print.debug('Odometer: reported', toReport, 'meters, total now', parts.odometer.totalMeters)
                        -- subtract reported meters
                        self._odometerAccum = math.max(0, self._odometerAccum - toReport)
                    else
                        lib.print.debug('Odometer report not accepted or failed callback', res and res.reason or 'nil')
                    end
                end, NetworkGetNetworkIdFromEntity(vehicle), toReport)
            end
            
        end
        self._odometerActive = false
    end)
end

function Vehicle:StopOdometerLoop()
    self._odometerActive = false
    self._odometerThread = nil
end

function Vehicle:GetHandling()
    lib.print.debug('Getting IV handling', json.encode(self.private.handlingD))
    local handlingD = self.private.handlingD
    return handlingD
end


return Vehicle