name = "Structure Alignment"
author = "pacopecox"
version = "1.0-stable"
forumthread = ""
api_version = 6

icon_atlas = "sa_modicon.xml"
icon = "sa_modicon.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
dst_compatible = false

-- DS supplies locale when loading modinfo, before runtime configuration is read.
-- This restricted environment cannot import sa_strings.lua. These initial
-- labels also work before the mod is enabled; runtime menus use sa_strings.
local chinese = locale == "zh" or locale == "zhr"
local function MenuText(english, simplified_chinese)
    return chinese and simplified_chinese or english
end

description = MenuText(
    "Align structures and objects when building or placing them with a configurable grid. Includes valid and invalid position indicators, a terrain tile outline, and opacity settings.",
    "通过可配置的网格对齐\n建造或放置的建筑和物品。\n包含可用与不可用位置指示、\n地皮轮廓和不透明度设置。"
)

local enabled_disabled = {
    { description = MenuText("Disabled", "禁用"), data = false },
    { description = MenuText("Enabled", "启用"), data = true },
}

local opacity_options = {
    { description = "25%", data = 0.25 },
    { description = "50%", data = 0.50 },
    { description = "75%", data = 0.75 },
    { description = "100%", data = 1 },
}

configuration_options = {
    {
        name = "menu_language",
        label = MenuText("Menu Language", "菜单语言"),
        options = {
            { description = MenuText("Auto", "自动"), data = "auto" },
            { description = "English", data = "en" },
            { description = "简体中文", data = "zh" },
        },
        default = "auto",
    },
    {
        name = "alignment_grid",
        label = MenuText("Alignment Intervals", "对齐间距"),
        options = {
            { description = MenuText("Half-Wall", "半墙"), data = 2 },
            { description = MenuText("Wall", "墙"), data = 1 },
            { description = MenuText("Half-Tile", "半地皮"), data = 0.5 },
            { description = MenuText("Tile", "地皮"), data = 0.25 },
        },
        default = 1,
    },
    {
        name = "tile_outline",
        label = MenuText("Tile Outline", "地皮轮廓"),
        options = enabled_disabled,
        default = false,
    },
    {
        name = "placer_opacity",
        label = MenuText("Placer Opacity", "放置预览不透明度"),
        options = opacity_options,
        default = 1,
    },
    {
        name = "grid_opacity",
        label = MenuText("Grid Opacity", "网格不透明度"),
        options = opacity_options,
        default = 1,
    },
}
