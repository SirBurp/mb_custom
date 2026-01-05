local Tyres = lib.load('config.handlingdata').parts.wheels

local Wheels = {}

local function WearCurve(x)
    return 0.5 * (x ^ 1.5) * 0.5
end

local function PressureFactor(p)
    local diff = math.abs(p - 2.2)
    diff = math.min(diff, 0.6)
    return 1.0 - (diff / 0.6) * 0.08
end

function Wheels:ComputeHandling(data)
    if data.tyreCount == 0 then return {} end
    local acc = {
        curveMax = 0.0,
        curveMin = 0.0,
        lossMult = 0.0,
        lowSpeedLoss = 0.0,
        dragCoeff = 0.0,
        presureFactor = 0.0
    }

    for _, tyre in pairs(data.tyres) do
        local gradeData = Tyres[tyre.grade]
        acc.curveMax = acc.curveMax + gradeData['fTractionCurveMax']
        acc.curveMin = acc.curveMin + gradeData['fTractionCurveMin']
        acc.lossMult = acc.lossMult + gradeData['fTractionLossMult']
        acc.lowSpeedLoss = acc.lowSpeedLoss + gradeData['fLowSpeedTractionLossMult']
        acc.dragCoeff = acc.dragCoeff + gradeData['fIntialDragCoeff']
        acc.presureFactor = acc.presureFactor + PressureFactor(tyre.presure) 
    end
    -- Average
    for k in pairs(acc) do
        acc[k] = acc[k] / data.tyreCount
    end

    -- Apply wear
    local avgHealth = data.globalHealth / data.tyreCount
    local healthNorm = math.min(math.max(avgHealth / 1000.0, 0.0), 1.0)
    local wearFactor = WearCurve(1.0 - healthNorm)

    -- Apply pressure
    local presureFactor = acc.presureFactor / data.tyreCount
    local finalFactor = wearFactor * presureFactor

    return {
        fTractionCurveMax = acc.curveMax * finalFactor,
        fTractionCurveMin = acc.curveMin * finalFactor,        
        fTractionLossMult = acc.lossMult * finalFactor,
        fLowSpeedTractionLossMult = acc.lowSpeedLoss * finalFactor,
        fIntialDragCoeff = acc.dragCoeff * finalFactor,
    }
end

return Wheels