# DCS Modding Reference — Control Mechanics & File Formats

This documents how DSR's switch/knob control system actually works, and the JSON/Lua format rules. These were established through testing and debugging across many sessions — treat them as settled unless new evidence overturns them, not something to re-derive from first principles each time.

## How performClickableAction actually behaves

- `performClickableAction(cmd, delta)` applies `delta` as a **relative offset** from the switch's cold-start argument value. It is not an absolute position setter.
- `val = 0` leaves the switch at its cold-start position; `val = 1` (or any other delta) moves it.
- Switches implemented in C++ with no Lua-side `SetCommand` handler silently ignore `performClickableAction` calls — no error, the call just does nothing. These must be marked `"enabled": false` rather than left active and silently failing.
- For multi-position switches with `step = X` in `clickabledata.lua`, the correct delta sequence is `0, X, 2X, ...` — **not** the delta multiplied by the position's index under some other numbering scheme.

## cmd numbering

`cmd` values come from counting `counter()` calls inside the relevant named command block, starting from `reset_counter()` (base value `3000`). Comment lines inside the block do **not** count toward the sequence — only actual `counter()` calls do. Miscounting here is a recurring source of wrong `cmd` values.

## JSON is the source of truth; Lua is generated

- JSON files are canonical. The matching `.lua` file is a generated derivative — never hand-edit a `.lua` file as the permanent fix; fix the JSON and regenerate.
- Every JSON control object requires `"enabled": true`, plus a trailing comma when pasted as a standalone snippet into a larger file.
- For discrete controls, all `"weight"` values across a control's `positions` must sum to exactly 100.
- Continuous controls use `vals = {0, 0.25, 0.5, 0.75, 1.0}` in the generated Lua.
- Discrete `vals` arrays in the generated Lua are **weight-expanded** — a position with weight 70 appears as 70 repeated delta values in the array, not as one weighted entry.
- `"skip_command": true` on a position makes `weights_to_vals()` substitute `None`, which `format_delta()` renders as Lua `false`. The `if pick ~= false then` guard in `DSR/core.lua` then skips the action for that draw entirely. This is the mechanism behind toggle covers and circuit breakers, where "do nothing" is itself the intended randomized outcome some fraction of the time.
- Circuit breakers follow a 99% IN / 1% OUT pattern: IN is `delta: false` with `skip_command: true`; OUT is `delta: true`.
- `select_one` type: used for radio-group buttons (selecting one position deactivates the others) — modeled as a single multi-position switch rather than several independent booleans.

## File organization convention

Within each aircraft's control file, discrete and continuous controls are kept in a **single unified alphabetical list** — not split into two lists by type. This has been reorganized a few times; alphabetical-and-unified is the current standard, and any new aircraft file should follow it from the start.

## Corrections that must be preserved

Found empirically — don't silently "correct" these back to what seems intuitive or what generic documentation suggests:

- **F/A-18C Generator Switch, NORM position**: delta must be `2`, not `1`. Confirmed through in-cockpit testing; DCS-BIOS documentation is misleading for this specific control.

## Hard boundaries

- Never add a `SPECIAL` tag to a control, and never disable a switch's parameters, without explicit permission.
- Do not make speculative edits to `aircraft_settings.py`. Unauthorized changes here have previously cost significant debugging time — if a change seems necessary, confirm the reasoning first rather than just applying it.
