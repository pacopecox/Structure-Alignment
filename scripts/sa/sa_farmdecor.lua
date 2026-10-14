-- DS checks farm decoration entities as construction obstacles; DST ignores DECOR.
-- Keep the farm itself blocking and restrict the adaptation to its own decorations.
local FarmDecor = {}

function FarmDecor.Apply(inst)
    for _, decor in pairs(inst.decor or {}) do
        if decor:IsValid() then decor:AddTag("NOBLOCK") end
    end
end

function FarmDecor.Install(inst)
    if inst.sa_farmdecor_installed then return end
    inst.sa_farmdecor_installed = true
    FarmDecor.Apply(inst)
    local onload = inst.OnLoad
    inst.OnLoad = function(entity, ...)
        if onload then onload(entity, ...) end
        FarmDecor.Apply(entity)
    end
    -- DLC farms replace their decorations on burning. Wait for native listeners.
    inst:ListenForEvent("burntup", function(entity)
        entity:DoTaskInTime(0, function() FarmDecor.Apply(entity) end)
    end)
end

return FarmDecor
