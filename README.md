# CockpitRandomizer

A DCS World Export script that randomizes cockpit switch positions each time
you sit down for a **cold start**, forcing you to perform a proper interior
check before doing anything else.

Currently supports:

- **F-4E Phantom II** (Heatblur) — 40 controls
- **F/A-18C Hornet** (Eagle Dynamics) — 36 controls
- **F-14B Tomcat** (Heatblur) — 30 controls
- **F-16C Viper** (Eagle Dynamics) — 52 controls
- **F-5E Tiger II** (Eagle Dynamics) — 57 controls

---

## Why this exists

In DCS, every time you occupy a cockpit the aircraft spawns with all switches
in their factory-default positions. For taxi, runway hold, and in-flight slots
this makes sense. For cold-start scenarios it breaks immersion: a real aircraft
coming out of a previous sortie would have been left in whatever state the last
crew left it in. Landing lights on, STAB AUG engaged, IFF in an unexpected
mode — anything is possible.

CockpitRandomizer recreates that reality. Each cold start is different. You
cannot skip the interior check.

---

## Features

- **Cold-start only**: the script reads both engine RPM values via
  `LoGetEngineInfo()`. If either engine is at or above 10% RPM the script
  silently does nothing. Taxi, runway, and in-flight slots are unaffected.
- **Multi-aircraft**: a shared core engine detects the active aircraft and
  applies the correct switch table automatically. No configuration needed when
  switching between modules.
- **Modular file structure**: each aircraft lives in its own file. Adding a new
  module means adding one file without touching anything else.
- **Non-destructive**: chains into any existing `LuaExport*` functions.
  Compatible with DCS-BIOS, SRS, Tacview, and similar Export.lua-based tools.
- **Weighted probabilities**: safety-critical switches (Master Arm, Arm Fuze,
  Generators) are more likely to remain in safe/normal positions, but not
  guaranteed.
- All activity is logged to `DCS.log` under the `COCKPIT_RANDOMIZER` tag.

---

## Requirements

- DCS World (Steam or standalone)
- One or more supported aircraft modules
- No additional mods or tools required

---

## Installation

**Step 1 — Create the folder structure** (skip folders that already exist)

Navigate to your DCS Saved Games folder:

```
%USERPROFILE%\Saved Games\DCS\
```

Create the following structure:

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

**Step 2 — Copy the files**

From this repository, copy each file under `CockpitRandomizer\` to the
corresponding path under `Saved Games\DCS\Scripts\CockpitRandomizer\`, and
copy `Export.lua` to `Saved Games\DCS\Scripts\Export.lua`.

Only copy the aircraft files for modules you own.

**Step 3 — If Export.lua already exists**

If you already have an `Export.lua` (DCS-BIOS, SRS, etc.), do **not** replace
it. Instead, add the CockpitRandomizer block from the provided `Export.lua` to
the **top** of your existing file:

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

> **Do not touch** `SteamLibrary\steamapps\common\DCSWorld\Scripts\Export.lua`.
> That file is read-only reference material. Your changes belong exclusively in
> `Saved Games\DCS\Scripts\Export.lua`.

**Step 4 — Verify**

Launch DCS and fly any supported cold-start mission. After ~3 seconds in the
cockpit, switches will randomize. Check `Saved Games\DCS\Logs\dcs.log` and
search for `COCKPIT_RANDOMIZER` to confirm the script is running.

---

## Uninstallation

**Full removal:**

1. Delete the `Saved Games\DCS\Scripts\CockpitRandomizer\` folder.
2. Open `Saved Games\DCS\Scripts\Export.lua` and remove the CockpitRandomizer
   block.
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

| Setting            | Default | Description                                                                                        |
| ------------------ | ------- | -------------------------------------------------------------------------------------------------- |
| `CR.ENABLED`       | `true`  | Set to `false` to disable without uninstalling.                                                    |
| `CR.DELAY_SECONDS` | `3.0`   | Seconds to wait after cockpit load before randomizing. Increase if switches snap back to default.  |
| `CR.RPM_THRESHOLD` | `10.0`  | Both engines must be below this RPM % for cold-start detection.                                    |

---

## Randomized controls

### F-4E Phantom II (40 controls)

| System           | Controls                                                                               |
| ---------------- | -------------------------------------------------------------------------------------- |
| Countermeasures  | Select Dispense Program                                                                |
| Communications   | Set Mode (ICS), Comm Antenna, Select Radio Mode, Select Frequency Mode                 |
| IFF              | Select Master Mode                                                                     |
| Fuel             | Wing Fuel Dump, Internal Wing Tanks Feed                                               |
| AFCS             | STAB AUG Yaw/Roll/Pitch, AFCS Autopilot, ALT Hold                                      |
| Gear/Brakes      | Anti-Skid, Emergency Wheel Brake                                                       |
| Navigation       | Select Reference System, TACAN Mode, Nav Input, Nav Mode, Flight Director              |
| HUD              | Select HUD Mode                                                                        |
| Weapons          | Arm Fuze, Select Delivery Mode, Select Quantity                                        |
| Oxygen           | Select Oxygen Mixture, Emergency Release Cockpit Pressure                              |
| Circuit Breakers | ARI CB, SAI CB                                                                         |
| Exterior Lights  | Taxi/Landing Light, Formation Lights Mode, Formation Lights Brightness                 |
| Interior Lights  | Console Floodlight, Console Light Brightness, White Floodlight, Instrument Floodlight  |
| Environmental    | Toggle Rain Removal, Change Temperature¹, Defog Handle¹                                |
| Audio            | Stall Warning Volume, Aural Tone Volume                                                |

---

### F/A-18C Hornet (36 controls)

| System          | Controls                                                                                                            |
| --------------- | ------------------------------------------------------------------------------------------------------------------- |
| Oxygen          | OXY Flow Knob, OBOGS Control Switch                                                                                 |
| Intercom        | TACAN Volume Knob                                                                                                   |
| Exterior Lights | POSITION Dimmer, FORMATION Dimmer, LDG/TAXI LIGHT                                                                   |
| Cockpit Lights  | HOOK BYPASS Switch, CONSOLES Dimmer, INST PNL Dimmer, FLOOD Dimmer, MODE Switch, WARN/CAUTION Dimmer, CHART Dimmer  |
| Gear            | Anti Skid Switch                                                                                                    |
| HUD             | Altitude Switch, HUD Symbology Brightness Selector                                                                  |
| UFC             | COMM 1 Volume, COMM 2 Volume                                                                                        |
| MDI             | Left MDI Brightness Selector, Right MDI Brightness Selector                                                         |
| AMPCD           | AMPCD Off/Brightness Knob                                                                                           |
| Weapons         | Master Arm Switch                                                                                                   |
| Electrical      | Left Generator Switch, Right Generator Switch, CB LAUNCH BAR, CB SPD BRK, CB FCS CHAN 1, CB FCS CHAN 2              |
| Countermeasures | DISPENSER Switch                                                                                                    |
| ECM             | ECM Mode Switch                                                                                                     |
| TGP             | LTD/R Switch², LST/NFLR Switch                                                                                      |
| Radar           | RADAR Switch                                                                                                        |
| INS             | INS Switch                                                                                                          |
| Flight Controls | FLAP Switch                                                                                                         |
| ECS             | Defog Handle¹                                                                                                       |

---

### F-14B Tomcat (30 controls)

| System          | Controls                                                                                                        |
| --------------- | --------------------------------------------------------------------------------------------------------------- |
| Audio           | Sidewinder Volume, ALR-67 Volume                                                                                |
| Radio           | VHF/UHF ARC-182 Volume, UHF ARC-159 Volume, ARC-159 Freq Mode, ARC-159 Function                                |
| AFCS            | Stability Augmentation (Yaw/Roll/Pitch), Autopilot Engage, ALT Hold, Heading/Ground Track, Vector/ACL          |
| Engine          | Left Engine Mode, Right Engine Mode                                                                             |
| Gear/Brakes     | Anti-Skid Spoiler BK Switch                                                                                     |
| Fuel            | Wing/Ext Trans                                                                                                  |
| Weapons         | Master Arm Cover                                                                                                |
| HUD             | Take-off Mode, Cruise Mode, A/A Mode, A/G Mode, Landing Mode, AWL Mode                                         |
| Navigation      | Steer Commands (TACAN/Destination/AWL PCD/Vector/Manual)                                                        |
| Displays        | VDI Landing Mode, VDI Power, HUD Power, HSD Display Mode                                                        |
| TACAN           | Mode Selector                                                                                                   |
| Oxygen          | Pilot Oxygen On                                                                                                 |

---

### F-16C Viper (52 controls)

| System           | Controls                                                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Electrical       | PROBE HEAT Switch, FLCS POWER Switch                                                                                                  |
| Flight Controls  | MANUAL TF FLYUP Switch, DIGITAL BACKUP Switch, ALT FLAPS Switch, Autopilot Roll Switch, STORES CONFIG Switch                          |
| Fuel             | Fuel Master Switch Cover, Engine Feed Knob, FUEL QTY SEL Knob, AIR REFUELING Switch                                                  |
| Gear/Brakes      | ANTI-SKID Switch                                                                                                                      |
| Exterior Lights  | ANTI-COLL Knob, FORM Knob, MASTER Switch, WING/TAIL Switch, FUSELAGE Switch, FLASH STEADY Switch, LANDING TAXI LIGHTS Switch          |
| Interior Lights  | PRIMARY CONSOLES BRT Knob, PRIMARY INST PNL Knob, PRIMARY DATA ENTRY DISPLAY BRT Knob, FLOOD CONSOLES BRT Knob, FLOOD INST PNL Knob  |
| ECS              | AIR SOURCE Knob                                                                                                                       |
| INS              | INS Knob                                                                                                                              |
| IFF              | IFF Master Knob, C & I Knob                                                                                                           |
| Audio            | COMM 1 Power Knob, COMM 2 Power Knob                                                                                                  |
| RWR/CMDS         | RWR 555 Switch, Jammer Source Switch, MWS Source Switch, O1/O2/CH/FL Expendable Category Switches, MODE Knob, PROGRAM Knob            |
| HMCS             | SYMBOLOGY INT Knob                                                                                                                    |
| Sensors          | FCR Switch, RDR ALT Switch, LEFT HDPT Switch, RIGHT HDPT Switch                                                                       |
| Avionics Power   | MMC Switch, ST STA Switch, MFD Switch, UFC Switch, MAP Switch, GPS Switch, DL Switch, MIDS LVT Knob                                   |
| Weapons          | MASTER ARM Switch, LASER ARM Switch                                                                                                   |
| HUD              | DED/PFLD Data Switch, Flightpath Marker Switch, Scales Switch, Altitude Switch, Brightness Control Switch                              |

---

### F-5E Tiger II (57 controls)

| System          | Controls                                                                                                                             |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Flight Controls | Yaw Damper Switch, Pitch Damper Switch, Rudder Trim Knob, Flaps Lever, Auto Flap System Thumb Switch, Speed Brake Switch             |
| Electrical      | Battery Switch, Left Generator Switch, Right Generator Switch, Pitot Anti-Ice Switch                                                 |
| Fuel            | Left/Right Fuel Shutoff Switch Covers, Left/Right Fuel Shutoff Switches, Ext Fuel Cl Switch, Ext Fuel Pylons Switch, Left/Right Boost Pump Switches, Crossfeed Switch |
| Engine          | Engine Anti-Ice Switch                                                                                                               |
| Oxygen          | Supply Lever, Diluter Lever, Emergency Lever                                                                                         |
| ECS             | Cabin Press Switch Cover, Cabin Press Switch, Cabin Temp Switch, Cabin Temperature Knob, Canopy Defog Knob                           |
| Exterior Lights | Nav Knob, Formation Knob, Beacon Switch, Landing & Taxi Light Switch                                                                 |
| Interior Lights | Magnetic Compass Light Switch, Flood Lights Knob, Flight Instruments Lights Knob, Engine Instruments Lights Knob, Console Lights Knob, Armament Panel Lights Knob |
| Countermeasures | Chaff Mode Selector, Flare Mode Selector, Flare Jettison Switch Cover                                                               |
| Weapons         | Armament Position Selectors (×7), Interval Switch, Bombs Arm Switch, Guns/Missile/Camera Switch Cover, Guns/Missile/Camera Switch, External Stores Selector, Missile Volume Knob |
| AHRS            | Compass Switch, Nav Mode Selector Switch                                                                                             |
| Radar           | Range Selector, Mode Selector, Bright Knob, Persistence Knob, Video Knob                                                            |
| Sight           | Mode Selector, Reticle Intensity Knob, BIT Switch                                                                                   |
| RWR             | Altitude Button, Power Button, Audio Knob, DIM Knob, INT Knob                                                                       |
| IFF             | Master Control Selector, MODE 4 Monitor Switch, MODE 4 Control Switch, MODE 1 Code Wheels (×2), MODE 3/A Code Wheels (×4)            |
| UHF Radio       | Frequency Mode Selector, Function Selector, Squelch Switch, Volume Knob, Antenna Selector                                           |
| TACAN           | Mode Selector, Volume Knob                                                                                                           |
| Sight Camera    | FPS Select Switch, Overrun Selector                                                                                                  |

---

¹ Not yet simulated in DCS. Handle/knob moves visually but has no functional effect.  
² Spring-loaded ARM position excluded; only SAFE is randomizable.

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
2. Find the aircraft's `clickabledata.lua`, `command_defs.lua`, and
   `devices.lua` under `DCSWorld\Mods\aircraft\<module>\Cockpit\Scripts\`.
3. Use an existing aircraft file as a template.
4. Register the switch table with `CR.register("DCS_aircraft_name", { ... })`.
5. Add a `dofile` line for the new file in `Export.lua`.

The DCS aircraft name string is what `LoGetSelfData().Name` returns in-game.
Confirm it by checking the `Aircraft detected:` line in `dcs.log` on first run.

---

## License

Free to use, modify, and redistribute. Credit appreciated but not required.
