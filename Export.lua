-- [DSR:begin]
local cr_status, cr_err = pcall(function()
    local lfs = require('lfs')
    local base = lfs.writedir() .. "Scripts\\DSR\\"
    dofile(base .. "core.lua")
    dofile(base .. "fa18c.lua")
    dofile(base .. "f16c.lua")
    dofile(base .. "f5e.lua")
    dofile(base .. "f4e.lua")
    dofile(base .. "f14b.lua")
end)
if not cr_status then
    log.write("DCS_SWITCH_RANDOMIZER", log.ERROR, "Load failed: " .. tostring(cr_err))
end
-- [DSR:end]
