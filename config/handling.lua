HandlingConfig = {
    Physical = {
        title = "Atributos Físicos",
        icon = "cube",
        params = {
            { field = "handlingName", label = "Nombre de Handling", type = "string", description = "Identificador del handling que usa el vehículo." },
            { field = "fMass", label = "Masa (kg)", type = "float", min = 0.0, max = 10000.0, step = 10.0, description = "Peso del vehículo; afecta colisiones." },
            { field = "fInitialDragCoeff", label = "Coeficiente de Arrastre Inicial", type = "float", min = 10.0, max = 120.0, step = 0.5, description = "Coeficiente aerodinámico; mayor valor reduce velocidad máxima." },
            { field = "fDownforceModifier", label = "Modificador de Down‑force", type = "float", min = 0.0, max = 10.0, step = 0.1, description = "Carga aerodinámica; mayor valor aumenta agarre a alta velocidad." },
            { field = "fPopUpLightRotation", label = "Rotación de Luz Pop‑Up", type = "float", min = 0.0, max = 360.0, step = 1.0, description = "Ángulo de rotación de luces emergentes (pop‑up)." },
            { field = "fPercentSubmerged", label = "Porcentaje Sumersión", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Proporción de altura sumergida antes de flotar." },
            { field = "vecCentreOfMassOffset", label = "Offset del Centro de Masa", type = "vector3", min = {x=-5, y=-5, z=-5}, max = {x=5, y=5, z=5}, step = 0.01, description = "Desplazamiento del centro de gravedad." },
            { field = "vecInertiaMultiplier", label = "Multiplicador de Inercia", type = "vector3", min = {x=0, y=0, z=0}, max = {x=4, y=4, z=4}, step = 0.01, description = "Modifica la inercia del vehículo en cada eje." },
        }
    },

    Transmission = {
        title = "Transmisión / Rendimiento",
        icon = "gear",
        params = {
            { field = "fDriveBiasFront", label = "Distribución Tracción Frontal", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Proporción de potencia al eje delantero." },
            { field = "nInitialDriveGears", label = "Número de Marchas", type = "int", min = 1, max = 10, step = 1, description = "Número de marchas de avance." },
            { field = "fInitialDriveForce", label = "Fuerza de Conducción", type = "float", min = 0.01, max = 2.0, step = 0.01, description = "Fuerza aplicada a las ruedas; mayor = más aceleración." },
            { field = "fDriveInertia", label = "Inercia de Motor", type = "float", min = 0.01, max = 2.0, step = 0.01, description = "Cuánto tarda el motor en reaccionar." },
            { field = "fClutchChangeRateScaleUpShift", label = "Velocidad Cambio Subida", type = "float", min = 0.1, max = 20.0, step = 0.1, description = "Multiplicador de velocidad al subir marcha." },
            { field = "fClutchChangeRateScaleDownShift", label = "Velocidad Cambio Bajada", type = "float", min = 0.1, max = 20.0, step = 0.1, description = "Multiplicador de velocidad al bajar marcha." },
            { field = "fInitialDriveMaxFlatVel", label = "Velocidad Máx Plana", type = "float", min = 0.0, max = 500.0, step = 1.0, description = "Velocidad máxima teórica en llano." },
        }
    },

    Brakes = {
        title = "Frenos",
        icon = "brake",
        params = {
            { field = "fBrakeForce", label = "Fuerza de Frenado", type = "float", min = 0.1, max = 10.0, step = 0.01, description = "Fuerza total de frenado; mayor = frena más rápido." },
            { field = "fBrakeBiasFront", label = "Bias de Frenado Frontal", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Distribución del frenado entre ejes." },
            { field = "fHandBrakeForce", label = "Fuerza del Freno de Mano", type = "float", min = 0.1, max = 10.0, step = 0.01, description = "Fuerza aplicada al freno de mano." },
        }
    },

    Traction = {
        title = "Tracción",
        icon = "road",
        params = {
            { field = "fTractionCurveMax", label = "Curva de Tracción Máxima", type = "float", min = 0.0, max = 5.0, step = 0.01, description = "Agarre máximo de los neumáticos." },
            { field = "fTractionCurveMin", label = "Curva de Tracción Mínima", type = "float", min = 0.0, max = 5.0, step = 0.01, description = "Agarre mínimo; afecta derrape." },
            { field = "fTractionCurveLateral", label = "Curva de Tracción Lateral", type = "float", min = 0.0, max = 35.0, step = 0.01, description = "Ángulo lateral a partir del cual empieza a perder tracción." },
            { field = "fTractionBiasFront", label = "Bias de Tracción Frontal", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Distribución de agarre entre ejes." },
            { field = "fTractionLossMult", label = "Multiplicador de Pérdida de Tracción", type = "float", min = 0.0, max = 2.0, step = 0.01, description = "Cuánto rápido pierden tracción las ruedas." },
        }
    },

    Suspension = {
        title = "Suspensión",
        icon = "cogs",
        params = {
            { field = "fSuspensionForce", label = "Fuerza de Suspensión", type = "float", min = 0.1, max = 10.0, step = 0.01, description = "Fuerza de la suspensión; mayor = más rígida." },
            { field = "fSuspensionCompDamp", label = "Amortiguación de Compresión", type = "float", min = 0.0, max = 5.0, step = 0.01, description = "Resistencia al comprimirse la suspensión." },
            { field = "fSuspensionReboundDamp", label = "Amortiguación de Rebote", type = "float", min = 0.0, max = 5.0, step = 0.01, description = "Resistencia al extender la suspensión." },
            { field = "fSuspensionUpperLimit", label = "Límite Superior", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Altura máxima de la suspensión." },
            { field = "fSuspensionLowerLimit", label = "Límite Inferior", type = "float", min = -1.0, max = 0.0, step = 0.01, description = "Altura mínima de la suspensión." },
            { field = "fSuspensionRaise", label = "Elevación de Suspensión", type = "float", min = -0.5, max = 0.5, step = 0.01, description = "Offset vertical de toda la suspensión." },
            { field = "fAntiRollBarForce", label = "Fuerza Anti‑roll‑bar", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Resistencia al balanceo lateral." },
            { field = "fRollCentreHeightFront", label = "Altura Roll Centre Delantero", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Altura del punto de balanceo delantero." },
            { field = "fRollCentreHeightRear", label = "Altura Roll Centre Trasero", type = "float", min = 0.0, max = 1.0, step = 0.01, description = "Altura del punto de balanceo trasero." },
        }
    },

    Damage = {
        title = "Daño",
        icon = "exclamation-triangle",
        params = {
            { field = "fCollisionDamageMult", label = "Multiplicador Daño Colisión", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Daño por colisiones; 0 = indestructible." },
            { field = "fWeaponDamageMult", label = "Multiplicador Daño Armas", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Daño por armas." },
            { field = "fDeformationDamageMult", label = "Multiplicador Deformación", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Multiplicador de deformación visible." },
            { field = "fEngineDamageMult", label = "Multiplicador Daño Motor", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Daño al motor; 0 = indestructible." },
            { field = "fPetrolTankVolume", label = "Volumen Tanque Combustible", type = "float", min = 10.0, max = 200.0, step = 1.0, description = "Capacidad del tanque en litros." },
        }
    },

    SubHandling = {
        title = "SubHandling",
        icon = "car-side",
        params = {
            { field = "fBackEndPopUpCarImpulseMult", label = "Impulso Posterior Vehículo", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Multiplicador de impulso trasero al chocar con vehículos." },
            { field = "fBackEndPopUpBuildingImpulseMult", label = "Impulso Posterior Edificio", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Multiplicador de impulso trasero al chocar con edificios." },
            { field = "fToeFront", label = "Toe Delantero", type = "float", min = -0.5, max = 0.5, step = 0.01, description = "Ángulo de convergencia ruedas delanteras." },
            { field = "fToeRear", label = "Toe Trasero", type = "float", min = -0.5, max = 0.5, step = 0.01, description = "Ángulo de convergencia ruedas traseras." },
            { field = "fCamberFront", label = "Camber Delantero", type = "float", min = -5.0, max = 5.0, step = 0.01, description = "Inclinación ruedas delanteras; positiva = hacia afuera." },
            { field = "fCamberRear", label = "Camber Trasero", type = "float", min = -5.0, max = 5.0, step = 0.01, description = "Inclinación ruedas traseras." },
            { field = "fCastor", label = "Caster", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Ángulo de caster; afecta estabilidad direccional." },
            { field = "fEngineResistance", label = "Resistencia Motor", type = "float", min = 0.0, max = 10.0, step = 0.01, description = "Resistencia interna del motor; valores altos reducen aceleración." },
        }
    }
}


return HandlingConfig