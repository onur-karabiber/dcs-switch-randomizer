# DCS Switch Randomizer (DSR)

A desktop application that randomizes DCS World cockpit switch and knob
positions at mission start, forcing you to perform a proper interior check
before doing anything else.

> **More than a randomizer.**  
> Because you can control the probability of every individual switch position,
> you can also use DSR to guarantee a fixed cockpit setup — finding the cockpit
> exactly the way you want it, every time.

> **Testing status:**  
> Only **F/A-18C, F-16C, F-5E (Remastered), F-4E, and F-14B** have been
> thoroughly tested so far. Other aircraft remain in the list by design — they
> are there specifically for community testing. Some switches on untested
> aircraft will likely not randomize correctly.

Currently supported aircraft:

- **F/A-18C Hornet**
- **F-16C Viper** 
- **F-5E Tiger II — Remastered**
- **F-4E Phantom II** 
- **F-14B Tomcat** 
- **A-10C II Tank Killer** 
- **UH-1H Huey** 
- **MiG-21bis**
- **Spitfire LF Mk. IX**

---

## Why this exists

In DCS, every time you occupy a cockpit the aircraft spawns with all switches
in their factory-default positions. For taxi, runway hold, and in-flight slots
this makes sense. For cold-start scenarios it breaks immersion: a real aircraft
coming out of a previous sortie would have been left in whatever state the last
crew left it in. Landing lights on, STAB AUG engaged, IFF in an unexpected
mode — anything is possible.

DSR recreates that reality. Each cold start is different. You cannot skip the
interior check.

---

## Features

- **Cold-start only**: reads engine RPM via `LoGetEngineInfo()`. If either
  engine is at or above 10 % RPM the script does nothing. Taxi, runway, and
  in-flight slots are unaffected.
- **Per-aircraft control**: a shared core engine detects the active aircraft
  and applies the correct switch table automatically.
- **Weighted probabilities**: adjust how likely each switch position is — from
  fully random to a fixed preset.
- **Non-destructive**: chains into any existing `LuaExport*` functions.
  Compatible with DCS-BIOS, SRS, Tacview, and similar Export.lua-based tools.
- All activity is logged to `DCS.log` under the `DSR` tag.

---

## Requirements

- DCS World (Steam or standalone)
- One or more supported aircraft modules
- Python 3.10 or later
- PyQt5

---

## Installation

**Step 1 — Download**

Download the latest release and extract it. You will get `dcs-switch-randomizer.exe` and a `DSR\` folder — keep them in the same directory.

**Step 2 — Launch the application**

Run `dcs-switch-randomizer.exe`.

**Step 3 — Install**

The application detects your DCS Saved Games folder automatically. If you have multiple DCS installations it will ask you to choose one. Click **Install**, then select the aircraft you want to activate and click **Apply**.

If you already have an `Export.lua`, it is backed up automatically. DSR is injected into it without removing your existing content.

**Step 4 — Verify**

Launch DCS and fly any supported cold-start mission. After a short delay in the cockpit, switches will randomize. Check `Saved Games\DCS\Logs\dcs.log` and search for `DCS_SWITCH_RANDOMIZER` to confirm the script is running.

> **Do not edit** `SteamLibrary\steamapps\common\DCSWorld\Scripts\Export.lua`. That file is read-only reference material. Your changes belong exclusively in `Saved Games\DCS\Scripts\Export.lua`.
---

## Uninstallation

Click the **Uninstall** button in the application. Your original `Export.lua` is restored from backup. If no backup exists, `Export.lua` is deleted.

---

## Per-switch settings

Click the gear icon next to any aircraft name to open the Settings dialog. Every randomizable control is listed. For each switch you can:

- **Enable or disable** it from randomization entirely.
- **Adjust the probability** of each position (weights must sum to 100%).

Knobs are randomized across a range and do not have per-position probabilities — they are either included or excluded.

Changes are saved immediately and take effect on the next cold start.

[![Patreon](https://img.shields.io/badge/Patreon-Support-orange)]([https://www.patreon.com/kullaniciadi](https://www.patreon.com/16265834/join))

---

## Randomized controls

### A-10C II Thunderbolt (106 controls — 82 switches, 24 knobs)

| System | Controls |
|---|---|
| APU | APU On/Off, APU Generator On/Off |
| Electrical | Battery Power, Left AC Generator Power, Right AC Generator Power, CICU On/Off, EGI Power On/Off |
| Engines | Left Engine Fuel Flow Control, Right Engine Fuel Flow Control |
| Fuel | Boost Pumps Left Wing, Boost Pumps Right Wing, Boost Pumps Main Fuselage Left, Boost Pumps Main Fuselage Right, External Wing Tanks Boost Pumps, External Fuselage Tank Boost Pump, Cross Feed, Tank Gate |
| Flight Controls | Flap Setting, Flaps Emergency Retract, Speed Brake Emergency Retract, Pitch SAS Engage Left, Pitch SAS Engage Right, Yaw SAS Engage Left, Yaw SAS Engage Right, Pitch/Roll Trim Norm/Emergency Override, Manual Reversion Flight Control System |
| Gear | Anti Skid, Landing Gear Lever |
| Oxygen | Oxygen Supply On/Off, Oxygen Normal/100% |
| Environmental | Bleed Air, Main Air Supply, Windshield Defog/Deice, Windshield Rain Removal/Wash, Pitot Heater |
| Navigation | Altimeter Source, HARS N/S Toggle, HARS SLAVE/DG Mode, HARS-SAS Override/NORM, ILS Frequency/Power, TACAN Mode Dial, Steerpoint Selector, CDU Page Select, CDU Power On/Off |
| Autopilot | Autopilot Mode Select, EAC On/Off, Signal Amplifier Norm/Override |
| Communications | ARC-210 Master Switch, UHF Antenna Switch, UHF Frequency Mode Dial, UHF Function Dial, UHF Squelch, VHF FM Frequency Mode Dial, KY-58 C/RAD Switch, KY-58 Fill Switch, KY-58 Mode Switch, KY-58 Power Switch |
| IFF | IFF Antenna Switch |
| Radar | Radar Altimeter Normal/Disabled |
| Weapons | Master Arm, Gun Arm Mode, Laser Arm, Targeting Pod Power, Jettison Countermeasures, Arm Ground Safety Override Switch, JTRS Datalink On/Off, Scorpion HMCS Power |
| Sensors | DVADR Function Control, Turn On/Off/Test IFFCC |
| Displays | Left MFCD DAY/NIGHT/OFF, Right MFCD DAY/NIGHT/OFF, Day/Night HUD Mode, NORM/Standby HUD Mode |
| Lighting | Land Taxi Lights, Nose Illumination, Position Lights FLASH/OFF/STEADY, Signal Lights, Nightvision Lights, Aerial Refueling Slipway Control |
| Miscellaneous | Zeroize Cover, Able-STOW ADI Localizer Bar |
| Knobs | Aux Instruments Lights, Canopy Defog, CMSC RWR Display Brightness, CMSC RWR Volume, CMSP Display Brightness, Console Light, Engine Instruments Lights, Flight Instruments Lights, Flood Light, Flow Level Control, Formation Lights, HSI Course Set Knob, HSI Heading Set Knob, Intercom Volume, Refuel Status Indexer Lights, Refueling Lighting Dial, RWR Display Brightness, Stall Peak Volume, Stall Volume, TACAN Signal Volume, Temp Level Control, Throttle Friction Control, UHF Volume, VHF FM Volume |

### F-4E Phantom II (52 controls — 38 switches, 14 knobs)

| System | Controls |
|---|---|
| AFCS | AFCS Autopilot, ALT Hold, STAB AUG Pitch, STAB AUG Roll, STAB AUG Yaw |
| Weapons | Arm Fuze, Arm Center Station, Arm Left/Inner Station, Arm Left/Outer Station, Arm Right/Inner Station, Arm Right/Outer Station, Select Delivery Mode, Select Quantity, Select Dispense Program |
| Navigation | Select Reference System, TACAN Mode, Select Navigation Input, Select Navigation Mode, Toggle Flight Director |
| IFF | IFF Master Mode |
| Fuel | Wing Fuel Dump, Internal Wing Tanks Feed |
| Communications | Set Mode (ICS), Comm Antenna, Select Radio Mode, Select Frequency Mode |
| HUD | Select HUD Mode |
| Oxygen | Select Oxygen Mixture, Emergency Release Cockpit Pressure |
| Gear | Anti-Skid |
| Lighting | Taxi/Landing Light, Formation Lights Mode, Console Floodlight, White Floodlight, Instrument Floodlight |
| Environmental | Toggle Rain Removal |
| Circuit Breakers | AIL Feel-Trim CB, ARI CB, Flaps CB, Landing Gear CB, Rudder Trim CB, SAI CB, Speed Brake CB, STAB Feel-Trim CB, Trim Controls CB |
| Knobs | Aural Tone Volume, Change Temperature, Console Light Brightness, Defog Handle, Emergency Wheel Brake, Formation Lights Brightness, Stall Warning Volume |

### F-5E Tiger II (84 controls — 56 switches, 28 knobs)

| System | Controls |
|---|---|
| Weapons | Armament Selector (Centerline, Left/Right Inbd, Left/Right Outbd, Left/Right Wingtip), Bombs Arm Switch, External Stores Selector, Guns/Missile/Camera Switch, Guns/Missile/Camera Switch Cover, Interval Switch |
| Countermeasures | Chaff Mode Selector, Flare Mode Selector, Flare Jettison Switch Cover |
| Fuel | Crossfeed Switch, Ext Fuel Cl Switch, Ext Fuel Pylons Switch, Left Boost Pump Switch, Right Boost Pump Switch, Left Fuel Shutoff Switch, Right Fuel Shutoff Switch, Left Fuel Shutoff Switch Cover, Right Fuel Shutoff Switch Cover |
| Flight Controls | Auto Flap System Thumb Switch, Flaps Lever, Pitch Damper Switch, Speed Brake Switch, Yaw Damper Switch |
| Oxygen | Oxygen Diluter Lever, Oxygen Emergency Lever, Oxygen Supply Lever |
| Navigation | Compass Switch, Nav Mode Selector Switch, TACAN Mode Selector |
| Radar | Radar Mode Selector, Radar Range Selector, Sight BIT Switch, Sight Camera FPS Switch, Sight Camera Overrun Selector, Sight Mode Selector |
| RWR | RWR Altitude Button, RWR Power Button |
| Environmental | Cabin Press Switch, Cabin Press Switch Cover, Cabin Temp Switch, Engine Anti-Ice Switch, Pitot Anti-Ice Switch, Magnetic Compass Light Switch |
| IFF | IFF Master Control Selector, IFF MODE 1 Code Wheels (×2), IFF MODE 3/A Code Wheels (×4), IFF MODE 4 Control Switch, IFF MODE 4 Monitor Switch |
| Communications | UHF Antenna Selector, UHF Frequency Mode Selector, UHF Function Selector, UHF Squelch Switch |
| Lighting | Exterior Lights Beacon Switch, Landing & Taxi Light Switch |
| Knobs | Armament Panel Lights, Cabin Temperature, Canopy Defog, Console Lights, Engine Instruments Lights, Exterior Lights Formation, Exterior Lights Nav, Flight Instruments Lights, Flood Lights, Missile Volume, Radar Bright, Radar Persistence, Radar Video, Reticle Intensity, Rudder Trim, RWR Audio, RWR DIM, RWR INT, TACAN Volume, UHF Volume |

### F-14B Tomcat (40 controls — 33 switches, 7 knobs)

| System | Controls |
|---|---|
| AFCS | AFCS Stability Augmentation (Pitch, Roll, Yaw), Autopilot Engage, Autopilot Altitude Hold, Autopilot Heading/Ground Track, Autopilot Vector/ACL |
| Weapons | ACM Cover, Master Arm Cover |
| Navigation | Navigation Steer Commands, ANA/ARA-63 Power Switch |
| HUD | HUD Mode, HUD AWL Mode, HUD Power On/Off |
| VDI | VDI Landing Mode, VDI Power On/Off |
| HSD | HSD Display Mode, HSD/ECM Power On/Off |
| Engine | Left Engine Mode, Right Engine Mode, Asymmetric Thrust Limiter Cover |
| Hydraulics | Hydraulic Emergency Flight Control Switch Cover, Hydraulic Transfer Pump Switch Cover |
| Electrical | Emergency Generator Switch Cover |
| Fuel | Wing/Ext Trans |
| Gear | Anti-Skid Spoiler BK Switch |
| Oxygen | Pilot Oxygen On |
| Lighting | Anti-Collision Lights, Position Lights Flash, Position Lights Tail, Position Lights Wing, Red Flood Light, White Flood Light, Taxi Light |
| Miscellaneous | Hook Bypass |
| Knobs | ALR-67 Volume, Console Light Intensity, Formation Light Intensity, Instrument Light Intensity, Sidewinder Volume, UHF ARC-159 Volume, VHF/UHF ARC-182 Volume |

### F-16C Viper (63 controls — 52 switches, 11 knobs)

| System | Controls |
|---|---|
| FLCS | DIGITAL BACKUP Switch, FLCS POWER Switch, ALT FLAPS Switch, TRIM/AP DISC Switch |
| Autopilot | Autopilot Roll Switch |
| Fuel | Engine Feed Knob, External Fuel Transfer Switch, FUEL MASTER Switch Cover, FUEL QTY SEL Knob |
| Environmental | AIR SOURCE Knob, PROBE HEAT Switch |
| Navigation | GPS Switch, INS Knob |
| Radar | FCR Switch, RDR ALT Switch, MAP Switch |
| Communications | C & I Knob, DL Switch, MIDS LVT Knob, MMC Switch, UFC Switch |
| IFF | IFF Master Knob |
| EW / ECM | Jammer Source Switch, MWS Source Switch, RWR Source Switch |
| Countermeasures | CH Expendable Category Switch, FL Expendable Category Switch, O1/O2 Expendable Category Switch, FLASH STEADY Switch, MODE Knob, PROGRAM Knob |
| Weapons | GND JETT ENABLE Switch, LASER ARM Switch, MASTER ARM Switch, MASTER Switch, MANUAL TF FLYUP Switch, ST STA Switch, STORES CONFIG Switch |
| Dispensers | FUSELAGE Switch, LEFT/RIGHT HDPT Switch, WING/TAIL Switch |
| Electrical | MFD Switch |
| HUD | HUD Altitude Switch, HUD Brightness Control Switch, HUD DED/PFLD Data Switch, HUD Flightpath Marker Switch, HUD Scales Switch |
| ECS | AIR REFUELING Switch, Supply Lever |
| Lighting | LANDING TAXI LIGHTS Switch |
| Knobs | ANTI-COLL, COMM 1 Power, COMM 2 Power, FLOOD CONSOLES BRT, FLOOD INST PNL, FORM, HMCS SYMBOLOGY INT, PRIMARY CONSOLES BRT, PRIMARY DATA ENTRY DISPLAY BRT, PRIMARY INST PNL |

### F/A-18C Hornet (62 controls — 41 switches, 21 knobs)

| System | Controls |
|---|---|
| Oxygen | OBOGS Control Switch |
| Flight Controls | FLAP Switch, Anti Skid Switch, ATTITUDE Selector Switch, Shoulder Harness Control Handle |
| Weapons | Master Arm Switch, Auxiliary Release Switch, Spin Recovery Switch Cover, GAIN Switch Cover |
| Navigation | INS Switch, ILS Channel Selector, ILS UFC/MAN Switch, HUD Altitude Switch, HUD Symbology Reject Switch, HUD Video Control Switch |
| Communications | COMM G XMT Switch, COMM Relay Switch, KY-58 Fill Select, KY-58 Mode Select, KY-58 Power Select |
| IFF | UFC ADF Function Select Switch |
| Radar | RADAR Switch |
| EW | ECM Mode Switch, FLIR Switch, LST/NFLR Switch |
| Electrical | Left Generator Switch, Right Generator Switch, Generator TIE Control Switch Cover, CB FCS CHAN 1–4, CB HOOK, CB LAUNCH BAR, CB LG, CB SPD BRK |
| Lighting | LDG/TAXI LIGHT Switch, HOOK BYPASS Switch, MODE Switch, ENGINE ANTI-ICE Switch |
| Knobs | AMPCD Off/Brightness, Balance Control, CHART Dimmer, COMM 1 Volume, COMM 2 Volume, CONSOLES Dimmer, Defog Handle, FLOOD Dimmer, FORMATION Lights Dimmer, IFEI Brightness, INST PNL Dimmer, KY-58 Volume, OXY Flow, POSITION Lights Dimmer, Left/Right MDI Brightness, TACAN Volume, Throttles Friction, UFC Brightness, WARN/CAUTION Dimmer |

### MiG-21bis (138 controls — 100 switches, 38 knobs)

| System | Controls |
|---|---|
| Electrical | AC Generator On/Off, DC Generator On/Off, Battery On/Off, Battery Heat On/Off, PO-750 Inverter #1 On/Off, PO-750 Inverter #2 On/Off, Emergency Inverter |
| Engine | Engine Cold/Normal Start, Engine Emergency Air Start, Engine Nozzle 2 Position Emergency Control, Anti Surge Doors Auto/Manual, Nosecone On/Off, Nosecone Control Manual/Auto, APU On/Off |
| Fuel | Fuel Tanks 1st Group Fuel Pump, Fuel Tanks 3rd Group Fuel Pump, Drain Fuel Tank Fuel Pump |
| Flight Controls | ABS Off/On, Aileron Booster Off/On, ARU System Manual/Auto, SPS System Off/On, Trimmer On/Off |
| Afterburner | Afterburner Maximum Off/On, Emergency Afterburner Off/On, Special AB/Missile-Rocket-Bombs-Cannon |
| Hydraulics | Emergency Hydraulic Pump On/Off |
| RATO | SPRD RATO Start Cover, SPRD RATO System On/Off, SPRD RATO Drop Cover, SPRD RATO Drop System On/Off |
| Oxygen | Emergency Oxygen Off/On, Mixture/Oxygen, Helmet Air Condition Off/On, Helmet Heat Manual/Auto, Helmet Visor Off/On |
| Navigation | DA-200/Giro NPP/SAU Power On/Off, Giro NPP SAU RLS KPP Power On/Off, KPP Main/Emergency, Low Altitude Off/Comp/On, Marker Far/Near, NPP On/Off, Radio Altimeter/Marker On/Off, RSBN On/Off, RSBN Mode Land/Navigation/Descend, RSBN Bearing, RSBN Distance, RSBN/ARK |
| Autopilot | SAU On/Off, SAU Pitch On/Off, SAU Preset Limit Altitude |
| IFF | IFF System Type 81 On/Off, SOD IFF On/Off, SOD Modes, SOD Wave Selector, SRZO IFF Coder/Decoder On/Off |
| Weapons | ASP Main Mode Manual/Auto, ASP Mode Bombardment/Shooting, ASP Mode Giro/Missile, ASP Mode Missiles-Rockets/Gun, ASP Optical Sight On/Off, Detonation Air/Ground, GS-23 Gun On/Off, Guncam On/Off, Missiles Rockets Heat On/Off, Missiles Rockets Launch On/Off, Pipper On/Off, Pylon 1-2 Power On/Off, Pylon 3-4 Power On/Off, Weapon Mode Air/Ground, Weapon Mode IR Missile/Neutral/SAR Missile |
| Radar | Locked Beam On/Off, Radar Off/Prep/On |
| EW | SPS-141 On/Off, SPS-141 Continuous/Impulse, SPS-141 Dispenser Auto/Manual, SPS-141 Off/Parallel/Full, SPS-141 Program I/II, SPS-141 Transmit/Receive, SPO-10 Night/Day, SPO-10 RWR On/Off |
| Communications | ARK Mode Antenna/Compass, ARK On/Off, Fix Net On/Off, Radio System On/Off, Radio/Compass, Squelch On/Off, UK-2M Mic Amplifier GS/KM, UK-2M Mic Amplifier M/L |
| Flight Data | SARPP-12 Flight Data Recorder On/Off |
| Canopy | Hermetize Canopy, Secure Canopy, Harness Separation |
| Pitot | Pitot Tube Selector Main/Emergency, Pitot Tube/Periscope/Clock Heat, Secondary Pitot Heat |
| Airbrake | Airbrake Out/In |
| Landing | Gear Up/Neutral/Down, Nosegear Brake Off/On, Landing Lights Off/Taxi/Land, Navigation Lights Off/Min/Med/Max |
| Emergency | Emergency Transmitter Cover, Emergency Transmitter On/Off, Fire Extinguisher Off/On |
| Miscellaneous | Flaps Landing, Flaps Neutral, Flaps Take-Off |
| Knobs | Altimeter Pressure, ARK Channel, ARK Sound, ARK Zone, Canopy Ventilation, Cockpit Texts Back-light, Dangerous Altitude Warning Set, Fix Net Light Control, Fuel Quantity Set, G-Suit Valve, Harness Loose/Tight, Instruments Back-light, Intercept Angle, Main Red Lights, Main White Lights, Missile Seeker Sound, Nosecone Manual Position, Pipper Light Control, PRMG Landing, Radar Polar Filter, Radio Channel, Radio Volume, RSBN Navigation, RSBN Sound, Scale Backlights Control, SPO-10 Volume, Suit Ventilation, Target Size, TDC Range/Pipper Span, Throttle Fixation |

### Spitfire LF Mk. IX (49 controls — 36 switches, 13 knobs)

| System | Controls |
|---|---|
| Engine | Magneto Left, Magneto Right, Mixture Cut-Off Lever, Carburettor Air Control Lever, Supercharger Mode Toggle, Supercharger Mode Test Button Cover, Radiator Control Toggle |
| Fuel | Fuel Cock, Fuel Pump Toggle, Tank Pressurizer Lever, Drop Tank Cock |
| Propulsion | Booster Coil Button Cover, Oil Diluter Button Cover, Starter Button Cover |
| Flight Controls | Flaps Lever, Undercarriage Lever, Elevator Trim Wheel |
| Gear | U/C Indicator Blind, U/C Indicator Cut-Off Toggle |
| Oxygen | Oxygen Valve |
| IFF | I.F.F. Protective Cover, I.F.F. Upper Toggle (Type B), I.F.F. Lower Toggle (Type D) |
| Identification Lights | ID Lamp Down Mode Selector, ID Lamp Up Mode Selector |
| Communications | Radio Mode Selector, Radio Dimmer Toggle, Radio Transmit Lock Toggle |
| Weapons | Safety Lever, Gun Sight Master Switch, Gun Sight Tint Screen |
| Environmental | De-Icer Lever, Pitot Heater Toggle, Radiator Flap Test Button Cover |
| Cockpit | Canopy Open/Close Control, Cockpit Side Door |
| Lighting | Nav Lights Toggle |
| Knobs | Altimeter Pressure Setting, Compass Azimuth Ring, Direction Indicator Knob, Gun Sight Dimmer, Gun Sight Range Setter, Gun Sight Span Setter, Cockpit Illumination LH, Cockpit Illumination RH, Propeller Pitch Lever, Throttle Lever, Rudder Trim Wheel, Wheel Brakes |

### UH-1H Huey (136 controls — 122 switches, 14 knobs)

| System | Controls |
|---|---|
| Electrical | Battery Switch, Inverter Switch, Non-Essential Bus Switch, Starter/Stdby GEN Switch, Main Generator Switch Cover |
| Rotor / Governor | Governor Switch, Force Trim Switch |
| Fuel | Main Fuel Switch |
| Environmental | De-Ice Switch, Bleed Air Switch |
| Miscellaneous | Gyro Mode Switch |
| Navigation | ADF/VOR Control Switch, Radar Altimeter Power Switch, Marker Beacon Sensing Switch |
| Communications | UHF Frequency Mode Dial, UHF Function Dial, UHF Radio Receiver Switch, UHF Squelch Disable Switch, VHF AM Radio Receiver Switch, VHF FM Mode Switch, VHF FM Radio Receiver Switch, VHF FM Squelch Mode Switch, INT Receiver Switch, BFO Switch |
| IFF | IFF Master Knob, IFF On/Out Switch (Mode 4), Receiver 4 N/F Switch, Receiver NAV Switch |
| Weapons | ARM Switch, Armament Selector Switch, Armament Switch, Gun Selector Switch, Chaff Mode Switch, Jettison Switch Cover, Ripple Fire Cover, Ripple Fire Switch |
| Lighting | Anti-Collision Lights Switch, Dome Light Switch, Landing Light Control Switch, Landing Light Switch, Navigation Lights Switch, Position Lights Switch (Dim/Bright), Position Lights Switch (Steady/Off/Flash), Search Light Switch, Low RPM Warning Switch |
| Wipers | Wiper Selector Switch |
| Circuit Breakers | 28V Trans, Anticollision Light, ARC-102 HF Static INVTR, Cabin Heater (Air/Outlet Valve), Cargo Hook Release, Caution Lights, Cockpit Lights, Console Lights, Copilot ATTD 1/2, Course Ind, Dome Lights, Engine Anti-Ice, EXT Stores Jettison, Fail Relay, Fire Detector, FM Radio, FM 2 Radio, FORCE Trim, Fuel Quantity, Fuel TRANS, Fuel Valves, Fuselage Lights, Generator & Bus Reset, Governor Control, Gyro Compass, Heated Blanket 1/2, HF ANT COUPLR, HF ARC-102, HYD Control, IDLE Stop Release, IFF APX 1/2, Ignition System, INST Panel Lights, INST SEC Lights, Intercom CPLT, Intercom PLT, Inverter CTRL, KY-28 Voice Security, Landing & Search Light Control, Landing Light Power, LF Nav (ARN-83), LH/RH Fuel Boost Pump, Main Inverter PWR, Marker Beacon, Navigation Lights, Pilot ATTD 1/2, Pitot Tube, Pressure Eng/Fuel/Torque/XMSN, Prox. Warn., Rescue Hoist Cable Cutter/CTL/PWR, RPM Warning System, Search Light Power, Spare Inverter PWR, Starter Relay, STBY Generator Field, TEMP Indicator, Turn & Slip Indicator, UHF Radio, VHF AM Radio, VHF Nav (ARN-82), Voltmeter Non Ess Bus, Wind Wiper CPLT/PLT, Cargo Safety |
| Knobs | Copilot Instrument Lights, Engine Instrument Lights, Intercom Volume, Marker Beacon Volume, Overhead Console Panel Lights, Pedestal Lights, Pilot Instrument Lights, Pilot Sighting Station Intensity, Radar Altimeter Low Altitude Setting, Secondary Instrument Lights, Sighting Station Intensity, UHF Volume, VHF FM Volume |

---

## Debugging

Search `Saved Games\DCS\Logs\dcs.log` for `DCS_SWITCH_RANDOMIZER`.

Typical output on a successful cold start:

```
[DCS_SWITCH_RANDOMIZER] Aircraft detected: FA-18C_hornet — arming with 3.0s delay.
[DCS_SWITCH_RANDOMIZER] RPM check: left=0.0%  right=0.0%  threshold=10.0%
[DCS_SWITCH_RANDOMIZER] Randomizing cockpit on: FA-18C_hornet
[DCS_SWITCH_RANDOMIZER]   Master Arm Switch                          dev=18  cmd=3003  -> 0
[DCS_SWITCH_RANDOMIZER]   RADAR Switch                               dev=19  cmd=3001  -> 0.1
...
[DCS_SWITCH_RANDOMIZER] Randomizer complete for: FA-18C_hornet
```

Typical output when skipped (taxi / in-flight):

```
[DCS_SWITCH_RANDOMIZER] RPM check: left=68.4%  right=67.9%  threshold=10.0%
[DCS_SWITCH_RANDOMIZER] Skipping: engines running (RPM >= threshold). Not a cold start.
```

---

## License

DCS Switch Randomizer is a hobby DCS mod distributed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).
Use it, modify it, share it — but not for commercial purposes. Credit required: please link back to this repository.

**No warranty:** This software is provided as-is, without any warranty, express or implied. The author is not responsible for any issues arising from its use, including but not limited to data loss, save file corruption, or unexpected behavior in DCS World. You install and use this mod at your own risk.

**Disclaimer:** DCS Switch Randomizer (DSR) is an independent hobby project with no affiliation with Eagle Dynamics, Heatblur Simulations, or any other DCS module developer.
