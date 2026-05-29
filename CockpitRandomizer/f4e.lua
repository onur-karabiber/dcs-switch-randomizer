-- =============================================================================
-- CockpitRandomizer — f4e.lua
-- F-4E Phantom II | Pilot seat
-- Switch table for: F-4E-45MC
--
-- Device IDs from: DCSWorld\Mods\aircraft\F-4E\Cockpit\Scripts\devices.lua
-- Command IDs from: command_defs.lua  (each device table resets to 3001)
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

CR.register("F-4E-45MC", {

    -- -------------------------------------------------------------------------
    -- COUNTERMEASURES   dev=5 (COUNTERMEASURES)
    -- -------------------------------------------------------------------------

    -- Select Dispense Program | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: NORMAL (arg=0). val=0 → stay NORMAL (default). val=+1 → SALVO.
    -- NORMAL=stay (chance: 85%, default) / SALVO=+1 (chance: 15%)
    { dev=5,  cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Select Dispense Program" },

    -- -------------------------------------------------------------------------
    -- COMMUNICATIONS   dev=2 (ICS), dev=3 (ARC164)
    -- -------------------------------------------------------------------------

    -- Set Mode (ICS Panel) | default_springloaded_up_3pos_switch | arg_lim={-1,0}/{0,1}
    -- Cold start: HOT MIC (arg=0, center). val=0 → stay HOT MIC (default).
    -- val=-1 → COLD MIC (momentary, lower). Radio Override side is springloaded/momentary.
    -- HOT MIC=stay (chance: 87%, default) / COLD MIC=-1 (chance: 13%)
    { dev=2,  cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1},  label="Set Mode (ICS)" },

    -- Select Communication Antenna | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: UPR (arg=0). val=0 → stay UPR (default). val=+1 → LWR.
    -- UPR=stay (chance: 87%, default) / LWR=+1 (chance: 13%)
    { dev=3,  cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Comm Antenna" },

    -- Select Radio Mode | multiposition_roller_limited, count=6, delta=0.2 | arg_lim={0,1}
    -- OFF=0 / T=0.2 / T/R=0.4 / A/G=0.6 / SQL=0.8 / G=1.0
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.2 → T.
    -- OFF=stay (chance: 87%, default) / T=+0.2 (chance: 5%) / T/R=+0.4 (chance: 4%)
    -- A/G=+0.6 (chance: 2%) / SQL=+0.8 (chance: 1%) / G=+1.0 (chance: 1%)
    { dev=3,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 0.4, 0.4, 0.6, 0.8, 1.0},  label="Select Radio Mode" },

    -- Select Frequency Mode | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: PRESET (arg=0). val=0 → stay PRESET (default). val=+1 → MANUAL.
    -- PRESET=stay (chance: 87%, default) / MANUAL=+1 (chance: 13%)
    { dev=3,  cmd=3026, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Select Frequency Mode" },

    -- -------------------------------------------------------------------------
    -- IFF   dev=4 (IFF)
    -- -------------------------------------------------------------------------

    -- Select Master Mode | multiposition_switch_limited, count=5, delta=0.25 | arg_lim={0,1}
    -- OFF=0 / SBY=0.25 / NORM=0.5 / EMER=0.75 / IDENT=1.0
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.25 → SBY.
    -- OFF=stay (chance: 87%, default) / SBY=+0.25 (chance: 7%) / NORM=+0.5 (chance: 4%)
    -- EMER=+0.75 (chance: 1%) / IDENT=+1.0 (chance: 1%)
    { dev=4,  cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0.25, 0.5, 0.75, 1.0},  label="IFF Master Mode" },

    -- -------------------------------------------------------------------------
    -- FUEL SYSTEM   dev=60 (FuelControls)
    -- -------------------------------------------------------------------------

    -- Wing Fuel Dump Selector | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: NORM (arg=0). val=0 → stay NORM (default). val=+1 → DUMP.
    -- NORM=stay (chance: 87%, default) / DUMP=+1 (chance: 13%)
    { dev=60, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Wing Fuel Dump" },

    -- Internal Wing Tanks Feed | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: NORMAL (arg=0). val=0 → stay NORMAL (default). val=+1 → TRANSFER.
    -- NORMAL=stay (chance: 87%, default) / TRANSFER=+1 (chance: 13%)
    { dev=60, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Internal Wing Tanks Feed" },

    -- -------------------------------------------------------------------------
    -- FLIGHT CONTROLS / AFCS   dev=9 (INPUTCONTROLS)
    -- -------------------------------------------------------------------------

    -- STAB AUG Yaw | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ENGAGE.
    -- OFF=stay (chance: 87%, default) / ENGAGE=+1 (chance: 13%)
    { dev=9,  cmd=3010, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="STAB AUG Yaw" },

    -- STAB AUG Roll | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ENGAGE.
    -- OFF=stay (chance: 87%, default) / ENGAGE=+1 (chance: 13%)
    { dev=9,  cmd=3012, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="STAB AUG Roll" },

    -- STAB AUG Pitch | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ENGAGE.
    -- OFF=stay (chance: 87%, default) / ENGAGE=+1 (chance: 13%)
    { dev=9,  cmd=3014, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="STAB AUG Pitch" },

    -- AFCS Autopilot | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: AFCS/OFF (arg=0). val=0 → stay OFF (default). val=+1 → ENGAGE.
    -- OFF=stay (chance: 87%, default) / ENGAGE=+1 (chance: 13%)
    { dev=9,  cmd=3016, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="AFCS Autopilot" },

    -- ALT Hold | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: ALT/OFF (arg=0). val=0 → stay OFF (default). val=+1 → ENGAGE.
    -- OFF=stay (chance: 87%, default) / ENGAGE=+1 (chance: 13%)
    { dev=9,  cmd=3018, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="ALT Hold" },

    -- -------------------------------------------------------------------------
    -- LANDING GEAR / BRAKES   dev=20 (GEARANDHOOK)
    -- -------------------------------------------------------------------------

    -- Anti-Skid Toggle | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=20, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Anti-Skid" },

    -- Emergency Wheel Brake | default_axis, stowed=arg=1 (gain=-0.2, relative)
    -- Exempt: axis/lever type, continuous — uniform sampling retained
    { dev=20, cmd=3004, vals={0, 0, 0, 0.3, 0.6, 1.0},    label="Emergency Wheel Brake" },

    -- -------------------------------------------------------------------------
    -- NAVIGATION   dev=44 (ADI_ARU_11_A), dev=48 (TACAN), dev=49 (FLIGHTDIRECTORCOMPUTER)
    -- -------------------------------------------------------------------------

    -- Select Reference System | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: STBY (arg=0). val=0 → stay STBY (default). val=+1 → PRIM.
    -- STBY=stay (chance: 87%, default) / PRIM=+1 (chance: 13%)
    { dev=44, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Select Reference System" },

    -- Select TACAN Mode | multiposition_roller_limited, count=5, delta=0.25 | arg_lim={0,1}
    -- OFF=0 / REC=0.25 / T/R=0.5 / A/A=0.75 / BCN=1.0
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.25 → REC.
    -- OFF=stay (chance: 87%, default) / REC=+0.25 (chance: 7%) / T/R=+0.5 (chance: 4%)
    -- A/A=+0.75 (chance: 1%) / BCN=+1.0 (chance: 1%)
    { dev=48, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0.25, 0.5, 0.75, 1.0},  label="TACAN Mode" },

    -- Select Navigation Input | multiposition_roller_limited, count=4, delta=0.333 | arg_lim={0,1}
    -- TACAN=0 / VOR_ILS=0.333 / ADF=0.667 / NAV COMP=1.0
    -- Cold start: NAV COMP (arg=1.0, rightmost). val=0 → stay NAV COMP (default).
    -- val=-0.333 → ADF. val=-0.667 → VOR/ILS. val=-1.0 → TACAN.
    -- NAV COMP=stay (chance: 87%, default) / ADF=-0.333 (chance: 7%) / VOR/ILS=-0.667 (chance: 4%) / TACAN=-1.0 (chance: 2%)
    { dev=49, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.333, -0.333, -0.667, -1.0, -1.0},  label="Select Navigation Input" },

    -- Select Navigation Mode | multiposition_roller_limited, count=4, delta=0.333 | arg_lim={0,1}
    -- HDG=0 / NAV=0.333 / NAV COMP=0.667 / ATT=1.0
    -- Cold start: NAV COMP (arg=0.667). val=0 → stay NAV COMP (default).
    -- val=-0.333 → NAV. val=-0.667 → HDG. val=+0.333 → ATT.
    -- NAV COMP=stay (chance: 87%, default) / NAV=-0.333 (chance: 7%) / HDG=-0.667 (chance: 4%) / ATT=+0.333 (chance: 2%)
    { dev=49, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.333, -0.333, -0.667, 0.333, 0.333},  label="Select Navigation Mode" },

    -- Toggle Flight Director | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=49, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   label="Toggle Flight Director" },

    -- -------------------------------------------------------------------------
    -- HUD   dev=31 (HUD_AN_ASG_26)
    -- -------------------------------------------------------------------------

    -- Select HUD Mode | multiposition_switch_limited, count=7, delta=0.1666 | arg_lim={0,0.9996}
    -- OFF=0 / NAV=0.1666 / ILS/NAV=0.3332 / ILS/MAN=0.4998 / A/G=0.6664 / A/A RDR=0.8330 / A/A COLL=0.9996
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.1666 → NAV.
    -- OFF=stay (chance: 87%, default) / NAV=+0.1666 (chance: 6%) / ILS/NAV=+0.3332 (chance: 3%)
    -- ILS/MAN=+0.4998 (chance: 2%) / A/G=+0.6664 (chance: 1%) / others ~0.5% each
    { dev=31, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1666, 0.1666, 0.3332, 0.4998, 0.6664, 0.8330, 0.9996},  label="Select HUD Mode" },

    -- -------------------------------------------------------------------------
    -- WEAPONS   dev=27 (WEAPONS)
    -- -------------------------------------------------------------------------

    -- Arm Fuze | multiposition_switch, count=4, min=0, max=0.75, delta=0.25 | arg_lim={0,0.75}
    -- SAFE=0 / NOSE=0.25 / TAIL=0.5 / NOSE&TAIL=0.75
    -- Cold start: SAFE (arg=0). val=0 → stay SAFE (default). val=+0.25 → NOSE.
    -- SAFE=stay (chance: 87%, default) / NOSE=+0.25 (chance: 7%) / TAIL=+0.5 (chance: 4%) / N&T=+0.75 (chance: 2%)
    { dev=27, cmd=3047, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0.25, 0.5, 0.75, 0.75},  label="Arm Fuze" },

    -- Select Delivery Mode | multiposition_switch_limited, count=13, delta=0.0833 | arg_lim={0,0.9996}
    -- OFF=0.4998 (6th pos, center). Cold start: OFF (arg=0.4998). val=0 → stay OFF (default).
    -- val=-0.0833 → one step left. val=+0.0833 → one step right.
    -- OFF=stay (chance: 87%, default) / adjacent steps ±0.0833 (chance: 6% each) / outer steps ~1% each
    { dev=27, cmd=3010, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.0833, -0.0833, 0.0833, 0.0833, -0.1666, 0.1666, -0.2499, 0.2499},  label="Select Delivery Mode" },

    -- Select Quantity | multiposition_switch, count=12, uniform | arg_lim={0,1}
    -- Exempt: no operationally fixed default position (mission-dependent), uniform sampling
    { dev=27, cmd=3021, vals={0, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5454, 0.6363, 0.7272, 0.8181, 0.9090, 1.0},  label="Select Quantity" },

    -- -------------------------------------------------------------------------
    -- OXYGEN SYSTEM   dev=26 (OXYGENSYSTEM)
    -- -------------------------------------------------------------------------

    -- Select Oxygen Mixture | multiposition_switch, count=2, min=0, max=1, delta=1.0 | arg_lim={0,1}
    -- NORMAL OXYGEN=0 / 100% OXYGEN=1.0
    -- Cold start: NORMAL OXYGEN (arg=0). val=0 → stay NORMAL (default). val=+1.0 → 100%.
    -- NORMAL=stay (chance: 87%, default) / 100%=+1.0 (chance: 13%)
    { dev=26, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0, 1.0},  label="Select Oxygen Mixture" },

    -- Emergency Release Cockpit Pressure | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: pushed in / SEALED (arg=0). val=0 → stay sealed (default). val=+1 → VENT.
    -- SEALED=stay (chance: 95%, default) / VENT=+1 (chance: 5%)
    { dev=26, cmd=3012, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Emergency Release Cockpit Pressure" },

    -- -------------------------------------------------------------------------
    -- CIRCUIT BREAKERS   dev=84 (CIRCUIT_BREAKERS)
    -- -------------------------------------------------------------------------

    -- ARI CB | default_circuit_breaker | arg_lim={0,1}
    -- Cold start: IN/active (arg=1). val=0 → stay IN (default). val=-1 → PULL/disabled.
    -- IN=stay (chance: 90%, default) / PULL=-1 (chance: 10%)
    { dev=84, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="ARI CB" },

    -- SAI CB | default_circuit_breaker | arg_lim={0,1}
    -- Cold start: IN/active (arg=1). val=0 → stay IN (default). val=-1 → PULL/off.
    -- IN=stay (chance: 90%, default) / PULL=-1 (chance: 10%)
    { dev=84, cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="SAI CB" },

    -- -------------------------------------------------------------------------
    -- EXTERIOR LIGHTS   dev=69 (EXTERIOR_LIGHTS)
    -- -------------------------------------------------------------------------

    -- Taxi/Landing Light | default_3_position_0_to_1_tumb | arg_lim={0,1}, delta=0.5
    -- LDG LT=0 / OFF=0.5 (center, default) / TAXI LT=1.0
    -- Cold start: OFF (arg=0.5). val=0 → stay OFF (default). val=-0.5 → LDG LT. val=+0.5 → TAXI LT.
    -- OFF=stay (chance: 87%, default) / LDG LT=-0.5 (chance: 7%) / TAXI LT=+0.5 (chance: 6%)
    { dev=69, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, -0.5, 0.5},  label="Taxi/Landing Light" },

    -- Set Formation Lights Mode | default_springloaded_down_3pos_0_to_1_switch | arg_lim={0,1}, delta=0.5
    -- OFF=0.5 (center, default) / BRT=1.0 (upper, momentary — springloaded back)
    -- Lower pos is springloaded (momentary). val=0 → stay OFF (default). val=+0.5 → BRT pulse.
    -- OFF=stay (chance: 87%, default) / BRT pulse=+0.5 (chance: 13%)
    { dev=69, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5},  label="Formation Lights Mode" },

    -- Change Formation Lights Brightness | default_axis, continuous
    -- Exempt: continuous knob, no fixed default position
    { dev=69, cmd=3002, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5},    label="Formation Lights Brightness" },

    -- -------------------------------------------------------------------------
    -- INTERIOR LIGHTS   dev=72 (INTERIOR_LIGHTS)
    -- -------------------------------------------------------------------------

    -- Set Console Floodlight (Red) Brightness | default_3_position_0_to_1_tumb | arg_lim={0,1}, delta=0.5
    -- MED=0 / OFF=0.5 (center, default) / BRT=1.0
    -- Cold start: OFF (arg=0.5). val=0 → stay OFF (default). val=-0.5 → MED. val=+0.5 → BRT.
    -- OFF=stay (chance: 87%, default) / MED=-0.5 (chance: 7%) / BRT=+0.5 (chance: 6%)
    { dev=72, cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, -0.5, 0.5},  label="Console Floodlight" },

    -- Change Console Light Brightness | default_axis, continuous
    -- Exempt: continuous knob, no fixed default position
    { dev=72, cmd=3012, vals={0, 0.25, 0.5, 0.75, 1.0},        label="Console Light Brightness" },

    -- Toggle White Floodlight | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=+1 (chance: 10%)
    { dev=72, cmd=3009, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="White Floodlight" },

    -- Set Instrument Floodlight (Red) Brightness | default_3_position_0_to_1_tumb | arg_lim={0,1}, delta=0.5
    -- DIM=0 / OFF=0.5 (center, default) / BRT=1.0
    -- Cold start: OFF (arg=0.5). val=0 → stay OFF (default). val=-0.5 → DIM. val=+0.5 → BRT.
    -- OFF=stay (chance: 87%, default) / DIM=-0.5 (chance: 7%) / BRT=+0.5 (chance: 6%)
    { dev=72, cmd=3013, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, -0.5, 0.5},  label="Instrument Floodlight" },

    -- -------------------------------------------------------------------------
    -- ENVIRONMENTAL / RAIN REMOVAL   dev=87 (TODO)
    -- -------------------------------------------------------------------------

    -- Toggle Rain Removal | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 90%, default) / ON=+1 (chance: 10%)
    { dev=87, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="Toggle Rain Removal" },

    -- Change Temperature | default_axis, continuous (not yet simulated)
    -- Exempt: continuous knob, no fixed default position
    { dev=87, cmd=3014, vals={0, 0.25, 0.5, 0.75, 1.0},        label="Change Temperature" },

    -- Defog Handle | default_axis, continuous (not yet simulated)
    -- Exempt: continuous slider, no fixed default position
    { dev=87, cmd=3018, vals={0, 0.25, 0.5, 0.75, 1.0},        label="Defog Handle" },

    -- -------------------------------------------------------------------------
    -- AUDIO   dev=13 (AOASYSTEM)
    -- -------------------------------------------------------------------------

    -- AoA Stall Warning Volume | default_axis, continuous
    -- Exempt: continuous knob, no fixed default position
    { dev=13, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},        label="Stall Warning Volume" },

    -- Aural Tone Volume | default_axis, continuous
    -- Exempt: continuous knob, no fixed default position
    { dev=13, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},        label="Aural Tone Volume" },
})