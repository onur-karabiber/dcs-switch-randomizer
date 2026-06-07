-- =============================================================================
-- CockpitRandomizer — f16c.lua
-- F-16C Viper | Block 50
-- Switch table for: F-16C_50
--
-- Device IDs: Mods/aircraft/F-16C/Cockpit/Scripts/devices.lua (counter order)
-- Argument numbers: clickabledata.lua
-- Command numbers: command_defs.lua (each device resets count = start_command = 3000)
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
-- EXCEPTION — RDR ALT Switch:
--   Cold start is STBY (arg=0). Positions: OFF(arg=-1), STBY(arg=0), RDR ALT(arg=+1).
--   Target dominant position is OFF → val=-1 is dominant.
--   val=-1 = OFF (90%), val=0 = stay STBY (10%), val=+1 = RDR ALT (not used).
--
-- DEFAULT WEIGHT POLICY:
--   All fixed-position switches have their dominant delta weighted at 85–95%
--   of the vals pool. Continuous axis/brightness/volume knobs are exempt and
--   retain uniform sampling.
-- =============================================================================

CR.register("F-16C_50", {
    -- Cold start: CLOSE (arg=0). val=0 → stay CLOSE. val=+1 → OPEN.
    -- CLOSE=stay (chance: 90%) / OPEN=+1 (chance: 10%)
    { dev=4,  cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="AIR REFUELING Switch" },

    -- Positions: OFF(arg=0.0), NORM(arg=0.1), DUMP(arg=0.2), RAM(arg=0.3)
    -- Cold start: NORM (arg=0.1). val=0 → stay NORM.
    -- val=-0.1 → OFF. val=+0.1 → DUMP. val=+0.2 → RAM.
    -- Target: NORM=30%, OFF=60%, DUMP=5%, RAM=5%
    { dev=13, cmd=3001, vals={0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, 0.1, 0.2},  label="AIR SOURCE Knob" },

    -- Cold start: NORM (arg=0). val=0 → stay NORM. val=+1 → EXTEND.
    -- NORM=stay (chance: 95%) / EXTEND=+1 (chance: 5%)
    { dev=2,  cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="ALT FLAPS Switch" },

    -- Cold start: OFF (arg=-1, lower bound of TUMB range). TUMB cmd = AntiSkidSw=3004.
    -- val=+1 → ANTI-SKID (arg=0, dominant). val=0 → stay OFF.
    -- ANTI-SKID=+1 (chance: 90%) / PARKING BRAKE=stay (chance: 10%)
    { dev=7,  cmd=3004, vals={1, 1, 1, 1, 1, 1, 1, 1, 1, 0},                       label="ANTI-SKID Switch" },

    -- Cold start: ATT HOLD (arg=0, center). val=0 → stay ATT HOLD.
    -- val=-1 → STRG SEL. val=+1 → HDG SEL.
    -- ATT HOLD=stay (chance: 86%) / STRG SEL=-1 (chance: 7%) / HDG SEL=+1 (chance: 7%)
    { dev=2,  cmd=3014, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="Autopilot Roll Switch" },

    -- Cold start: UFC (arg=0). UFC=stay (90%) / BACKUP=+1 (10%)
    { dev=35, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="C & I Knob" },

    { dev=32, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="CH Expendable Category Switch" },

    -- Cold start: OFF (arg=1). val=0 → stay OFF. val=-1 → BACKUP.
    -- OFF=stay (chance: 90%) / BACKUP=-1 (chance: 10%)
    { dev=2,  cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="DIGITAL BACKUP Switch" },

    -- DL Switch | default_2_position_tumb | arg 721 | cold=ON. ON=stay (85%) / OFF=+1 (15%)
    { dev=60, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="DL Switch" },

    -- Cold start: NORM (arg=0.1). val=0 → stay NORM.
    -- val=-0.1 → OFF. val=+0.1 → AFT. val=+0.2 → FWD.
    -- NORM=stay (chance: 90%) / OFF=-0.1 (chance: 7%) / AFT=+0.1 (chance: 2%) / FWD=+0.2 (chance: 1%)
    { dev=4,  cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, 0.1, 0.1, 0.2, 0.2},  label="Engine Feed Knob" },

    -- EPU SYSTEM   dev=6  (ENGINE_INTERFACE)
    -- engine_commands counter (start=3000):
    --   EpuSwCvrOn=3001  arg=527  default_red_cover         CLOSE=0 / OPEN=+1
    --   EpuSwCvrOff=3002 arg=529  default_red_cover         CLOSE=0 / OPEN=+1
    --   EpuSw=3003       arg=528  default_3_pos_tumb_small  NORM=0  / ON=+0.5 / OFF=-0.5
    --
    -- Reset strategy: delta=-1 drives an open cover (arg=1) to arg=0 (CLOSE).
    -- If already closed (arg=0), delta=-1 clamps to arg=0 — safe no-op.
    -- With both covers closed the mechanical interlock prevents switch movement.
    --
    -- Scenarios (r = math.random(10)):
    --   r=1     : ON OPEN,  OFF OPEN,  NORM  (10%)
    --   r=2     : ON OPEN,  OFF OPEN,  OFF   (10%)
    --   r=3     : ON CLOSE, OFF OPEN,  NORM  (10%)
    --   r=4     : ON CLOSE, OFF OPEN,  OFF   (10%)
    --   r=5     : ON OPEN,  OFF CLOSE, NORM  (10%)
    --   r=6..10 : ON CLOSE, OFF CLOSE, NORM  (50%)
    {
        label = "EPU SYSTEM",
        dev   = 6,
        run   = function(dev)
            local r = math.random(10)
            local function click(cmd, val) dev:performClickableAction(cmd, val) end

            -- Force both covers CLOSED before anything else.
            click(3001, -1)  -- ON  cover → CLOSE
            click(3002, -1)  -- OFF cover → CLOSE

            if r == 1 then          -- ON OPEN, OFF OPEN, NORM (10%)
                click(3001, 1)
                click(3002, 1)
            elseif r == 2 then      -- ON OPEN, OFF OPEN, OFF (10%)
                click(3001, 1)
                click(3002, 1)
                click(3003, -0.5)
            elseif r == 3 then      -- ON CLOSE, OFF OPEN, NORM (10%)
                click(3002, 1)
            elseif r == 4 then      -- ON CLOSE, OFF OPEN, OFF (10%)
                click(3002, 1)
                click(3003, -0.5)
            elseif r == 5 then      -- ON OPEN, OFF CLOSE, NORM (10%)
                click(3001, 1)
            end
            -- r=6..10: ON CLOSE, OFF CLOSE, NORM (50%) — covers already forced closed.
        end
    },

    -- External Fuel Transfer Switch | default_2_position_tumb | arg=159
    -- fuel_commands: ExtFuelTransferSw=3003  cold=NORM(arg=0) / WING FIRST=+1
    -- NORM=stay (90%) / WING FIRST=+1 (10%)
    { dev=4, cmd=3003, vals={1, 1, 1, 1, 1, 1, 1, 1, 0, 1},   label="External Fuel Transfer Switch" },

    -- Cold start: ON (arg=0). val=0 → stay ON. val=+1 → OFF.
    -- ON=stay (chance: 70%) / OFF=+1 (chance: 30%)
    { dev=31, cmd=3001, vals={1, 1, 1, 0, 0, 0, 0, 0, 0, 0},  label="FCR Switch" },

    { dev=32, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="FL Expendable Category Switch" },

    -- Cold start: STEADY (arg=1). val=0 → stay STEADY. val=-1 → FLASH.
    -- STEADY=stay (chance: 85%) / FLASH=-1 (chance: 15%)
    { dev=11, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1},  label="FLASH STEADY Switch" },

    -- Cold start: NORM (arg=0, upper limit of TUMB side). TUMB cmd = FlcsPwrTestSwMAINT=3003.
    -- val=0 → stay NORM. val=-1 → MAINT.
    -- NORM=stay (chance: 90%) / MAINT=-1 (chance: 10%)
    { dev=3,  cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="FLCS POWER Switch" },

    -- FUEL MASTER Switch Cover | default_red_cover | arg=558
    -- FuelMasterSwCvr = 3002  cold=CLOSE(arg=0) / OPEN=+1
    -- Switch (FuelMasterSw) is sim-controlled and cannot be randomized.
    -- CLOSE=stay (90%) / OPEN=+1 (10%)
    { dev=4, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   label="FUEL MASTER Switch Cover" },

    -- Cold start: NORM (arg=0.1). val=0 → stay NORM.
    -- val=+0.1 → RSVR, +0.2 → INT WING, +0.3 → EXT WING, +0.4 → EXT CTR.
    -- NORM=stay (chance: 90%) / others ~2–3% each
    { dev=4,  cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.2, 0.3, 0.4},  label="FUEL QTY SEL Knob" },

    -- Cold start: OFF (arg=0, center). val=0 → stay OFF.
    -- val=-1 → BRT. val=+1 → DIM.
    -- OFF=stay (chance: 86%) / BRT=-1 (chance: 7%) / DIM=+1 (chance: 7%)
    { dev=11, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="FUSELAGE Switch" },

    -- Cold start: ENABLE (arg=0). val=+1 → OFF (dominant). val=0 → stay ENABLE.
    -- OFF=+1 (chance: 90%) / ENABLE=stay (chance: 10%)
    { dev=19, cmd=3004, vals={1, 0, 0, 0, 0, 0, 0, 0, 0, 0},                       label="GND JETT ENABLE Switch" },

    -- GPS Switch | default_2_position_tumb | arg 720 | cold=ON. ON=stay (85%) / OFF=+1 (15%)
    { dev=59, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="GPS Switch" },

    -- Cold start: BARO (arg=0, center). val=0 → stay BARO.
    -- val=-1 → RADAR. val=+1 → AUTO.
    -- BARO=stay (chance: 86%) / RADAR=-1 (chance: 7%) / AUTO=+1 (chance: 7%)
    { dev=19, cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD Altitude Switch" },

    -- Cold start: AUTO BRT (arg=0, center). val=0 → stay AUTO BRT.
    -- val=-1 → DAY. val=+1 → NIGHT.
    -- AUTO BRT=stay (chance: 86%) / DAY=-1 (chance: 7%) / NIGHT=+1 (chance: 7%)
    { dev=19, cmd=3012, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD Brightness Control Switch" },

    -- Cold start: PFL (arg=0, center). val=0 → stay PFL.
    -- val=-1 → DED. val=+1 → OFF.
    -- PFL=stay (chance: 86%) / DED=-1 (chance: 7%) / OFF=+1 (chance: 7%)
    { dev=19, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD DED/PFLD Data Switch" },

    -- Cold start: ATT/FPM (arg=-1, leftmost). val=0 → stay ATT/FPM.
    -- val=+1 → FPM (center, one step). No single-step to OFF from ATT/FPM.
    -- ATT/FPM=stay (chance: 90%) / FPM=+1 (chance: 10%)
    { dev=19, cmd=3007, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="HUD Flightpath Marker Switch" },

    -- Cold start: VAH (arg=0, center). val=0 → stay VAH.
    -- val=-1 → VV/VAH. val=+1 → OFF.
    -- VAH=stay (chance: 86%) / VV/VAH=-1 (chance: 7%) / OFF=+1 (chance: 7%)
    { dev=19, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="HUD Scales Switch" },

    -- Cold start: STBY (arg=0.1). STBY=stay (90%) / OFF=-0.1 (5%) / others ~2% each
    { dev=35, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, 0.1, 0.1, 0.2, 0.3},  label="IFF Master Knob" },

    -- Cold start: NAV (arg=0.3). val=0 → stay NAV.
    -- val=-0.1 → NORM, -0.2 → STOR HDG, -0.3 → OFF.
    -- val=+0.1 → CAL, +0.2 → INFLT ALIGN, +0.3 → ATT.
    -- NAV=stay (chance: 85%) / others ~2–3% each
    { dev=14, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.2, -0.3, 0.1, 0.2, 0.3},  label="INS Knob" },

    { dev=32, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="Jammer Source Switch" },

    -- Cold start: OFF (arg=0, center). val=0 → stay OFF.
    -- val=-1 → LANDING. val=+1 → TAXI.
    -- OFF=stay (chance: 86%) / LANDING=-1 (chance: 7%) / TAXI=+1 (chance: 7%)
    { dev=11, cmd=3008, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="LANDING TAXI LIGHTS Switch" },

    -- Cold start: ARM (arg=0). val=+1 → OFF (dominant). val=0 → stay ARM.
    -- OFF=+1 (chance: 70%) / ARM=stay (chance: 30%)
    { dev=22, cmd=3004, vals={1, 1, 1, 0, 0, 0, 0, 0, 0, 0},                       label="LASER ARM Switch" },

    -- Cold start: ON (arg=0). val=0 → stay ON (dominant). val=+1 → OFF.
    -- ON=stay (chance: 90%) / OFF=+1 (chance: 10%)
    { dev=22, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="LEFT HDPT Switch" },

    -- Cold start: DISABLE (arg=1). val=0 → stay DISABLE. val=-1 → ENABLE.
    -- DISABLE=stay (chance: 90%) / ENABLE=-1 (chance: 10%)
    { dev=2,  cmd=3016, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},                      label="MANUAL TF FLYUP Switch" },

    -- MAP Switch | default_2_position_tumb | arg 722 | cold=ON. ON=stay (85%) / OFF=+1 (15%)
    { dev=61, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="MAP Switch" },

    -- Cold start: OFF (arg=0, center). val=0 → stay OFF.
    -- val=-1 → MASTER ARM. val=+1 → SIMULATE.
    -- OFF=stay (chance: 90%) / MASTER ARM=-1 (chance: 5%) / SIMULATE=+1 (chance: 5%)
    { dev=19, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},  label="MASTER ARM Switch" },

    -- Cold start: NORM (arg=0.4). val=0 → stay NORM.
    -- val=-0.1 → FORM, -0.2 → A-C, -0.3 → ALL, -0.4 → OFF.
    -- NORM=stay (chance: 85%) / others ~5% each
    { dev=11, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.2, -0.3, -0.4},  label="MASTER Switch" },

    -- Cold start: ON (arg=0). val=0 → stay ON. val=+1 → OFF.
    -- ON=stay (chance: 85%) / OFF=+1 (chance: 15%)
    { dev=19, cmd=3014, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="MFD Switch" },

    -- Cold start: OFF (arg=0.1). OFF=stay (90%) / ZERO=-0.1 (5%) / ON=+0.1 (5%)
    { dev=41, cmd=3001, vals={0, 0, 0, 0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, -0.1, 0.1},  label="MIDS LVT Knob" },

    -- Cold start: ON (arg=0). val=0 → stay ON. val=+1 → OFF.
    -- ON=stay (chance: 85%) / OFF=+1 (chance: 15%)
    { dev=19, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="MMC Switch" },

    -- Cold start: STBY (arg=0.1). STBY=stay (90%) / OFF=-0.1 (5%) / others ~1–2% each
    { dev=32, cmd=3010, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.1, -0.1, 0.1, 0.2, 0.3, 0.4},  label="MODE Knob" },

    { dev=32, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="MWS Source Switch" },

    { dev=32, cmd=3005, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="O1 Expendable Category Switch" },

    { dev=32, cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="O2 Expendable Category Switch" },

    -- Cold start: OFF (arg=0). TUMB cmd = ProbeHeatSw=3006. val=0 → stay OFF. val=+1 → PROBE HEAT.
    -- OFF=stay (chance: 90%) / PROBE HEAT=+1 (chance: 10%)
    { dev=3,  cmd=3006, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                       label="PROBE HEAT Switch" },

    { dev=32, cmd=3009, vals={0, 0.1, 0.2, 0.3, 0.4},                              label="PROGRAM Knob" },

    -- Positions: OFF(arg=-1), STBY(arg=0), RDR ALT(arg=+1)
    -- Cold start: STBY (arg=0). val=-1 → OFF (dominant). val=0 → stay STBY.
    -- OFF=-1 (chance: 90%) / STBY=stay (chance: 10%) / RDR ALT not used
    { dev=15, cmd=3001, vals={-1, -1, -1, -1, -1, -1, -1, -1, -1, 0},              label="RDR ALT Switch" },

    -- Cold start: ON (arg=0). val=0 → stay ON (dominant). val=+1 → OFF.
    -- ON=stay (chance: 90%) / OFF=+1 (chance: 10%)
    { dev=22, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="RIGHT HDPT Switch" },

    { dev=32, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="RWR Source Switch" },

    -- Cold start: ST STA (arg=0). val=0 → stay ST STA (dominant). val=+1 → OFF.
    -- ST STA=stay (chance: 90%) / OFF=+1 (chance: 10%)
    { dev=22, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},                        label="ST STA Switch" },

    -- Cold start: CAT III (arg=0). val=+1 → CAT I (dominant). val=0 → stay CAT III.
    -- CAT I=+1 (chance: 60%) / CAT III=stay (chance: 40%)
    { dev=2,  cmd=3011, vals={1, 1, 1, 0, 0},                       label="STORES CONFIG Switch" },

    -- Positions: PBG=arg=0 / ON=arg=0.5 (cold) / OFF=arg=1
    -- delta=-0.5 → PBG, delta=0 → stay ON, delta=+0.5 → OFF
    -- ON=stay (80%) / OFF=+0.5 (20%) / PBG: never
    { dev=8, cmd=3001, vals={0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0, 0, 0.5, 0.5},   label="Supply Lever" },

    -- Cold start: DISC (arg=0). val=+1 → NORM (dominant). val=0 → stay DISC.
    -- NORM=+1 (chance: 90%) / DISC=stay (chance: 10%)
    { dev=2,  cmd=3006, vals={1, 1, 1, 1, 1, 1, 1, 1, 1, 0},                       label="TRIM/AP DISC Switch" },

    -- Cold start: ON (arg=0). val=0 → stay ON. val=+1 → OFF.
    -- ON=stay (chance: 85%) / OFF=+1 (chance: 15%)
    { dev=17, cmd=3001, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="UFC Switch" },

    -- Cold start: OFF (arg=0, center). val=0 → stay OFF.
    -- val=-1 → BRT. val=+1 → DIM.
    -- OFF=stay (chance: 86%) / BRT=-1 (chance: 7%) / DIM=+1 (chance: 7%)
    { dev=11, cmd=3003, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1},          label="WING/TAIL Switch" },

    -- =========================================================================
    -- CONTINUOUS KNOBS (brightness / volume / axis)
    -- =========================================================================

    -- ANTI-COLL Knob | multiposition_switch, count=8, delta=0.1 | arg 531
    -- Exempt: no fixed operationally default position, uniform sampling
    { dev=11, cmd=3001, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},              label="ANTI-COLL Knob" },

    -- COMM 1 Power Knob | default_axis_limited | arg 430 — Exempt
    { dev=39, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="COMM 1 Power Knob" },

    -- COMM 2 Power Knob | default_axis_limited | arg 431 — Exempt
    { dev=39, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="COMM 2 Power Knob" },

    { dev=12, cmd=3006, vals={0, 0.25, 0.5, 0.75, 1.0},  label="FLOOD CONSOLES BRT Knob" },

    { dev=12, cmd=3007, vals={0, 0.25, 0.5, 0.75, 1.0},  label="FLOOD INST PNL Knob" },

    -- FORM Knob | default_axis_limited, continuous | arg 535
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=11, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="FORM Knob" },

    -- HMCS SYMBOLOGY INT Knob | default_axis_limited | arg 392
    -- Exempt: continuous brightness knob, no fixed default position
    { dev=30, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},                            label="HMCS SYMBOLOGY INT Knob" },

    { dev=12, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1.0},  label="PRIMARY CONSOLES BRT Knob" },

    { dev=12, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},  label="PRIMARY DATA ENTRY DISPLAY BRT Knob" },

    { dev=12, cmd=3004, vals={0, 0.25, 0.5, 0.75, 1.0},  label="PRIMARY INST PNL Knob" },
}, 3.0)
