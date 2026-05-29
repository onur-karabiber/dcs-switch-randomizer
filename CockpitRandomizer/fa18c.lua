-- =============================================================================
-- CockpitRandomizer — fa18c.lua
-- F/A-18C Hornet | Pilot seat
-- Switch table for: FA-18C_hornet
--
-- Device IDs: DCSWorld\Mods\aircraft\FA-18C\Cockpit\Scripts\devices.lua
-- Command IDs: command_defs.lua (each device table resets to 3001)
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
-- ENCODING CONVENTION used in this file:
--   "stay at default"  → val = 0   (always safe, no movement)
--   "move away"        → val = ±1 or ±delta (one or more steps from default)
--
-- DEFAULT WEIGHT POLICY:
--   All fixed-position switches have their default delta (0 = stay) weighted
--   at 85%–90% of the vals pool. Continuous axis/brightness/volume knobs are
--   exempt and retain uniform sampling.
-- =============================================================================

CR.register("FA-18C_hornet", {

    -- -------------------------------------------------------------------------
    -- OXYGEN SYSTEM   dev=10 (OXYGEN_INTERFACE)
    -- -------------------------------------------------------------------------

    -- OXY Flow Knob | default_axis_limited, continuous | arg 366
    -- Exempt: continuous rotary, no fixed default position
    { dev=10, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},    label="OXY Flow Knob" },

    -- OBOGS Control Switch | default_2_position_tumb | arg 365 | arg_lim={0,1}
    -- Cold start: ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=+1 (chance: 10%)
    { dev=10, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="OBOGS Control Switch" },

    -- -------------------------------------------------------------------------
    -- INTERCOM   dev=40 (INTERCOM)
    -- -------------------------------------------------------------------------

    -- TACAN Volume Knob | default_axis_limited, continuous | arg ~
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3032, vals={0, 0.25, 0.5, 0.75, 1.0},    label="TACAN Volume Knob" },

    -- -------------------------------------------------------------------------
    -- EXTERIOR LIGHTS   dev=8 (EXT_LIGHTS)
    -- -------------------------------------------------------------------------

    -- POSITION Lights Dimmer | default_axis_limited, continuous | arg 338
    -- Exempt: continuous dimmer, no fixed default position
    { dev=8,  cmd=3006, vals={0, 0.25, 0.5, 0.75, 1.0},    label="POSITION Lights Dimmer" },

    -- FORMATION Lights Dimmer | default_axis_limited, continuous | arg 337
    -- Exempt: continuous dimmer, no fixed default position
    { dev=8,  cmd=3008, vals={0, 0.25, 0.5, 0.75, 1.0},    label="FORMATION Lights Dimmer" },

    -- LDG/TAXI LIGHT Switch | default_2_position_tumb | arg 237 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=8,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="LDG/TAXI LIGHT Switch" },

    -- -------------------------------------------------------------------------
    -- COCKPIT LIGHTS   dev=9 (CPT_LIGHTS)
    -- -------------------------------------------------------------------------

    -- HOOK BYPASS Switch | springloaded_2_pos_tumb2 | arg 239
    -- Springloaded: momentary action, val=+1 pulses the switch.
    -- FIELD=stay (chance: 85%, default) / CARRIER pulse=+1 (chance: 15%)
    { dev=9,  cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="HOOK BYPASS Switch" },

    -- CONSOLES Dimmer | default_axis_limited, continuous | arg 413
    -- Exempt: continuous dimmer, no fixed default position
    { dev=9,  cmd=3011, vals={0, 0.25, 0.5, 0.75, 1.0},    label="CONSOLES Dimmer" },

    -- INST PNL Dimmer | default_axis_limited, continuous | arg 414
    -- Exempt: continuous dimmer, no fixed default position
    { dev=9,  cmd=3013, vals={0, 0.25, 0.5, 0.75, 1.0},    label="INST PNL Dimmer" },

    -- FLOOD Dimmer | default_axis_limited, continuous | arg 415
    -- Exempt: continuous dimmer, no fixed default position
    { dev=9,  cmd=3015, vals={0, 0.25, 0.5, 0.75, 1.0},    label="FLOOD Dimmer" },

    -- MODE Switch | default_3_position_tumb | arg 419 | arg_lim={-1,1}
    -- Hint: NVG/NITE/DAY. Cold start: DAY (arg=1, right end).
    -- val=0 → stay DAY (default). val=-1 → NITE. Sending -1 twice → NVG.
    -- DAY=stay (chance: 87%, default) / NITE=-1 (chance: 13%)
    { dev=9,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1},  label="MODE Switch" },

    -- WARN/CAUTION Dimmer | default_axis_limited, continuous | arg 417
    -- Exempt: continuous dimmer, no fixed default position
    { dev=9,  cmd=3023, vals={0, 0.25, 0.5, 0.75, 1.0},    label="WARN/CAUTION Dimmer" },

    -- CHART Dimmer | default_axis_limited, continuous | arg 418
    -- Exempt: continuous dimmer, no fixed default position
    { dev=9,  cmd=3018, vals={0, 0.25, 0.5, 0.75, 1.0},    label="CHART Dimmer" },

    -- -------------------------------------------------------------------------
    -- LANDING GEAR   dev=5 (GEAR_INTERFACE)
    -- -------------------------------------------------------------------------

    -- Anti Skid Switch | default_2_position_tumb | arg 238 | arg_lim={0,1}
    -- Hint: ON/OFF. Cold start: ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=+1 (chance: 10%)
    { dev=5,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="Anti Skid Switch" },

    -- -------------------------------------------------------------------------
    -- HUD   dev=34 (HUD)
    -- -------------------------------------------------------------------------

    -- Altitude Switch | default_2_position_tumb | arg 147 | arg_lim={0,1}
    -- Hint: BARO/RDR. Cold start: BARO (arg=0). val=0 → stay BARO (default). val=+1 → RDR.
    -- BARO=stay (chance: 87%, default) / RDR=+1 (chance: 13%)
    { dev=34, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Altitude Switch" },

    -- HUD Symbology Brightness Selector | default_3_position_tumb | arg 51/76
    -- OFF/NIGHT/DAY, arg_value=0.1, arg_lim={0,0.2}. Cold start: DAY (arg=0.2, right end).
    -- val=0 → stay DAY (default). val=-0.1 → NIGHT. Sending -0.1 twice → OFF.
    -- DAY=stay (chance: 90%, default) / NIGHT=-0.1 (chance: 10%)
    { dev=34, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1},  label="HUD Symbology Brightness Selector" },

    -- -------------------------------------------------------------------------
    -- UFC   dev=25 (UFC)
    -- -------------------------------------------------------------------------

    -- UFC COMM 1 Volume | continuous rotary — no default bias applied
    { dev=25, cmd=3037, vals={0, 0.25, 0.5, 0.75, 1.0},    label="UFC COMM 1 Volume" },

    -- UFC COMM 2 Volume | continuous rotary — no default bias applied
    { dev=25, cmd=3039, vals={0, 0.25, 0.5, 0.75, 1.0},    label="UFC COMM 2 Volume" },

    -- -------------------------------------------------------------------------
    -- MDI LEFT   dev=35 (MDI_LEFT)
    -- -------------------------------------------------------------------------

    -- Left MDI Brightness Selector | default_3_position_tumb | arg 51 | arg_lim={0,0.2}
    -- OFF/NIGHT/DAY. Cold start: DAY (arg=0.2, right end).
    -- val=0 → stay DAY (default). val=-0.1 → NIGHT.
    -- DAY=stay (chance: 90%, default) / NIGHT=-0.1 (chance: 10%)
    { dev=35, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1},  label="Left MDI Brightness Selector" },

    -- -------------------------------------------------------------------------
    -- MDI RIGHT   dev=36 (MDI_RIGHT)
    -- -------------------------------------------------------------------------

    -- Right MDI Brightness Selector | default_3_position_tumb | arg 76 | arg_lim={0,0.2}
    -- OFF/NIGHT/DAY. Cold start: DAY (arg=0.2, right end).
    -- val=0 → stay DAY (default). val=-0.1 → NIGHT.
    -- DAY=stay (chance: 90%, default) / NIGHT=-0.1 (chance: 10%)
    { dev=36, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1},  label="Right MDI Brightness Selector" },

    -- -------------------------------------------------------------------------
    -- AMPCD   dev=37 (AMPCD)
    -- -------------------------------------------------------------------------

    -- AMPCD Off/Brightness Knob | default_axis_limited, continuous | arg 203
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=37, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1.0},    label="AMPCD Off/Brightness Knob" },

    -- -------------------------------------------------------------------------
    -- WEAPONS   dev=23 (SMS)
    -- -------------------------------------------------------------------------

    -- Master Arm Switch | default_2_position_tumb | arg 49 | arg_lim={0,1}
    -- Hint: ARM/SAFE. Cold start: SAFE (arg=1). val=0 → stay SAFE (default). val=-1 → ARM.
    -- SAFE=stay (chance: 90%, default) / ARM=-1 (chance: 10%)
    { dev=23, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},   label="Master Arm Switch" },

    -- -------------------------------------------------------------------------
    -- ELECTRICAL   dev=3 (ELEC_INTERFACE)
    -- -------------------------------------------------------------------------

    -- Left Generator Switch | default_2_position_tumb | arg 402 | arg_lim={0,1}
    -- Hint: NORM/OFF. Cold start: NORM (arg=0). val=0 → stay NORM (default). val=+1 → OFF.
    -- NORM=stay (chance: 90%, default) / OFF=+1 (chance: 10%)
    { dev=3,  cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="Left Generator Switch" },

    -- Right Generator Switch | default_2_position_tumb | arg 403 | arg_lim={0,1}
    -- Hint: NORM/OFF. Cold start: NORM (arg=0). val=0 → stay NORM (default). val=+1 → OFF.
    -- NORM=stay (chance: 90%, default) / OFF=+1 (chance: 10%)
    { dev=3,  cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="Right Generator Switch" },

    -- CB LAUNCH BAR | default_CB_button | arg 384
    -- CB buttons use arg_value={1}, arg_lim={0,1}: val=+1 pulls CB out (OPEN), val=0 stays IN.
    -- IN=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=3,  cmd=3020, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="CB LAUNCH BAR" },

    -- CB SPD BRK | default_CB_button | arg 383
    -- IN=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=3,  cmd=3019, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="CB SPD BRK" },

    -- CB FCS CHAN 1 | default_CB_button | arg 381
    -- IN=stay (chance: 95%, default) / OPEN=+1 (chance: 5%)
    { dev=3,  cmd=3017, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="CB FCS CHAN 1" },

    -- CB FCS CHAN 2 | default_CB_button | arg 382
    -- IN=stay (chance: 95%, default) / OPEN=+1 (chance: 5%)
    { dev=3,  cmd=3018, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="CB FCS CHAN 2" },

    -- -------------------------------------------------------------------------
    -- COUNTERMEASURES   dev=54 (CMDS)
    -- -------------------------------------------------------------------------

    -- DISPENSER Switch | default_3_position_tumb | arg 517 | arg_value=0.1, arg_lim={0,0.2}
    -- Hint: BYPASS/ON/OFF. Cold start: OFF (arg=0.2, right end).
    -- val=0 → stay OFF (default). val=-0.1 → ON. Sending -0.1 twice → BYPASS.
    -- OFF=stay (chance: 88%, default) / ON=-0.1 (chance: 10%) / BYPASS=-0.2 (chance: 2%)
    { dev=54, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, -0.1, -0.2, -0.2, -0.2, -0.2},  label="DISPENSER Switch" },

    -- -------------------------------------------------------------------------
    -- ECM   dev=66 (ASPJ)
    -- -------------------------------------------------------------------------

    -- ECM Mode Switch | multiposition_switch, count=5, delta=0.1 | arg 248 | arg_lim={0,0.4}
    -- Hint: XMIT/REC/BIT/STBY/OFF (reversed order in arg). Cold start: OFF (arg=0).
    -- val=0 → stay OFF (default). val=+0.1 → STBY. val=+0.2 → BIT. val=+0.3 → REC. val=+0.4 → XMIT.
    -- OFF=stay (chance: 88%, default) / STBY=+0.1 (chance: 8%) / others ~1-2% each
    { dev=66, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 0.1, 0.2, 0.3, 0.4, 0.4},  label="ECM Mode Switch" },

    -- -------------------------------------------------------------------------
    -- TGP   dev=62 (TGP_INTERFACE)
    -- -------------------------------------------------------------------------

    -- LST/NFLR Switch | default_2_position_tumb | arg 442 | arg_lim={0,1}
    -- Hint: ON/OFF. Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=62, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},   label="LST/NFLR Switch" },

    -- -------------------------------------------------------------------------
    -- RADAR   dev=42 (RADAR)
    -- -------------------------------------------------------------------------

    -- RADAR Switch | multiposition_switch_with_pull, count=4, delta=0.1 | arg 440 | arg_lim={0,0.3}
    -- OFF=0 / STBY=0.1 / OPR=0.2 / EMERG=0.3. Cold start: STBY (arg=0.1).
    -- val=0 → stay STBY (default). val=-0.1 → OFF. val=+0.1 → OPR. val=+0.2 → EMERG.
    -- STBY=stay (chance: 88%, default) / OFF=-0.1 (chance: 7%) / OPR=+0.1 (chance: 4%) / EMERG=+0.2 (chance: 1%)
    { dev=42, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, 0.1, 0.1, 0.2, 0.2},  label="RADAR Switch" },

    -- -------------------------------------------------------------------------
    -- INS   dev=44 (INS)
    -- -------------------------------------------------------------------------

    -- INS Switch | multiposition_switch_cl, count=8, delta=0.1 | arg 443 | arg_lim={0,0.7}
    -- OFF/CV/GND/NAV/IFA/GYRO/GB/TEST → 0/0.1/0.2/0.3/0.4/0.5/0.6/0.7
    -- Cold start: NAV (arg=0.3). val=0 → stay NAV (default).
    -- val=-0.1 → GND. val=-0.2 → CV. val=-0.3 → OFF.
    -- val=+0.1 → IFA. val=+0.2 → GYRO. val=+0.3 → GB. val=+0.4 → TEST.
    -- NAV=stay (chance: 87%, default) / OFF=-0.3 (chance: 3%) / GND=-0.2 (chance: 3%)
    -- CV=-0.1 (chance: 3%) / IFA=+0.1 (chance: 2%) / others ~1% each
    { dev=44, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.2, -0.2, -0.2, -0.3, 0.1, 0.1, 0.2, 0.3, 0.4},  label="INS Switch" },

    -- -------------------------------------------------------------------------
    -- FLIGHT CONTROLS   dev=2 (CONTROL_INTERFACE)
    -- -------------------------------------------------------------------------

    -- FLAP Switch | default_3_position_tumb | arg 234 | arg_lim={-1,1}
    -- Hint: AUTO/HALF/FULL. Cold start: AUTO (arg=0, center).
    -- val=0 → stay AUTO (default). val=-1 → FULL. val=+1 → HALF.
    -- AUTO=stay (chance: 87%, default) / FULL=-1 (chance: 7%) / HALF=+1 (chance: 6%)
    { dev=2,  cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 1, 1, 1},  label="FLAP Switch" },

    -- -------------------------------------------------------------------------
    -- ECS   dev=11 (ECS_INTERFACE)
    -- -------------------------------------------------------------------------

    -- Defog Handle | default_axis_limited, continuous | arg ~
    -- Exempt: continuous slider, no fixed default position
    { dev=11, cmd=3016, vals={-1, -0.5, 0, 0.5, 1.0},      label="Defog Handle" },

}, 3.1)