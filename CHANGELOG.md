# Changelog

All notable changes to DCS Switch Randomizer (DSR) are documented here.

---

## [v0.2.0] — 2026-05-31

### Added

**core.lua — `run()` dispatch path**
Switch table entries now support a `run` field containing a custom function. When present, the engine calls `run(device)` instead of the standard `performClickableAction(cmd, val)` path. This allows a single entry to issue multiple device calls, implement conditional logic, or handle trigger-based controls that are incompatible with the delta model. Log output for `run`-type entries reports `cmd=multi` and `val=<custom>`.

**F-4E Phantom II — additional circuit breakers**
Seven circuit breakers added: Landing Gear CB, Speed Brake CB, STAB Feel-Trim CB, AIL Feel-Trim CB, Rudder Trim CB, Trim Controls CB, Flaps CB. Each has a ~10% chance of being found pulled.

**F-4E Phantom II — DCU arm station selectors**
Five weapon station arm selectors added (Left Outer, Left Inner, Center, Right Inner, Right Outer), each with a ~10% chance of being found ARMED.

**F/A-18C Hornet — right-console circuit breakers**
CB FCS CHAN 3, CB FCS CHAN 4, CB HOOK, and CB LG added. These controls sit on the right console sub-panel and require `_EXT` command IDs because Export Lua cannot reach them via the main panel object. Each is implemented via `run()` and fires at ~5% probability.

**F/A-18C Hornet — additional systems**
External Power Switch, Selective Jettison Knob, Throttles Friction Adjusting Lever, ILS Channel Selector Switch, ILS UFC/MAN Switch, IFF Master Switch, IFF Mode 4 Switch, Hydraulic Isolate Override Switch, External Wing Tanks Fuel Control Switch, External Centerline Tank Fuel Control Switch, Suit Temperature Knob, Cabin Temperature Knob, and Shoulder Harness Control Handle added. Volume knobs expanded to include RWR, MIDS A, MIDS B, ICS, VOX, and AUX.

**F-16C Viper — new controls**
TRIM/AP DISC Switch, GND JETT ENABLE Switch, External Fuel Transfer Switch, and EPU System added. The EPU entry uses `run()` to model six distinct cover/switch state combinations with correct mechanical interlock behavior.

---

### Changed

**core.lua — randomization loop**
The loop now checks for `sw.run` before selecting from `sw.vals`. When `sw.run` is present, custom logic executes directly and `sw.vals`/`sw.cmd` are ignored for that entry. Log format adapts accordingly.

**F-16C Viper — command IDs corrected across most entries**
Command IDs for the majority of F-16C switches were incorrect in v0.1.0 due to a misread of `command_defs.lua`. Affected switches include PROBE HEAT, MANUAL TF FLYUP, DIGITAL BACKUP, ALT FLAPS, ENGINE FEED, FUEL QTY SEL, AIR REFUEL, ANTI-SKID, and several MMC/SMS entries. All corrected to match the actual device tables.

**F-16C Viper — STORES CONFIG Switch cold-start logic corrected**
v0.1.0 incorrectly assumed cold-start default is CAT I. Actual cold-start position is CAT III. Dominant outcome is now CAT I (+1 delta, 60%).

**F-16C Viper — ANTI-SKID Switch cold-start logic corrected**
v0.1.0 treated the switch as cold-starting at ANTI-SKID. Actual cold-start position is PARKING BRAKE. Dominant outcome is now ANTI-SKID (+1 delta, 90%).

**F-16C Viper — RDR ALT Switch dominant state changed**
Dominant outcome is now OFF (−1 delta, 90%) rather than stay-at-STBY.

**F-16C Viper — FCR Switch probability revised**
Probability of FCR being found OFF increased from 15% to 30%.

**F-16C Viper — AIR SOURCE Knob distribution revised**
OFF weighted at 60% (up from ~5%), NORM at 30%, reflecting that ECS is typically shut down between sorties.

**F-16C Viper — LASER ARM Switch probability revised**
Split changed to 70% OFF / 30% ARM, reflecting the possibility of the laser having been left armed after a previous sortie.

**F-14B Tomcat — AFCS Stability Augmentation probability revised**
Dominant outcome changed to ON (67%), reflecting that SAS is normally left engaged between sorties.

**F-14B Tomcat — Autopilot submode switches corrected**
Altitude Hold, Heading/Ground Track, and Vector/ACL entries were debug-mode stubs in v0.1.0 (always nonzero). Replaced with proper weighted delta entries.

**F-5E Tiger II — Left/Right Fuel Shutoff Switches commented out**
Both switches are defined but inactive. Covers remain randomized.

**F-5E Tiger II — Pitot Anti-Ice and Left Boost Pump probability tightened**
Default stay probability increased from 90% to 95% for both.

**F-5E Tiger II — External Stores Selector distribution revised**
SAFE (stay) probability reduced from 88% to 60%; BOMB, RKT DISP, and RIPL each take ~10%, reflecting that this selector is mission-dependent.

---

### Fixed

**F-14B Tomcat — TACAN Mode Selector removed**
`multiposition_switch_limited` controls on dev=47 do not respond to `performClickableAction` via Export Lua and were silently ignored by DCS. Entry removed.

**F-14B Tomcat — UHF ARC-159 Freq Mode and Function selectors removed**
Both `multiposition_switch_limited` selectors produced no physical movement when called via Export Lua, confirmed across multiple command ID variants including `dev=0`. Both entries removed.

**F-14B Tomcat — Temperature knob removed**
Device/command mapping for the cockpit temperature knob (dev=12, cmd=3651) could not be confirmed to produce visible movement. Entry removed pending verification.

**F/A-18C Hornet — TACAN Volume Knob command corrected**
v0.1.0 used cmd=3032 (`TCN_Volume_AXIS`). Correct command for Export Lua is cmd=3008 (`TCN_Volume`).

**F/A-18C Hornet — LST/NFLR Switch removed**
TGP_INTERFACE (dev=62) is a C++ DLL device and is not accessible from Export Lua via `performClickableAction`. Entry removed.

**F-16C Viper — LANDING TAXI LIGHTS Switch command corrected**
v0.1.0 used cmd=3006, which overlaps with the MASTER Switch. Correct command is cmd=3008.

**F-16C Viper — CMDS switch ordering corrected**
RWR Source and Jammer Source command IDs were swapped in v0.1.0. Corrected to match `command_defs.lua`: RWR Source=3001, Jammer Source=3002, MWS Source=3003.

**F-16C Viper — Expendable Category Switch labels corrected**
Labels read "Expandable" in v0.1.0. Corrected to "Expendable" throughout.

---

### Known Limitations

**F-16C — FUEL MASTER Switch**
The switch state is controlled by the simulation engine and overrides any Export Lua command. Only the cover is randomized.

**F-14B — TACAN Mode Selector / UHF ARC-159 Freq Mode / UHF ARC-159 Function**
These `multiposition_switch_limited` controls do not respond to `performClickableAction` via Export Lua regardless of command ID. Confirmed through in-sim testing. Not randomized.

**F-14B — Temperature knob**
Device/command mapping unconfirmed. Not randomized pending verification.

**F/A-18C — LST/NFLR Switch and FLIR Switch**
TGP_INTERFACE is a C++ DLL device. Export Lua cannot reach it via `performClickableAction`. Neither switch is randomizable through this mechanism.

**F/A-18C — Right-console CBs (standard command IDs)**
CB FCS CHAN 3/4, CB HOOK, and CB LG cannot be reached using standard command IDs because Export Lua only dispatches to clickables on `ccF18MainPanel`. Accessible only via `_EXT` trigger-based variants, which this release uses. `_EXT` commands fire unconditionally — the delta model does not apply.

---

## [v0.1.0] — initial release

- F-4E Phantom II support
- F/A-18C Hornet support
- F-14B Tomcat support
- F-16C Viper support
- F-5E Tiger II support
- Cold-start RPM guard
- Weighted randomization engine
- Export.lua hook chaining (DCS-BIOS, SRS, Tacview compatible)
- Per-aircraft configurable delay
- Full activity logging under `DCS_SWITCH_RANDOMIZER` tag
