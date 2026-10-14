-- Native spatial placement systems must keep their own position and visuals.
local exclusions = {}
local boats = {
    rowboat = true, raft = true, lograft = true, surfboard = true,
    cargoboat = true, armouredboat = true, encrustedboat = true, woodlegsboat = true,
}
local interiorfamilies = { "deco_", "chair_", "shelves_", "swinging_light_", "rug_", "window_" }
local deploytags = { "boat", "boatbuilder", "tile_deploy", "groundtile", "wallbuilder" }
local emptyrecipe = {}

local function basename(name)
    return (name or ""):match("([^/]+)$") or ""
end

local function isboat(name)
    return boats[basename(name):gsub("_placer$", "")] == true
end

function exclusions.Reason(p)
    if p.snap_to_tile or p.snap_to_meters or p.snap_to_flood or p.snaptogrid then
        return "native_grid"
    end
    if p.modifyfn then return "native_modify" end
    local item = p.invobject
    local deployable = item and item.components and item.components.deployable
    if deployable and deployable.quantizefn then return "native_quantize" end
    if item and item.HasTag then
        for _, tag in ipairs(deploytags) do
            if item:HasTag(tag) then return "native_deploy" end
        end
    end
    local name = basename(p.inst.prefab)
    local recipe = p.recipe or emptyrecipe
    if isboat(name) or isboat(recipe.name) or isboat(recipe.product) or isboat(recipe.placer) then
        return "boat"
    end
    if name == "tar_extractor_placer" then return "tar_source" end
    for _, prefix in ipairs(interiorfamilies) do
        if name:sub(1, #prefix) == prefix then return "interior_decoration" end
    end
    -- Hamlet rooms use a room-local origin and special bounds/rotation rules.
    -- This baseline has no interior adapter; do not apply the outdoor terrain grid.
    if TheCamera and TheCamera.interior then return "interior" end
    local world = GetWorld()
    local spawner = world and world.components and world.components.interiorspawner
    if spawner and spawner.IsInInterior and spawner:IsInInterior() then return "interior" end
    return nil
end

return exclusions
