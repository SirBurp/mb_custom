Customs = {
    -- Tests control: configura pruebas locales y parámetros de prueba
    tests = {
        enabled = true,             -- Si true, el runner se carga automáticamente en cliente
        registerCommands = true,    -- Si true, registra el comando `mb_custom:run_tests` en el cliente
        registerTargets = true,     -- Si true, añade targets de prueba usando ox_target
        -- Valores de test personalizables (usados por tests/wheels)
        settings = {
            wearInputs = {0.0, 0.5, 1.0},            -- valores para probar WearCurve
            pressureInputs = {2.2, 2.8, 1.6},        -- valores para probar PressureFactor
            computeHandlingCases = {                 -- lista de casos para ComputeHandling
                {
                    name = 'two perfect street tyres',
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
        }
    }
}



return Customs