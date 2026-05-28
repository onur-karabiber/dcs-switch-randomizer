-- =============================================================================
-- CockpitRandomizer — f16c.lua
-- F-16C Viper | Block 50
-- Switch table for: F-16C_50
--
-- Device IDs: Mods/aircraft/F-16C/Cockpit/Scripts/devices.lua (counter order)
-- Argument numbers: clickabledata.lua
--
-- Switch type → vals mapping:
--   default_2_position_tumb          : {0, 1}
--   default_3_position_tumb          : {-1, 0, 1}
--   multiposition_switch (n, delta)  : {0, delta, 2*delta, ...}
--   default_axis_limited / LEV knob  : discrete samples across {0..1}
--   default_button_tumb (BTN+TUMB)   : momentary BTN side excluded, TUMB side only
--   default_tumb_button (TUMB+BTN)   : momentary BTN side excluded, TUMB side only
-- =============================================================================

CR.register("F-16C_50", {

    -- =========================================================================
    -- ELECTRICAL / TEST PANEL   dev=3  (ELEC_INTERFACE)
    -- =========================================================================

    -- PROBE HEAT Switch (default_button_tumb)
    -- BTN side = TEST (momentary) → excluded
    -- TUMB side: OFF=0, PROBE HEAT=1  |  arg 578
    { dev=3,  cmd=3002, vals={0, 1},                        label="PROBE HEAT Switch" },

    -- FLCS PWR TEST Switch (default_tumb_button)
    -- BTN side = TEST (momentary) → excluded
    -- TUMB side: MAINT=-1, NORM=0  |  arg 585
    { dev=3,  cmd=3003, vals={-1, 0},                       label="FLCS POWER Switch" },

    -- =========================================================================
    -- FLIGHT CONTROL PANEL   dev=2  (CONTROL_INTERFACE)
    -- =========================================================================

    -- MANUAL TF FLYUP Switch (default_2_position_tumb)  ENABLE=0 / DISABLE=1  |  arg 568
    { dev=2,  cmd=3029, vals={0, 1},                        label="MANUAL TF FLYUP Switch" },

    -- DIGITAL BACKUP Switch (default_2_position_tumb)  OFF=0 / BACKUP=1  |  arg 566
    { dev=2,  cmd=3027, vals={0, 1},                        label="DIGITAL BACKUP Switch" },

    -- ALT FLAPS Switch (default_2_position_tumb)  NORM=0 / EXTEND=1  |  arg 567
    { dev=2,  cmd=3028, vals={0, 1},                        label="ALT FLAPS Switch" },

    -- Autopilot ROLL Switch (default_3_position_tumb_small)
    -- STRG SEL=-1 / ATT HOLD=0 / HDG SEL=1  |  arg 108
    { dev=2,  cmd=3006, vals={-1, 0, 1},                    label="Autopilot Roll Switch" },

    -- STORES CONFIG Switch (default_2_position_tumb_small)  CAT III=0 / CAT I=1  |  arg 358
    { dev=2,  cmd=3011, vals={0, 1},                        label="STORES CONFIG Switch" },

    -- =========================================================================
    -- FUEL SYSTEM   dev=4  (FUEL_INTERFACE)
    -- =========================================================================

    -- FUEL MASTER Switch Cover (default_red_cover)  CLOSE=0 / OPEN=1  |  arg 558
    { dev=4,  cmd=3002, vals={0, 1},                        label="Fuel Master Switch Cover" },

    -- ENGINE FEED Knob (multiposition_switch, count=4, delta=0.1)
    -- OFF=0 / NORM=0.1 / AFT=0.2 / FWD=0.3  |  arg 556
    { dev=4,  cmd=3001, vals={0, 0.1, 0.2, 0.3},           label="Engine Feed Knob" },

    -- FUEL QTY SEL Knob (custom multiposition, TEST momentary excluded)
    -- NORM=0.1 / RSVR=0.2 / INT WING=0.3 / EXT WING=0.4 / EXT CTR=0.5  |  arg 158
    { dev=4,  cmd=3004, vals={0.1, 0.2, 0.3, 0.4, 0.5},    label="FUEL QTY SEL Knob" },

    -- AIR REFUEL Switch (default_2_position_tumb)  CLOSE=0 / OPEN=1  |  arg 555
    { dev=4,  cmd=3005, vals={0, 1},                        label="AIR REFUELING Switch" },

    -- =========================================================================
    -- GEAR / BRAKES   dev=7  (GEAR_INTERFACE)
    -- =========================================================================

    -- ANTI-SKID Switch (default_tumb_button)
    -- BTN side = OFF (momentary) → excluded
    -- TUMB side: PARKING BRAKE=-1, ANTI-SKID=0  |  arg 357
    { dev=7,  cmd=3007, vals={-1, 0},                       label="ANTI-SKID Switch" },

    -- =========================================================================
    -- EXTERIOR LIGHTS   dev=11  (EXTLIGHTS_SYSTEM)
    -- =========================================================================

    -- ANTI-COLL Knob (multiposition_switch, count=8, delta=0.1)
    -- OFF=0 / 1..4=0.1..0.4 / A=0.5 / B=0.6 / C=0.7  |  arg 531
    { dev=11, cmd=3001, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7},  label="ANTI-COLL Knob" },

    -- FORM Knob (default_axis_limited, continuous)  |  arg 535
    { dev=11, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},    label="FORM Knob" },

    -- MASTER Switch (multiposition_switch, count=5, delta=0.1)
    -- OFF=0 / ALL=0.1 / A-C=0.2 / FORM=0.3 / NORM=0.4  |  arg 536
    { dev=11, cmd=3006, vals={0, 0.1, 0.2, 0.3, 0.4},      label="MASTER Switch" },

    -- WING/TAIL Switch (default_3_position_tumb_small)  BRT=-1 / OFF=0 / DIM=1  |  arg 533
    { dev=11, cmd=3003, vals={-1, 0, 1},                    label="WING/TAIL Switch" },

    -- FUSELAGE Switch (default_3_position_tumb_small)  BRT=-1 / OFF=0 / DIM=1  |  arg 534
    { dev=11, cmd=3004, vals={-1, 0, 1},                    label="FUSELAGE Switch" },

    -- FLASH STEADY Switch (default_2_position_tumb_small)  FLASH=0 / STEADY=1  |  arg 532
    { dev=11, cmd=3002, vals={0, 1},                        label="FLASH STEADY Switch" },

    -- LANDING TAXI LIGHTS Switch (default_3_position_tumb_small)
    -- LANDING=-1 / OFF=0 / TAXI=1  |  arg 360
    { dev=11, cmd=3006, vals={-1, 0, 1},                    label="LANDING TAXI LIGHTS Switch" },

    -- =========================================================================
    -- INTERIOR LIGHTS   dev=12  (CPTLIGHTS_SYSTEM)
    -- =========================================================================

    -- PRIMARY CONSOLES BRT Knob (default_axis_limited)  |  arg 685
    { dev=12, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},    label="PRIMARY CONSOLES BRT Knob" },

    -- PRIMARY INST PNL BRT Knob (default_axis_limited)  |  arg 686
    { dev=12, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1.0},    label="PRIMARY INST PNL Knob" },

    -- PRIMARY DATA ENTRY DISPLAY BRT Knob (default_axis_limited)  |  arg 687
    { dev=12, cmd=3003, vals={0, 0.25, 0.5, 0.75, 1.0},    label="PRIMARY DATA ENTRY DISPLAY BRT Knob" },

    -- FLOOD CONSOLES BRT Knob (default_axis_limited)  |  arg 688
    { dev=12, cmd=3004, vals={0, 0.25, 0.5, 0.75, 1.0},    label="FLOOD CONSOLES BRT Knob" },

    -- FLOOD INST PNL BRT Knob (default_axis_limited)  |  arg 690
    { dev=12, cmd=3005, vals={0, 0.25, 0.5, 0.75, 1.0},    label="FLOOD INST PNL Knob" },

    -- =========================================================================
    -- ECS   dev=13  (ECS_INTERFACE)
    -- =========================================================================

    -- AIR SOURCE Knob (multiposition_switch, count=4, delta=0.1)
    -- OFF=0 / NORM=0.1 / DUMP=0.2 / RAM=0.3  |  arg 693
    { dev=13, cmd=3002, vals={0, 0.1, 0.2, 0.3},            label="AIR SOURCE Knob" },

    -- =========================================================================
    -- INS   dev=14  (INS)
    -- =========================================================================

    -- INS Knob (multiposition_switch, count=7, delta=0.1)
    -- OFF=0 / STOR HDG=0.1 / NORM=0.2 / NAV=0.3 / CAL=0.4 / INFLT ALIGN=0.5 / ATT=0.6  |  arg 719
    { dev=14, cmd=3001, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6},  label="INS Knob" },

    -- =========================================================================
    -- RALT   dev=15  (RALT)
    -- =========================================================================

    -- RDR ALT Switch (default_3_position_tumb)
    -- RDR ALT=-1 / STBY=0 / OFF=1  |  arg 673
    { dev=15, cmd=3001, vals={-1, 0, 1},                    label="RDR ALT Switch" },

    -- =========================================================================
    -- UFC   dev=17  (UFC)
    -- =========================================================================

    -- UFC Switch (default_2_position_tumb)  UFC=0 / OFF=1  |  arg 718
    { dev=17, cmd=3001, vals={0, 1},                        label="UFC Switch" },

    -- =========================================================================
    -- MMC   dev=19  (MMC)
    -- =========================================================================

    -- MMC Switch (default_2_position_tumb)  MMC=0 / OFF=1  |  arg 715
    { dev=19, cmd=3001, vals={0, 1},                        label="MMC Switch" },

    -- MFD Switch (default_2_position_tumb)  MFD=0 / OFF=1  |  arg 717
    { dev=19, cmd=3002, vals={0, 1},                        label="MFD Switch" },

    -- MASTER ARM Switch (default_3_position_tumb)
    -- MASTER ARM=-1 / OFF=0 / SIMULATE=1  |  arg 105
    { dev=19, cmd=3003, vals={-1, 0, 0, 1},                 label="MASTER ARM Switch" },

    -- HUD Scales Switch (default_3_position_tumb_small)
    -- VV/VAH=-1 / VAH=0 / OFF=1  |  arg 675
    { dev=19, cmd=3006, vals={-1, 0, 1},                    label="HUD Scales Switch" },

    -- HUD Flightpath Marker Switch (default_3_position_tumb_small)
    -- ATT/FPM=-1 / FPM=0 / OFF=1  |  arg 676
    { dev=19, cmd=3007, vals={-1, 0, 1},                    label="HUD Flightpath Marker Switch" },

    -- HUD DED/PFLD Data Switch (default_3_position_tumb_small)
    -- DED=-1 / PFL=0 / OFF=1  |  arg 677
    { dev=19, cmd=3008, vals={-1, 0, 1},                    label="HUD DED/PFLD Data Switch" },

    -- HUD Altitude Switch (default_3_position_tumb_small)
    -- RADAR=-1 / BARO=0 / AUTO=1  |  arg 680
    { dev=19, cmd=3011, vals={-1, 0, 1},                    label="HUD Altitude Switch" },

    -- HUD Brightness Control Switch (default_3_position_tumb_small)
    -- DAY=-1 / AUTO BRT=0 / NIGHT=1  |  arg 681
    { dev=19, cmd=3012, vals={-1, 0, 1},                    label="HUD Brightness Control Switch" },

    -- =========================================================================
    -- SMS   dev=22  (SMS)
    -- =========================================================================

    -- LEFT HDPT Switch (default_2_position_tumb)  ON=0 / OFF=1  |  arg 670
    { dev=22, cmd=3001, vals={0, 1},                        label="LEFT HDPT Switch" },

    -- RIGHT HDPT Switch (default_2_position_tumb)  ON=0 / OFF=1  |  arg 671
    { dev=22, cmd=3002, vals={0, 1},                        label="RIGHT HDPT Switch" },

    -- ST STA Switch (default_2_position_tumb)  ST STA=0 / OFF=1  |  arg 716
    { dev=22, cmd=3003, vals={0, 1},                        label="ST STA Switch" },

    -- LASER ARM Switch (default_2_position_tumb)  ARM=0 / OFF=1  |  arg 103
    { dev=22, cmd=3004, vals={0, 1},                        label="LASER ARM Switch" },

    -- =========================================================================
    -- FCR   dev=31  (FCR)
    -- =========================================================================

    -- FCR Switch (default_2_position_tumb)  FCR=0 / OFF=1  |  arg 672
    { dev=31, cmd=3001, vals={0, 1},                        label="FCR Switch" },

    -- =========================================================================
    -- CMDS   dev=32  (CMDS)
    -- =========================================================================

    -- Jammer Source Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 374
    { dev=32, cmd=3001, vals={0, 1},                        label="Jammer Source Switch" },

    -- RWR 555 Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 375
    { dev=32, cmd=3002, vals={0, 1},                        label="RWR 555 Switch" },

    -- MWS Source Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 373
    { dev=32, cmd=3003, vals={0, 1},                        label="MWS Source Switch" },

    -- O1 Expendable Category Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 365
    { dev=32, cmd=3004, vals={0, 1},                        label="O1 Expandable Category Switch" },

    -- O2 Expendable Category Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 366
    { dev=32, cmd=3005, vals={0, 1},                        label="O2 Expandable Category Switch" },

    -- CH Expendable Category Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 367
    { dev=32, cmd=3006, vals={0, 1},                        label="CH Expandable Category Switch" },

    -- FL Expendable Category Switch (default_2_position_tumb_small)  ON=0 / OFF=1  |  arg 368
    { dev=32, cmd=3007, vals={0, 1},                        label="FL Expandable Category Switch" },

    -- PROGRAM Knob (multiposition_switch, count=5, delta=0.1)
    -- BIT=0 / 1=0.1 / 2=0.2 / 3=0.3 / 4=0.4  |  arg 377
    { dev=32, cmd=3008, vals={0, 0.1, 0.2, 0.3, 0.4},      label="PROGRAM Knob" },

    -- MODE Knob (multiposition_switch, count=6, delta=0.1)
    -- OFF=0 / STBY=0.1 / MAN=0.2 / SEMI=0.3 / AUTO=0.4 / BYP=0.5  |  arg 378
    { dev=32, cmd=3009, vals={0, 0.1, 0.2, 0.3, 0.4, 0.5}, label="MODE Knob" },

    -- =========================================================================
    -- HMCS   dev=30  (HMCS)
    -- =========================================================================

    -- HMCS SYMBOLOGY INT Knob (default_axis_limited)  |  arg 392
    { dev=30, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},    label="HMCS SYMBOLOGY INT Knob" },

    -- =========================================================================
    -- IFF CONTROL PANEL   dev=35  (IFF_CONTROL_PANEL)
    -- =========================================================================

    -- IFF MASTER Knob (multiposition_switch, count=5, delta=0.1)
    -- OFF=0 / STBY=0.1 / LOW=0.2 / NORM=0.3 / EMER=0.4  |  arg 539
    { dev=35, cmd=3001, vals={0, 0.1, 0.2, 0.3, 0.4},      label="IFF Master Knob" },

    -- C & I Knob (multiposition_switch, count=2, delta=1)
    -- UFC=0 / BACKUP=1  |  arg 542
    { dev=35, cmd=3005, vals={0, 1},                        label="C & I Knob" },

    -- =========================================================================
    -- INTERCOM   dev=39  (INTERCOM)
    -- =========================================================================

    -- COMM 1 Power Knob (default_axis_limited)  |  arg 430
    { dev=39, cmd=3001, vals={0, 0.25, 0.5, 0.75, 1.0},    label="COMM 1 Power Knob" },

    -- COMM 2 Power Knob (default_axis_limited)  |  arg 431
    { dev=39, cmd=3002, vals={0, 0.25, 0.5, 0.75, 1.0},    label="COMM 2 Power Knob" },

    -- =========================================================================
    -- MIDS   dev=41  (MIDS)
    -- =========================================================================

    -- MIDS LVT Knob (multiposition_switch, count=3, delta=0.1)
    -- ZERO=0 / OFF=0.1 / ON=0.2  |  arg 723
    { dev=41, cmd=3001, vals={0, 0.1, 0.2},                 label="MIDS LVT Knob" },

    -- =========================================================================
    -- GPS   dev=59  (GPS)
    -- =========================================================================

    -- GPS Switch (default_2_position_tumb)  GPS=0 / OFF=1  |  arg 720
    { dev=59, cmd=3001, vals={0, 1},                        label="GPS Switch" },

    -- =========================================================================
    -- IDM   dev=60  (IDM)
    -- =========================================================================

    -- DL Switch (default_2_position_tumb)  DL=0 / OFF=1  |  arg 721
    { dev=60, cmd=3001, vals={0, 1},                        label="DL Switch" },

    -- =========================================================================
    -- MAP   dev=61  (MAP)
    -- =========================================================================

    -- MAP Switch (default_2_position_tumb)  MAP=0 / OFF=1  |  arg 722
    { dev=61, cmd=3001, vals={0, 1},                        label="MAP Switch" },

}, 3.0)
