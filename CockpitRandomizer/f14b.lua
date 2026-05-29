-- =============================================================================
-- CockpitRandomizer — f14b.lua
-- F-14B Tomcat | Pilot seat
-- Switch table for: F-14B
--
-- Device IDs: DCSWorld\Mods\aircraft\F14\Cockpit\Scripts\devices.lua
-- Command IDs: command_defs.lua
--
-- HOW vals WORK (delta semantics — not absolute positions):
--   performClickableAction(cmd, val) applies val as a DELTA to the current
--   arg value, clamped to arg_lim. It does NOT set an absolute position.
--
--   val = 0   → no movement, switch stays at cold-start default
--   val = +1  → arg increases (moves toward upper limit)
--   val = -1  → arg decreases (moves toward lower limit)
--
-- ENCODING CONVENTION used in this file:
--   "stay at default"  → val = 0   (always safe, no movement)
--   "move away"        → val = ±1 or ±delta
--
-- NOTES:
--   HUD mode buttons and Navigation Steer Commands are momentary
--   (default_displaybutton, val=+1). These are not subject to the
--   stay-at-default policy — one is always activated on randomization.
--   default_3_position_tumb with inversed_=true: arg_lim={-1,1},
--   left end = arg=-1, center = arg=0, right end = arg=+1.
--   Continuous knobs (volume, light intensity, temperature) are exempt.
--
-- DEFAULT WEIGHT POLICY:
--   All fixed-position switches have their default delta (0 = stay) weighted
--   at 85%–90% of the vals pool.
-- =============================================================================

CR.register("F-14B", {

    -- -------------------------------------------------------------------------
    -- TACAN   dev=47 (TACAN)
    -- -------------------------------------------------------------------------

    -- TACAN Mode Selector | multiposition_switch_limited, count=5, delta=0.25 | arg_lim={0,1}
    -- OFF=0 / REC=0.25 / T-R=0.5 / A/A TR=0.75 / BCN=1.0
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.25 → REC.
    -- OFF=stay (chance: 87%, default) / REC=+0.25 (chance: 7%) / T-R=+0.5 (chance: 4%)
    -- A/A TR=+0.75 (chance: 1%) / BCN=+1.0 (chance: 1%)
    { dev=47, cmd=3329, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0.25, 0.5, 0.75, 1.0},  label="TACAN Mode Selector" },

    -- -------------------------------------------------------------------------
    -- OXYGEN   dev=12 (COCKPITMECHANICS)
    -- -------------------------------------------------------------------------

    -- Pilot Oxygen On | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default). val=-1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=-1 (chance: 10%)
    { dev=12, cmd=3190, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Pilot Oxygen On" },

    -- -------------------------------------------------------------------------
    -- ICS VOLUMES   dev=2 (ICS)
    -- Exempt: continuous axis knobs, no fixed default position
    -- -------------------------------------------------------------------------
    { dev=2,  cmd=3400, vals={0, 0.25, 0.5, 0.75, 1.0},  label="Sidewinder Volume" },
    { dev=2,  cmd=3398, vals={0, 0.25, 0.5, 0.75, 1.0},  label="ALR-67 Volume" },

    -- -------------------------------------------------------------------------
    -- RADIO VOLUMES
    -- Exempt: continuous axis knobs, no fixed default position
    -- -------------------------------------------------------------------------
    { dev=4,  cmd=3406, vals={0, 0.25, 0.5, 0.75, 1.0},  label="VHF/UHF ARC-182 Volume Pilot" },
    { dev=3,  cmd=3362, vals={0, 0.25, 0.5, 0.75, 1.0},  label="UHF ARC-159 Volume Pilot" },

    -- UHF ARC-159 Freq Mode | multiposition_switch_limited, count=3, delta=0.5 | arg_lim={0,1}
    -- GUARD=0 / MAN=0.5 / PRESET=1.0
    -- Cold start: PRESET (arg=1.0, right end). val=0 → stay PRESET (default).
    -- val=-0.5 → MAN. val=-1.0 → GUARD.
    -- PRESET=stay (chance: 87%, default) / MAN=-0.5 (chance: 9%) / GUARD=-1.0 (chance: 4%)
    { dev=3,  cmd=3378, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.5, -0.5, -1.0},  label="UHF ARC-159 Freq Mode" },

    -- UHF ARC-159 Function | multiposition_switch_limited, count=4, delta=0.333 | arg_lim={0,~1}
    -- OFF=0 / MAIN=0.333 / BOTH=0.666 / ADF=1.0
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+0.333 → MAIN.
    -- OFF=stay (chance: 87%, default) / MAIN=+0.333 (chance: 7%) / BOTH=+0.666 (chance: 4%) / ADF=+1.0 (chance: 2%)
    { dev=3,  cmd=3374, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.333, 0.333, 0.666, 1.0, 1.0},  label="UHF ARC-159 Function" },

    -- -------------------------------------------------------------------------
    -- AFCS   dev=22 (AFCS)
    -- -------------------------------------------------------------------------

    -- AFCS Stability Augmentation | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default). val=-1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=-1 (chance: 10%)
    { dev=22, cmd=3036, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="AFCS Stability Augmentation - Yaw" },
    { dev=22, cmd=3035, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="AFCS Stability Augmentation - Roll" },
    { dev=22, cmd=3034, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="AFCS Stability Augmentation - Pitch" },

    -- Autopilot Engage | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=22, cmd=3040, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Autopilot - Engage" },

    -- Autopilot Altitude Hold | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=22, cmd=3038, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Autopilot - Altitude Hold" },

    -- Autopilot Heading / Ground Track | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- HDG=arg=-1 / OFF=arg=0 (center) / GT=arg=+1
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=-1 → HDG. val=+1 → GT.
    -- OFF=stay (chance: 87%, default) / HDG=-1 (chance: 7%) / GT=+1 (chance: 6%)
    { dev=22, cmd=3039, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 1},  label="Autopilot - Heading / Ground Track" },

    -- Autopilot Vector / Automatic Carrier Landing | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- VEC=arg=-1 / OFF=arg=0 (center) / ACL=arg=+1
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=-1 → VEC. val=+1 → ACL.
    -- OFF=stay (chance: 87%, default) / VEC=-1 (chance: 7%) / ACL=+1 (chance: 6%)
    { dev=22, cmd=3037, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 1},  label="Autopilot - Vector / Automatic Carrier Landing" },

    -- -------------------------------------------------------------------------
    -- COVERS (default CLOSED)
    -- -------------------------------------------------------------------------

    -- Asymmetric Thrust Limiter Cover | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 85%, default) / OPEN=+1 (chance: 15%)
    { dev=20, cmd=3062, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Asymmetric Thrust Limiter Cover" },

    -- Emergency Generator Switch Cover | default_flipcover | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 85%, default) / OPEN=+1 (chance: 15%)
    { dev=16, cmd=3012, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Emergency Generator Switch Cover" },

    -- Inboard Spoiler Override Cover | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 85%, default) / OPEN=+1 (chance: 15%)
    { dev=16, cmd=3018, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Inboard Spoiler Override Cover" },

    -- Outboard Spoiler Override Cover | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 85%, default) / OPEN=+1 (chance: 15%)
    { dev=16, cmd=3019, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Outboard Spoiler Override Cover" },

    -- ACM Cover | default_animated_lever | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 85%, default) / OPEN=+1 (chance: 15%)
    { dev=55, cmd=3144, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="ACM Cover" },

    -- Hydraulic Emergency Flight Control Switch Cover | default_flipcover | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 85%, default) / OPEN=+1 (chance: 15%)
    { dev=13, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Hydraulic Emergency Flight Control Switch Cover" },

    -- -------------------------------------------------------------------------
    -- ENGINE   dev=20 (ENGINE)
    -- -------------------------------------------------------------------------

    -- Engine Mode | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: NORM (arg=1). val=0 → stay NORM (default). val=-1 → OFF-IDLE.
    -- NORM=stay (chance: 90%, default) / OFF-IDLE=-1 (chance: 10%)
    { dev=20, cmd=3052, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Left Engine Mode" },
    { dev=20, cmd=3053, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="Right Engine Mode" },

    -- -------------------------------------------------------------------------
    -- GEAR/BRAKES   dev=18 (GEARHOOK)
    -- -------------------------------------------------------------------------

    -- Anti-Skid Spoiler BK Switch | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- BOTH=arg=-1 (left end) / OFF=arg=0 (center) / SPOILER BK=arg=+1 (right end)
    -- Cold start: BOTH (arg=-1). val=0 → stay BOTH (default).
    -- val=+1 → OFF (center). val=+2 → SPOILER BK (two steps right, clamped to +1).
    -- Note: single delta +1 reaches OFF only; SPOILER BK requires two steps.
    -- BOTH=stay (chance: 87%, default) / OFF=+1 (chance: 10%) / SPOILER BK=+2 (chance: 3%)
    { dev=18, cmd=3014, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2},  label="Anti-Skid Spoiler BK Switch" },

    -- -------------------------------------------------------------------------
    -- FUEL   dev=21 (FUELSYSTEM)
    -- -------------------------------------------------------------------------

    -- Wing/Ext Trans | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- WING=arg=-1 / NORM=arg=0 (center) / EXT=arg=+1
    -- Cold start: NORM (arg=0). val=0 → stay NORM (default). val=-1 → WING. val=+1 → EXT.
    -- NORM=stay (chance: 87%, default) / WING=-1 (chance: 7%) / EXT=+1 (chance: 6%)
    { dev=21, cmd=3066, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 1},  label="Wing/Ext Trans" },

    -- -------------------------------------------------------------------------
    -- WEAPONS   dev=55 (WEAPONS)
    -- -------------------------------------------------------------------------

    -- Master Arm Cover | default_animated_lever | arg_lim={0,1}
    -- arg_value={+1,-1}. Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=55, cmd=3135, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Master Arm Cover" },

    -- -------------------------------------------------------------------------
    -- HUD MODES   dev=40 (HUD)
    -- Momentary buttons (default_displaybutton, val=+1).
    -- Not subject to stay-at-default policy — one is always activated.
    -- -------------------------------------------------------------------------
    { dev=40, cmd=3216, vals={1},  label="HUD Take-off Mode" },
    { dev=40, cmd=3217, vals={1},  label="HUD Cruise Mode" },
    { dev=40, cmd=3218, vals={1},  label="HUD Air-to-Air Mode" },
    { dev=40, cmd=3219, vals={1},  label="HUD Air-to-Ground Mode" },
    { dev=40, cmd=3220, vals={1},  label="HUD Landing Mode" },

    -- -------------------------------------------------------------------------
    -- NAVIGATION STEER COMMANDS   dev=46 (NAV_INTERFACE)
    -- Momentary buttons — not subject to stay-at-default policy.
    -- -------------------------------------------------------------------------
    { dev=46, cmd=3317, vals={1},  label="Navigation Steer Commands: TACAN" },
    { dev=46, cmd=3318, vals={1},  label="Navigation Steer Commands: Destination" },
    { dev=46, cmd=3321, vals={1},  label="Navigation Steer Commands: AWL PCD" },
    { dev=46, cmd=3319, vals={1},  label="Navigation Steer Commands: Vector" },
    { dev=46, cmd=3320, vals={1},  label="Navigation Steer Commands: Manual" },

    -- -------------------------------------------------------------------------
    -- HUD / VDI / HSD   dev=40/42/41
    -- -------------------------------------------------------------------------

    -- HUD AWL Mode | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=40, cmd=3227, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="HUD AWL Mode" },

    -- VDI Landing Mode | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=42, cmd=3225, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="VDI Landing Mode" },

    -- HSD Display Mode | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- pos1=arg=-1 / OFF=arg=0 (center, default) / pos3=arg=+1
    -- Cold start: center (arg=0). val=0 → stay center (default). val=-1 → left. val=+1 → right.
    -- center=stay (chance: 87%, default) / left=-1 (chance: 7%) / right=+1 (chance: 6%)
    { dev=41, cmd=3235, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, 1},  label="HSD Display Mode" },

    -- VDI Power On/Off | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default). val=-1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=-1 (chance: 10%)
    { dev=42, cmd=3214, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="VDI Power On/Off" },

    -- HUD Power On/Off | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default). val=-1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=-1 (chance: 10%)
    { dev=40, cmd=3213, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="HUD Power On/Off" },

    -- HSD/ECM Power On/Off | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: ON (arg=1). val=0 → stay ON (default). val=-1 → OFF.
    -- ON=stay (chance: 90%, default) / OFF=-1 (chance: 10%)
    { dev=41, cmd=3215, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, -1},  label="HSD/ECM Power On/Off" },

    -- -------------------------------------------------------------------------
    -- ANA/ARA-63   dev=50 (ILS)
    -- -------------------------------------------------------------------------

    -- ANA/ARA-63 Power Switch | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=50, cmd=3322, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="ANA/ARA-63 Power Switch" },

    -- -------------------------------------------------------------------------
    -- COCKPIT MECHANICS   dev=12 (COCKPITMECHANICS)
    -- -------------------------------------------------------------------------

    -- Hook Bypass | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=12, cmd=3211, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Hook Bypass" },

    -- Taxi Light | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=12, cmd=3171, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Taxi Light" },

    -- White Flood Light | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- OFF=arg=-1 (left end) / MID=arg=0 (center) / BRT=arg=+1 (right end)
    -- Exempt: no fixed operationally meaningful default, uniform sampling
    { dev=12, cmd=3173, vals={-1, 0, 1},  label="White Flood Light" },

    -- Red Flood Light | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- OFF=arg=-1 / MID=arg=0 / BRT=arg=+1
    -- Exempt: no fixed operationally meaningful default, uniform sampling
    { dev=12, cmd=3172, vals={-1, 0, 1},  label="Red Flood Light" },

    -- Position Lights Wing | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- OFF=arg=-1 (left end) / DIM=arg=0 (center) / BRT=arg=+1 (right end)
    -- Cold start: OFF (arg=-1). val=0 → stay OFF (default). val=+1 → DIM. val=+2 → BRT.
    -- OFF=stay (chance: 87%, default) / DIM=+1 (chance: 9%) / BRT=+2 (chance: 4%)
    { dev=12, cmd=3174, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2},  label="Position Lights Wing" },

    -- Position Lights Tail | default_3_position_tumb, inversed_=true | arg_lim={-1,1}
    -- OFF=arg=-1 / DIM=arg=0 / BRT=arg=+1
    -- Cold start: OFF (arg=-1). val=0 → stay OFF (default). val=+1 → DIM. val=+2 → BRT.
    -- OFF=stay (chance: 87%, default) / DIM=+1 (chance: 9%) / BRT=+2 (chance: 4%)
    { dev=12, cmd=3175, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2},  label="Position Lights Tail" },

    -- Position Lights Flash | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=12, cmd=3176, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Position Lights Flash" },

    -- Anti-Collision Lights | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: OFF (arg=0). val=0 → stay OFF (default). val=+1 → ON.
    -- OFF=stay (chance: 87%, default) / ON=+1 (chance: 13%)
    { dev=12, cmd=3177, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},  label="Anti-Collision Lights" },

    -- Instrument/Console/Formation Light Intensity | multiposition, continuous
    -- Exempt: continuous 9-position knobs, no fixed default position
    { dev=12, cmd=3179, vals={0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0},  label="Instrument Light Intensity" },
    { dev=12, cmd=3180, vals={0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0},  label="Console Light Intensity" },
    { dev=12, cmd=3181, vals={0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0},  label="Formation Light Intensity" },

-- Temperature (9 equal positions)
{
    dev=12,
    cmd=3651,
    steps={-4,-3,-2,-1,0,1,2,3,4},
    step_size=0.125,
    label="Temperature"
},

    -- -------------------------------------------------------------------------
    -- HYDRAULICS   dev=13 (HYDRAULICS)
    -- -------------------------------------------------------------------------

    -- Hydraulic Transfer Pump Switch Cover | default_flipcover | arg_lim={0,1}
    -- arg_value={+1,-1}. Cold start: CLOSED (arg=0). val=0 → stay CLOSED (default). val=+1 → OPEN.
    -- CLOSED=stay (chance: 90%, default) / OPEN=+1 (chance: 10%)
    { dev=13, cmd=3002, vals={0, 0, 0, 0, 0, 0, 0, 0, 0, 1},  label="Hydraulic Transfer Pump Switch Cover" },

}, 3.1)
-- Note: F-14B uses a 3.1s delay to allow avionics initialization to complete.