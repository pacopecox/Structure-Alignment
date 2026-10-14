local SA = { api_version = 1, adapters = {}, intervals = 1 }
local exclusions = require("sa/sa_exclusions")
local strings = require("sa/sa_strings")
local grids = { 2, 1, 0.5, 0.25 }
local animations = { [2] = "halfunit", [1] = "unit", [0.5] = "doubleunit", [0.25] = "tileunit" }
local defaults = { toggle = KEY_LSHIFT, cycle = KEY_V }

function SA.Configure(get)
    strings.Configure(get)
    local i = get("alignment_grid")
    SA.intervals = animations[i] and i or 1
    SA.outline = get("tile_outline") == true
    SA.placeropacity = get("placer_opacity") or 1
    SA.gridopacity = get("grid_opacity") or 1
end

function SA.GetBindings()
    local saved = Profile and Profile:GetValue("sa_keyboard") or {}
    return { toggle = tonumber(saved.toggle) or defaults.toggle, cycle = tonumber(saved.cycle) or defaults.cycle }
end

function SA.DefaultBindings()
    return { toggle = defaults.toggle, cycle = defaults.cycle }
end

function SA.SaveBindings(bindings)
    Profile:SetValue("sa_keyboard", { toggle = bindings.toggle, cycle = bindings.cycle })
    Profile:Save()
end

function SA.KeyName(key)
    local names = strings.Get().keys
    if key == KEY_LSHIFT then return names.left_shift end
    if key == KEY_RSHIFT then return names.right_shift end
    if key == KEY_CTRL then return names.ctrl end
    if key == KEY_ALT then return names.alt end
    if key == KEY_SPACE then return names.space end
    if key == KEY_TAB then return names.tab end
    if key >= 97 and key <= 122 then return string.upper(string.char(key)) end
    if key >= 48 and key <= 57 then return string.char(key) end
    if key >= 282 and key <= 293 then return "F" .. tostring(key - 281) end
    return string.format(names.unknown, tostring(key))
end

function SA.RegisterAdapter(prefab, adapter)
    assert(type(prefab) == "string" and type(adapter) == "table", "Invalid SA adapter")
    SA.adapters[prefab] = adapter
end

function SA.Eligible(p)
    if not p.builder or p.builder ~= GetPlayer() or TheInput:ControllerAttached() then return false end
    return exclusions.Reason(p) == nil
end

function SA.Active(p)
    return SA.Eligible(p) and not TheInput:IsKeyDown(SA.GetBindings().toggle)
end

function SA.Snap(pt)
    local map = GetWorld().Map
    local ox, _, oz = map:GetTileCenterPoint(0, 0, 0)
    ox, oz = ox + TILE_SCALE * 0.5, oz + TILE_SCALE * 0.5
    local i = SA.intervals
    return Vector3((math.floor((pt.x - ox) * i) + 0.5) / i + ox,
        0, (math.floor((pt.z - oz) * i) + 0.5) / i + oz)
end

local function clear(p)
    if p.sa_helpers then
        for _, v in ipairs(p.sa_helpers) do if v.ent:IsValid() then v.ent:Remove() end end
    end
    p.sa_helpers, p.sa_grid = nil, nil
    if p.sa_parent and p.sa_parent:IsValid() then p.sa_parent:Remove() end
    p.sa_parent = nil
    p.sa_center = nil
    p.sa_visibility, p.sa_index = nil, nil
    if p.sa_outline and p.sa_outline:IsValid() then p.sa_outline:Remove() end
    p.sa_outline = nil
end

local function create(p)
    clear(p)
    p.sa_helpers, p.sa_grid, p.sa_visibility, p.sa_index = {}, SA.intervals, 0, 1
    -- One world origin, with every decal positioned in local coordinates.
    p.sa_parent = SpawnPrefab("sa_grid_outline")
    p.sa_parent.AnimState:SetMultColour(0, 0, 0, 0)
    local i, radius = SA.intervals, math.min(8 / SA.intervals, 4)
    local r = math.floor(radius * i)
    for x = -r, r do
        for z = -r, r do
            if x*x + z*z <= r*r then
                local ent = SpawnPrefab("sa_grid_outline")
                ent.entity:SetParent(p.sa_parent.entity)
                ent.Transform:SetPosition(x/i, 0, z/i)
                ent:Hide()
                table.insert(p.sa_helpers, { ent = ent, dx = x/i, dz = z/i,
                    distance = math.sqrt(x*x+z*z)/i/radius })
            end
        end
    end
    table.sort(p.sa_helpers, function(a,b) return a.distance < b.distance end)
end

local function test(p, pt)
    local inst = p.inst
    local x, y, z = inst.Transform:GetWorldPosition()
    local rotation = inst.Transform:GetRotation()
    inst.Transform:SetPosition(pt:Get())
    local ok, valid = pcall(function()
        if p.placeTestFn and not p.placeTestFn(inst, pt) then return false end
        local deployable = p.invobject and p.invobject.components.deployable
        if deployable and not deployable:CanDeploy(pt, true) then return false end
        if p.testfn then
            return p.testfn(Vector3(inst.Transform:GetWorldPosition()))
        end
        return true
    end)
    inst.Transform:SetPosition(x, y, z)
    inst.Transform:SetRotation(rotation)
    if not ok then error(valid, 0) end
    return not not valid
end

local function helpers(p, dt, active, eligible)
    -- Exclusions apply to every SA overlay, including the optional tile border.
    -- Remove old helpers immediately when entering a native placement context.
    if not eligible then clear(p); return end
    if active and p.sa_grid ~= SA.intervals then create(p) end
    if p.sa_helpers then
        local position = p.inst:GetPosition()
        local moved = not p.sa_center or p.sa_center.x ~= position.x or p.sa_center.z ~= position.z
        local previous
        if moved and active and p.sa_center then
            previous = {}
            -- Preserve collision results at overlapping world grid points, as DST does.
            for _, v in ipairs(p.sa_helpers) do
                local x = math.floor((p.sa_center.x + v.dx) * p.sa_grid + 0.5)
                local z = math.floor((p.sa_center.z + v.dz) * p.sa_grid + 0.5)
                previous[x] = previous[x] or {}
                previous[x][z] = v.good
            end
        end
        if active then p.sa_center = position end
        p.sa_visibility = math.max(0, math.min(1, p.sa_visibility + dt / (active and 0.15 or -0.2)))
        local center = p.sa_center or position
        if moved and active then
            p.sa_parent.Transform:SetPosition(center:Get())
            for _, v in ipairs(p.sa_helpers) do
                local x = math.floor((center.x + v.dx) * p.sa_grid + 0.5)
                local z = math.floor((center.z + v.dz) * p.sa_grid + 0.5)
                v.good = previous and previous[x] and previous[x][z]
            end
        end
        if active then
            for _ = 1, math.min(15, #p.sa_helpers) do
                local v = p.sa_helpers[p.sa_index]
                v.good = test(p, Vector3(center.x+v.dx, 0, center.z+v.dz))
                p.sa_index = p.sa_index % #p.sa_helpers + 1
            end
        end
        for _, v in ipairs(p.sa_helpers) do
            if p.sa_visibility > 0 and v.distance <= p.sa_visibility then
                -- Newly visible points must be tested before they are drawn.
                -- The rolling budget is only for refreshing already known results.
                if active and v.good == nil then
                    v.good = not not test(p, Vector3(center.x+v.dx, 0, center.z+v.dz))
                end
                local good = v.good
                -- Decals are static: refresh visuals only when their state changes.
                local changed = not v.drawn or v.drawn_good ~= good
                if changed then
                    v.ent.AnimState:PlayAnimation(animations[p.sa_grid] .. (good and "" or "_x"))
                    v.ent.AnimState:SetAddColour(good == false and .75 or .25, good and .75 or .25, 0, 0)
                end
                if changed or v.drawn_opacity ~= SA.gridopacity then
                    v.ent.AnimState:SetMultColour(good == false and 1 or 0, good and 1 or 0, 0, SA.gridopacity)
                end
                v.drawn, v.drawn_good, v.drawn_opacity = true, good, SA.gridopacity
                if not v.shown then v.ent:Show(); v.shown = true end
            elseif v.shown then v.ent:Hide(); v.shown = false end
        end
    end
    if SA.outline then
        if not p.sa_outline then
            p.sa_outline = SpawnPrefab("sa_grid_outline")
            p.sa_outline.AnimState:PlayAnimation("anim")
            -- The tile border, unlike alignment decals, is lit in native DST.
            p.sa_outline.AnimState:SetLightOverride(1)
            p.sa_outline.AnimState:SetMultColour(1,1,1,1)
            p.sa_outline.AnimState:SetSortOrder(4)
        end
        p.sa_outline.Transform:SetPosition(GetWorld().Map:GetTileCenterPoint(p.inst.Transform:GetWorldPosition()))
    end
end

local function updateAligned(p)
    local pt = SA.Snap(p.selected_pos or Input:GetWorldPosition())
    p.inst.Transform:SetPosition(pt:Get())
    p.can_build = test(p, pt)
    if p.placeTestFn then p.targetPos = p.inst:GetPosition() end
end

local function previewColour(p)
    local r, g = p.can_build and .25 or .75, p.can_build and .75 or .25
    -- DS previews require the native additive alpha. DST's zero produced
    -- black campfire previews in the in-game regression test.
    p.inst.AnimState:SetAddColour(r, g, .25, 1)
    p.inst.AnimState:SetMultColour(1, 1, 1, SA.placeropacity)
    for _, ent in ipairs(p.linked or {}) do
        ent.AnimState:SetAddColour(r, g, .25, 1)
        ent.AnimState:SetMultColour(1, 1, 1, SA.placeropacity)
    end
end

function SA.InstallPlacer(p)
    local update = p.OnUpdate
    p.inst:ListenForEvent("onremove", function() clear(p) end)
    p.OnUpdate = function(self, dt)
        local active = SA.Active(self)
        self.sa_active = active
        -- Keep DS's native placement, validation, and preview behavior intact.
        update(self, dt)
        if active then
            updateAligned(self)
        end
        local eligible = SA.Eligible(self)
        if eligible then previewColour(self) end
        helpers(self, dt, active, eligible)
    end
end

function SA.InstallBuilder(b)
    local make = b.MakeRecipe
    b.MakeRecipe = function(self, recipe, pt, ...)
        local pc = self.inst.components.playercontroller
        local p = pc and pc.placer and pc.placer.components.placer
        if p and p.sa_active and p.recipe == recipe then pt = p.inst:GetPosition() end
        return make(self, recipe, pt, ...)
    end
end

function SA.InstallController(pc)
    local action = pc.GetRightMouseAction
    pc.GetRightMouseAction = function(self, ...)
        local p = self.deployplacer and self.deployplacer.components.placer
        if p and p.sa_active and p.invobject then
            -- DS already provides a deploy action based on the preview transform.
            -- Looking up a mouse action must not pin the preview (Hamlet does
            -- that inside GetDeployAction for controller actions).
            if not p.can_build then return nil end
            local selected = p.selected_pos
            local ok, result = pcall(p.GetDeployAction, p)
            p.selected_pos = selected
            if not ok then error(result) end
            return result
        end
        local result = action(self, ...)
        if result and p and p.sa_active and result.action == ACTIONS.DEPLOY then result.pos = p.inst:GetPosition() end
        return result
    end
    local handler = TheInput:AddKeyHandler(function(key, down)
        if not down or key ~= SA.GetBindings().cycle or GetPlayer() ~= pc.inst then return end
        local screen = TheFrontEnd:GetActiveScreen()
        if not screen or screen.name ~= "HUD" or not pc:IsEnabled() then return end
        local p = (pc.placer or pc.deployplacer)
        p = p and p.components.placer
        if p and SA.Active(p) then
            for n, i in ipairs(grids) do
                if i == SA.intervals then SA.intervals = grids[n % #grids + 1]; break end
            end
        end
    end)
    pc.inst:ListenForEvent("onremove", function() handler:Remove() end)
end

return SA
