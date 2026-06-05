-- =============================================================================
-- CockpitRandomizer -- f14b.lua
-- F-14B Tomcat | Pilot seat
-- Switch table for: F-14B
--
-- Device IDs: DCSWorld\Mods\aircraft\F14\Cockpit\Scripts\devices.lua
-- Command IDs: command_defs.lua
--
-- CONFIRMED WORKING (tested, physically move in cockpit):
--   COCKPITMECHANICS (dev=12): oxygen, lights, temperature
--   HYDRAULICS (dev=13): covers, pump
--   PNEUMATICS (dev=16): covers
--   GEARHOOK (dev=18): anti-skid
--   ENGINE (dev=20): mode switches, cover
--   FUELSYSTEM (dev=21): wing/ext trans
--   AFCS (dev=22): stability aug, autopilot
--   ICS (dev=2): volumes
--   ARC159 (dev=3): volume only
--   ARC182 (dev=4): volume
--   AOASYSTEM (dev=12*): hook bypass  [*shares COCKPITMECHANICS dev ID]
--   HUD (dev=40), VDI (dev=42), HSD (dev=41): power, modes
--   NAV_INTERFACE (dev=46): steer commands
--   ILS (dev=50): power
--   WEAPONS (dev=55): covers
--
-- NOT CONTROLLABLE via performClickableAction (silently ignored):
--   TACAN Mode Selector (dev=47, multiposition_switch_limited)
--   UHF ARC-159 Freq Mode (dev=3, multiposition_switch_limited)
--   UHF ARC-159 Function (dev=3, multiposition_switch_limited)
--   These three were tested with original cmd, corrected cmd, STEP cmd,
--   and dev=0 -- none produced physical movement.
--
-- DEFAULT WEIGHT POLICY:
--   Fixed-position switches: default (0=stay) weighted at 85-90%.
--   Continuous knobs (volume, lights, temperature): uniform sampling.
-- =============================================================================

CR.register("F-14B", {

    -- -------------------------------------------------------------------------
    -- OXYGEN   dev=12 (COCKPITMECHANICS)
    -- -------------------------------------------------------------------------
    -- Cold start: ON (arg=1). val=0 -> stay ON. val=-1 -> OFF.
    -- ON=stay (90%) / OFF=-1 (10%)
    { dev=12, cmd=3190, vals={0,0,0,0,0,0,0,0,0,-1}, label="Pilot Oxygen On" },

    -- -------------------------------------------------------------------------
    -- ICS VOLUMES   dev=2 (ICS) -- continuous, uniform
    -- -------------------------------------------------------------------------
    { dev=2, cmd=3400, vals={0,0.25,0.5,0.75,1.0}, label="Sidewinder Volume" },
    { dev=2, cmd=3398, vals={0,0.25,0.5,0.75,1.0}, label="ALR-67 Volume" },

    -- -------------------------------------------------------------------------
    -- RADIO VOLUMES -- continuous, uniform
    -- -------------------------------------------------------------------------
    { dev=4, cmd=3406, vals={0,0.25,0.5,0.75,1.0}, label="VHF/UHF ARC-182 Volume Pilot" },
    { dev=3, cmd=3362, vals={0,0.25,0.5,0.75,1.0}, label="UHF ARC-159 Volume Pilot" },

    -- -------------------------------------------------------------------------
    -- AFCS   dev=22 (AFCS)
    -- -------------------------------------------------------------------------
    -- Stability Augmentation | cold start: OFF (arg=0). val=+1 -> ON.
    -- OFF=stay (33%) / ON=+1 (67%) -- matching original working version probability
    { dev=22, cmd=3036, vals={0,1,1}, label="AFCS Stability Augmentation - Yaw" },
    { dev=22, cmd=3035, vals={0,1,1}, label="AFCS Stability Augmentation - Roll" },
    { dev=22, cmd=3034, vals={0,1,1}, label="AFCS Stability Augmentation - Pitch" },

    -- Autopilot Engage | cold start: OFF. val=+1 -> ON.
    -- OFF=stay (87%) / ON=+1 (13%)
    { dev=22, cmd=3041, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, label="Autopilot - Engage" },

    -- Autopilot Altitude Hold | DEBUG: always nonzero
    { dev=22, cmd=3038, vals={1}, label="Autopilot - Altitude Hold" },

    -- Autopilot Heading/GT | DEBUG: always nonzero
    { dev=22, cmd=3039, vals={1,-1}, label="Autopilot - Heading / Ground Track" },

    -- Autopilot Vector/ACL | DEBUG: always nonzero
    { dev=22, cmd=3037, vals={1,-1}, label="Autopilot - Vector / Automatic Carrier Landing" },

-- -------------------------------------------------------------------------
    -- COVER SWITCHES — 70% closed / 30% open
    --
    -- All covers default to CLOSED at cold start (arg=0).
    -- val=0 → stays CLOSED (no delta applied)
    -- val=+1 → OPEN (increments arg by +1, clamped to upper limit)
    -- 10-element vals array: 7×0 + 3×1 → 70% closed / 30% open
    --
    -- Element types (clickabledata.lua):
    --   default_2_position_tumb : Asymmetric Thrust Limiter Cover (PNT_16005)
    --                             Inboard Spoiler Override Cover   (PNT_902)
    --                             Outboard Spoiler Override Cover  (PNT_903)
    --   default_flipcover       : Emergency Generator Switch Cover (PNT_927)
    --                             Hydraulic Emergency Flight       (PNT_8100)
    --                             Control Switch Cover
    --   default_animated_lever  : ACM Cover                        (PNT_1049)
    --
    -- Device/Command ID verification (command_defs.lua, start_command=3000):
    --   ENGINE (dev=20) | ENGINE_Asym_LimiterCover     index 55  → cmd=3055
    --   ELECTRICS (dev=15) | ELEC_EMERG_GEN_SwitchCover index 11 → cmd=3011
    --   ELECTRICS (dev=15) | SPOIL_Inboard_Override_Cover index 431 → cmd=3431
    --   ELECTRICS (dev=15) | SPOIL_Outboard_Override_Cover index 432 → cmd=3432
    --   WEAPONS (dev=55)   | WEAP_ACM_Cover              index 133 → cmd=3133
    --   HYDRAULICS (dev=13)| HYD_EMERG_FLT_SwitchCover   index 4   → cmd=3004
    -- -------------------------------------------------------------------------

    -- Asymmetric Thrust Limiter Cover | default_2_position_tumb | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → CLOSED. val=+1 → OPEN.
    { dev=20, cmd=3055, vals={0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Asymmetric Thrust Limiter Cover" },

    -- Emergency Generator Switch Cover | default_flipcover | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → CLOSED. val=+1 → OPEN.
    { dev=15, cmd=3011, vals={0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Emergency Generator Switch Cover" },

    -- ACM Cover | default_animated_lever | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → CLOSED. val=+1 → OPEN.
    { dev=55, cmd=3133, vals={0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="ACM Cover" },

    -- Hydraulic Emergency Flight Control Switch Cover | default_flipcover | arg_lim={0,1}
    -- Cold start: CLOSED (arg=0). val=0 → CLOSED. val=+1 → OPEN.
    { dev=13, cmd=3004, vals={0, 0, 0, 0, 0, 0, 0, 1, 1, 1},  label="Hydraulic Emergency Flight Control Switch Cover" },

    -- -------------------------------------------------------------------------
    -- ENGINE   dev=20 (ENGINE)
    -- -------------------------------------------------------------------------
    -- Engine Mode | cold start: NORM (arg=1). NORM=stay (90%) / OFF-IDLE=-1 (10%)
    { dev=20, cmd=3052, vals={0,0,0,0,0,0,0,0,0,-1}, label="Left Engine Mode" },
    { dev=20, cmd=3053, vals={0,0,0,0,0,0,0,0,0,-1}, label="Right Engine Mode" },

    -- -------------------------------------------------------------------------
    -- GEAR/BRAKES   dev=18 (GEARHOOK)
    -- -------------------------------------------------------------------------
    -- Anti-Skid Spoiler BK | cold start: BOTH. stay (87%) / OFF=+1 (10%) / SPOILER BK=+2 (3%)
    { dev=18, cmd=3014, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2}, label="Anti-Skid Spoiler BK Switch" },

    -- -------------------------------------------------------------------------
    -- FUEL   dev=21 (FUELSYSTEM)
    -- -------------------------------------------------------------------------
    -- Wing/Ext Trans | cold start: NORM. NORM=stay (87%) / WING=-1 (7%) / EXT=+1 (6%)
    { dev=21, cmd=3066, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,1}, label="Wing/Ext Trans" },

    -- -------------------------------------------------------------------------
    -- WEAPONS   dev=55 (WEAPONS)
    -- -------------------------------------------------------------------------
    { dev=55, cmd=3135, vals={0,0,0,0,0,0,0,0,0,1}, label="Master Arm Cover" },

    -- -------------------------------------------------------------------------
    -- HUD MODE   dev=40 (HUD)
    -- Radio group: one of 5 momentary buttons activates the mode, others deactivate.
    -- Landing=54% (default) / Take-off=12% / Cruise=12% / Air-to-Air=12% / Air-to-Ground=10%
    -- -------------------------------------------------------------------------
    {
        dev=40, cmd=nil, label="HUD Mode",
        run=function(device)
            local cmds = {3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3220,3216,3216,3216,3216,3216,3216,3217,3217,3217,3217,3217,3217,3218,3218,3218,3218,3218,3218,3219,3219,3219,3219,3219}
            device:performClickableAction(cmds[math.random(#cmds)], 1)
        end
    },

    -- -------------------------------------------------------------------------
    -- NAVIGATION STEER COMMANDS   dev=46 (NAV_INTERFACE)
    -- Radio group: one of 5 momentary buttons sets the steer source, others deactivate.
    -- TACAN=54% (default) / Destination=12% / Vector=12% / Manual=12% / AWL PCD=10%
    -- -------------------------------------------------------------------------
    {
        dev=46, cmd=nil, label="Navigation Steer Commands",
        run=function(device)
            local cmds = {3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3317,3318,3318,3318,3318,3318,3318,3321,3321,3321,3321,3321,3319,3319,3319,3319,3319,3319,3320,3320,3320,3320,3320,3320}
            device:performClickableAction(cmds[math.random(#cmds)], 1)
        end
    },

    -- -------------------------------------------------------------------------
    -- HUD / VDI / HSD   dev=40/42/41
    -- -------------------------------------------------------------------------
    -- HUD AWL Mode | cold start: OFF. OFF=stay (87%) / ON=+1 (13%)
    { dev=40, cmd=3227, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, label="HUD AWL Mode" },

    -- VDI Landing Mode | cold start: OFF. OFF=stay (87%) / ON=+1 (13%)
    { dev=42, cmd=3225, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, label="VDI Landing Mode" },

    -- HSD Display Mode | cold start: center. stay (87%) / left=-1 (7%) / right=+1 (6%)
    { dev=41, cmd=3235, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,1}, label="HSD Display Mode" },

    -- Power switches | cold start: ON. stay (90%) / OFF=-1 (10%)
    { dev=42, cmd=3214, vals={0,0,0,0,0,0,0,0,0,-1}, label="VDI Power On/Off" },
    { dev=40, cmd=3213, vals={0,0,0,0,0,0,0,0,0,-1}, label="HUD Power On/Off" },
    { dev=41, cmd=3215, vals={0,0,0,0,0,0,0,0,0,-1}, label="HSD/ECM Power On/Off" },

    -- -------------------------------------------------------------------------
    -- ANA/ARA-63   dev=50 (ILS)
    -- -------------------------------------------------------------------------
    { dev=50, cmd=3322, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, label="ANA/ARA-63 Power Switch" },

    -- -------------------------------------------------------------------------
    -- COCKPIT MECHANICS   dev=12 (COCKPITMECHANICS)
    -- -------------------------------------------------------------------------
    { dev=12, cmd=3211, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, label="Hook Bypass" },
    { dev=12, cmd=3171, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}, label="Taxi Light" },

    -- Flood lights | exempt: no operationally meaningful default, uniform
    { dev=12, cmd=3173, vals={-1,0,1}, label="White Flood Light" },
    { dev=12, cmd=3172, vals={-1,0,1}, label="Red Flood Light" },

    -- Position lights | cold start: OFF. stay (87%) / DIM=+1 (9%) / BRT=+2 (4%)
    { dev=12, cmd=3174, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2}, label="Position Lights Wing" },
    { dev=12, cmd=3175, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2}, label="Position Lights Tail" },
    { dev=12, cmd=3176, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},   label="Position Lights Flash" },
    { dev=12, cmd=3177, vals={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},   label="Anti-Collision Lights" },

    -- Light intensity knobs | continuous, uniform
    -- cmd=3179/3180/3181 (1 below command_defs values 3180/3181/3182 -- matches working pattern)
    { dev=12, cmd=3179, vals={0,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1.0}, label="Instrument Light Intensity" },
    { dev=12, cmd=3180, vals={0,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1.0}, label="Console Light Intensity" },
    { dev=12, cmd=3181, vals={0,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1.0}, label="Formation Light Intensity" },

    -- -------------------------------------------------------------------------
    -- HYDRAULICS   dev=13 (HYDRAULICS)
    -- -------------------------------------------------------------------------
    { dev=13, cmd=3002, vals={0,0,0,0,0,0,0,0,0,1}, label="Hydraulic Transfer Pump Switch Cover" },

}, 3.1)
-- Note: F-14B uses a 3.1s delay to allow avionics initialization to complete.


