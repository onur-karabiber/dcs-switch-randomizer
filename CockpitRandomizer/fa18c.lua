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
--   val = 0   -> no movement, switch stays at cold-start default
--   val = +1  -> arg increases (moves toward upper limit)
--   val = -1  -> arg decreases (moves toward lower limit)
--   val = +d  -> multiposition: one step forward  (d = switch delta)
--   val = -d  -> multiposition: one step backward
--
-- ENCODING CONVENTION used in this file:
--   "stay at default"  -> val = 0   (always safe, no movement)
--   "move away"        -> val = +/-1 or +/-delta (one or more steps from default)
--
-- DEFAULT WEIGHT POLICY:
--   All fixed-position switches have their default delta (0 = stay) weighted
--   at 85%-90% of the vals pool. Continuous axis/brightness/volume knobs are
--   exempt and retain uniform sampling.
--
-- PERMANENTLY REMOVED SWITCHES (do not re-add):
--   LST/NFLR Switch    dev=62 cmd=3003  -- TGP_INTERFACE is a C++ DLL device
--   FLIR Switch        dev=62 cmd=3001  -- (avTGP_Interface_F18); not accessible
--                                       -- from Export Lua via performClickableAction.
--
-- RIGHT-CONSOLE CB BUTTONS -- confirmed working via _EXT command IDs (in-sim tested):
--   CB FCS CHAN 3/4, CB HOOK, CB LG are physically on the right console sub-panel.
--   performClickableAction with their regular IDs (3021-3024) fails because Export
--   Lua can only reach clickables on the main panel object (ccF18MainPanel).
--   The _EXT variants (3046-3049) bypass the panel membership check and dispatch
--   directly to ElectricSystem.lua — confirmed by in-sim observation (CBs tripped
--   at expected ~5% rate across independent runs).
--
--   Important: _EXT commands are trigger-based, not delta-based. Any call to
--   performClickableAction fires the CB pull unconditionally regardless of val.
--   Therefore vals={0,...,1} cannot be used — even val=0 trips the breaker.
--   Each CB uses run() and only calls performClickableAction when OUT is desired.
-- =============================================================================

CR.register("FA-18C_hornet", {

    -- -------------------------------------------------------------------------
    -- OXYGEN SYSTEM   dev=10 (OXYGEN_INTERFACE)
    -- -------------------------------------------------------------------------

    -- OXY Flow Knob | default_axis_limited, continuous | arg 366
    -- Exempt: continuous rotary, no fixed default position
    { dev=10, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},    label="OXY Flow Knob" },

    -- OBOGS Control Switch | default_2_position_tumb | arg 365 | arg_lim={0,1}
    -- Cold start: ON (arg=0). val=0 -> stay ON (default). val=+1 -> OFF.
    -- ON=stay (90%) / OFF=+1 (10%)
    { dev=10, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="OBOGS Control Switch" },

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
    -- Cold start: OFF (arg=1). val=0 -> stay OFF (default). val=-1 -> ON.
    -- OFF=stay (90%) / ON=-1 (10%)
    { dev=8,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="LDG/TAXI LIGHT Switch" },

    -- -------------------------------------------------------------------------
    -- COCKPIT LIGHTS   dev=9 (CPT_LIGHTS)
    -- -------------------------------------------------------------------------

    -- HOOK BYPASS Switch | springloaded_2_pos_tumb2 | arg 239
    -- Springloaded: momentary pulse. val=+1 pulses toward CARRIER, val=0 stays FIELD.
    -- FIELD=stay (85%) / CARRIER pulse=+1 (15%)
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
    -- NVG/NITE/DAY. Cold start: DAY (arg=1, right end).
    -- val=0 -> stay DAY (default). val=-1 -> NITE.
    -- DAY=stay (87%) / NITE=-1 (13%)
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
    -- Cold start: ON (arg=0). val=0 -> stay ON (default). val=+1 -> OFF.
    -- ON=stay (90%) / OFF=+1 (10%)
    { dev=5,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="Anti Skid Switch" },

    -- -------------------------------------------------------------------------
    -- HUD   dev=34 (HUD)
    -- -------------------------------------------------------------------------

    -- Altitude Switch | default_2_position_tumb | arg 147 | arg_lim={0,1}
    -- BARO/RDR. Cold start: BARO (arg=0). val=0 -> stay BARO (default). val=+1 -> RDR.
    -- BARO=stay (87%) / RDR=+1 (13%)
    { dev=34, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Altitude Switch" },

    -- HUD Symbology Brightness Selector | default_3_position_tumb | arg 51 | arg_lim={0,0.2}
    -- OFF/NIGHT/DAY, delta=0.1. Cold start: DAY (arg=0.2, right end).
    -- val=0 -> stay DAY (default). val=-0.1 -> NIGHT.
    -- DAY=stay (90%) / NIGHT=-0.1 (10%)
    { dev=34, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1},  label="HUD Symbology Brightness Selector" },

    -- -------------------------------------------------------------------------
    -- UFC   dev=25 (UFC)
    -- -------------------------------------------------------------------------

    -- UFC COMM 1 Volume | continuous rotary | arg ~
    -- Exempt: continuous volume knob, no fixed default position
    { dev=25, cmd=3037, vals={0, 0.25, 0.5, 0.75, 1.0},    label="UFC COMM 1 Volume" },

    -- UFC COMM 2 Volume | continuous rotary | arg ~
    -- Exempt: continuous volume knob, no fixed default position
    { dev=25, cmd=3039, vals={0, 0.25, 0.5, 0.75, 1.0},    label="UFC COMM 2 Volume" },

    -- -------------------------------------------------------------------------
    -- MDI LEFT   dev=35 (MDI_LEFT)
    -- -------------------------------------------------------------------------

    -- Left MDI Brightness Selector | default_3_position_tumb | arg 51 | arg_lim={0,0.2}
    -- OFF/NIGHT/DAY, delta=0.1. Cold start: DAY (arg=0.2, right end).
    -- val=0 -> stay DAY (default). val=-0.1 -> NIGHT.
    -- DAY=stay (90%) / NIGHT=-0.1 (10%)
    { dev=35, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1},  label="Left MDI Brightness Selector" },

    -- -------------------------------------------------------------------------
    -- MDI RIGHT   dev=36 (MDI_RIGHT)
    -- -------------------------------------------------------------------------

    -- Right MDI Brightness Selector | default_3_position_tumb | arg 76 | arg_lim={0,0.2}
    -- OFF/NIGHT/DAY, delta=0.1. Cold start: DAY (arg=0.2, right end).
    -- val=0 -> stay DAY (default). val=-0.1 -> NIGHT.
    -- DAY=stay (90%) / NIGHT=-0.1 (10%)
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
    -- ARM/SAFE. Cold start: SAFE (arg=1). val=0 -> stay SAFE (default). val=-1 -> ARM.
    -- SAFE=stay (90%) / ARM=-1 (10%)
    { dev=23, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},   label="Master Arm Switch" },

    -- -------------------------------------------------------------------------
    -- ELECTRICAL   dev=3 (ELEC_INTERFACE)
    -- -------------------------------------------------------------------------

    -- Left Generator Switch | default_2_position_tumb | arg 402 | arg_lim={0,1}
    -- NORM/OFF. Cold start: NORM (arg=0). val=0 -> stay NORM (default). val=+1 -> OFF.
    -- NORM=stay (90%) / OFF=+1 (10%)
    { dev=3,  cmd=3002, vals={0, 1, 1, 1, 1, 1, 1, 1, 1, 1},    label="Left Generator Switch" },

    -- Right Generator Switch | default_2_position_tumb | arg 403 | arg_lim={0,1}
    -- NORM/OFF. Cold start: NORM (arg=0). val=0 -> stay NORM (default). val=+1 -> OFF.
    -- NORM=stay (90%) / OFF=+1 (10%)
    { dev=3,  cmd=3003, vals={0, 1, 1, 1, 1, 1, 1, 1, 1, 1},    label="Right Generator Switch" },

    -- CB LAUNCH BAR | default_CB_button | arg 384 | arg_lim={0,1}
    -- CB buttons: val=+1 pulls CB out (OPEN), val=0 stays IN.
    -- IN=stay (90%) / OPEN=+1 (10%)
    { dev=3,  cmd=3020, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="CB LAUNCH BAR" },

    -- CB SPD BRK | default_CB_button | arg 383 | arg_lim={0,1}
    -- IN=stay (90%) / OPEN=+1 (10%)
    { dev=3,  cmd=3019, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="CB SPD BRK" },

    -- CB FCS CHAN 1 | default_CB_button | arg 381 | arg_lim={0,1}
    -- IN=stay (95%) / OPEN=+1 (5%)
    { dev=3,  cmd=3017, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="CB FCS CHAN 1" },

    -- CB FCS CHAN 2 | default_CB_button | arg 382 | arg_lim={0,1}
    -- IN=stay (95%) / OPEN=+1 (5%)
    { dev=3,  cmd=3018, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="CB FCS CHAN 2" },

    -- CB FCS CHAN 3 | arg 454 | elec_commands.CB_FCS_CHAN3_EXT = 3046
    -- _EXT commands are trigger-based, not delta-based: any performClickableAction call
    -- fires the CB pull unconditionally, regardless of val. vals={0,...,1} does not work —
    -- even val=0 pulls the CB OUT. Fix: use run() and only call when we want OUT (5%).
    -- Cold-start: IN (arg=0, not listed in args_initial_state -> C++ default).
    -- IN=no call (95%) / OUT=call with +1 (5%)
    {
        dev=3, cmd=3046, label="CB FCS CHAN 3",
        run=function(device)
            if math.random(1, 20) == 1 then
                device:performClickableAction(3046, 1)
            end
        end
    },

    -- CB FCS CHAN 4 | arg 455 | elec_commands.CB_FCS_CHAN4_EXT = 3047
    -- Same _EXT trigger-based behavior. IN=no call (95%) / OUT=call (5%)
    {
        dev=3, cmd=3047, label="CB FCS CHAN 4",
        run=function(device)
            if math.random(1, 20) == 1 then
                device:performClickableAction(3047, 1)
            end
        end
    },

    -- CB HOOK | arg 456 | elec_commands.CB_HOOK_EXT = 3048
    -- IN=no call (95%) / OUT=call (5%)
    {
        dev=3, cmd=3048, label="CB HOOK",
        run=function(device)
            if math.random(1, 20) == 1 then
                device:performClickableAction(3048, 1)
            end
        end
    },

    -- CB LG | arg 457 | elec_commands.CB_LG_EXT = 3049
    -- IN=no call (95%) / OUT=call (5%)
    {
        dev=3, cmd=3049, label="CB LG",
        run=function(device)
            if math.random(1, 20) == 1 then
                device:performClickableAction(3049, 1)
            end
        end
    },

    -- External Power Switch | default_button_tumb_v2 | arg 336
    -- RESET(momentary)/NORM/OFF. arg_lim={-1,0} for tumb, {0,1} for btn.
    -- arg=-1=OFF, arg=0=NORM (cold-start default), arg=+1=RESET (momentary, not applied).
    -- cmd=3004 (ExtPwrSw) moves the tumb: val=-1 -> OFF, val=0 -> stay NORM.
    -- OFF=80% / NORM=stay (20%)
    { dev=3, cmd=3004, vals={-1, -1, -1, -1, -1, -1, -1, -1, 0, 0},  label="External Power Switch" },

    -- -------------------------------------------------------------------------
    -- COUNTERMEASURES   dev=54 (CMDS)
    -- -------------------------------------------------------------------------

    -- DISPENSER Switch | default_3_position_tumb | arg 517 | arg_lim={0,0.2}, delta=0.1
    -- BYPASS/ON/OFF. Cold start: OFF (arg=0.2, right end).
    -- val=0 -> stay OFF (default). val=-0.1 -> ON. Two steps of -0.1 -> BYPASS.
    -- OFF=stay (88%) / ON=-0.1 (10%) / BYPASS (via two -0.1 calls) ~2%
    { dev=54, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, -0.1, -0.2, -0.2, -0.2, -0.2},  label="DISPENSER Switch" },

    -- -------------------------------------------------------------------------
    -- ECM   dev=66 (ASPJ)
    -- -------------------------------------------------------------------------

    -- ECM Mode Switch | multiposition_switch, count=5, delta=0.1 | arg 248 | arg_lim={0,0.4}
    -- XMIT/REC/BIT/STBY/OFF (order reversed in arg). Cold start: OFF (arg=0).
    -- val=0 -> stay OFF (default). val=+0.1 -> STBY. val=+0.2 -> BIT. etc.
    -- OFF=stay (88%) / STBY=+0.1 (8%) / BIT=+0.2 (2%) / REC=+0.3 (1%) / XMIT=+0.4 (1%)
    { dev=66, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 0.1, 0.2, 0.3, 0.4, 0.4},  label="ECM Mode Switch" },

    -- -------------------------------------------------------------------------
    -- RADAR   dev=42 (RADAR)
    -- -------------------------------------------------------------------------

    -- RADAR Switch | multiposition_switch_with_pull, count=4, delta=0.1 | arg 440 | arg_lim={0,0.3}
    -- OFF=0 / STBY=0.1 / OPR=0.2 / EMERG=0.3. Cold start: STBY (arg=0.1).
    -- val=0 -> stay STBY (default). val=-0.1 -> OFF. val=+0.1 -> OPR. val=+0.2 -> EMERG.
    -- STBY=stay (88%) / OFF=-0.1 (7%) / OPR=+0.1 (4%) / EMERG=+0.2 (1%)
    { dev=42, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, 0.1, 0.1, 0.2, 0.2},  label="RADAR Switch" },

    -- -------------------------------------------------------------------------
    -- INS   dev=44 (INS)
    -- -------------------------------------------------------------------------

    -- INS Switch | multiposition_switch_cl, count=8, delta=0.1 | arg 443 | arg_lim={0,0.7}
    -- OFF/CV/GND/NAV/IFA/GYRO/GB/TEST -> 0/0.1/0.2/0.3/0.4/0.5/0.6/0.7
    -- Cold start: NAV (arg=0.3). val=0 -> stay NAV (default).
    -- NAV=stay (87%) / GND=-0.1 (3%) / CV=-0.2 (3%) / OFF=-0.3 (3%)
    -- IFA=+0.1 (2%) / GYRO=+0.2 (1%) / GB=+0.3 (0.5%) / TEST=+0.4 (0.5%)
    { dev=44, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.2, -0.2, -0.2, -0.3, 0.1, 0.1, 0.2, 0.3, 0.4},  label="INS Switch" },

    -- -------------------------------------------------------------------------
    -- FLIGHT CONTROLS   dev=2 (CONTROL_INTERFACE)
    -- -------------------------------------------------------------------------

    -- FLAP Switch | default_3_position_tumb | arg 234 | arg_lim={-1,1}
    -- AUTO/HALF/FULL. Cold start: AUTO (arg=0, center).
    -- val=0 -> stay AUTO (default). val=-1 -> FULL. val=+1 -> HALF.
    -- AUTO=stay (87%) / FULL=-1 (7%) / HALF=+1 (6%)
    { dev=2,  cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 1, 1, 1},  label="FLAP Switch" },

    -- Throttles Friction Adjusting Lever | default_movable_axis, continuous | arg 504
    -- Exempt: continuous lever, no fixed default position
    { dev=2,  cmd=3012, vals={-1, -0.5, 0, 0.5, 1.0},      label="Throttles Friction Adjusting Lever" },

    -- -------------------------------------------------------------------------
    -- SELECTIVE JETTISON
    -- -------------------------------------------------------------------------

    -- Selective Jettison Knob | multiposition_switch | arg 236 | count=5, delta=0.1, init=-0.1
    -- L FUS MSL / SAFE / R FUS MSL / RACK/LCHR / STORES
    -- arg=-0.1=L FUS MSL, arg=0.0=SAFE (cold-start default), arg=+0.1=R FUS MSL,
    -- arg=+0.2=RACK/LCHR, arg=+0.3=STORES
    -- val=0 -> stay SAFE. val=-0.1 -> L FUS MSL. val=+0.1..+0.3 -> right positions.
    -- SAFE=stay (95%) / each of the 4 others (1.25% each) -> 1 slot each out of 80
    { dev=23, cmd=3011, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                              -0.1, 0.1, 0.2, 0.3},  label="Selective Jettison Knob" },

    -- -------------------------------------------------------------------------
    -- ECS   dev=11 (ECS_INTERFACE)
    -- -------------------------------------------------------------------------

    -- Defog Handle | default_axis_limited, continuous | arg ~
    -- Exempt: continuous slider, no fixed default position
    { dev=11, cmd=3016, vals={-1, -0.5, 0, 0.5, 1.0},      label="Defog Handle" },

    -- Suit Temperature Knob | default_axis_limited, continuous | arg 406
    -- Exempt: continuous rotary, no fixed default position
    { dev=11, cmd=3007, vals={0, 0.25, 0.5, 0.75, 1.0},    label="Suit Temperature Knob" },

    -- Cabin Temperature Knob | default_axis_limited, continuous | arg 407
    -- Exempt: continuous rotary, no fixed default position
    { dev=11, cmd=3006, vals={0, 0.25, 0.5, 0.75, 1.0},    label="Cabin Temperature Knob" },

    -- -------------------------------------------------------------------------
    -- HYDRAULIC   dev=4 (HYDRAULIC_INTERFACE)
    -- -------------------------------------------------------------------------

    -- Hydraulic Isolate Override Switch | default_2_position_tumb | arg 369 | arg_lim={0,1}
    -- NORM/ORIDE. Cold start: NORM (arg=0). val=0 -> stay NORM (default). val=+1 -> ORIDE.
    -- NORM=stay (90%) / ORIDE=+1 (10%)
    { dev=4,  cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="Hydraulic Isolate Override Switch" },

    -- -------------------------------------------------------------------------
    -- FUEL   dev=6 (FUEL_INTERFACE)
    -- -------------------------------------------------------------------------

    -- External Wing Tanks Fuel Control Switch | default_3_position_tumb | arg 342 | arg_lim={-1,1}
    -- STOP/NORM/ORIDE. Cold start: NORM (arg=0, center).
    -- val=0 -> stay NORM (default). val=-1 -> STOP. val=+1 -> ORIDE.
    -- NORM=stay (90%) / STOP=-1 (5%) / ORIDE=+1 (5%)
    { dev=6,  cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="External Wing Tanks Fuel Control Switch" },

    -- External Centerline Tank Fuel Control Switch | default_3_position_tumb | arg 343 | arg_lim={-1,1}
    -- STOP/NORM/ORIDE. Cold start: NORM (arg=0, center).
    -- val=0 -> stay NORM (default). val=-1 -> STOP. val=+1 -> ORIDE.
    -- NORM=stay (90%) / STOP=-1 (5%) / ORIDE=+1 (5%)
    { dev=6,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="External Centerline Tank Fuel Control Switch" },

    -- -------------------------------------------------------------------------
    -- INTERCOM   dev=40 (INTERCOM)
    -- -------------------------------------------------------------------------

    -- ILS Channel Selector Switch | multiposition_switch, count=20, delta=0.05 | arg 352 | arg_lim={0,0.95}
    -- 20 equally-spaced positions. All positions equally probable.
    -- Implementation note: this switch has animation_speed = anim_speed_default * 0.05
    -- (extremely slow). Sending N separate +0.05 delta calls in a loop causes intermediate
    -- calls to fire before each animation settles, resulting in the selector always landing
    -- on ch2 regardless of the intended target. Fix: send exactly two calls —
    -- one large negative delta to clamp to ch1 (arg=0), then one single delta of
    -- (step * 0.05) to reach the target in a single engine-side update.
    {
        dev=40, cmd=3017, label="ILS Channel Selector Switch",
        run=function(device)
            local step = math.random(0, 19)
            device:performClickableAction(3017, -1.0)           -- clamp to ch1 (arg=0)
            device:performClickableAction(3017, step * 0.05)    -- single delta to target
        end
    },

    -- ILS UFC/MAN Switch | default_2_position_tumb | arg 353 | arg_lim={0,1}
    -- UFC/MAN. Cold start: UFC (arg=0). val=0 -> stay UFC (default). val=+1 -> MAN.
    -- UFC=stay (90%) / MAN=+1 (10%)
    { dev=40, cmd=3016, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="ILS UFC/MAN Switch" },

    -- IFF Master Switch | default_2_position_tumb | arg 356 | arg_lim={0,1}
    -- EMER/NORM. Cold start: NORM (arg=0). val=0 -> stay NORM (default). val=+1 -> EMER.
    -- NORM=stay (90%) / EMER=+1 (10%)
    { dev=40, cmd=3012, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},    label="IFF Master Switch" },

    -- IFF Mode 4 Switch | default_3_position_tumb | arg 355 | arg_lim={-1,1}
    -- DIS / AUD+DIS / OFF. Cold start: center (AUD+DIS, arg=0).
    -- val=0 -> stay center (default). val=-1 -> DIS (left). val=+1 -> OFF (right).
    -- CENTER=stay (90%) / DIS=-1 (5%) / OFF=+1 (5%)
    { dev=40, cmd=3013, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="IFF Mode 4 Switch" },

    -- TACAN Volume Knob | default_axis_limited, continuous | arg 363
    -- intercom_commands.TCN_Volume = 3008. (3032 = TCN_Volume_AXIS, the axis-input channel.)
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3008, vals={0, 0.25, 0.5, 0.75, 1.0},    label="TACAN Volume Knob" },

    -- RWR Volume Control Knob | default_axis_limited, continuous | arg 359
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3004, vals={0, 0.25, 0.5, 0.75, 1.0},    label="RWR Volume Control Knob" },

    -- MIDS A Volume Control Knob | default_axis_limited, continuous | arg 362
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3006, vals={0, 0.25, 0.5, 0.75, 1.0},    label="MIDS A Volume Control Knob" },

    -- MIDS B Volume Control Knob | default_axis_limited, continuous | arg 361
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3007, vals={0, 0.25, 0.5, 0.75, 1.0},    label="MIDS B Volume Control Knob" },

    -- ICS Volume Control Knob | default_axis_limited, continuous | arg 358
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1.0},    label="ICS Volume Control Knob" },

    -- VOX Volume Control Knob | default_axis_limited, continuous | arg 357
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1.0},    label="VOX Volume Control Knob" },

    -- AUX Volume Control Knob | default_axis_limited, continuous | arg 364
    -- Exempt: continuous volume knob, no fixed default position
    { dev=40, cmd=3009, vals={0, 0.25, 0.5, 0.75, 1.0},    label="AUX Volume Control Knob" },

    -- -------------------------------------------------------------------------
    -- CPT MECHANICS   dev=7 (CPT_MECHANICS)
    -- -------------------------------------------------------------------------

    -- Shoulder Harness Control Handle | default_2_position_tumb | arg 513 | arg_lim={0,1}
    -- LOCK/UNLOCK. No operationally fixed cold-start default; sampled uniformly.
    { dev=7,  cmd=3009, vals={-1, 0, 1},                    label="Shoulder Harness Control Handle" },

}, 3.1)
