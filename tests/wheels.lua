local Wheels = lib.load('modules.parts.wheels')

local M = {}

local function almostEqual(a, b, eps)
    eps = eps or 1e-6
    return math.abs(a - b) <= eps
end

-- Accept a settings table (from config.tests.settings) or nil and run customizable tests
function M.run(settings)
    local settings = settings or {}
    local wearInputs = settings.wearInputs or {0.0, 1.0}
    local pressureInputs = settings.pressureInputs or {2.2, 2.8}
    local computeCases = settings.computeHandlingCases or {
        {
            name = 'default two perfect street tyres',
            data = {
                tyreCount = 2,
                tyres = {
                    [0] = { grade = 'street', pressure = 2.2, health = 1000 },
                    [1] = { grade = 'street', pressure = 2.2, health = 1000 },
                },
                globalHealth = 2000.0
            }
        }
    }

    local results = {}

    -- WearCurve tests
    for _, v in ipairs(wearInputs) do
        local expected = (v == 0) and 0.5 or ((v == 1) and 1.0 or nil)
        local actual = Wheels._WearCurve(v)
        local pass = true
        if expected then pass = almostEqual(actual, expected) end
        results[#results+1] = { name = ('WearCurve(%s)'):format(v), pass = pass, note = actual }
    end

    -- PressureFactor tests
    for _, p in ipairs(pressureInputs) do
        local actual = Wheels._PressureFactor(p)
        -- No strict expected value for intermediate p; just sanity check 0.0 < val <= 1.0
        local pass = (actual > 0.0 and actual <= 1.0)
        results[#results+1] = { name = ('PressureFactor(%s)'):format(p), pass = pass, note = actual }
    end

    -- ComputeHandling cases
    for _, case in ipairs(computeCases) do
        local out = Wheels.ComputeHandling(case.data)
        local pass = (out.fTractionCurveMax ~= nil and out.fTractionCurveMin ~= nil)
        results[#results+1] = { name = ('ComputeHandling: %s'):format(case.name), pass = pass, note = json.encode(out) }
    end

    -- tyreCount zero
    local out2 = Wheels.ComputeHandling({ tyreCount = 0 })
    results[#results+1] = { name = 'ComputeHandling with tyreCount 0 returns empty table', pass = (type(out2) == 'table' and next(out2) == nil) }

    return results
end

return M