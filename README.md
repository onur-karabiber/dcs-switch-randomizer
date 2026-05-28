# CockpitRandomizer

A DCS World Export script that randomizes cockpit switch positions each time
you sit down for a **cold start**, forcing you to perform a proper interior
check before doing anything else.

Currently supports:
- **F-4E Phantom II** (Heatblur) — 40 controls
- **F/A-18C Hornet** (Eagle Dynamics) — 36 controls

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
        Export.lua
```

**Step 2 — Copy the files**

From this repository, copy:
- `CockpitRandomizer\core.lua`    → `Saved Games\DCS\Scripts\CockpitRandomizer\core.lua`
- `CockpitRandomizer\f4e.lua`     → `Saved Games\DCS\Scripts\CockpitRandomizer\f4e.lua`
- `CockpitRandomizer\fa18c.lua`   → `Saved Games\DCS\Scripts\CockpitRandomizer\fa18c.lua`
- `Export.lua`                    → `Saved Games\DCS\Scripts\Export.lua`

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
end)
if not cr_status then
    log.write("COCKPIT_RANDOMIZER", log.ERROR, "Load failed: " .. tostring(cr_err))
end
```

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
2. Open `Saved Games\DCS\Scripts\Export.lua` and remove the
   CockpitRandomizer block.
3. If `Export.lua` is now empty, delete it as well.

**Temporary disable** (without uninstalling):

Open `CockpitRandomizer\core.lua` and set:
```lua
CR.ENABLED = false
```

**Disable a single aircraft** (without removing its file):

Comment out its `dofile` line in `Export.lua`:
```lua
-- dofile(base .. "f4e.lua")
```

---

## Configuration

All user-facing settings are at the top of `CockpitRandomizer\core.lua`:

| Setting | Default | Description |
|---|---|---|
| `CR.ENABLED` | `true` | Set to `false` to disable without uninstalling |
| `CR.DELAY_SECONDS` | `3.0` | Seconds to wait after cockpit load before randomizing. Increase if switches snap back to default. |
| `CR.RPM_THRESHOLD` | `10.0` | Both engines must be below this RPM % for cold-start detection. |

---

## Randomized controls

### F-4E Phantom II  (40 controls)

| System | Controls |
|---|---|
| Countermeasures | Select Dispense Program |
| Communications | Set Mode (ICS), Comm Antenna, Select Radio Mode, Select Frequency Mode |
| IFF | Select Master Mode |
| Fuel | Wing Fuel Dump, Internal Wing Tanks Feed |
| AFCS | STAB AUG Yaw/Roll/Pitch, AFCS Autopilot, ALT Hold |
| Gear/Brakes | Anti-Skid, Emergency Wheel Brake |
| Navigation | Select Reference System, TACAN Mode, Nav Input, Nav Mode, Flight Director |
| HUD | Select HUD Mode |
| Weapons | Arm Fuze, Select Delivery Mode, Select Quantity |
| Oxygen | Select Oxygen Mixture, Emergency Release Cockpit Pressure |
| Circuit Breakers | ARI CB, SAI CB |
| Exterior Lights | Taxi/Landing Light, Formation Lights Mode, Formation Lights Brightness |
| Interior Lights | Console Floodlight, Console Light Brightness, White Floodlight, Instrument Floodlight |
| Environmental | Toggle Rain Removal, Change Temperature¹, Defog Handle¹ |
| Audio | Stall Warning Volume, Aural Tone Volume |

### F/A-18C Hornet  (36 controls)

| System | Controls |
|---|---|
| Oxygen | OXY Flow Knob, OBOGS Control Switch |
| Intercom | TACAN Volume Knob |
| Exterior Lights | POSITION Dimmer, FORMATION Dimmer, LDG/TAXI LIGHT |
| Cockpit Lights | HOOK BYPASS Switch, CONSOLES Dimmer, INST PNL Dimmer, FLOOD Dimmer, MODE Switch, WARN/CAUTION Dimmer, CHART Dimmer |
| Gear | Anti Skid Switch |
| HUD | Altitude Switch, HUD Symbology Brightness Selector |
| UFC | COMM 1 Volume, COMM 2 Volume |
| MDI | Left MDI Brightness Selector, Right MDI Brightness Selector |
| AMPCD | AMPCD Off/Brightness Knob |
| Weapons | Master Arm Switch |
| Electrical | Left Generator Switch, Right Generator Switch, CB LAUNCH BAR, CB SPD BRK, CB FCS CHAN 1, CB FCS CHAN 2 |
| Countermeasures | DISPENSER Switch |
| ECM | ECM Mode Switch |
| TGP | LTD/R Switch², LST/NFLR Switch |
| Radar | RADAR Switch |
| INS | INS Switch |
| Flight Controls | FLAP Switch |
| ECS | Defog Handle¹ |

¹ Not yet simulated in DCS. Handle/knob moves visually but has no functional effect.
² Spring-loaded ARM position excluded; only SAFE is randomizable.

---

## Debugging

Search `Saved Games\DCS\Logs\dcs.log` for `COCKPIT_RANDOMIZER`.

Typical output on a successful cold start:
```
[COCKPIT_RANDOMIZER] Aircraft detected: FA-18C_hornet — arming with 3.0s delay.
[COCKPIT_RANDOMIZER] RPM check: left=0.0%  right=0.0%  threshold=10.0%
[COCKPIT_RANDOMIZER] Randomizing cockpit on: FA-18C_hornet
[COCKPIT_RANDOMIZER]   Master Arm Switch   dev=18  cmd=3003 -> 0
[COCKPIT_RANDOMIZER]   RADAR Switch        dev=19  cmd=3001 -> 0.1
...
[COCKPIT_RANDOMIZER] Randomizer complete for: FA-18C_hornet
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
3. Use the existing `f4e.lua` or `fa18c.lua` as a template.
4. Register the switch table with `CR.register("DCS_aircraft_name", { ... })`.
5. Add a `dofile` line for the new file in `Export.lua`.

---

## License

Free to use, modify, and redistribute. Credit appreciated but not required.
