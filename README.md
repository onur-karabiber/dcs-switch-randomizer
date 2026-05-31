# CockpitRandomizer

A DCS World Export script that randomizes cockpit switch positions on every cold start, forcing a proper interior check before doing anything else.

Currently supports:

- **F-4E Phantom II** (Heatblur)
- **F/A-18C Hornet** (Eagle Dynamics)
- **F-14B Tomcat** (Heatblur)
- **F-16C Viper** (Eagle Dynamics)
- **F-5E Tiger II** (Eagle Dynamics)

---

## Who is this for?

This mod is **not for everyone**.

CockpitRandomizer is built for DCS players who enjoy:

- Real cold-start procedures
- Checklists
- Interior checks
- Proper switch discipline
- Realistic cockpit workflow
- Catching something out of place before startup

If you are the type of player who spawns, hits auto-start, and takes off in 30 seconds, this mod is probably not for you.

If you enjoy real procedures, checklists, and doing things properly, this mod is for you.

---

## Why this exists

In vanilla DCS, cold starts become predictable.

Every time you enter the cockpit, the aircraft appears in the exact same state. Same switches. Same knobs. Same panel positions.

After a while, interior checks stop being checks.

You stop **checking** and start **remembering**.

After enough repetitions, you already know where everything is before even looking. The checklist becomes memory instead of verification.

That breaks immersion.

A real aircraft coming from a previous sortie would rarely be left in a perfectly standardized state. A previous pilot, crew chief, or technician may have left things differently:

- A light dimmer slightly moved
- A radio volume changed
- A formation light setting altered
- A non-critical system left in an unexpected position
- A switch not exactly where you expected

CockpitRandomizer brings some of that uncertainty back.

---

## How the randomization works

**This is not a chaos or failure simulator.** CockpitRandomizer will not open your landing gear, jettison the canopy, pull the ejection handle, or drop your stores. It does not simulate mechanical failures or broken aircraft.

What it does is more subtle — and that is exactly the point.

Safety-critical and operationally important switches are intentionally biased toward their correct cold-start position. Most of the time, the cockpit will look familiar. But occasionally — at low probability — something will be different. A generator that normally comes up ON might start OFF. A circuit breaker that is always in might be pulled. A weapons system that is always SAFE might have taken a stray elbow in the hangar.

A switch in the wrong position will not always announce itself. It may only reveal itself when you need that system — on the runway, during cruise, or in an engagement.

That is the whole point: **if you are serious about flying like a real pilot, you must be serious about your interior check. Every time. Without exception.**

In other words: this mod does not create chaos. It creates the conditions under which failing to do a proper interior check has consequences. If you install it, you are signing up for that stress. Do not forget it.

A switch's default state usually has somewhere between **75% and 95% probability** of appearing unchanged. Non-critical elements such as interior lighting, brightness knobs, and radio volumes are often randomized more freely.

---

## Features

- **Cold-start only**
  The script checks engine RPM values and only activates when the aircraft is truly cold. Taxi, runway, hot-start, and in-flight slots are unaffected.

- **Aircraft-aware**
  Automatically detects the active aircraft and loads the correct switch table.

- **Weighted randomization**
  Safety-critical systems heavily favor realistic defaults instead of pure randomness.

- **Modular structure**
  Each aircraft uses its own switch table file, making expansion straightforward.

- **Export.lua friendly**
  Compatible with DCS-BIOS, SRS, Tacview, and other Export.lua-based tools.

- **Logging support**
  All activity is written to `DCS.log` under the `COCKPIT_RANDOMIZER` tag.

---

## Requirements

- DCS World (Steam or standalone)
- One or more supported aircraft modules
- No additional mods or tools required

---

## Installation

> **Before you begin:** CockpitRandomizer is installed entirely inside your `Saved Games\DCS\` folder. It does not touch your DCS installation directory. That said, you are responsible for following these instructions carefully, taking any backups you consider appropriate (particularly of an existing `Export.lua`), and understanding what the mod does before using it. Install at your own discretion.

**Step 1 — Locate your Saved Games folder**

```
%USERPROFILE%\Saved Games\DCS\
```

If you use the OpenBeta branch, the folder may be `Saved Games\DCS.openbeta\`.

**Step 2 — Create the folder structure** (skip folders that already exist)

```
Saved Games\DCS\
    Scripts\
        CockpitRandomizer\
            core.lua
            f4e.lua
            fa18c.lua
            f14b.lua
            f16c.lua
            f5e.lua
        Export.lua
```

**Step 3 — Copy the files**

From this repository, copy each file under `CockpitRandomizer\` to the corresponding path under `Saved Games\DCS\Scripts\CockpitRandomizer\`, and copy `Export.lua` to `Saved Games\DCS\Scripts\Export.lua`.

Only copy the aircraft files for modules you own.

**Step 4 — If Export.lua already exists**

If you already have an `Export.lua` (DCS-BIOS, SRS, Tacview, etc.), do **not** replace it. Instead, add the CockpitRandomizer block from the provided `Export.lua` to the **top** of your existing file:

```lua
local cr_status, cr_err = pcall(function()
    local lfs = require('lfs')
    local base = lfs.writedir() .. "Scripts\\CockpitRandomizer\\"
    dofile(base .. "core.lua")
    dofile(base .. "f4e.lua")
    dofile(base .. "fa18c.lua")
    dofile(base .. "f14b.lua")
    dofile(base .. "f16c.lua")
    dofile(base .. "f5e.lua")
end)
if not cr_status then
    log.write("COCKPIT_RANDOMIZER", log.ERROR, "Load failed: " .. tostring(cr_err))
end
```

Remove any `dofile` lines for aircraft you do not own.

> **Do not touch** `SteamLibrary\steamapps\common\DCSWorld\Scripts\Export.lua`. That file is read-only reference material. Your changes belong exclusively in `Saved Games\DCS\Scripts\Export.lua`.

**Step 5 — Verify**

Launch DCS and fly any supported cold-start mission. After ~3 seconds in the cockpit, switches will randomize. Check `Saved Games\DCS\Logs\dcs.log` and search for `COCKPIT_RANDOMIZER` to confirm the script is running.

---

## Uninstallation

**Full removal:**

1. Delete the `Saved Games\DCS\Scripts\CockpitRandomizer\` folder.
2. Open `Saved Games\DCS\Scripts\Export.lua` and remove the CockpitRandomizer block.
3. If `Export.lua` is now empty, delete it as well.

**Temporary disable** (without uninstalling):

Open `CockpitRandomizer\core.lua` and set:

```lua
CR.ENABLED = false
```

**Disable a single aircraft** (without removing its file):

Comment out its `dofile` line in `Export.lua`:

```lua
-- dofile(base .. "f16c.lua")
```

---

## Configuration

All user-facing settings are at the top of `CockpitRandomizer\core.lua`:

| Setting            | Default | Description                                                                                       |
| ------------------ | ------- | ------------------------------------------------------------------------------------------------- |
| `CR.ENABLED`       | `true`  | Set to `false` to disable without uninstalling.                                                   |
| `CR.DELAY_SECONDS` | `3.0`   | Seconds to wait after cockpit load before randomizing. Increase if switches snap back to default. |
| `CR.RPM_THRESHOLD` | `10.0`  | Both engines must be below this RPM % for cold-start detection.                                   |

---

## Randomized controls

Probabilities below are derived from the comment annotations in each aircraft file. In all tables, a switch listed here is randomized; unlisted switches are not touched.

### F-4E Phantom II

| System | Controls |
| --- | --- |
| Countermeasures | Select Dispense Program |
| Communications | Set Mode (ICS Panel), Select Communication Antenna, Select Radio Mode, Select Frequency Mode |
| IFF | Select Master Mode |
| Fuel | Wing Fuel Dump Selector, Internal Wing Tanks Feed |
| AFCS | STAB AUG Yaw, STAB AUG Roll, STAB AUG Pitch, AFCS Autopilot, ALT Hold |
| Gear / Brakes | Anti-Skid Toggle, Emergency Wheel Brake |
| Navigation | Select Reference System, Select TACAN Mode, Select Navigation Input, Select Navigation Mode, Toggle Flight Director |
| HUD | Select HUD Mode |
| Weapons | Arm Fuze, Select Delivery Mode, Select Quantity |
| Oxygen | Select Oxygen Mixture, Emergency Release Cockpit Pressure |
| Circuit Breakers | ARI CB, SAI CB, Landing Gear CB, Speed Brake CB, STAB Feel-Trim CB, AIL Feel-Trim CB, Rudder Trim CB, Trim Controls CB, Flaps CB |
| Exterior Lights | Taxi/Landing Light, Set Formation Lights Mode, Change Formation Lights Brightness |
| Interior Lights | Set Console Floodlight (Red) Brightness, Change Console Light Brightness, Toggle White Floodlight, Set Instrument Floodlight (Red) Brightness |
| Environmental | Toggle Rain Removal, Change Temperature¹, Defog Handle¹ |
| DCU Arm Stations | Arm Left/Outer Station, Arm Left/Inner Station, Arm Center Station, Arm Right/Inner Station, Arm Right/Outer Station |
| Audio | AoA Stall Warning Volume, Aural Tone Volume |

### F/A-18C Hornet

| System | Controls |
| --- | --- |
| Oxygen | OXY Flow Knob, OBOGS Control Switch |
| Exterior Lights | POSITION Lights Dimmer, FORMATION Lights Dimmer, LDG/TAXI LIGHT Switch |
| Cockpit Lights | HOOK BYPASS Switch, CONSOLES Dimmer, INST PNL Dimmer, FLOOD Dimmer, MODE Switch, WARN/CAUTION Dimmer, CHART Dimmer |
| Gear | Anti Skid Switch |
| HUD | Altitude Switch, HUD Symbology Brightness Selector |
| UFC | UFC COMM 1 Volume, UFC COMM 2 Volume |
| MDI | Left MDI Brightness Selector, Right MDI Brightness Selector |
| AMPCD | AMPCD Off/Brightness Knob |
| Weapons | Master Arm Switch, Selective Jettison Knob |
| Electrical | Left Generator Switch, Right Generator Switch, External Power Switch, CB LAUNCH BAR, CB SPD BRK, CB FCS CHAN 1, CB FCS CHAN 2, CB FCS CHAN 3, CB FCS CHAN 4, CB HOOK, CB LG |
| Countermeasures | DISPENSER Switch |
| ECM | ECM Mode Switch |
| Radar | RADAR Switch |
| INS | INS Switch |
| Flight Controls | FLAP Switch, Throttles Friction Adjusting Lever |
| ECS | Defog Handle, Suit Temperature Knob, Cabin Temperature Knob |
| Hydraulics | Hydraulic Isolate Override Switch |
| Fuel | External Wing Tanks Fuel Control Switch, External Centerline Tank Fuel Control Switch |
| Intercom / IFF | ILS Channel Selector Switch, ILS UFC/MAN Switch, IFF Master Switch, IFF Mode 4 Switch, TACAN Volume Knob, RWR Volume Control Knob, MIDS A/B Volume Control Knobs, ICS Volume Control Knob, VOX Volume Control Knob, AUX Volume Control Knob |
| CPT Mechanics | Shoulder Harness Control Handle |

### F-14B Tomcat

| System | Controls |
| --- | --- |
| Oxygen | Pilot Oxygen On |
| Audio | Sidewinder Volume, ALR-67 Volume |
| Radio | VHF/UHF ARC-182 Volume Pilot, UHF ARC-159 Volume Pilot |
| AFCS | AFCS Stability Augmentation (Yaw/Roll/Pitch), Autopilot Engage, Autopilot Altitude Hold, Autopilot Heading/Ground Track, Autopilot Vector/ACL |
| Covers | Asymmetric Thrust Limiter Cover, Emergency Generator Switch Cover, ACM Cover, Hydraulic Emergency Flight Control Switch Cover, Hydraulic Transfer Pump Switch Cover |
| Engine | Left Engine Mode, Right Engine Mode |
| Gear / Brakes | Anti-Skid Spoiler BK Switch |
| Fuel | Wing/Ext Trans |
| Weapons | Master Arm Cover |
| HUD | HUD Take-off Mode, HUD Cruise Mode, HUD Air-to-Air Mode, HUD Air-to-Ground Mode, HUD Landing Mode, HUD AWL Mode, HUD Power On/Off |
| VDI | VDI Landing Mode, VDI Power On/Off |
| HSD | HSD Display Mode, HSD/ECM Power On/Off |
| Navigation | Navigation Steer Commands (TACAN, Destination, AWL PCD, Vector, Manual) |
| ILS | ANA/ARA-63 Power Switch |
| Cockpit Mechanics | Hook Bypass, Taxi Light, White Flood Light, Red Flood Light, Position Lights Wing, Position Lights Tail, Position Lights Flash, Anti-Collision Lights, Instrument Light Intensity, Console Light Intensity, Formation Light Intensity |

### F-16C Viper

| System | Controls |
| --- | --- |
| Electrical | PROBE HEAT Switch, FLCS PWR TEST Switch |
| Flight Controls | TRIM/AP DISC Switch, DIGITAL BACKUP Switch, ALT FLAPS Switch, MANUAL TF FLYUP Switch, Autopilot ROLL Switch, STORES CONFIG Switch |
| Fuel | FUEL MASTER Switch Cover, External Fuel Transfer Switch, ENGINE FEED Knob, FUEL QTY SEL Knob, AIR REFUEL Switch |
| Oxygen | Supply Lever |
| Gear / Brakes | ANTI-SKID Switch |
| Exterior Lights | ANTI-COLL Knob, FORM Knob, MASTER Switch, WING/TAIL Switch, FUSELAGE Switch, FLASH STEADY Switch, LANDING TAXI LIGHTS Switch |
| Interior Lights | PRIMARY CONSOLES BRT Knob, PRIMARY INST PNL Knob, PRIMARY DATA ENTRY DISPLAY BRT Knob, FLOOD CONSOLES BRT Knob, FLOOD INST PNL Knob |
| ECS | AIR SOURCE Knob |
| INS | INS Knob |
| RALT | RDR ALT Switch |
| UFC | UFC Switch |
| MMC / Avionics | MMC Switch, MFD Switch, ST STA Switch, LEFT HDPT Switch, RIGHT HDPT Switch, GPS Switch, DL Switch, MAP Switch |
| HUD | HUD Scales Switch, HUD Flightpath Marker Switch, HUD DED/PFLD Data Switch, HUD Altitude Switch, HUD Brightness Control Switch |
| Weapons | MASTER ARM Switch, GND JETT ENABLE Switch, LASER ARM Switch |
| HMCS | HMCS SYMBOLOGY INT Knob |
| FCR / Radar | FCR Switch |
| CMDS | RWR Source Switch, Jammer Source Switch, MWS Source Switch, O1 Expendable Category Switch, O2 Expendable Category Switch, CH Expendable Category Switch, FL Expendable Category Switch, PROGRAM Knob, MODE Knob |
| IFF | IFF MASTER Knob, C & I Knob |
| Intercom | COMM 1 Power Knob, COMM 2 Power Knob |
| MIDS | MIDS LVT Knob |
| EPU | EPU System (covers + switch) |

### F-5E Tiger II

| System | Controls |
| --- | --- |
| Flight Controls | Yaw Damper Switch, Pitch Damper Switch, Rudder Trim Knob, Flaps Lever, Auto Flap System Thumb Switch, Speed Brake Switch |
| Electrical | Pitot Anti-Ice Switch |
| Fuel | Left/Right Fuel Shutoff Switch Covers, Ext Fuel Cl Switch, Ext Fuel Pylons Switch, Left Boost Pump Switch, Crossfeed Switch, Right Boost Pump Switch |
| Engine | Engine Anti-Ice Switch |
| Oxygen | Oxygen Supply Lever, Oxygen Diluter Lever, Oxygen Emergency Lever |
| ECS | Cabin Press Switch Cover, Cabin Press Switch, Cabin Temp Switch, Cabin Temperature Knob, Canopy Defog Knob |
| Exterior Lights | Exterior Lights Nav Knob, Exterior Lights Formation Knob, Exterior Lights Beacon Switch, Landing & Taxi Light Switch |
| Interior Lights | Magnetic Compass Light Switch, Flood Lights Knob, Flight Instruments Lights Knob, Engine Instruments Lights Knob, Console Lights Knob, Armament Panel Lights Knob |
| Countermeasures | Chaff Mode Selector, Flare Mode Selector, Flare Jettison Switch Cover |
| Weapons | Armament Position Selectors (×7), Interval Switch, Bombs Arm Switch, Guns/Missile/Camera Switch Cover, External Stores Selector, Missile Volume Knob |
| AHRS | Compass Switch, Nav Mode Selector Switch |
| Radar | Radar Range Selector, Radar Mode Selector, Radar Bright Knob, Radar Persistence Knob, Radar Video Knob |
| Sight | Sight Mode Selector, Reticle Intensity Knob, Sight BIT Switch |
| RWR | RWR Altitude Button, RWR Power Button, RWR Audio Knob, RWR DIM Knob, RWR INT Knob |
| IFF | IFF Master Control Selector, IFF MODE 4 Monitor Switch, IFF MODE 4 Control Switch, IFF MODE 1 Code Wheels (×2), IFF MODE 3/A Code Wheels (×4) |
| UHF Radio | UHF Frequency Mode Selector, UHF Function Selector, UHF Squelch Switch, UHF Volume Knob, UHF Antenna Selector |
| TACAN | TACAN Mode Selector, TACAN Signal Volume Knob |
| Sight Camera | Sight Camera FPS Select Switch, Sight Camera Overrun Selector |

¹ Not yet simulated in DCS. Handle/knob moves visually but has no functional effect.

---

## Debugging

Search `Saved Games\DCS\Logs\dcs.log` for `COCKPIT_RANDOMIZER`.

Typical output on a successful cold start:

```
[COCKPIT_RANDOMIZER] Aircraft detected: F-16C_50 — arming with 3.0s delay.
[COCKPIT_RANDOMIZER] RPM check: left=0.0%  right=0.0%  threshold=10.0%
[COCKPIT_RANDOMIZER] Randomizing cockpit on: F-16C_50
[COCKPIT_RANDOMIZER]   PROBE HEAT Switch   dev=3  cmd=3002 -> 1
[COCKPIT_RANDOMIZER]   INS Knob            dev=14 cmd=3001 -> 0.3
...
[COCKPIT_RANDOMIZER] Randomizer complete for: F-16C_50
```

Typical output when skipped (taxi / in-flight):

```
[COCKPIT_RANDOMIZER] RPM check: left=68.4%  right=67.9%  threshold=10.0%
[COCKPIT_RANDOMIZER] Skipping: engines running (RPM >= threshold). Not a cold start.
```

---

## Adding support for other aircraft

1. Create a new file: `CockpitRandomizer\<module>.lua`
2. Find the aircraft's `clickabledata.lua`, `command_defs.lua`, and `devices.lua` under `DCSWorld\Mods\aircraft\<module>\Cockpit\Scripts\`.
3. Use an existing aircraft file as a template.
4. Register the switch table with `CR.register("DCS_aircraft_name", { ... })`.
5. Add a `dofile` line for the new file in `Export.lua`.

The DCS aircraft name string is what `LoGetSelfData().Name` returns in-game. Confirm it by checking the `Aircraft detected:` line in `dcs.log` on first run.

---

## License and use

This project is free to use and free to share.

The scripts are original work. There are no third-party licenses or intellectual property claims involved.

**Credit:** You are not required to credit this project to use or share it, but doing so is the ethical thing to do if you redistribute or build on it.

**Commercial use:** This project may not be used for commercial purposes in any form.

**No warranty:** This software is provided as-is, without any warranty, express or implied. The author is not responsible for any issues arising from its use, including but not limited to data loss, save file corruption, or unexpected behavior in DCS World. You install and use this mod at your own risk.

**Disclaimer:** CockpitRandomizer is an independent hobby project with no affiliation with Eagle Dynamics, Heatblur Simulations, or any other DCS module developer.
