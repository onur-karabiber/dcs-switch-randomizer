-- =============================================================================
-- CockpitRandomizer v3.1
-- F-4E Phantom II | Pilot seat
--
-- Author  : Onur Karabiber
-- File    : Saved Games\DCS\Scripts\CockpitRandomizer_Export.lua
--
-- PURPOSE:
--   DCS always places you in a "clean" cockpit — every switch is in its
--   factory-default position. For cold-start scenarios this breaks immersion:
--   a real aircraft coming out of a previous sortie would have switches left
--   in various states by the last crew. This script randomizes a curated set
--   of cockpit controls each time you sit down for a cold start, so you are
--   forced to perform a proper interior check before doing anything else.
--
-- COLD-START GUARD:
--   Randomization only fires when BOTH engines are below RPM_THRESHOLD (10%).
--   Taxi, runway hold, and in-flight slots are automatically skipped.
--
-- COMPATIBILITY:
--   Tested on DCS World (Steam) with the Heatblur F-4E Phantom II module.
--   The script chains into existing Export hooks and does not conflict with
--   DCS-BIOS, SRS, or other tools that use Export.lua.
-- =============================================================================

local CR = {}

-- =============================================================================
-- SETTINGS  — edit these to your preference
-- =============================================================================

-- Set to false to disable the script without uninstalling it.
CR.ENABLED         = true

-- Seconds to wait after the cockpit is detected before randomizing.
-- Increase this if switches snap back to default (cockpit still initializing).
CR.DELAY_SECONDS   = 3.0

-- Only randomize this aircraft. Set to "" to run on any aircraft.
CR.TARGET_AIRCRAFT = "F-4E-45MC"

-- Both engines must be BELOW this RPM % for cold-start to be detected.
-- F-4E idle is ~55–65 % RPM; 10 % is a safe lower bound.
CR.RPM_THRESHOLD   = 10.0

-- =============================================================================
-- SWITCH TABLE
--
-- Each entry: { dev=<device_id>, cmd=<command_id>, vals={...}, label="..." }
--
-- vals is the list of positions the switch can be randomly placed in.
-- Repeating a value increases its probability (e.g. {0,0,0,1} = 75% chance of 0).
-- Spring-loaded positions (momentary) are excluded from all entries.
--
-- Value ranges by widget type:
--   default_2_position_tumb          {0, 1}
--   default_3_position_0_to_1_tumb   {0, 0.5, 1}
--   multiposition_switch_limited     0, step, 2*step … (n-1)*step
--   multiposition_roller_limited     0 … 1  (n positions, equal spacing)
--   multiposition_switch             0 … 1  (n positions, 1/(n-1) spacing)
--   default_circuit_breaker          {0, 1}  (0 = pushed in / active)
--   default_axis                     0 … 1  (sampled at discrete steps)
-- =============================================================================
CR.SWITCHES = {

    -- -------------------------------------------------------------------------
    -- COUNTERMEASURES
    -- -------------------------------------------------------------------------

    -- Select Dispense Program (AN/ALE-40)
    -- 0 = NORMAL (default), 1 = SALVO
    { dev=5,  cmd=3001, vals={0,1},                    label="Select Dispense Program" },

    -- -------------------------------------------------------------------------
    -- COMMUNICATIONS
    -- -------------------------------------------------------------------------

    -- Set Mode (ICS Panel)  — spring-loaded upper pos (Radio Override) excluded
    -- -1 = COLD MIC, 0 = HOT MIC (default)
    { dev=2,  cmd=3005, vals={-1,0},                   label="Set Mode (ICS)" },

    -- Select Communication Antenna
    -- 0 = UPR (default), 1 = LWR
    { dev=3,  cmd=3001, vals={0,1},                    label="Comm Antenna" },

    -- Select Radio Mode  (6-position roller)
    -- 0=OFF(default), 0.2=T, 0.4=T/R, 0.6=A/G, 0.8=SQL, 1.0=G
    { dev=3,  cmd=3004, vals={0,0.2,0.4,0.6,0.8,1.0}, label="Select Radio Mode" },

    -- Select Frequency Mode
    -- 0 = PRESET (default), 1 = MANUAL
    { dev=3,  cmd=3026, vals={0,1},                    label="Select Frequency Mode" },

    -- -------------------------------------------------------------------------
    -- IFF
    -- -------------------------------------------------------------------------

    -- Select Master Mode  (5-position, 0.25 step)
    -- 0=OFF(default), 0.25=SBY, 0.5=NORM, 0.75=EMER, 1.0=IDENT
    { dev=4,  cmd=3005, vals={0,0.25,0.5,0.75,1.0},   label="IFF Master Mode" },

    -- -------------------------------------------------------------------------
    -- FUEL SYSTEM
    -- -------------------------------------------------------------------------

    -- Wing Fuel Dump Selector
    -- 0 = NORM (default), 1 = DUMP
    { dev=60, cmd=3003, vals={0,1},                    label="Wing Fuel Dump" },

    -- Internal Wing Tanks Feed
    -- 0 = NORMAL (default), 1 = TRANSFER
    { dev=60, cmd=3004, vals={0,1},                    label="Internal Wing Tanks Feed" },

    -- -------------------------------------------------------------------------
    -- FLIGHT CONTROLS / AFCS
    -- -------------------------------------------------------------------------

    -- STAB AUG Yaw
    -- 0 = off (default), 1 = ENGAGE
    { dev=9,  cmd=3010, vals={0,1},                    label="STAB AUG Yaw" },

    -- STAB AUG Roll
    -- 0 = off (default), 1 = ENGAGE
    { dev=9,  cmd=3012, vals={0,1},                    label="STAB AUG Roll" },

    -- STAB AUG Pitch
    -- 0 = off (default), 1 = ENGAGE
    { dev=9,  cmd=3014, vals={0,1},                    label="STAB AUG Pitch" },

    -- AFCS Autopilot
    -- 0 = AFCS (default), 1 = ENGAGE
    { dev=9,  cmd=3016, vals={0,1},                    label="AFCS Autopilot" },

    -- ALT Hold
    -- 0 = ALT (default), 1 = ENGAGE
    { dev=9,  cmd=3018, vals={0,1},                    label="ALT Hold" },

    -- -------------------------------------------------------------------------
    -- LANDING GEAR / BRAKES
    -- -------------------------------------------------------------------------

    -- Anti-Skid Toggle
    -- 0 = OFF (default), 1 = ON
    { dev=20, cmd=3002, vals={0,1},                    label="Anti-Skid" },

    -- Emergency Wheel Brake  (handle / axis)
    -- 0 = stowed (default) — weighted 50%, 0.3/0.6/1.0 = partially/fully pulled
    { dev=20, cmd=3004, vals={0,0,0,0.3,0.6,1.0},     label="Emergency Wheel Brake" },

    -- -------------------------------------------------------------------------
    -- NAVIGATION
    -- -------------------------------------------------------------------------

    -- Select Reference System (ADI)
    -- 0 = STBY (default), 1 = PRIM
    { dev=44, cmd=3002, vals={0,1},                    label="Select Reference System" },

    -- Select TACAN Mode  (5-position roller)
    -- 0=OFF(default), 0.25=REC, 0.5=T/R, 0.75=A/A, 1.0=BCN
    { dev=48, cmd=3006, vals={0,0.25,0.5,0.75,1.0},   label="TACAN Mode" },

    -- Select Navigation Input  (4-position roller)
    -- 0=TACAN, 0.333=VOR/ILS, 0.667=ADF, 1.0=NAV COMP (default)
    -- NAV COMP appears twice → 40% probability of staying at default
    { dev=49, cmd=3001,
      vals={0, 0.333, 0.667, 1.0, 1.0},
      label="Select Navigation Input" },

    -- Select Navigation Mode  (4-position roller)
    -- 0=HDG, 0.333=NAV, 0.667=NAV COMP (default = 3rd pos), 1.0=ATT
    -- Default position appears twice → 40% probability
    { dev=49, cmd=3002,
      vals={0, 0.333, 0.667, 0.667, 1.0},
      label="Select Navigation Mode" },

    -- Toggle Flight Director
    -- 0 = OFF / vertical (default), 1 = ON
    { dev=49, cmd=3003, vals={0,1},                    label="Toggle Flight Director" },

    -- -------------------------------------------------------------------------
    -- HUD
    -- -------------------------------------------------------------------------

    -- Select HUD Mode  (7-position, ~0.1666 step)
    -- 0=OFF(default), 0.1666=NAV, 0.3332=ILS/NAV, 0.4998=ILS/MAN,
    -- 0.6664=A/G, 0.8330=A/A RDR, 1.0=A/A COLL
    { dev=31, cmd=3001,
      vals={0, 0.1666, 0.3332, 0.4998, 0.6664, 0.8330, 1.0},
      label="Select HUD Mode" },

    -- -------------------------------------------------------------------------
    -- WEAPONS
    -- -------------------------------------------------------------------------

    -- Arm Fuze  (4-position, 0.25 step)
    -- 0=SAFE(default) — weighted 60%, 0.25=NOSE, 0.5=TAIL, 0.75=NOSE&TAIL
    { dev=27, cmd=3047,
      vals={0, 0, 0.25, 0.5, 0.75},
      label="Arm Fuze" },

    -- Select Delivery Mode  (13-position, 0.0833 step)
    -- 0=DIRECT, 0.0833=TGT FIND, 0.1666=OFFSET, 0.2499=IP,
    -- 0.3332=TGT FIND 2, 0.4165=LADD, 0.4998=OFF (default, 6th pos),
    -- 0.5831=MAN, 0.6664=INST O/S, 0.7497=OVER SHD,
    -- 0.8330=TL, 0.9163=RL, 1.0=CMPTR
    -- OFF appears three times → ~20% probability
    { dev=27, cmd=3010,
      vals={0, 0.0833, 0.1666, 0.2499, 0.3332, 0.4165,
            0.4998, 0.4998, 0.4998,
            0.5831, 0.6664, 0.7497, 0.8330, 0.9163, 1.0},
      label="Select Delivery Mode" },

    -- Select Quantity  (12-position, 1/11 ≈ 0.0909 step)
    -- 0=1, 0.0909=2, 0.1818=3, 0.2727=4, 0.3636=5, 0.4545=6,
    -- 0.5454=7, 0.6363=8, 0.7272=9, 0.8181=10, 0.9090=11, 1.0=12
    { dev=27, cmd=3021,
      vals={0, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545,
            0.5454, 0.6363, 0.7272, 0.8181, 0.9090, 1.0},
      label="Select Quantity" },

    -- -------------------------------------------------------------------------
    -- OXYGEN SYSTEM
    -- -------------------------------------------------------------------------

    -- Select Oxygen Mixture
    -- 0 = NORMAL OXYGEN (default), 1 = 100% OXYGEN
    { dev=26, cmd=3004, vals={0,1},                    label="Select Oxygen Mixture" },

    -- Emergency Release Cockpit Pressure
    -- 0 = pushed in / sealed (default), 1 = pulled out / venting
    { dev=26, cmd=3012, vals={0,1},                    label="Emergency Release Cockpit Pressure" },

    -- -------------------------------------------------------------------------
    -- CIRCUIT BREAKERS
    -- -------------------------------------------------------------------------

    -- Aileron-Rudder Interconnect (ARI) CB
    -- 0 = pushed in / ARI active (default), 1 = pulled out / disabled
    { dev=84, cmd=3001, vals={0,1},                    label="ARI CB" },

    -- Standby Attitude Indicator CB
    -- 0 = pushed in / AI powered (default), 1 = pulled out / off
    { dev=84, cmd=3009, vals={0,1},                    label="SAI CB" },

    -- -------------------------------------------------------------------------
    -- EXTERIOR LIGHTS
    -- -------------------------------------------------------------------------

    -- Taxi / Landing Light  (3-position)
    -- 0 = LDG LT, 0.5 = OFF (default), 1 = TAXI LT
    { dev=69, cmd=3001, vals={0,0.5,1},                label="Taxi/Landing Light" },

    -- Set Formation Lights Mode  (spring-loaded lower pos excluded)
    -- 0.5 = OFF (default / middle), 1 = BRT (upper)
    { dev=69, cmd=3003, vals={0.5,1},                  label="Formation Lights Mode" },

    -- Change Formation Lights Brightness  (knob, max effective = 0.5)
    { dev=69, cmd=3002, vals={0,0.1,0.2,0.3,0.4,0.5}, label="Formation Lights Brightness" },

    -- -------------------------------------------------------------------------
    -- INTERIOR LIGHTS
    -- -------------------------------------------------------------------------

    -- Set Console Floodlight (Red) Brightness  (3-position)
    -- 0 = MED (lower), 0.5 = OFF (middle / default), 1 = BRT (upper)
    { dev=72, cmd=3011, vals={0,0.5,1},                label="Console Floodlight" },

    -- Change Console Light Brightness  (knob)
    { dev=72, cmd=3012, vals={0,0.25,0.5,0.75,1.0},   label="Console Light Brightness" },

    -- Toggle White Floodlight
    -- 0 = OFF (default), 1 = ON
    { dev=72, cmd=3009, vals={0,1},                    label="White Floodlight" },

    -- Set Instrument Floodlight (Red) Brightness  (3-position)
    -- 0 = DIM (lower), 0.5 = OFF (middle / default), 1 = BRT (upper)
    { dev=72, cmd=3013, vals={0,0.5,1},                label="Instrument Floodlight" },

    -- -------------------------------------------------------------------------
    -- RAIN REMOVAL / ENVIRONMENTAL
    -- -------------------------------------------------------------------------

    -- Toggle Rain Removal
    -- 0 = OFF (default), 1 = ON
    { dev=87, cmd=3005, vals={0,1},                    label="Toggle Rain Removal" },

    -- Change Temperature  (knob — not yet simulated in DCS, visual only)
    { dev=87, cmd=3014, vals={0,0.25,0.5,0.75,1.0},   label="Change Temperature" },

    -- Defog Handle  (slider — not yet simulated in DCS, visual only)
    -- 0 = fully forward, 0.5 = center (default), 1.0 = fully aft
    { dev=87, cmd=3018, vals={0,0.25,0.5,0.75,1.0},   label="Defog Handle" },

    -- -------------------------------------------------------------------------
    -- AUDIO
    -- -------------------------------------------------------------------------

    -- AoA Stall Warning Volume  (knob)
    { dev=13, cmd=3005, vals={0,0.25,0.5,0.75,1.0},   label="Stall Warning Volume" },

    -- Aural Tone Volume  (knob)
    { dev=13, cmd=3001, vals={0,0.25,0.5,0.75,1.0},   label="Aural Tone Volume" },
}

-- =============================================================================
-- INTERNAL STATE  — do not edit
-- =============================================================================
CR._fired    = false
CR._arm_time = nil
CR._armed    = false

-- =============================================================================
-- HELPERS
-- =============================================================================
local function cr_log(msg)
    log.write("COCKPIT_RANDOMIZER", log.INFO, msg)
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
    math.randomseed(os.time())
    for _ = 1, math.random(5, 20) do math.random() end

    local ac = cr_get_aircraft()
    if CR.TARGET_AIRCRAFT ~= "" and ac ~= CR.TARGET_AIRCRAFT then
        cr_log("Skipping: aircraft='" .. tostring(ac) ..
               "', expected='" .. CR.TARGET_AIRCRAFT .. "'")
        return
    end

    if not cr_is_cold_start() then
        cr_log("Skipping: engines running (RPM >= threshold). Not a cold start.")
        return
    end

    cr_log("Randomizing cockpit on: " .. tostring(ac))

    for _, sw in ipairs(CR.SWITCHES) do
        local ok2, device = pcall(GetDevice, sw.dev)
        if ok2 and device then
            local pick = sw.vals[math.random(#sw.vals)]
            local ok3 = pcall(function()
                device:performClickableAction(sw.cmd, pick)
            end)
            if ok3 then
                cr_log(string.format("  %-40s dev=%-3d cmd=%-5d -> %s",
                    sw.label, sw.dev, sw.cmd, tostring(pick)))
            else
                cr_log(string.format("  FAIL: %-40s dev=%d cmd=%d",
                    sw.label, sw.dev, sw.cmd))
            end
        else
            cr_log(string.format("  GetDevice(%d) failed: %s",
                sw.dev, sw.label))
        end
    end

    cr_log("Randomizer v3.1 complete.")
end

-- =============================================================================
-- EXPORT HOOKS
-- Chains into any existing LuaExport* functions already loaded by Export.lua.
-- Safe to use alongside DCS-BIOS, SRS, Tacview, and similar tools.
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
                CR._armed    = true
                CR._arm_time = t + CR.DELAY_SECONDS
                cr_log("Aircraft detected: " .. ac ..
                       " — arming with " .. CR.DELAY_SECONDS .. "s delay.")
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

return CR
