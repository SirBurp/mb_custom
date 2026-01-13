local Odometer = lib.load('modules.parts.odometer')

local M = {}

local function almostEqual(a, b, eps)
    eps = eps or 1e-6
    return math.abs(a - b) <= eps
end

function M.run()
    local results = {}

    -- DamageFromMeters
    local dmg = Odometer._DamageFromMeters(1000, 0.5) -- 1 km * 0.5 wearPerKm
    results[#results+1] = { name = 'DamageFromMeters 1km with 0.5 wearPerKm', pass = almostEqual(dmg, 0.5), note = dmg }

    -- ApplyWearToTyres
    local parts = {
        wheels = {
            tyres = {
                [0] = { health = 1000 },
                [1] = { health = 1000 }
            },
            tyreCount = 2,
            globalHealth = 2000
        }
    }
    local before = parts.wheels.tyres[0].health
    local newParts = Odometer.ApplyWearToTyres(parts, 2000, 1.0) -- 2 km * 1.0 => 2 health
    local after = newParts.wheels.tyres[0].health
    results[#results+1] = { name = 'ApplyWearToTyres reduces each tyre health by expected amount', pass = almostEqual(before - after, 2.0), note = ('before=%s after=%s'):format(before, after) }

    return results
end

return M