-- =============================================================================
-- CockpitRandomizer — f16c.lua
-- F-16C Viper | Block 50
-- Switch table for: F-16C_50
--
-- Device IDs: Mods/aircraft/F-16C/Cockpit/Scripts/devices.lua (counter order)
-- Argument numbers: clickabledata.lua
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
--   at 85%–95% of the vals pool. Continuous axis/brightness/volume knobs are
--   exempt and retain uniform sampling.
-- =============================================================================

CR.register("F-16C_50", {

    -- =========================================================================
    -- ELECTRICAL / TEST PANEL   dev=3  (ELEC_INTERFACE)
    -- =========================================================================

    -- PROBE HEAT Switch | default_button_tumb | arg 578 | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → PROBE HEAT.
    -- OFF=stay (chance: 90%, default) / PROBE HEAT=+1 (chance: 10%)
    { dev=3,  cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="PROBE HEAT Switch" },

    -- FLCS PWR TEST Switch | default_tumb_button | arg 585 | arg_lim={-1,0}
    -- Cold start: NORM (arg=0, upper limit). val=0 → stay NORM (default). val=-1 → MAINT.
    -- NORM=stay (chance: 90%, default) / MAINT=-1 (chance: 10%)
    { dev=3,  cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="FLCS POWER Switch" },

    -- =========================================================================
    -- FLIGHT CONTROL PANEL   dev=2  (CONTROL_INTERFACE)
    -- =========================================================================

    -- MANUAL TF FLYUP Switch | default_2_position_tumb | arg 568 | arg_lim={0,1}
    -- Cold start: DISABLE (arg=1). val=0 → stay DISABLE (default). val=-1 → ENABLE.
    -- DISABLE=stay (chance: 90%, default) / ENABLE=-1 (chance: 10%)
    { dev=2,  cmd=3029, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="MANUAL TF FLYUP Switch" },

    -- DIGITAL BACKUP Switch | default_2_position_tumb | arg 566 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → BACKUP.
    -- OFF=stay (chance: 90%, default) / BACKUP=-1 (chance: 10%)
    { dev=2,  cmd=3027, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="DIGITAL BACKUP Switch" },

    -- ALT FLAPS Switch | default_2_position_tumb | arg 567 | arg_lim={0,1}
    -- Cold start: NORM (arg=0). val=0 → stay NORM (default). val=+1 → EXTEND.
    -- NORM=stay (chance: 95%, default) / EXTEND=+1 (chance: 5%)
    { dev=2,  cmd=3028, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="ALT FLAPS Switch" },

    -- Autopilot ROLL Switch | default_3_position_tumb_small | arg 108 | arg_lim={-1,1}
    -- Cold start: ATT HOLD (arg=0, center). val=0 → stay ATT HOLD (default).
    -- val=-1 → STRG SEL. val=+1 → HDG SEL.
    -- ATT HOLD=stay (chance: 86%, default) / STRG SEL=-1 (chance: 7%) / HDG SEL=+1 (chance: 7%)
    { dev=2,  cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="Autopilot Roll Switch" },

    -- STORES CONFIG Switch | default_2_position_tumb_small | arg 358 | arg_lim={0,1}
    -- Cold start: CAT I (arg=1). val=0 → stay CAT I (default). val=-1 → CAT III.
    -- CAT I=stay (chance: 90%, default) / CAT III=-1 (chance: 10%)
    { dev=2,  cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="STORES CONFIG Switch" },

    -- =========================================================================
    -- FUEL SYSTEM   dev=4  (FUEL_INTERFACE)
    -- =========================================================================

    -- FUEL MASTER Switch Cover | default_red_cover | arg 558 | arg_lim={0,1}
    -- Cold start: CLOSE (arg=0). val=0 → stay CLOSE (default). val=+1 → OPEN.
    -- CLOSE=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=4,  cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="Fuel Master Switch Cover" },

    -- ENGINE FEED Knob | multiposition_switch, count=4, delta=0.1 | arg 556 | arg_lim={0,0.3}
    -- Cold start: NORM (arg=0.1). val=0 → stay NORM (default).
    -- val=-0.1 → OFF. val=+0.1 → AFT. val=+0.2 → FWD.
    -- NORM=stay (chance: 90%, default) / OFF=-0.1 (chance: 7%) / AFT=+0.1 (chance: 2%) / FWD=+0.2 (chance: 1%)
    { dev=4,  cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, 0.1, 0.1, 0.2, 0.2},  label="Engine Feed Knob" },

    -- FUEL QTY SEL Knob | multiposition, delta=0.1 | arg 158 | arg_lim={0.1,0.5}
    -- Cold start: NORM (arg=0.1). val=0 → stay NORM (default).
    -- val=+0.1 → RSVR, +0.2 → INT WING, +0.3 → EXT WING, +0.4 → EXT CTR.
    -- NORM=stay (chance: 90%, default) / others ~2-3% each
    { dev=4,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3, 0.4},  label="FUEL QTY SEL Knob" },

    -- AIR REFUEL Switch | default_2_position_tumb | arg 555 | arg_lim={0,1}
    -- Cold start: CLOSE (arg=0). val=0 → stay CLOSE (default). val=+1 → OPEN.
    -- CLOSE=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=4,  cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="AIR REFUELING Switch" },

    -- =========================================================================
    -- GEAR / BRAKES   dev=7  (GEAR_INTERFACE)
    -- =========================================================================

    -- ANTI-SKID Switch | default_tumb_button | arg 357 | arg_lim={-1,0}
    -- Cold start: ANTI-SKID (arg=0, upper limit). val=0 → stay ANTI-SKID (default). val=-1 → PARKING BRAKE.
    -- ANTI-SKID=stay (chance: 90%, default) / PARKING BRAKE=-1 (chance: 10%)
    { dev=7,  cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="ANTI-SKID Switch" },

    -- =========================================================================
    -- EXTERIOR LIGHTS   dev=11  (EXTLIGHTS_SYSTEM)
    -- =========================================================================

    -- ANTI-COLL Knob | multiposition_switch, count=8, delta=0.1 | arg 531
    -- Exempt: no fixed default position (mission/environment dependent), uniform sampling
    { dev=11, cmd=3001, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},              label="ANTI-COLL Knob" },

    -- FORM Knob | default_axis_limited, continuous | arg 535
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=11, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="FORM Knob" },

    -- MASTER Switch | multiposition_switch, count=5, delta=0.1 | arg 536 | arg_lim={0,0.4}
    -- Cold start: NORM (arg=0.4). val=0 → stay NORM (default).
    -- val=-0.1 → FORM, -0.2 → A-C, -0.3 → ALL, -0.4 → OFF.
    -- NORM=stay (chance: 85%, default) / others ~5% each
    { dev=11, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.2, -0.3, -0.4},  label="MASTER Switch" },

    -- WING/TAIL Switch | default_3_position_tumb_small | arg 533 | arg_lim={-1,1}
    -- Cold start: OFF (arg=0, center). val=0 → stay OFF (default).
    -- val=-1 → BRT. val=+1 → DIM.
    -- OFF=stay (chance: 86%, default) / BRT=-1 (chance: 7%) / DIM=+1 (chance: 7%)
    { dev=11, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="WING/TAIL Switch" },

    -- FUSELAGE Switch | default_3_position_tumb_small | arg 534 | arg_lim={-1,1}
    -- Cold start: OFF (arg=0, center). val=0 → stay OFF (default).
    -- val=-1 → BRT. val=+1 → DIM.
    -- OFF=stay (chance: 86%, default) / BRT=-1 (chance: 7%) / DIM=+1 (chance: 7%)
    { dev=11, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="FUSELAGE Switch" },

    -- FLASH STEADY Switch | default_2_position_tumb_small | arg 532 | arg_lim={0,1}
    -- Cold start: STEADY (arg=1). val=0 → stay STEADY (default). val=-1 → FLASH.
    -- STEADY=stay (chance: 85%, default) / FLASH=-1 (chance: 15%)
    { dev=11, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1},  label="FLASH STEADY Switch" },

    -- LANDING TAXI LIGHTS Switch | default_3_position_tumb_small | arg 360 | arg_lim={-1,1}
    -- Cold start: OFF (arg=0, center). val=0 → stay OFF (default).
    -- val=-1 → LANDING. val=+1 → TAXI.
    -- OFF=stay (chance: 86%, default) / LANDING=-1 (chance: 7%) / TAXI=+1 (chance: 7%)
    { dev=11, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="LANDING TAXI LIGHTS Switch" },

    -- =========================================================================
    -- INTERIOR LIGHTS   dev=12  (CPTLIGHTS_SYSTEM)
    -- =========================================================================

    -- PRIMARY CONSOLES BRT Knob | default_axis_limited | arg 685
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=12, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="PRIMARY CONSOLES BRT Knob" },

    -- PRIMARY INST PNL BRT Knob | default_axis_limited | arg 686
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=12, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="PRIMARY INST PNL Knob" },

    -- PRIMARY DATA ENTRY DISPLAY BRT Knob | default_axis_limited | arg 687
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=12, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="PRIMARY DATA ENTRY DISPLAY BRT Knob" },

    -- FLOOD CONSOLES BRT Knob | default_axis_limited | arg 688
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=12, cmd=3004, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="FLOOD CONSOLES BRT Knob" },

    -- FLOOD INST PNL BRT Knob | default_axis_limited | arg 690
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=12, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="FLOOD INST PNL Knob" },

    -- =========================================================================
    -- ECS   dev=13  (ECS_INTERFACE)
    -- =========================================================================

    -- AIR SOURCE Knob | multiposition_switch, count=4, delta=0.1 | arg 693 | arg_lim={0,0.3}
    -- Cold start: NORM (arg=0.1). val=0 → stay NORM (default).
    -- val=-0.1 → OFF. val=+0.1 → DUMP. val=+0.2 → RAM.
    -- NORM=stay (chance: 90%, default) / OFF=-0.1 (chance: 5%) / DUMP=+0.1 (chance: 3%) / RAM=+0.2 (chance: 2%)
    { dev=13, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, -0.1, 0.1, 0.1, 0.1, 0.2, 0.2},  label="AIR SOURCE Knob" },

    -- =========================================================================
    -- INS   dev=14  (INS)
    -- =========================================================================

    -- INS Knob | multiposition_switch, count=7, delta=0.1 | arg 719 | arg_lim={0,0.6}
    -- Cold start: NAV (arg=0.3). val=0 → stay NAV (default).
    -- val=-0.1 → NORM, -0.2 → STOR HDG, -0.3 → OFF.
    -- val=+0.1 → CAL, +0.2 → INFLT ALIGN, +0.3 → ATT.
    -- NAV=stay (chance: 85%, default) / others ~2-3% each
    { dev=14, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.2, -0.3, 0.1, 0.2, 0.3},  label="INS Knob" },

    -- =========================================================================
    -- RALT   dev=15  (RALT)
    -- =========================================================================

    -- RDR ALT Switch | default_3_position_tumb | arg 673 | arg_lim={-1,1}
    -- Cold start: OFF (arg=1, rightmost). val=0 → stay OFF (default).
    -- val=-1 → STBY (one step left). Sending -1 twice would reach RDR ALT.
    -- Single delta: val=-1 → STBY (chance: 10%). No direct single-step to RDR ALT from OFF.
    -- OFF=stay (chance: 90%, default) / STBY=-1 (chance: 10%)
    { dev=15, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="RDR ALT Switch" },

    -- =========================================================================
    -- UFC   dev=17  (UFC)
    -- =========================================================================

    -- UFC Switch | default_2_position_tumb | arg 718 | arg_lim={0,1}
    -- Cold start: UFC/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=17, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="UFC Switch" },

    -- =========================================================================
    -- MMC   dev=19  (MMC)
    -- =========================================================================

    -- MMC Switch | default_2_position_tumb | arg 715 | arg_lim={0,1}
    -- Cold start: MMC/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=19, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="MMC Switch" },

    -- MFD Switch | default_2_position_tumb | arg 717 | arg_lim={0,1}
    -- Cold start: MFD/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=19, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="MFD Switch" },

    -- MASTER ARM Switch | default_3_position_tumb | arg 105 | arg_lim={-1,1}
    -- Cold start: OFF (arg=0, center). val=0 → stay OFF (default).
    -- val=-1 → MASTER ARM. val=+1 → SIMULATE.
    -- OFF=stay (chance: 90%, default) / MASTER ARM=-1 (chance: 5%) / SIMULATE=+1 (chance: 5%)
    { dev=19, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="MASTER ARM Switch" },

    -- HUD Scales Switch | default_3_position_tumb_small | arg 675 | arg_lim={-1,1}
    -- Cold start: VAH (arg=0, center). val=0 → stay VAH (default).
    -- val=-1 → VV/VAH. val=+1 → OFF.
    -- VAH=stay (chance: 86%, default) / VV/VAH=-1 (chance: 7%) / OFF=+1 (chance: 7%)
    { dev=19, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD Scales Switch" },

    -- HUD Flightpath Marker Switch | default_3_position_tumb_small | arg 676 | arg_lim={-1,1}
    -- Cold start: ATT/FPM (arg=-1, leftmost). val=0 → stay ATT/FPM (default).
    -- val=+1 → FPM (center). Sending +1 twice would reach OFF.
    -- Single delta: val=+1 → FPM (chance: 10%). No direct single-step to OFF from ATT/FPM.
    -- ATT/FPM=stay (chance: 90%, default) / FPM=+1 (chance: 10%)
    { dev=19, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="HUD Flightpath Marker Switch" },

    -- HUD DED/PFLD Data Switch | default_3_position_tumb_small | arg 677 | arg_lim={-1,1}
    -- Cold start: PFL (arg=0, center). val=0 → stay PFL (default).
    -- val=-1 → DED. val=+1 → OFF.
    -- PFL=stay (chance: 86%, default) / DED=-1 (chance: 7%) / OFF=+1 (chance: 7%)
    { dev=19, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD DED/PFLD Data Switch" },

    -- HUD Altitude Switch | default_3_position_tumb_small | arg 680 | arg_lim={-1,1}
    -- Cold start: BARO (arg=0, center). val=0 → stay BARO (default).
    -- val=-1 → RADAR. val=+1 → AUTO.
    -- BARO=stay (chance: 86%, default) / RADAR=-1 (chance: 7%) / AUTO=+1 (chance: 7%)
    { dev=19, cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD Altitude Switch" },

    -- HUD Brightness Control Switch | default_3_position_tumb_small | arg 681 | arg_lim={-1,1}
    -- Cold start: AUTO BRT (arg=0, center). val=0 → stay AUTO BRT (default).
    -- val=-1 → DAY. val=+1 → NIGHT.
    -- AUTO BRT=stay (chance: 86%, default) / DAY=-1 (chance: 7%) / NIGHT=+1 (chance: 7%)
    { dev=19, cmd=3012, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD Brightness Control Switch" },

    -- =========================================================================
    -- SMS   dev=22  (SMS)
    -- =========================================================================

    -- LEFT HDPT Switch | default_2_position_tumb | arg 670 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=22, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="LEFT HDPT Switch" },

    -- RIGHT HDPT Switch | default_2_position_tumb | arg 671 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=22, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="RIGHT HDPT Switch" },

    -- ST STA Switch | default_2_position_tumb | arg 716 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ST STA.
    -- OFF=stay (chance: 90%, default) / ST STA=-1 (chance: 10%)
    { dev=22, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="ST STA Switch" },

    -- LASER ARM Switch | default_2_position_tumb | arg 103 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ARM.
    -- OFF=stay (chance: 90%, default) / ARM=-1 (chance: 10%)
    { dev=22, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="LASER ARM Switch" },

    -- =========================================================================
    -- FCR   dev=31  (FCR)
    -- =========================================================================

    -- FCR Switch | default_2_position_tumb | arg 672 | arg_lim={0,1}
    -- Cold start: FCR/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=31, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="FCR Switch" },

    -- =========================================================================
    -- CMDS   dev=32  (CMDS)
    -- =========================================================================

    -- Jammer Source Switch | default_2_position_tumb_small | arg 374 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="Jammer Source Switch" },

    -- RWR 555 Switch | default_2_position_tumb_small | arg 375 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="RWR 555 Switch" },

    -- MWS Source Switch | default_2_position_tumb_small | arg 373 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="MWS Source Switch" },

    -- O1 Expendable Category Switch | default_2_position_tumb_small | arg 365 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="O1 Expandable Category Switch" },

    -- O2 Expendable Category Switch | default_2_position_tumb_small | arg 366 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="O2 Expandable Category Switch" },

    -- CH Expendable Category Switch | default_2_position_tumb_small | arg 367 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="CH Expandable Category Switch" },

    -- FL Expendable Category Switch | default_2_position_tumb_small | arg 368 | arg_lim={0,1}
    -- Cold start: OFF (arg=1). val=0 → stay OFF (default). val=-1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=-1 (chance: 10%)
    { dev=32, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="FL Expandable Category Switch" },

    -- PROGRAM Knob | multiposition_switch, count=5, delta=0.1 | arg 377 | arg_lim={0,0.4}
    -- Exempt: no fixed operationally default position (mission-dependent), uniform sampling
    { dev=32, cmd=3008, vals={0, 0.1, 0.2, 0.3, 0.4},                              label="PROGRAM Knob" },

    -- MODE Knob | multiposition_switch, count=6, delta=0.1 | arg 378 | arg_lim={0,0.5}
    -- Cold start: STBY (arg=0.1). val=0 → stay STBY (default).
    -- val=-0.1 → OFF. val=+0.1 → MAN. val=+0.2 → SEMI. val=+0.3 → AUTO. val=+0.4 → BYP.
    -- STBY=stay (chance: 90%, default) / OFF=-0.1 (chance: 5%) / others ~1-2% each
    { dev=32, cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, 0.1, 0.2, 0.3, 0.4},  label="MODE Knob" },

    -- =========================================================================
    -- HMCS   dev=30  (HMCS)
    -- =========================================================================

    -- HMCS SYMBOLOGY INT Knob | default_axis_limited | arg 392
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=30, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="HMCS SYMBOLOGY INT Knob" },

    -- =========================================================================
    -- IFF CONTROL PANEL   dev=35  (IFF_CONTROL_PANEL)
    -- =========================================================================

    -- IFF MASTER Knob | multiposition_switch, count=5, delta=0.1 | arg 539 | arg_lim={0,0.4}
    -- Cold start: STBY (arg=0.1). val=0 → stay STBY (default).
    -- val=-0.1 → OFF. val=+0.1 → LOW. val=+0.2 → NORM. val=+0.3 → EMER.
    -- STBY=stay (chance: 90%, default) / OFF=-0.1 (chance: 5%) / others ~2% each
    { dev=35, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, 0.1, 0.1, 0.2, 0.3},  label="IFF Master Knob" },

    -- C & I Knob | multiposition_switch, count=2, delta=1 | arg 542 | arg_lim={0,1}
    -- Cold start: UFC (arg=0). val=0 → stay UFC (default). val=+1 → BACKUP.
    -- UFC=stay (chance: 90%, default) / BACKUP=+1 (chance: 10%)
    { dev=35, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="C & I Knob" },

    -- =========================================================================
    -- INTERCOM   dev=39  (INTERCOM)
    -- =========================================================================

    -- COMM 1 Power Knob | default_axis_limited | arg 430
    -- Exempt: continuous volume knob, no fixed default position
    { dev=39, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="COMM 1 Power Knob" },

    -- COMM 2 Power Knob | default_axis_limited | arg 431
    -- Exempt: continuous volume knob, no fixed default position
    { dev=39, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="COMM 2 Power Knob" },

    -- =========================================================================
    -- MIDS   dev=41  (MIDS)
    -- =========================================================================

    -- MIDS LVT Knob | multiposition_switch, count=3, delta=0.1 | arg 723 | arg_lim={0,0.2}
    -- Cold start: OFF (arg=0.1). val=0 → stay OFF (default).
    -- val=-0.1 → ZERO. val=+0.1 → ON.
    -- OFF=stay (chance: 90%, default) / ZERO=-0.1 (chance: 5%) / ON=+0.1 (chance: 5%)
    { dev=41, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, 0.1},  label="MIDS LVT Knob" },

    -- =========================================================================
    -- GPS   dev=59  (GPS)
    -- =========================================================================

    -- GPS Switch | default_2_position_tumb | arg 720 | arg_lim={0,1}
    -- Cold start: GPS/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=59, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="GPS Switch" },

    -- =========================================================================
    -- IDM   dev=60  (IDM)
    -- =========================================================================

    -- DL Switch | default_2_position_tumb | arg 721 | arg_lim={0,1}
    -- Cold start: DL/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=60, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="DL Switch" },

    -- =========================================================================
    -- MAP   dev=61  (MAP)
    -- =========================================================================

    -- MAP Switch | default_2_position_tumb | arg 722 | arg_lim={0,1}
    -- Cold start: MAP/ON (arg=0). val=0 → stay ON (default). val=+1 → OFF.
    -- ON=stay (chance: 85%, default) / OFF=+1 (chance: 15%)
    { dev=61, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="MAP Switch" },

}, 3.0)