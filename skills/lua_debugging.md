# Debugging Workflow for DCS Controls

The sequence to follow when adding or fixing a control for any aircraft. Skipping steps — especially the last one — is the most common source of wrong values ending up in JSON.

## 1. Find the element

Look it up in `clickabledata.lua` to get its base definition (device id, cockpit device, argument).

## 2. Find its command block

Locate the relevant block in `command_defs.lua`. Determine the correct `cmd` by counting `counter()` calls from `reset_counter()` (base `3000`) within that block — comments don't count. (Full rule in `dcs_modding.md`.)

## 3. Cross-reference switch type and limits

Check `clickable_defs.lua` for the switch's type and argument limits, to know what range of `delta`/`val` values is even physically valid for it.

## 4. Test before committing to JSON

Hardcode the candidate `vals` entries directly into the aircraft's `.lua` file (e.g. `f14b.lua`) and test in-cockpit. Do **not** write the value into JSON until it's confirmed working this way — JSON is the source of truth, so a wrong value there is a wrong value that persists and regenerates every time.

## 5. Confirm, then incorporate

Testing happens in-cockpit, with results reported back. Only confirmed values get written into JSON. If a value hasn't been tested, say so explicitly rather than presenting a best guess as confirmed — a flagged guess is useful; an unflagged wrong "fact" costs more time later to undo than it would have taken to just say "untested."

## Reference files (uploaded per session, not part of this repo)

These come from the aircraft module's own `Cockpit/Scripts/` folder:

- `clickabledata.lua` — element/device definitions
- `command_defs.lua` — command blocks, `cmd` numbering
- `devices.lua` — device list
- `clickable_defs.lua` — switch types, argument limits
- `device_init.lua` — initial / cold-start argument values
- `Macro_sequencies.lua` — multi-step macro sequences, where relevant

## File handling discipline

- Work only from the file explicitly provided in the current message — uploaded, or fetched live from the repo — never from a cached or previously-seen version of the same file.
- Verify any change with a diff before treating it as applied.
- Edits should be targeted to the specific lines/function in question. Don't rewrite a file from scratch unless that was specifically asked for.
