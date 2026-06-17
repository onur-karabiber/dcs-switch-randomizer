# Project State

> Last updated: 2026-06-17 — this file is a snapshot, not a history. Update it when work starts/ends on something; don't let it drift from reality. The append-only record of what shipped lives in `CHANGELOG.md` — this file should not duplicate that.

## What this project is

DCS Switch Randomizer (DSR) is a PyQt5 desktop application that randomizes DCS World cockpit switch and knob positions at mission start, forcing a real interior check on cold start instead of spawning in factory-default positions. Distributed as a single-file Windows executable, built via PyInstaller and GitHub Actions.

Repo: `github.com/onur-karabiber/dcs-switch-randomizer` (previously `dcs-cockpit-randomizer` — GitHub redirects the old name, but treat the current name as canonical going forward).

## Current release

**v3.0.0.** The GUI application (`dcs-switch-randomizer-qt.py` + `aircraft_settings.py`) replaced manual file editing. Each aircraft is now defined by a canonical `<key>.json` file; the corresponding `.lua` is generated from it. Four aircraft were added this cycle (A-10C II, UH-1H, MiG-21bis, Spitfire LF Mk. IX), bringing the total to nine.

Key fixes shipped this cycle:
- `copy_lua_files()` now copies both `.lua` and `.json` to the install directory (previously JSON was omitted, causing "No metadata found" errors)
- 9 unused PNG files removed from `DSR/`
- GitHub Actions workflow updated to reference `DSR\` (was `CockpitRandomizer\`)

## Supported aircraft & test status

| Aircraft | Status |
|---|---|
| F/A-18C Hornet | Thoroughly tested |
| F-16C Viper | Thoroughly tested |
| F-5E Tiger II (Remastered) | Thoroughly tested |
| F-4E Phantom II | Thoroughly tested per README; control files also actively being expanded (see below) |
| F-14B Tomcat | Thoroughly tested overall; several individual switches still under investigation (see below) |
| A-10C II Tank Killer | Open for community testing — not yet thoroughly verified |
| UH-1H Huey | Open for community testing — not yet thoroughly verified |
| MiG-21bis | Open for community testing — not yet thoroughly verified |
| Spitfire LF Mk. IX | Open for community testing — not yet thoroughly verified |

## Active investigations

**F-14B Tomcat**
- HUD De-Clutter: confirmed uncontrollable via `performClickableAction` → should be `"enabled": false`.
- ANA/ARA-63 Power Switch: controllability still under investigation, not confirmed either way.
- Temperature knob: controllability still under investigation, not confirmed either way.
- VDI Display / Landing mode: label/cmd mismatch identified, not yet resolved.

**F-4E Phantom II**
- Control files in progress, following the alphabetical sort convention (see `skills/dcs_modding.md`).

## Architecture (quick reference — see `skills/dcs_modding.md` for the mechanics)

- `dcs-switch-randomizer-qt.py` — main PyQt5 window
- `aircraft_settings.py` — per-aircraft settings dialog
- Per-aircraft `<key>.json` (source of truth) + generated `<key>.lua`
- `DSR/core.lua` — runs `performClickableAction(cmd, delta)`, guarded by `if pick ~= false then`
- Install path: `Saved Games\DCS\Scripts\DSR\`
- Version check: plain string equality between the EXE-adjacent `version.txt` and the one in the DSR scripts folder — not semver-aware

## Rules that must not be re-derived from scratch

- F/A-18C Generator Switch NORM delta is `2`, not `1` — empirically confirmed; DCS-BIOS documentation is misleading for this specific control.
- Never add a `SPECIAL` tag or disable a switch's parameters without explicit permission.
- Do not make speculative edits to `aircraft_settings.py`.

Full detail and reasoning for all of these lives in `skills/dcs_modding.md` and `skills/lua_debugging.md` — this section is intentionally a duplicate of the highest-stakes items so they can't be missed by skimming this file alone.
