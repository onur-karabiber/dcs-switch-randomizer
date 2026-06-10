-- =============================================================================
-- CockpitRandomizer — f5e.lua
-- F-5E Tiger II
-- Switch table for: F-5E-3
--
-- Device IDs: devices.lua (counter order)
--   CONTROL_INTERFACE  =  2    ELEC_INTERFACE   =  3
--   FUEL_INTERFACE     =  4    ENGINE_INTERFACE =  6
--   GEAR_INTERFACE     =  7    OXYGEN_INTERFACE =  8
--   ECS_INTERFACE      =  9    EXTLIGHTS_SYSTEM = 11
--   INTLIGHTS_SYSTEM   = 12    CMDS             = 13
--   WEAPONS_CONTROL    = 15    AHRS             = 16
--   AN_APQ159          = 17    AN_ASG31         = 18
--   RWR_IC             = 19    AN_ALR87         = 20
--   IFF                = 22    UHF_RADIO        = 23
--   TACAN_CTRL_PANEL   = 41    SIGHT_CAMERA     = 21
--
-- Landing Gear and Canopy excluded per request.
-- Momentary / spring-loaded positions excluded throughout.
-- CB (circuit breaker) buttons excluded — not meaningful for cold-start immersion.
--
-- HOW vals WORK (delta semantics — not absolute positions):
--   performClickableAction(cmd, val) applies val as a DELTA to the current
--   arg value, clamped to arg_lim. It does NOT set an absolute position.
--
--   val = 0   → no movement, switch stays at cold-start default
--   val = +1  → arg increases (moves toward upper limit)
--   val = -1  → arg decreases (moves toward lower limit)
--   val = +d  → multiposition: one step forward  (d = switch delta)
--   val = -d  → multiposition: one step backward
--
-- DEFAULT WEIGHT POLICY:
--   All fixed-position switches have their default delta (0 = stay) weighted
--   at 85%–90% of the vals pool. Continuous axis knobs are exempt.
-- =============================================================================

CR.register("F-5E-3", {
    { dev=12, cmd=3007, vals={0, 0.25, 0.5, 0.75, 1},  label="Armament Panel Lights Knob" },

    { dev=15, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Centerline" },

    { dev=15, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Left Inbd" },

    { dev=15, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Left Outbd" },

    -- Armament Position Selectors | default_2_position_tumb2 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 95%, default) / ON=-1 (chance: 5%)
    { dev=15, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Left Wingtip" },

    { dev=15, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Right Inbd" },

    { dev=15, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Right Outbd" },

    { dev=15, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Armament Selector - Right Wingtip" },

    -- Auto Flap System Thumb Switch | default_3_position_tumb | arg 115 | arg_lim={-1,1}
    -- UP=arg=-1 / FIXED=arg=0 (center, default) / AUTO=arg=+1
    -- Cold start: FIXED (arg=0). val=0 → stay (default). val=-1 → UP. val=+1 → AUTO.
    -- FIXED=stay (chance: 88%, default) / UP=-1 (chance: 6%) / AUTO=+1 (chance: 6%)
    { dev=2, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="Auto Flap System Thumb Switch" },

    -- Bombs Arm Switch | multiposition_switch, count=4, delta=0.2, min=0.2 | arg 341 | arg_lim={0.2,0.8}
    -- SAFE=0.2 / TAIL=0.4 / NOSE&TAIL=0.6 / NOSE=0.8
    -- Cold start: SAFE (arg=0.2, leftmost). val=0 → stay SAFE (default). val=+0.2 → TAIL.
    -- SAFE=stay (chance: 88%, default) / TAIL=+0.2 (chance: 7%) / NOSE&TAIL=+0.4 (chance: 3%) / NOSE=+0.6 (chance: 2%)
    { dev=15, cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.4, 0.6},  label="Bombs Arm Switch" },

    -- Cabin Press Switch | default_3_position_tumb2 | arg 371 | arg_value_=0.5, arg_lim={0,1}
    -- DEFOG ONLY=0 / NORMAL=0.5 (center, default) / RAM DUMP=1.0
    -- Cold start: NORMAL (arg=0.5). val=0 → stay NORMAL (default). val=-0.5 → DEFOG. val=+0.5 → RAM DUMP.
    -- NORMAL=stay (chance: 88%, default) / DEFOG=-0.5 (chance: 6%) / RAM DUMP=+0.5 (chance: 6%)
    { dev=9, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, 0.5},  label="Cabin Press Switch" },

    -- Cabin Press Switch Cover | default_red_cover | arg 370 | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=9, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Cabin Press Switch Cover" },

    -- Cabin Temp Switch | multiposition_switch_2_cl, count=7, delta=0.1, inversed_=true | arg 372
    -- inversed: arg_value={+delta,-delta}. arg_lim={0,0.6}. Cold start: AUTO.
    -- With inversed_=true, leftmost position (AUTO) corresponds to arg=0.6, rightmost to arg=0.
    -- Cold start: AUTO (arg=0.6, leftmost visual). val=0 → stay AUTO (default). val=-0.1 → next step.
    -- AUTO=stay (chance: 88%, default) / adjacent steps ~4% each / far steps ~1% each
    { dev=9, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.2, -0.3, -0.4, -0.5, -0.6},  label="Cabin Temp Switch" },

    -- Cabin Temperature Knob | default_axis_limited, continuous | arg 373
    -- Exempt: continuous axis, no fixed default position
    { dev=9, cmd=3004, vals={-1, -0.5, 0, 0.5, 1},  label="Cabin Temperature Knob" },

    -- Canopy Defog Knob | default_axis_limited, continuous | arg 374
    -- Exempt: continuous axis, no fixed default position
    { dev=9, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1},  label="Canopy Defog Knob" },

    -- CB 26 Volt AC Power | default_CB_button | arg 453 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3041, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB 26 Volt AC Power" },

    -- CB ATTD & HDG Ref Sys A | default_CB_button | arg 454 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3042, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB ATTD & HDG Ref Sys A" },

    -- CB ATTD & HDG Ref Sys B | default_CB_button | arg 461 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3046, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB ATTD & HDG Ref Sys B" },

    -- CB ATTD & HDG Ref Sys C | default_CB_button | arg 468 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3051, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB ATTD & HDG Ref Sys C" },

    -- CB Cabin Air Valves | default_CB_button | arg 234 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3030, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Cabin Air Valves" },

    -- CB Cabin Cond | default_CB_button | arg 464 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3049, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Cabin Cond" },

    -- CB Caution & Warn Lights-DIM | default_CB_button | arg 244 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3034, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Caution & Warn Lights-DIM" },

    -- CB Central Air Data Computer | default_CB_button | arg 455 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3043, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Central Air Data Computer" },

    -- CB Emergency All Jettison | default_CB_button | arg 289 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3027, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Emergency All Jettison" },

    -- CB Eng IGN L Eng Inst & HYD IND | default_CB_button | arg 456 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3044, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Eng IGN L Eng Inst & HYD IND" },

    -- CB Fuel QTY Primary | default_CB_button | arg 467 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3050, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Fuel QTY Primary" },

    -- CB Ignition Inverter Power | default_CB_button | arg 473 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3055, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Ignition Inverter Power" },

    -- CB Inst Lights | default_CB_button | arg 238 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3031, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Inst Lights" },

    -- CB Jettison Control | default_CB_button | arg 286 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3026, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Jettison Control" },

    -- CB L Boost CL & Tip Tank Fuel Cont | default_CB_button | arg 472 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3054, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB L Boost CL & Tip Tank Fuel Cont" },

    -- CB L Eng Aux Door | default_CB_button | arg 463 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3048, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB L Eng Aux Door" },

    -- CB L Eng Start & AB Cont | default_CB_button | arg 474 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3056, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB L Eng Start & AB Cont" },

    -- CB LDG-Taxi Lamp PWR | default_CB_button | arg 246 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3036, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB LDG-Taxi Lamp PWR" },

    -- CB Left AIM-9 Cont | default_CB_button | arg 290 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3024, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Left AIM-9 Cont" },

    -- CB Left AIM-9 Power | default_CB_button | arg 450 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3037, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Left AIM-9 Power" },

    -- CB Left Gun Firing | default_CB_button | arg 451 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3039, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Left Gun Firing" },

    -- CB Left LE Flap Cont | default_CB_button | arg 477 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3059, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Left LE Flap Cont" },

    -- CB Left TE Flap Cont | default_CB_button | arg 479 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3061, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Left TE Flap Cont" },

    -- CB OXY QTY & Canopy Seal | default_CB_button | arg 245 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3035, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB OXY QTY & Canopy Seal" },

    -- CB Pitot Heater | default_CB_button | arg 231 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3028, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Pitot Heater" },

    -- CB Pylon Tank Fuel Cont | default_CB_button | arg 471 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3053, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Pylon Tank Fuel Cont" },

    -- CB R Eng Aux Doors | default_CB_button | arg 239 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3032, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB R Eng Aux Doors" },

    -- CB R Eng Start & AB Cont | default_CB_button | arg 475 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3057, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB R Eng Start & AB Cont" },

    -- CB R Oil & HYD IND Fuel QTY Sel | default_CB_button | arg 233 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3029, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB R Oil & HYD IND Fuel QTY Sel" },

    -- CB Right AIM-9 Cont | default_CB_button | arg 291 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3025, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Right AIM-9 Cont" },

    -- CB Right AIM-9 Power | default_CB_button | arg 457 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3038, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Right AIM-9 Power" },

    -- CB Right Gun Firing | default_CB_button | arg 458 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3040, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Right Gun Firing" },

    -- CB Right LE Flap Cont | default_CB_button | arg 478 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3060, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Right LE Flap Cont" },

    -- CB Right TE Flap Cont & IND | default_CB_button | arg 480 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3062, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Right TE Flap Cont & IND" },

    -- CB TACAN | default_CB_button | arg 469 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3052, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB TACAN" },

    -- CB Total Temp Probe HTR | default_CB_button | arg 462 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3047, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Total Temp Probe HTR" },

    -- CB Trim Control | default_CB_button | arg 460 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3045, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB Trim Control" },

    -- CB UHF Command Radio | default_CB_button | arg 476 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3058, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB UHF Command Radio" },

    -- CB WPN Arming | default_CB_button | arg 284 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3021, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN Arming" },

    -- CB WPN Mode Sel & AIM-9 Intlk | default_CB_button | arg 288 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3023, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN Mode Sel & AIM-9 Intlk" },

    -- CB WPN PWR Center Line | default_CB_button | arg 281 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3018, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN PWR Center Line" },

    -- CB WPN PWR Left Inbd | default_CB_button | arg 280 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3017, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN PWR Left Inbd" },

    -- CB WPN PWR Left Outbd | default_CB_button | arg 283 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3016, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN PWR Left Outbd" },

    -- CB WPN PWR Right Inbd | default_CB_button | arg 282 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3019, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN PWR Right Inbd" },

    -- CB WPN PWR Right Outbd | default_CB_button | arg 285 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3020, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN PWR Right Outbd" },

    -- CB WPN Release | default_CB_button | arg 287 | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default, 99%). val=1 → OFF.
    { dev=3, cmd=3022, vals={false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true},  label="CB WPN Release" },
    -- Chaff Mode Selector | multiposition_switch, count=4, delta=0.1 | arg 400 | arg_lim={0,0.3}
    -- OFF=0 / SINGLE=0.1 / PRGM=0.2 / MULT=0.3
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → SINGLE.
    -- OFF=stay (chance: 88%, default) / SINGLE=+0.1 (chance: 7%) / PRGM=+0.2 (chance: 3%) / MULT=+0.3 (chance: 2%)
    { dev=13, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3},  label="Chaff Mode Selector" },

    -- Compass Switch | default_button_tumb, TUMB side | arg 220 | arg_lim={0,1}
    -- BTN side = FAST SLAVE (momentary) → excluded. TUMB side: DIR GYRO/MAG.
    -- MAG/OFF. Cold start: MAG (arg=0). val=0 → stay MAG (default). val=+1 → DIR GYRO.
    -- MAG=stay (chance: 88%, default) / DIR GYRO=+1 (chance: 12%)
    { dev=16, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Compass Switch" },

    { dev=12, cmd=3006, vals={0, 0.25, 0.5, 0.75, 1},  label="Console Lights Knob" },

    -- Crossfeed Switch | default_2_position_tumb2 | arg 381 | arg_lim={0,1}
    -- OPEN/CLOSED. Cold start: CLOSED (arg=1). val=0 → stay CLOSED (default). val=-1 → OPEN.
    -- CLOSED=stay (chance: 90%, default) / OPEN=-1 (chance: 10%)
    { dev=4, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Crossfeed Switch" },

    -- Engine Anti-Ice Switch | default_2_position_tumb2 | arg 376 | arg_lim={0,1}
    -- ENGINE/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ENGINE.
    -- OFF=stay (chance: 95%, default) / ENGINE=-1 (chance: 5%)
    { dev=6, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Engine Anti-Ice Switch" },

    { dev=12, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1},  label="Engine Instruments Lights Knob" },

    -- Ext Fuel Cl Switch | default_2_position_tumb2 | arg 377 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=4, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Ext Fuel Cl Switch" },

    -- Ext Fuel Pylons Switch | default_2_position_tumb2 | arg 378 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=4, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Ext Fuel Pylons Switch" },

    -- Exterior Lights Beacon Switch | default_2_position_tumb2 | arg 229 | arg_lim={0,1}
    -- BEACON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → BEACON.
    -- OFF=stay (chance: 90%, default) / BEACON=-1 (chance: 10%)
    { dev=11, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Exterior Lights Beacon Switch" },

    -- Exterior Lights Formation Knob | default_axis_limited, continuous | arg 228
    -- Exempt: continuous knob, no fixed default position
    { dev=11, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1},  label="Exterior Lights Formation Knob" },

    -- Exterior Lights Nav Knob | default_axis_limited, continuous | arg 227
    -- Exempt: continuous knob, no fixed default position
    { dev=11, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1},  label="Exterior Lights Nav Knob" },

    -- External Stores Selector | multiposition_switch, count=4, delta=0.1 | arg 344 | arg_lim={0,0.3}
    -- RIPL=0 / BOMB=0.1 / SAFE=0.2 / RKT DISP=0.3
    -- Cold start: SAFE (arg=0.2). val=0 → stay SAFE (default). val=-0.1 → BOMB. val=+0.1 → RKT DISP. val=-0.2 → RIPL.
    -- SAFE=stay (chance: 60%, default) / BOMB=-0.1 (chance: 10%) / RKT DISP=+0.1 (chance: 10%) / RIPL=-0.2 (chance: 10%)
    -- Note: val=+0.2 would exceed arg_lim and clamp to 0.3 (RKT DISP, 1 step).
    { dev=15, cmd=3012, vals={0, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.3},  label="External Stores Selector" },

    -- Flaps Lever | default_3_position_tumb | arg 116 | arg_lim={-1,1}
    -- EMER UP=arg=-1 / THUMB SW=arg=0 (center, default) / FULL=arg=+1
    -- Cold start: THUMB SW (arg=0). val=0 → stay (default). val=-1 → EMER UP. val=+1 → FULL.
    -- THUMB SW=stay (chance: 88%, default) / EMER UP=-1 (chance: 6%) / FULL=+1 (chance: 6%)
    { dev=2, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="Flaps Lever" },

    -- Flare Jettison Switch Cover | default_red_cover | arg 408 | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=13, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Flare Jettison Switch Cover" },

    -- Flare Mode Selector | multiposition_switch, count=3, delta=0.1 | arg 404 | arg_lim={0,0.2}
    -- OFF=0 / SINGLE=0.1 / PRGM=0.2
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → SINGLE.
    -- OFF=stay (chance: 88%, default) / SINGLE=+0.1 (chance: 8%) / PRGM=+0.2 (chance: 4%)
    { dev=13, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.2},  label="Flare Mode Selector" },

    { dev=12, cmd=3004, vals={0, 0.25, 0.5, 0.75, 1},  label="Flight Instruments Lights Knob" },

    -- Continuous light knobs — exempt
    { dev=12, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1},  label="Flood Lights Knob" },

    -- Guns/Missile/Camera Switch Cover | default_red_cover | arg 342 | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=15, cmd=3010, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Guns/Missile/Camera Switch Cover" },

    -- IFF MASTER Control Selector | multiposition, count=5, delta=0.1 | arg 200 | arg_lim={0,0.4}
    -- OFF=0 / STBY=0.1 / LOW=0.2 / NORM=0.3 / EMER=0.4
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → STBY.
    -- OFF=stay (chance: 88%, default) / STBY=+0.1 (chance: 7%) / NORM=+0.3 (chance: 3%) / others ~1%
    { dev=22, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.3, 0.2, 0.4},  label="IFF Master Control Selector" },

    -- IFF Code Wheels — exempt: no operationally fixed default (mission-dependent)
    { dev=22, cmd=3001, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},  label="IFF MODE 1 Code Wheel 1" },

    { dev=22, cmd=3002, vals={0, 0.1, 0.2, 0.3},                       label="IFF MODE 1 Code Wheel 2" },

    { dev=22, cmd=3003, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},  label="IFF MODE 3/A Code Wheel 1" },

    { dev=22, cmd=3004, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},  label="IFF MODE 3/A Code Wheel 2" },

    { dev=22, cmd=3005, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},  label="IFF MODE 3/A Code Wheel 3" },

    { dev=22, cmd=3006, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},  label="IFF MODE 3/A Code Wheel 4" },

    -- IFF MODE 4 Control Switch | default_2_position_tumb | arg 208 | arg_lim={0,1}
    -- ON/OUT. Cold start: OUT (arg=1). val=0 → stay OUT (default). val=-1 → ON.
    -- OUT=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=22, cmd=3016, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="IFF MODE 4 Control Switch" },

    -- IFF MODE 4 Monitor Switch | default_3_position_tumb2 | arg 201 | arg_lim={-1,1}
    -- AUDIO=arg=-1 / OUT=arg=0 (center, default) / LIGHT=arg=+1
    -- Cold start: OUT (arg=0). val=0 → stay OUT (default). val=-1 → AUDIO. val=+1 → LIGHT.
    -- OUT=stay (chance: 88%, default) / AUDIO=-1 (chance: 6%) / LIGHT=+1 (chance: 6%)
    { dev=22, cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="IFF MODE 4 Monitor Switch" },

    -- Interval Switch | default_3_position_tumb | arg 340 | arg_lim={-1,1}
    -- .06=arg=-1 / .10=arg=0 (center, default) / .14=arg=+1
    -- Cold start: .10 (arg=0). val=0 → stay (default). val=-1 → .06. val=+1 → .14.
    -- .10=stay (chance: 88%, default) / .06=-1 (chance: 6%) / .14=+1 (chance: 6%)
    { dev=15, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="Interval Switch" },

    -- Landing & Taxi Light Switch | default_2_position_tumb | arg 353 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=11, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Landing & Taxi Light Switch" },

    -- Left Boost Pump Switch | default_2_position_tumb | arg 380 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 95%, default) / ON=-1 (chance: 5%)
    { dev=4, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Left Boost Pump Switch" },

    -- Left Fuel Shutoff Switch Cover | default_red_cover | arg 359 | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 95%, default) / OPEN=+1 (chance: 5%)
    { dev=4, cmd=3010, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Left Fuel Shutoff Switch Cover" },

    -- Magnetic Compass Light Switch | default_2_position_tumb | arg 613 | arg_lim={0,1}
    -- LIGHT/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → LIGHT.
    -- OFF=stay (chance: 90%, default) / LIGHT=-1 (chance: 10%)
    { dev=12, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Magnetic Compass Light Switch" },

    -- Missile Volume Knob | default_axis, continuous | arg 345
    -- Exempt: continuous axis, no fixed default position
    { dev=15, cmd=3015, vals={0, 0.25, 0.5, 0.75, 1},  label="Missile Volume Knob" },

    -- Nav Mode Selector Switch | default_2_position_tumb | arg 273 | arg_lim={0,1}
    -- DF=0 / TACAN=1. Cold start: DF (arg=0). val=0 → stay DF (default). val=+1 → TACAN.
    -- DF=stay (chance: 88%, default) / TACAN=+1 (chance: 12%)
    { dev=16, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Nav Mode Selector Switch" },

    -- Oxygen Diluter Lever | default_2_position_tumb | arg 602 | arg_lim={0,1}
    -- 100%/NORM. Cold start: NORM (arg=1). val=0 → stay NORM (default). val=-1 → 100%.
    -- NORM=stay (chance: 90%, default) / 100%=-1 (chance: 10%)
    { dev=8, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Oxygen Diluter Lever" },

    -- Oxygen Emergency Lever | default_2_position_tumb | arg 601 | arg_lim={0,1}
    -- NORMAL/EMERGENCY. Cold start: NORMAL (arg=0). val=0 → stay NORMAL (default). val=+1 → EMERGENCY.
    -- NORMAL=stay (chance: 90%, default) / EMERGENCY=+1 (chance: 10%)
    { dev=8, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Oxygen Emergency Lever" },

    -- Oxygen Supply Lever | default_2_position_tumb | arg 603 | arg_lim={0,1}
    -- ON/OFF. Cold start: ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=+1 (chance: 10%)
    { dev=8, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Oxygen Supply Lever" },

    -- Pitch Damper Switch | default_2_position_tumb2 | arg 322 | arg_lim={0,1}
    -- PITCH/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → PITCH.
    -- OFF=stay (chance: 90%, default) / PITCH=-1 (chance: 10%)
    { dev=2, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Pitch Damper Switch" },

    -- Pitot Anti-Ice Switch | default_2_position_tumb2 | arg 375 | arg_lim={0,1}
    -- PITOT/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → PITOT.
    -- OFF=stay (chance: 95%, default) / PITOT=-1 (chance: 5%)
    { dev=3, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Pitot Anti-Ice Switch" },

    -- Continuous radar knobs — exempt
    { dev=17, cmd=3006, vals={0, 0.25, 0.5, 0.75, 1},  label="Radar Bright Knob" },

    -- Radar Mode Selector | multiposition_switch, count=4, delta=0.1 | arg 316 | arg_lim={0,0.3}
    -- OFF=0 / STBY=0.1 / OPER=0.2 / TEST=0.3
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → STBY.
    -- OFF=stay (chance: 88%, default) / STBY=+0.1 (chance: 7%) / OPER=+0.2 (chance: 4%) / TEST=+0.3 (chance: 1%)
    { dev=17, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3},  label="Radar Mode Selector" },

    { dev=17, cmd=3007, vals={0, 0.25, 0.5, 0.75, 1},  label="Radar Persistence Knob" },

    -- Radar Range Selector | multiposition_switch, count=4, delta=0.1 | arg 315 | arg_lim={0,0.3}
    -- 5nm=0 / 10nm=0.1 / 20nm=0.2 / 40nm=0.3
    -- Exempt: no operationally fixed cold-start default — uniform sampling
    { dev=17, cmd=3003, vals={0, 0.1, 0.2, 0.3},  label="Radar Range Selector" },

    { dev=17, cmd=3008, vals={0, 0.25, 0.5, 0.75, 1},  label="Radar Video Knob" },

    -- Reticle Intensity Knob | default_axis, continuous | arg 41
    -- Exempt: continuous axis, no fixed default position
    { dev=18, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1},  label="Reticle Intensity Knob" },

    -- Right Boost Pump Switch | default_2_position_tumb | arg 382 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=4, cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Right Boost Pump Switch" },

    -- Right Fuel Shutoff Switch Cover | default_red_cover | arg 361 | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 95%, default) / OPEN=+1 (chance: 5%)
    { dev=4, cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Right Fuel Shutoff Switch Cover" },

    -- Rudder Trim Knob | default_axis_limited, continuous | arg 324
    -- Exempt: continuous axis, no fixed default position
    { dev=2, cmd=3003, vals={-1, -0.5, 0, 0.5, 1},  label="Rudder Trim Knob" },

    -- RWR ALTITUDE Button | default_CB_button, latching | arg 561 | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 88%, default) / ON=+1 (chance: 12%)
    { dev=19, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="RWR Altitude Button" },

    -- Continuous RWR knobs — exempt
    { dev=19, cmd=3012, vals={0, 0.25, 0.5, 0.75, 1},  label="RWR Audio Knob" },

    { dev=19, cmd=3011, vals={0, 0.25, 0.5, 0.75, 1},  label="RWR DIM Knob" },

    -- RWR INT Knob | default_axis_limited, continuous | arg 140
    -- Exempt: continuous axis, no fixed default position
    { dev=20, cmd=3001, vals={0.15, 0.35, 0.55, 0.75, 0.85},  label="RWR INT Knob" },

    -- RWR POWER Button | default_CB_button, latching | arg 575 | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 88%, default) / ON=+1 (chance: 12%)
    { dev=19, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="RWR Power Button" },

    -- Sight BIT Switch | default_3_position_tumb | arg 47 | arg_lim={-1,1}
    -- BIT 1=arg=-1 / OFF=arg=0 (center, default) / BIT 2=arg=+1
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=-1 → BIT 1. val=+1 → BIT 2.
    -- OFF=stay (chance: 88%, default) / BIT 1=-1 (chance: 6%) / BIT 2=+1 (chance: 6%)
    { dev=18, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="Sight BIT Switch" },

    -- Sight Camera FPS Select Switch | default_2_position_tumb | arg 80 | arg_lim={0,1}
    -- 24fps/48fps. Cold start: 24fps (arg=0). val=0 → stay 24fps (default). val=+1 → 48fps.
    -- 24fps=stay (chance: 88%, default) / 48fps=+1 (chance: 12%)
    { dev=21, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Sight Camera FPS Switch" },

    -- Sight Camera Overrun Selector | multiposition_switch, count=4, delta=0.1, inversed_=true | arg 84
    -- inversed: arg_value={+0.1,-0.1}. arg_lim={0,0.3}. leftmost visual = rightmost arg.
    -- 0s=arg=0.3 / 3s=arg=0.2 / 10s=arg=0.1 / 20s=arg=0
    -- Cold start: 0s (arg=0.3). val=0 → stay 0s (default). val=-0.1 → 3s. val=-0.2 → 10s. val=-0.3 → 20s.
    -- 0s=stay (chance: 88%, default) / 3s=-0.1 (chance: 6%) / 10s=-0.2 (chance: 4%) / 20s=-0.3 (chance: 2%)
    { dev=21, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.2, -0.3},  label="Sight Camera Overrun Selector" },

    -- Sight Mode Selector | multiposition_switch, count=5, delta=0.1 | arg 40 | arg_lim={0,0.4}
    -- OFF=0 / MSL=0.1 / A/A1 GUNS=0.2 / A/A2 GUNS=0.3 / MAN=0.4
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → MSL.
    -- OFF=stay (chance: 88%, default) / MSL=+0.1 (chance: 6%) / A/A1=+0.2 (chance: 3%) / others ~1-2%
    { dev=18, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3, 0.4},  label="Sight Mode Selector" },

    -- Speed Brake Switch | default_3_position_tumb | arg 101 | arg_lim={-1,1}
    -- OUT=arg=-1 / OFF=arg=0 (center, default) / IN=arg=+1
    -- Cold start: OFF (arg=0). val=0 → stay (default). val=-1 → OUT. val=+1 → IN.
    -- OFF=stay (chance: 88%, default) / OUT=-1 (chance: 6%) / IN=+1 (chance: 6%)
    { dev=2, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="Speed Brake Switch" },

    -- TACAN Mode Selector | multiposition_switch, count=5, delta=0.1 | arg 262 | arg_lim={0,0.4}
    -- OFF=0 / REC=0.1 / T/R=0.2 / A/A=0.3 / BCN=0.4
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → REC.
    -- OFF=stay (chance: 88%, default) / REC=+0.1 (chance: 6%) / T/R=+0.2 (chance: 3%) / others ~1-2%
    { dev=41, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3, 0.4},  label="TACAN Mode Selector" },

    -- TACAN Signal Volume Knob | default_axis_limited, continuous | arg 261
    -- Exempt: continuous knob, no fixed default position
    { dev=41, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1},  label="TACAN Volume Knob" },

    -- UHF Antenna Selector | multiposition_switch, count=3, delta=0.5 | arg 336 | arg_lim={0,1}
    -- UPPER=0 / AUTO=0.5 (center, default) / LOWER=1.0
    -- Cold start: AUTO (arg=0.5). val=0 → stay AUTO (default). val=-0.5 → UPPER. val=+0.5 → LOWER.
    -- AUTO=stay (chance: 88%, default) / UPPER=-0.5 (chance: 6%) / LOWER=+0.5 (chance: 6%)
    { dev=23, cmd=3016, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, 0.5},  label="UHF Antenna Selector" },

    -- UHF Frequency Mode Selector | multiposition_switch, count=3, delta=0.1 | arg 307 | arg_lim={0,0.2}
    -- MANUAL=0 / PRESET=0.1 / GUARD=0.2
    -- Cold start: PRESET (arg=0.1). val=0 → stay PRESET (default). val=-0.1 → MANUAL. val=+0.1 → GUARD.
    -- PRESET=stay (chance: 88%, default) / MANUAL=-0.1 (chance: 8%) / GUARD=+0.1 (chance: 4%)
    { dev=23, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, 0.1, 0.1},  label="UHF Frequency Mode Selector" },

    -- UHF Function Selector | multiposition_switch, count=4, delta=0.1 | arg 311 | arg_lim={0,0.3}
    -- OFF=0 / MAIN=0.1 / BOTH=0.2 / ADF=0.3
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1 → MAIN.
    -- OFF=stay (chance: 88%, default) / MAIN=+0.1 (chance: 7%) / BOTH=+0.2 (chance: 3%) / ADF=+0.3 (chance: 2%)
    { dev=23, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3},  label="UHF Function Selector" },

    -- UHF Squelch Switch | default_2_position_tumb | arg 308 | arg_lim={0,1}
    -- ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=23, cmd=3010, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="UHF Squelch Switch" },

    -- UHF Volume Knob | default_axis, continuous | arg 309
    -- Exempt: continuous axis, no fixed default position
    { dev=23, cmd=3011, vals={0, 0.25, 0.5, 0.75, 1},  label="UHF Volume Knob" },

    -- Yaw Damper Switch | default_2_position_tumb2 | arg 323 | arg_lim={0,1}
    -- YAW/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → YAW.
    -- OFF=stay (chance: 90%, default) / YAW=-1 (chance: 10%)
    { dev=2, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Yaw Damper Switch" },

    -- Entries excluded from randomization (not applicable or spring-loaded):
    -- Entries excluded from randomization (not applicable or spring-loaded):
    -- Guns/Missile/Camera Switch | default_3_position_tumb | arg 343 | arg_lim={-1,1}
    -- GUNS MSL & CAMR=arg=-1 / OFF=arg=0 (center, default) / CAMR ONLY=arg=+1
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=-1 → GUNS. val=+1 → CAMR.
    -- OFF=stay (chance: 88%, default) / GUNS=-1 (chance: 6%) / CAMR=+1 (chance: 6%)
    -- { dev=15, cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="Guns/Missile/Camera Switch" },
    -- Left Fuel Shutoff Switch | default_2_position_tumb2 | arg 360 | arg_lim={0,1}
    -- OPEN/CLOSED. Cold start: OPEN (arg=0). val=0 → stay OPEN (default). val=+1 → CLOSED.
    -- OPEN=stay (chance: 90%, default) / CLOSED=+1 (chance: 10%)
    -- { dev=4, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Left Fuel Shutoff Switch" },
    -- Right Fuel Shutoff Switch | default_2_position_tumb2 | arg 362 | arg_lim={0,1}
    -- OPEN/CLOSED. Cold start: OPEN (arg=0). val=0 → stay OPEN (default). val=+1 → CLOSED.
    -- OPEN=stay (chance: 90%, default) / CLOSED=+1 (chance: 10%)
    -- { dev=4, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Right Fuel Shutoff Switch" },



}, 3.0)