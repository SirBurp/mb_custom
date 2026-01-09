local handlingData = {
    ['fMass'] = { 
        name = 'Mass',
        type = 'float',
        defaultMultiplier = 1.25
    },
    ['vecCentreOfMassOffset'] = {
        name = 'Centre of Mass Offset',
        type = 'vector3',
        defaultOffset = vector3(0.0, 0.0, -0.05)
    },
    
    --Suspension
    ['fSuspensionForce'] = {
        name = 'Suspension Force',
        type = 'float',
        defaultMultiplier = 0.80
    },
    ['fSuspensionCompDamp'] = {
        name = 'Suspension Compression Damping',
        type = 'float',
        defaultMultiplier = 0.70
    },
    ['fSuspensionReboundDamp'] = {
        name = 'Suspension Rebound Damping',
        type = 'float',
        defaultMultiplier = 0.75
    },
    ['fAntiRollBarForce'] = {
        name = 'Anti Roll Bar Force',
        type = 'float',
        defaultMultiplier = 0.40
    },

    --Traction
    ['fTractionCurveMax'] = {
        name = 'Traction Curve Max',
        type = 'float',
        part = 'wheels',
        defaultMultiplier = 0.80
    },
    ['fTractionCurveMin'] = {
        name = 'Traction Curve Min',
        type = 'float',
        part = 'wheels',
        defaultMultiplier = 1.10
    },
    ['fTractionLossMult'] = {
        name = 'Traction Loss Multiplier',
        type = 'float',
        part = 'wheels',
        defaultMultiplier = 1.20
    },
    ['fLowSpeedTractionLossMult'] = {
        name = 'Low Speed Traction Loss Multiplier',
        type = 'float',
        part = 'wheels',
        defaultMultiplier = 1.20
    },
    ['fInitialDragCoeff'] = {
        name = 'Initial Drag Coefficient',
        type = 'float',
        part = 'wheels',
        defaultMultiplier = 0.90
    },

    --Braking
    ['fBrakeForce'] = {
        name = 'Brake Force',
        type = 'float',
        defaultMultiplier = 0.60
    },
    ['fHandBrakeForce'] = {
        name = 'Hand Brake Force',
        type = 'float',
        defaultMultiplier = 0.70
    },

    --Steering
    ['fSteeringLock'] = {
        name = 'Steering Lock',
        type = 'float',
        defaultMultiplier = 0.85
    },
        

}

local Handling = {
    default = {
        ['fMass'] = { 
            name = 'Mass',
            type = 'float',
            defaultMultiplier = 1.25
        },
        ['vecCentreOfMassOffset'] = {
            name = 'Centre of Mass Offset',
            type = 'vector3',
            defaultOffset = vector3(0.0, 0.0, -0.05)
        },
        
        --Suspension
        ['fSuspensionForce'] = {
            name = 'Suspension Force',
            type = 'float',
            defaultMultiplier = 0.80
        },
        ['fSuspensionCompDamp'] = {
            name = 'Suspension Compression Damping',
            type = 'float',
            defaultMultiplier = 0.70
        },
        ['fSuspensionReboundDamp'] = {
            name = 'Suspension Rebound Damping',
            type = 'float',
            defaultMultiplier = 0.75
        },
        ['fAntiRollBarForce'] = {
            name = 'Anti Roll Bar Force',
            type = 'float',
            defaultMultiplier = 0.40
        },

        --Traction
        ['fTractionCurveMax'] = {
            name = 'Traction Curve Max',
            type = 'float',
            part = 'wheels',
            defaultMultiplier = 0.80
        },
        ['fTractionCurveMin'] = {
            name = 'Traction Curve Min',
            type = 'float',
            part = 'wheels',
            defaultMultiplier = 1.10
        },
        ['fTractionLossMult'] = {
            name = 'Traction Loss Multiplier',
            type = 'float',
            part = 'wheels',
            defaultMultiplier = 1.20
        },
        ['fLowSpeedTractionLossMult'] = {
            name = 'Low Speed Traction Loss Multiplier',
            type = 'float',
            part = 'wheels',
            defaultMultiplier = 1.20
        },
        ['fInitialDragCoeff'] = {
            name = 'Initial Drag Coefficient',
            type = 'float',
            part = 'wheels',
            defaultMultiplier = 1.10
        },

        --Braking
        ['fBrakeForce'] = {
            name = 'Brake Force',
            type = 'float',
            defaultMultiplier = 0.60
        },
        ['fHandBrakeForce'] = {
            name = 'Hand Brake Force',
            type = 'float',
            defaultMultiplier = 0.70
        },

        --Steering
        ['fSteeringLock'] = {
            name = 'Steering Lock',
            type = 'float',
            defaultMultiplier = 0.85
        },
    },

    class = {
        [0] = {}, --Compact
        [1] = {}, --Sedan
        [2] = {}, --SUV
        [3] = {}, --Coupes
        [4] = {}, --Muscle
        [5] = {}, --Sports Classics
        [6] = {}, --Sports
        [7] = {}, --Super
        [8] = {}, --Motorcycles
        [9] = {   --Offroad
            ['fMass'] = {defaultMultiplier = 1.40},
            ['fSuspensionForce'] = {defaultMultiplier = 0.65},
            ['fBrakeForce'] = {defaultMultiplier = 0.50},
        }, 
        [10] = {}, --Industrial
        [11] = {}, --Utility
        [12] = {}, --Vans
    },

    model = {
        --['model_name'] = {
        --    ['fMass'] = {defaultMultiplier = 1.10},
        --    ['fSuspensionForce'] = {defaultMultiplier = 0.95},
        --    ['fBrakeForce'] = {defaultMultiplier = 0.80},
        --},
    },

    parts = {
        wheels = {
            street = {
                ['fTractionCurveMax'] = 1.00,
                ['fTractionCurveMin'] = 1.00,
                ['fTractionLossMult'] = 1.00,
                ['fLowSpeedTractionLossMult'] = 1.00,
                ['fInitialDragCoeff'] = 1.00,
            },
            sport = {
                ['fTractionCurveMax'] = 1.04,
                ['fTractionCurveMin'] = 1.03,
                ['fTractionLossMult'] = 0.96,
                ['fLowSpeedTractionLossMult'] = 0.92,
                ['fInitialDragCoeff'] = 1.01,
            },
            slick = {
                ['fTractionCurveMax'] = 1.08,
                ['fTractionCurveMin'] = 1.06,
                ['fTractionLossMult'] = 0.92,
                ['fLowSpeedTractionLossMult'] = 0.88,
                ['fInitialDragCoeff'] = 1.02,
            },
            offroad = {
                ['fTractionCurveMax'] = 0.96,
                ['fTractionCurveMin'] = 0.94,
                ['fTractionLossMult'] = 1.08,
                ['fLowSpeedTractionLossMult'] = 1.10,
                ['fInitialDragCoeff'] = 1.03,
            },
        },
    },
}

return Handling
