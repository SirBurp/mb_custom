local Runner = {}

local Config = lib.load('config.main')

-- Run a single test suite and return results
local function runSuite(suiteName)
    local success, suite = pcall(require, suiteName)
    if not success then
        return nil, ('Failed to load %s: %s'):format(suiteName, suite)
    end
    local results = suite.run(Config and Config.tests and Config.tests.settings)
    return results
end

function Runner.runAll()
    lib.print.debug('mb_custom tests: running')
    local okCount = 0
    local total = 0

    local results, err = runSuite('tests.wheels')
    if not results then
        lib.print.error(err)
        return
    end

    for _, r in ipairs(results) do
        total = total + 1
        if r.pass then
            lib.print.debug('PASS:', r.name)
            okCount = okCount + 1
        else
            lib.print.error('FAIL:', r.name, r.note or '')
        end
    end

    -- Odometer tests
    local odResults, odErr = runSuite('tests.odometer')
    if not odResults then
        lib.print.error(odErr)
    else
        for _, r in ipairs(odResults) do
            total = total + 1
            if r.pass then
                lib.print.debug('PASS:', r.name)
                okCount = okCount + 1
            else
                lib.print.error('FAIL:', r.name, r.note or '')
            end
        end
    end

    lib.print.debug(('Tests finished: %d/%d passed'):format(okCount, total))
end

function Runner.registerTargets()
    if not exports or not exports.ox_target then
        lib.print.error('ox_target is not available; cannot register test targets')
        return
    end
    local ox_target = exports.ox_target

    -- If there's a custom tests.targets module, delegate registration to it
    local ok, custom = pcall(require, 'tests.targets')
    if ok and type(custom.register) == 'function' then
        custom.register(ox_target)
        return
    end

    -- Default test targets
    ox_target:addGlobalVehicle({
        {
            name = 'mb_custom:VehicleHandlings',
            icon = 'fa-solid fa-cogs',
            label = 'Show Vehicle Handlings (tests)',
            distance = 2.5,
            canInteract = function(entity) return true end,
            onSelect = function(data)
                require 'modules.menu.menu_handling'(data.entity)
            end
        }
    })
end

function Runner.init()
    -- Auto-register targets/commands based on config
    if not Config or not Config.tests or not Config.tests.enabled then return end
    if Config.tests.registerTargets then
        Runner.registerTargets()
    end
    if Config.tests.registerCommands then
        RegisterCommand('run_tests', function()
            Runner.runAll()
        end, false)
    end
end

return Runner