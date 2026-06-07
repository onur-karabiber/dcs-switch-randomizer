-- =============================================================================
-- DCS Switch Randomizer (DSR) — core.lua
-- Shared engine: aircraft detection, RPM guard, hook chaining, logging.
-- Aircraft-specific switch tables live in separate files (f4e.lua, fa18c.lua…).
-- =============================================================================

CR = {}  -- global: aircraft modules access this without require()

-- =============================================================================
-- SETTINGS
-- =============================================================================
CR.ENABLED        = true
CR.DELAY_SECONDS  = 3.0
CR.RPM_THRESHOLD  = 10.0   -- Both engines must be below this % RPM for cold-start

-- =============================================================================
-- SWITCH REGISTRY  (populated by aircraft modules at load time)
-- =============================================================================
CR.AIRCRAFT = {}
-- Each entry: { switches = {...}, delay = <seconds or nil> }
-- Registered via CR.register(aircraft_name, switches_table, optional_delay)
-- optional_delay overrides CR.DELAY_SECONDS for that aircraft only.
--
-- Switch table entries support two forms:
--   Standard:  { label="..", dev=N, cmd=N, vals={...} }
--   Multi-cmd: { label="..", dev=N, run=function(device) ... end }
-- When sw.run is present, it is called directly and sw.vals/sw.cmd are ignored.
-- sw.run receives the device object; it may call performClickableAction
-- multiple times or perform any other device interaction.

function CR.register(aircraft_name, switches, delay)
    CR.AIRCRAFT[aircraft_name] = { switches = switches, delay = delay }
end

-- =============================================================================
-- INTERNAL STATE
-- =============================================================================
CR._fired    = false
CR._arm_time = nil
CR._armed    = false

-- =============================================================================
-- HELPERS
-- =============================================================================
local function cr_log(msg)
    log.write("DCS_SWITCH_RANDOMIZER", log.INFO, msg)
end

local function cr_get_aircraft()
    local ok, data = pcall(LoGetSelfData)
    if ok and data and data.Name then return data.Name end
    return nil
end

-- Returns true only when both engines are below RPM_THRESHOLD.
-- Fails safe (returns false) if LoGetEngineInfo is unavailable.
local function cr_is_cold_start()
    local ok, eng = pcall(LoGetEngineInfo)
    if not ok or not eng or not eng.RPM then
        cr_log("RPM check: LoGetEngineInfo unavailable — skipping randomizer.")
        return false
    end
    local rpm_l = eng.RPM.left  or 0
    local rpm_r = eng.RPM.right or 0
    cr_log(string.format("RPM check: left=%.1f%%  right=%.1f%%  threshold=%.1f%%",
        rpm_l, rpm_r, CR.RPM_THRESHOLD))
    return (rpm_l < CR.RPM_THRESHOLD) and (rpm_r < CR.RPM_THRESHOLD)
end

local function cr_randomize()
    -- os.time() has 1-second resolution; rapid restarts can produce identical
    -- seeds. os.clock() adds sub-second CPU time, making collisions negligible.
    math.randomseed(os.time() + math.floor(os.clock() * 1e6))
    for _ = 1, math.random(5, 20) do math.random() end

    local ac = cr_get_aircraft()
    if not ac then
        cr_log("Skipping: could not identify aircraft.")
        return
    end

    local entry = CR.AIRCRAFT[ac]
    if not entry then
        cr_log("Skipping: no switch table registered for '" .. ac .. "'.")
        return
    end

    if not cr_is_cold_start() then
        cr_log("Skipping: engines running (RPM >= threshold). Not a cold start.")
        return
    end

    cr_log("Randomizing cockpit on: " .. ac)

    for _, sw in ipairs(entry.switches) do
        local ok2, device = pcall(GetDevice, sw.dev)
        if ok2 and device then
            -- sw.run: multi-command path (custom function, no vals/cmd needed).
            -- sw.vals: standard single-command path.
            local pick
            local ok3, err3 = pcall(function()
                if sw.run then
                    sw.run(device)
                else
                    pick = sw.vals[math.random(#sw.vals)]
                    device:performClickableAction(sw.cmd, pick)
                end
            end)
            if ok3 then
                cr_log(string.format("  %-40s dev=%-3d cmd=%-5s -> %s",
                    sw.label, sw.dev,
                    sw.run and "multi" or tostring(sw.cmd),
                    sw.run and "<custom>"  or tostring(pick)))
            else
                cr_log(string.format("  FAIL: %-40s dev=%d cmd=%s | %s",
                    sw.label, sw.dev,
                    sw.run and "multi" or tostring(sw.cmd),
                    tostring(err3)))
            end
        else
            cr_log(string.format("  GetDevice(%d) failed: %s", sw.dev, sw.label))
        end
    end

    cr_log("Randomizer complete for: " .. ac)
end

-- =============================================================================
-- EXPORT HOOKS
-- Chains into any existing LuaExport* functions already in Export.lua.
-- Safe alongside DCS-BIOS, SRS, Tacview, and similar tools.
-- =============================================================================
local _prev_start = LuaExportStart
function LuaExportStart()
    CR._fired    = false
    CR._armed    = false
    CR._arm_time = nil
    if _prev_start then _prev_start() end
end

local _prev_stop = LuaExportStop
function LuaExportStop()
    CR._fired    = false
    CR._armed    = false
    CR._arm_time = nil
    if _prev_stop then _prev_stop() end
end

local _prev_next = LuaExportActivityNextEvent
function LuaExportActivityNextEvent(t)
    local next_call = t + 0.1

    if CR.ENABLED and not CR._fired then
        if not CR._armed then
            local ac = cr_get_aircraft()
            if ac and ac ~= "" then
                local entry = CR.AIRCRAFT[ac]
                local delay = (entry and entry.delay) or CR.DELAY_SECONDS
                CR._armed    = true
                CR._arm_time = t + delay
                cr_log("Aircraft detected: " .. ac ..
                       " — arming with " .. delay .. "s delay.")
            end
        end

        if CR._armed and t >= CR._arm_time then
            CR._fired = true
            cr_randomize()
        end
    end

    if _prev_next then return _prev_next(t) end
    return next_call
end

-- core.lua loaded. CR is now a global table available to f4e.lua, fa18c.lua, etc.