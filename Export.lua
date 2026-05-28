-- Saved Games\DCS\Scripts\Export.lua
--
-- This file is the user-level Export hook loader for DCS World.
-- Do NOT edit the original Export.lua located in:
--   SteamLibrary\steamapps\common\DCSWorld\Scripts\Export.lua
-- That file is read-only reference material provided by Eagle Dynamics.
--
-- To add more Export-based tools (DCS-BIOS, SRS, Tacview, etc.),
-- append their loader blocks below the CockpitRandomizer section.

-- ------------------------------------------------------------
-- CockpitRandomizer
-- ------------------------------------------------------------
local cr_status, cr_err = pcall(function()
    local lfs = require('lfs')
    local cr_path = lfs.writedir() .. "Scripts\\CockpitRandomizer_Export.lua"
    dofile(cr_path)
end)
if not cr_status then
    log.write("COCKPIT_RANDOMIZER", log.ERROR, "Load failed: " .. tostring(cr_err))
end

-- ------------------------------------------------------------
-- Add other Export scripts below this line
-- ------------------------------------------------------------
