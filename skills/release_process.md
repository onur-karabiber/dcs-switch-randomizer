# Release Process

## Build

The distributable is a single-file Windows executable, built with PyInstaller via a GitHub Actions workflow. The `.spec` file is auto-generated at build time and is covered by `.gitignore` — it isn't meant to be hand-maintained or committed.

The workflow builds from the `DSR\` folder (updated from the old `CockpitRandomizer\` path as part of the v3.0.0 rename). If a workflow run is referencing the old path, that's a regression, not a valid alternate config.

## Version check mechanism

The app compares a `version.txt` next to the EXE against a `version.txt` inside the DSR scripts directory, using plain string equality — not semver parsing. Any release needs `version.txt` kept in sync with the actual tag; the comparison won't catch a "newer-but-differently-formatted" mismatch on its own.

## Re-tagging a release

If a tag needs to be deleted and recreated (e.g. to force a workflow re-run against the same version number), the established pattern is:

```bash
git push origin :refs/tags/v3.0.0
git tag -d v3.0.0
git tag v3.0.0
git push origin v3.0.0
```

(substitute the actual tag — this is the v3.0.0 instance of the pattern, kept as the template.)

## Git operations

Tag/push operations use a remote URL with an embedded token rather than interactive auth. When `str_replace`-style patching fails, writing a patch script to a temp location and applying it directly has worked as a fallback.

## Known regression to guard against

`copy_lua_files()` must copy both `.lua` **and** `.json` files to the install directory. An earlier version only copied `.lua`, which produced "No metadata found" errors at runtime because the JSON — the actual source the app reads settings from — was missing on the target machine. Fixed in v3.0.0. If this function is touched again, check that both extensions are still included.

---

*Not yet documented*: the full step-by-step order of a release (version bump → changelog entry → tag → build → verify EXE) beyond the individual mechanics above. Worth filling in the next time a release goes out end-to-end, rather than reconstructed from memory now.
