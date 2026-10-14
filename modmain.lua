PrefabFiles = { "sa_grid_outline" }
Assets = {
    Asset("ANIM", "anim/gridplacer.zip"),
}
for _, asset in ipairs(GLOBAL.require("sa/sa_assets")) do
    table.insert(Assets, asset)
end

local SA = GLOBAL.require("sa/sa_core")
SA.Configure(GetModConfigData)
GLOBAL.require("sa/sa_strings").InstallConfigMenu(modname)
-- The extension registry is shared with optional addons, not with save entities.
GLOBAL.StructureAlignment = SA
AddComponentPostInit("placer", SA.InstallPlacer)
AddComponentPostInit("builder", SA.InstallBuilder)
AddComponentPostInit("playercontroller", SA.InstallController)
GLOBAL.require("sa/sa_controlsmenu").Install(SA)
local farmdecor = GLOBAL.require("sa/sa_farmdecor")
AddPrefabPostInit("slow_farmplot", farmdecor.Install)
AddPrefabPostInit("fast_farmplot", farmdecor.Install)
