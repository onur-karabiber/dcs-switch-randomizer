-- =============================================================================
-- CockpitRandomizer — f4e.lua
-- F-4E Phantom II | Pilot seat
-- Switch table for: F-4E-45MC
--
-- Device IDs from: DCSWorld\Mods\aircraft\F-4E\Cockpit\Scripts\devices.lua
-- Command IDs from: command_defs.lua  (each device table resets to 3001)
-- Values: derived from clickabledata.lua widget types
-- =============================================================================

local CR = require("CockpitRandomizer.core")

CR.register("F-4E-45MC", {

    -- -------------------------------------------------------------------------
    -- COUNTERMEASURES
    -- -------------------------------------------------------------------------

    -- Select Dispense Program (AN/ALE-40)
    -- 0 = NORMAL (default), 1 = SALVO
    { dev=5,  cmd=3001, vals={0,1},                    label="Select Dispense Program" },

    -- -------------------------------------------------------------------------
    -- COMMUNICATIONS
    -- -------------------------------------------------------------------------

    -- Set Mode (ICS Panel) — spring-loaded upper pos (Radio Override) excluded
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
    -- OFF (0.4998, 6th pos) appears three times → ~20% probability
    { dev=27, cmd=3010,
      vals={0, 0.0833, 0.1666, 0.2499, 0.3332, 0.4165,
            0.4998, 0.4998, 0.4998,
            0.5831, 0.6664, 0.7497, 0.8330, 0.9163, 1.0},
      label="Select Delivery Mode" },

    -- Select Quantity  (12-position, 1/11 ≈ 0.0909 step)
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
    -- ENVIRONMENTAL / RAIN REMOVAL
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
})
