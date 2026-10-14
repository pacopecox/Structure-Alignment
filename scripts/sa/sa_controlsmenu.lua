local M = {}
local strings = require("sa/sa_strings")

function M.Install(SA)
    local Screen = require("screens/controlsscreen")
    local Widget = require("widgets/widget")
    local Image = require("widgets/image")
    local Text = require("widgets/text")
    local Button = require("widgets/imagebutton")
    local Popup = require("screens/popupdialog")
    local refresh, scroll = Screen.RefreshControls, Screen.Scroll
    local native
    -- Read the native list so DLC-specific actions and other list extensions survive.
    for n = 1, 30 do
        local name, value = debug.getupvalue(refresh, n)
        if not name then break end
        if name == "kbcontrols" then native = value; break end
    end
    assert(native, "SA: native keyboard control list not found")
    local rows = {}
    for _, id in ipairs(native) do
        if id == CONTROL_OPEN_CRAFTING then
            table.insert(rows, "toggle")
            table.insert(rows, "cycle")
        end
        table.insert(rows, id)
    end

    local function pending(s)
        if not s.sa_pending then s.sa_pending = SA.GetBindings() end
        return s.sa_pending
    end

    local function capture(s, id)
        local texts = strings.Get()
        local titles = texts.controls
        local popup, handler
        local function close()
            if handler then handler:Remove(); handler = nil end
            if TheFrontEnd:GetActiveScreen() == popup then TheFrontEnd:PopScreen() end
        end
        popup = Popup(titles[id], string.format(texts.choose_key, SA.KeyName(SA.DefaultBindings()[id])), {})
        -- Match the native DS remapping dialog's body layout and font.
        popup.text:SetFont(UIFONT)
        popup.text:SetRegionSize(480, 150)
        popup.text:SetPosition(0, -25, 0)
        -- Consume mapped controls while raw keyboard input is being captured.
        popup.OnControl = function() return true end
        local destroy = popup.OnDestroy
        popup.OnDestroy = function(self, ...)
            if handler then handler:Remove(); handler = nil end
            return destroy(self, ...)
        end
        TheFrontEnd:PushScreen(popup)
        handler = TheInput:AddKeyHandler(function(key, down)
            if not down or TheFrontEnd:GetActiveScreen() ~= popup then return end
            if key ~= KEY_ESCAPE then
                local bindings = pending(s)
                local other = id == "toggle" and "cycle" or "toggle"
                if key == bindings[other] then
                    popup.text:SetString(string.format(texts.key_conflict, titles[other]))
                    return
                end
                bindings[id] = key
                s:MakeDirty()
            end
            close()
            s:RefreshControls()
        end)
    end

    Screen.RefreshControls = function(s)
        if s.devicespinner:GetSelectedData() ~= 0 then return refresh(s) end
        local bindings = pending(s)
        local titles = strings.Get().controls
        local focus = s:GetDeepestFocus()
        local oldidx = focus and focus.idx
        s.enablespinner:Hide()
        for _, v in pairs(s.controlwidgets) do v.root:Kill() end
        s.controlwidgets = {}
        local previous
        for k = 1, 10 do
            local id = rows[s.control_offset + k]
            if id then
                local custom = type(id) == "string"
                local group = s.controlspanel:AddChild(Widget("control"))
                group:SetScale(.75,.75,.75)
                local bg = group:AddChild(Image("images/ui.xml", "nondefault_customization.tex"))
                bg:SetPosition(180,0,0)
                bg:SetScale(2.5,.95,1)
                local changed
                if custom then changed = bindings[id] ~= SA.DefaultBindings()[id]
                else changed = TheInputProxy:HasMappingChanged(0,id) end
                if not changed then bg:Hide() end
                local button = group:AddChild(Button("images/ui.xml", "button_long.tex", "button_long_over.tex", "button_long_disabled.tex"))
                button:SetText(custom and titles[id] or STRINGS.UI.CONTROLSSCREEN.CONTROLS[id+1])
                button.text:SetColour(0,0,0,1)
                button:SetFont(BUTTONFONT)
                button:SetTextSize(30)
                if custom then strings.FitText(button.text, 300, 50) end
                button:SetPosition(-25,0,0)
                button.idx = k
                button:SetOnClick(function()
                    if custom then capture(s,id) else s:MapControl(0,id) end
                end)
                if previous then
                    button:SetFocusChangeDir(MOVE_UP,previous)
                    previous:SetFocusChangeDir(MOVE_DOWN,button)
                end
                previous = button
                local text = group:AddChild(Text(UIFONT,40))
                text:SetString(custom and SA.KeyName(bindings[id]) or TheInput:GetLocalizedControl(0,id))
                text:SetHAlign(ANCHOR_LEFT)
                text:SetRegionSize(500,50)
                text:SetPosition(325,0,0)
                text:SetClickable(false)
                group.text = text
                group:SetPosition(-150,225-(k-1)*50,0)
                table.insert(s.controlwidgets,{root=group,bg=bg,id=id,button=button})
            end
        end
        s:RefreshNav()
        if oldidx and #s.controlwidgets > 0 then s.controlwidgets[math.min(oldidx,#s.controlwidgets)].button:SetFocus() end
    end

    Screen.Scroll = function(s, dir)
        if s.devicespinner:GetSelectedData() ~= 0 then return scroll(s,dir) end
        if (dir > 0 and s.control_offset + 10 < #rows) or (dir < 0 and s.control_offset + dir >= 0) then
            s.control_offset = s.control_offset + dir
        end
        if s.control_offset > 0 then s.leftbutton:Show() else s.leftbutton:Hide() end
        if s.control_offset + 10 < #rows then s.rightbutton:Show() else s.rightbutton:Hide() end
        s:RefreshControls()
    end

    local apply, current, reset = Screen.Apply, Screen.LoadCurrentControls, Screen.LoadDefaultControls
    Screen.Apply = function(s)
        SA.SaveBindings(pending(s))
        return apply(s)
    end
    Screen.LoadCurrentControls = function(s)
        s.sa_pending = SA.GetBindings()
        return current(s)
    end
    Screen.LoadDefaultControls = function(s)
        s.sa_pending = SA.DefaultBindings()
        return reset(s)
    end
end

return M
