local assets = { Asset("ANIM", "anim/gridplacer.zip") }
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")
    inst.AnimState:SetBank("gridplacer")
    inst.AnimState:SetBuild("gridplacer")
    inst.AnimState:PlayAnimation("tileunit")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(7)
    return inst
end
return Prefab("sa_grid_outline", fn, assets)
