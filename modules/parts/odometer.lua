local Handling = lib.load('config.handlingdata')

local Odometer = {}

-- Compute tyre health damage (in health units 0..1000) from meters driven
function Odometer.DamageFromMeters(meters, wearPerKm)
    wearPerKm = wearPerKm or (Handling.parts.odometer.default.wearPerKm)
    if not wearPerKm or wearPerKm <= 0 then return 0.0 end
    local km = (meters or 0.0) / 1000.0
    return lib.math.round(km * wearPerKm, 2)
end

-- Apply wear to the tyres in `parts` (mutates and returns parts table)
function Odometer.ApplyWearToTyres(parts, meters, wearPerKm)
    if not parts or not parts.wheels or not parts.wheels.tyres then return parts end
    local damage = Odometer.DamageFromMeters(meters, wearPerKm)
    for idx, tyre in pairs(parts.wheels.tyres) do
        tyre.health = math.max(0.0, (tyre.health or 0.0) - damage)
    end
    -- Recompute global health
    local gh = 0.0
    for _, tyre in pairs(parts.wheels.tyres) do gh = gh + (tyre.health or 0.0) end
    parts.wheels.globalHealth = gh
    return parts
end

-- Expose helpers for testing
Odometer._DamageFromMeters = Odometer.DamageFromMeters
Odometer.ApplyWear = Odometer.ApplyWearToTyres

return Odometer