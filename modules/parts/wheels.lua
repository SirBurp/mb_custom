local Tyres = lib.load('config.handlingdata').parts.wheels

local Wheels = {}

local function WearCurve(x)
    return lib.math.round(0.5 + (x ^ 1.5) * 0.5, 4)
end

local function PressureFactor(p)
    local diff = math.abs(p - 2.2)
    diff = math.min(diff, 0.6)
    return 1.0 - (diff / 0.6) * 0.08
end

function Wheels.ComputeHandling(data)
    if data.tyreCount == 0 then return {} end
    local acc = {
        curveMax = 0.0,
        curveMin = 0.0,
        lossMult = 0.0,
        lowSpeedLoss = 0.0,
        dragCoeff = 0.0,
        pressureFactor = 0.0
    }

    for _, tyre in pairs(data.tyres) do
        local gradeData = Tyres[tyre.grade]
        acc.curveMax = acc.curveMax + gradeData['fTractionCurveMax']
        acc.curveMin = acc.curveMin + gradeData['fTractionCurveMin']
        acc.lossMult = acc.lossMult + gradeData['fTractionLossMult']
        acc.lowSpeedLoss = acc.lowSpeedLoss + gradeData['fLowSpeedTractionLossMult']
        acc.dragCoeff = acc.dragCoeff + gradeData['fInitialDragCoeff']
        acc.pressureFactor = acc.pressureFactor + PressureFactor(tyre.pressure) 
    end

    
    -- Average
    for k, v in pairs(acc) do
        acc[k] = v / data.tyreCount
    end
    -- Apply wear
    local avgHealth = data.globalHealth / (data.tyreCount * 1000.0)
    local healthNorm = lib.math.clamp(avgHealth, 0.0, 1.0)
    local wearFactor = WearCurve(healthNorm)
    --lib.print.debug('Tyre handling wear factor:', wearFactor, ' avgHealth:', avgHealth, ' healthNorm:', healthNorm)
    -- Apply pressure
    local finalFactor = lib.math.clamp(wearFactor * acc.pressureFactor, 0.55, 1.0)
    lib.print.debug('Tyre handling final factor:', wearFactor, acc.pressureFactor, finalFactor)

    return {
        ['fTractionCurveMax'] = acc.curveMax * (1.0 + (1.0 - finalFactor) * 20.0),     --aumetar con el desgaste
        ['fTractionCurveMin'] = acc.curveMin * finalFactor,                             --reducir con el desgaste
        ['fTractionLossMult'] = acc.lossMult * finalFactor,
        ['fLowSpeedTractionLossMult'] = acc.lowSpeedLoss *  (1.0 + (1.0 - finalFactor) * 20.0),
        ['fInitialDragCoeff'] = acc.dragCoeff * (1.0 + (1.0 - finalFactor) * 20.0),
    }
end

-- Expose helpers for testing
Wheels._WearCurve = WearCurve
Wheels._PressureFactor = PressureFactor

return Wheels