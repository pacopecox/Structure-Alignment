local M = {}

local languages = {
    en = {
        description = "Align structures and objects when building or placing them with a configurable grid. Includes valid and invalid position indicators, a terrain tile outline, and opacity settings.",
        labels = {
            menu_language = "Menu Language", alignment_grid = "Alignment Intervals",
            tile_outline = "Tile Outline", placer_opacity = "Placer Opacity", grid_opacity = "Grid Opacity",
        },
        options = {
            menu_language = { auto = "Auto", en = "English", zh = "简体中文" },
            alignment_grid = { [2] = "Half-Wall", [1] = "Wall", [.5] = "Half-Tile", [.25] = "Tile" },
            tile_outline = { [false] = "Disabled", [true] = "Enabled" },
        },
        controls = { toggle = "Toggle Alignment (mod)", cycle = "Cycle Alignment Grid" },
        choose_key = "-- Choose a new key --\n\nDefault: %s",
        key_conflict = "This key is assigned to %s.\nChoose another key, or press Escape.",
        keys = { left_shift = "Left Shift", right_shift = "Right Shift", ctrl = "Ctrl",
            alt = "Alt", space = "Space", tab = "Tab", unknown = "Key %s" },
    },
    zh = {
        description = "通过可配置的网格对齐\n建造或放置的建筑和物品。\n包含可用与不可用位置指示、\n地皮轮廓和不透明度设置。",
        labels = {
            menu_language = "菜单语言", alignment_grid = "对齐间距",
            tile_outline = "地皮轮廓", placer_opacity = "放置预览不透明度", grid_opacity = "网格不透明度",
        },
        options = {
            menu_language = { auto = "自动", en = "English", zh = "简体中文" },
            alignment_grid = { [2] = "半墙", [1] = "墙", [.5] = "半地皮", [.25] = "地皮" },
            tile_outline = { [false] = "禁用", [true] = "启用" },
        },
        controls = { toggle = "切换对齐（模组）", cycle = "切换对齐网格间距" },
        choose_key = "-- 请选择新按键 --\n\n默认：%s",
        key_conflict = "此按键已用于“%s”。\n请选择其他按键，或按 Esc 取消。",
        keys = { left_shift = "左 Shift", right_shift = "右 Shift", ctrl = "Ctrl",
            alt = "Alt", space = "空格", tab = "Tab", unknown = "按键 %s" },
    },
}

function M.Resolve(selection, code)
    if selection == "en" or selection == "zh" then return selection end
    if selection ~= nil and selection ~= "auto" then return "en" end
    code = string.lower(code or "en")
    return (code == "zhr" or code == "zh" or string.sub(code, 1, 3) == "zh-") and "zh" or "en"
end

function M.Configure(get)
    M.get = get
end

function M.Get(selection)
    if selection == nil and M.get then selection = M.get("menu_language") end
    local code = LOC and LOC.GetLocaleCode and LOC.GetLocaleCode() or "en"
    return languages[M.Resolve(selection, code)]
end

-- Measure at normal width before assigning the bounded text region.
function M.FitText(text, width, height)
    text:SetHorizontalSqueeze(1)
    text:SetRegionSize(0, 0)
    local natural_width = text:GetRegionSize()
    if natural_width > width then text:SetHorizontalSqueeze(width / natural_width) end
    text:SetRegionSize(width, height)
end

function M.LocalizeOptions(options, selection)
    local strings = M.Get(selection)
    for _, option in ipairs(options) do
        option.label = strings.labels[option.name] or option.label
        local choices = strings.options[option.name]
        if choices then
            for _, choice in ipairs(option.options) do
                choice.description = choices[choice.data] or choice.description
            end
        end
    end
end

function M.InstallConfigMenu(modname)
    local info = KnownModIndex:GetModInfo(modname)
    if info then
        info.description = M.Get().description
        M.LocalizeOptions(info.configuration_options, M.get and M.get("menu_language") or "auto")
    end
    local Screen = require("screens/modconfigurationscreen")
    local refresh = Screen.RefreshOptions
    local options
    -- The native screen keeps pending values in this private table.
    for n = 1, 30 do
        local name, value = debug.getupvalue(refresh, n)
        if not name then break end
        if name == "options" then options = n; break end
    end
    assert(options, "SA: native configuration option list not found")
    Screen.RefreshOptions = function(screen)
        if screen.modname ~= modname then return refresh(screen) end
        local _, rows = debug.getupvalue(refresh, options)
        local selection = "auto"
        for _, row in ipairs(rows) do
            if row.name == "menu_language" then selection = row.value or row.default; break end
        end
        M.LocalizeOptions(rows, selection)
        refresh(screen)
        for k in ipairs(screen.optionwidgets) do
            local row = rows[screen.option_offset + k]
            local column = k <= 7 and screen.left_spinners or screen.right_spinners
            local spinner = column[k <= 7 and k or k - 7]
            if spinner then
                M.FitText(spinner.text, 160, 50)
                for _, child in pairs(spinner.children) do
                    if child ~= spinner.text and child.name == "Text" then M.FitText(child, 180, 50) end
                end
                if row and row.name == "menu_language" then
                    local changed = spinner.OnChanged
                    spinner.OnChanged = function(self, ...)
                        changed(self, ...)
                        screen:RefreshOptions()
                    end
                end
            end
        end
    end
end

return M
