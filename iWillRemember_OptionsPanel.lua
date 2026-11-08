-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                      Options Panel (Custom Standalone Frame)                  │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local L = iWR.L
local print = function(...) iWR:PrintToChat(...) end

local iconPath = iWR.AddonPath .. "Images\\Logo_iWR.blp"

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper Functions                                 │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local SETTINGS_BACKDROP = {
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeSize = 1,
}

local function StyleSettingsSurface(frame, header)
    frame:SetBackdrop(SETTINGS_BACKDROP)
    if header then frame:SetBackdropColor(0.075, 0.058, 0.035, 0.98)
    else frame:SetBackdropColor(0.025, 0.023, 0.020, 0.98) end
    frame:SetBackdropBorderColor(0.32, 0.25, 0.14, 1)
end

local function StyleSettingsButton(button, destructive)
    button.iWRSettingsControl = true
    iWR:StyleButton(button, destructive)
    button.iWRButtonBackdrop:SetBackdrop(SETTINGS_BACKDROP)
    -- Replacing the backdrop resets its tint, so restore this button's colors.
    iWR:SetButtonActive(button, button.iWRActive)
end

local function CreateAppearanceReset(parent, hint, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(44, 24)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.text:SetPoint("CENTER")
    button.text:SetText(L["ResetIcon"])
    button.text:SetTextColor(0.66, 0.61, 0.51)
    button:SetScript("OnClick", onClick)
    button:SetScript("OnEnter", function(self)
        self.text:SetTextColor(1, 0.73, 0.25)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(hint, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        self.text:SetTextColor(0.66, 0.61, 0.51)
        if GameTooltip then GameTooltip:Hide() end
    end)
    button:SetScript("OnDisable", function(self) self:SetAlpha(0.3) end)
    button:SetScript("OnEnable", function(self) self:SetAlpha(1) end)
    return button
end

local function StyleSettingsCheckbox(cb)
    cb:SetSize(24, 24)
    cb:SetNormalTexture("Interface\\BUTTONS\\WHITE8X8")
    cb:GetNormalTexture():SetVertexColor(0, 0, 0, 0)
    cb:GetNormalTexture():SetAllPoints(cb)
    cb:SetPushedTexture("Interface\\BUTTONS\\WHITE8X8")
    cb:GetPushedTexture():SetVertexColor(0.18, 0.13, 0.06, 1)
    cb:SetHighlightTexture("Interface\\BUTTONS\\WHITE8X8", "ADD")
    cb:GetHighlightTexture():SetVertexColor(0.5, 0.32, 0.09, 0.25)
    local background = CreateFrame("Frame", nil, cb, "BackdropTemplate")
    background:SetAllPoints(cb)
    background:SetFrameLevel(math.max(0, cb:GetFrameLevel() - 1))
    background:SetBackdrop(SETTINGS_BACKDROP)
    background:SetBackdropColor(0.035, 0.030, 0.022, 1)
    background:SetBackdropBorderColor(0.42, 0.32, 0.15, 1)
    cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    cb:GetCheckedTexture():SetVertexColor(1, 0.76, 0.30, 1)
    cb:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    cb.Text:ClearAllPoints()
    cb.Text:SetPoint("LEFT", cb, "RIGHT", 8, 0)
end

local function StyleSettingsScroll(scrollFrame)
    local bar = scrollFrame.ScrollBar
    if not bar then return end
    for _, texture in ipairs({bar:GetRegions()}) do
        if texture.IsObjectType and texture:IsObjectType("Texture") then texture:SetAlpha(0) end
    end
    if bar.ScrollUpButton then bar.ScrollUpButton:Hide() end
    if bar.ScrollDownButton then bar.ScrollDownButton:Hide() end
    bar:ClearAllPoints()
    bar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 6, -3)
    bar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 6, 3)
    bar:SetWidth(8)
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(bar)
    track:SetColorTexture(0.11, 0.09, 0.06, 0.7)
    bar:SetThumbTexture("Interface\\BUTTONS\\WHITE8X8")
    bar:GetThumbTexture():SetSize(8, 28)
    bar:GetThumbTexture():SetVertexColor(0.72, 0.48, 0.17, 1)
    bar:GetThumbTexture():SetAlpha(1)
end

local function CreateSectionHeader(parent, text, yOffset)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    header:SetBackdrop({ bgFile = "Interface\\BUTTONS\\WHITE8X8" })
    header:SetBackdropColor(0.11, 0.08, 0.035, 0.6)

    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(1)
    accent:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    accent:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    accent:SetColorTexture(1, 0.59, 0.09, 0.4)

    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", header, "LEFT", 8, 0)
    label:SetText(text)

    return header, yOffset - 34
end

local function CreateSettingsCheckbox(parent, label, descText, yOffset, settingKey, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    StyleSettingsCheckbox(cb)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    cb.Text:SetText(label)
    cb.Text:SetFontObject(GameFontHighlight)

    if getFunc then
        cb:SetChecked(getFunc())
    else
        cb:SetChecked(iWRSettings[settingKey])
    end

    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        if setFunc then
            setFunc(checked)
        else
            iWRSettings[settingKey] = checked
        end
    end)

    local nextY = yOffset - 26
    if descText and descText ~= "" then
        local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 52, nextY)
        desc:SetWidth(parent:GetWidth() - 72)
        desc:SetJustifyH("LEFT")
        desc:SetText(descText)
        local height = desc:GetStringHeight()
        if height < 12 then height = 12 end
        nextY = nextY - height - 12
    end

    return cb, nextY
end

local function CreateSettingsButton(parent, text, width, yOffset, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    StyleSettingsButton(btn)
    btn:SetSize(width, 26)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    btn:SetText(text)
    btn:SetScript("OnClick", onClick)
    return btn, yOffset - 34
end

local openSettingsDropdown

local function CreateSettingsDropdown(parent, width, getOptions, getValue, setValue, placeholder)
    local dropdown = CreateFrame("Button", nil, parent, "BackdropTemplate")
    dropdown:SetSize(width, 28)
    StyleSettingsButton(dropdown)
    dropdown.text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dropdown.text:SetPoint("LEFT", 10, 0)
    dropdown.text:SetPoint("RIGHT", -26, 0)
    dropdown.text:SetJustifyH("LEFT")
    dropdown.text:SetWordWrap(false)
    local arrow = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("RIGHT", -9, 0)
    arrow:SetText("v")

    -- Parent the choices to the window so they can extend beyond the scroll area.
    local menu = CreateFrame("Frame", nil, iWR.SettingsFrame, "BackdropTemplate")
    menu:SetWidth(math.max(width, 100))
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:SetToplevel(true)
    StyleSettingsSurface(menu)
    local dismiss = CreateFrame("Button", nil, menu:GetParent())
    dismiss:SetAllPoints(UIParent)
    dismiss:SetFrameStrata("FULLSCREEN_DIALOG")
    dismiss:SetFrameLevel(menu:GetFrameLevel())
    menu:SetFrameLevel(dismiss:GetFrameLevel() + 1)
    dismiss:SetScript("OnClick", function() menu:Hide() end)
    dismiss:Hide()
    menu:SetScript("OnHide", function()
        dismiss:Hide()
        if openSettingsDropdown == menu then openSettingsDropdown = nil end
    end)
    menu:Hide()
    dropdown.menu = menu
    local scroll = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -20, 4)
    StyleSettingsScroll(scroll)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(math.max(width, 100) - 24)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange(), self:GetVerticalScroll() - delta * 24)))
    end)
    local rows = {}
    function dropdown:Refresh()
        local current = getValue()
        self.text:SetText(current and tostring(current) or placeholder or "")
    end
    dropdown:SetScript("OnClick", function(self)
        if menu:IsShown() then menu:Hide(); return end
        if openSettingsDropdown then openSettingsDropdown:Hide() end
        local options = getOptions()
        if #options == 0 then return end
        for index, value in ipairs(options) do
            local row = rows[index]
            if not row then
                row = CreateFrame("Button", nil, content)
                row:SetHeight(24)
                row:SetPoint("TOPLEFT", 0, -(index - 1) * 24)
                row:SetPoint("TOPRIGHT", 0, -(index - 1) * 24)
                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.text:SetPoint("LEFT", 8, 0)
                row.text:SetPoint("RIGHT", -8, 0)
                row.text:SetJustifyH("LEFT")
                row.text:SetWordWrap(false)
                row:SetHighlightTexture("Interface\\BUTTONS\\WHITE8X8", "ADD")
                row:GetHighlightTexture():SetVertexColor(0.4, 0.28, 0.08, 0.4)
                rows[index] = row
            end
            row.text:SetText(tostring(value))
            if value == getValue() then row.text:SetTextColor(1, 0.72, 0.2)
            else row.text:SetTextColor(0.9, 0.86, 0.76) end
            row:SetScript("OnClick", function()
                menu:Hide()
                setValue(value)
                self:Refresh()
            end)
            row:Show()
        end
        for index = #options + 1, #rows do rows[index]:Hide() end
        content:SetHeight(#options * 24)
        menu:SetHeight(math.min(#options, 10) * 24 + 8)
        scroll:SetVerticalScroll(0)
        menu:SetScale(self:GetEffectiveScale() / menu:GetParent():GetEffectiveScale())
        menu:ClearAllPoints()
        if (self:GetBottom() or 0) > menu:GetHeight() + 12 then
            menu:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -2)
        else
            menu:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 2)
        end
        openSettingsDropdown = menu
        dismiss:Show()
        menu:Show()
    end)
    dropdown:SetScript("OnHide", function() menu:Hide() end)
    dropdown:SetScript("OnShow", function(self) self:Refresh() end)
    dropdown:Refresh()
    return dropdown
end

local function CreateInfoText(parent, text, yOffset, fontObj)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObj or "GameFontHighlight")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset)
    fs:SetWidth(parent:GetWidth() - 50)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    local height = fs:GetStringHeight()
    if height < 14 then height = 14 end
    return fs, yOffset - height - 4
end

local function CreateSettingsEditBox(parent, label, yOffset, width, getFunc, setFunc)
    local labelStr = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    labelStr:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset)
    labelStr:SetText(label)

    local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    iWR:StyleEditBox(editBox)
    editBox:SetSize(width or 150, 22)
    editBox:SetPoint("LEFT", labelStr, "LEFT", 90, 0)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlight)
    editBox:SetMaxLetters(30)

    if getFunc then
        editBox:SetText(getFunc())
    end

    editBox:SetScript("OnEnterPressed", function(self)
        if setFunc then setFunc(self:GetText()) end
        self:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        if getFunc then self:SetText(getFunc()) end
        self:ClearFocus()
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        if setFunc then setFunc(self:GetText()) end
    end)

    return editBox, labelStr, yOffset - 28
end

local function CreateSettingsSlider(parent, frameName, label, descText, yOffset,
                                    minValue, maxValue, step, value, onValueChanged)
    local slider = CreateFrame("Slider", frameName, parent)
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset - 24)
    slider:SetSize(360, 18)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    local title = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
    title:SetText(label)
    local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 4)
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetHeight(4)
    track:SetPoint("LEFT", 0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetColorTexture(0.16, 0.13, 0.09, 1)
    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(4)
    fill:SetPoint("LEFT", track, "LEFT")
    fill:SetColorTexture(0.85, 0.52, 0.12, 1)
    slider:SetThumbTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    local thumb = slider:GetThumbTexture()
    thumb:SetSize(14, 14)
    thumb:SetVertexColor(1, 0.73, 0.26, 1)

    local function UpdateText(currentValue)
        valueText:SetText(tostring(currentValue))
        fill:SetWidth(math.max(1, slider:GetWidth() * (currentValue - minValue) / (maxValue - minValue)))
    end

    value = tonumber(value) or 0
    slider:SetValue(value)
    UpdateText(value)
    slider:SetScript("OnValueChanged", function(_, currentValue)
        currentValue = math.floor(currentValue + 0.5)
        UpdateText(currentValue)
        onValueChanged(currentValue)
    end)
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(math.max(minValue, math.min(maxValue, self:GetValue() + delta * step)))
    end)

    local nextY = yOffset - 52
    if descText and descText ~= "" then
        local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, nextY)
        desc:SetWidth(parent:GetWidth() - 50)
        desc:SetJustifyH("LEFT")
        desc:SetText(descText)
        nextY = nextY - math.max(desc:GetStringHeight(), 12) - 8
    end

    return slider, nextY
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                             Icon Picker Popup                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local iconPickerFrame = nil

local function ShowIconPicker(typeIndex, previewTexture, onChanged)
    if iconPickerFrame then
        iconPickerFrame:Hide()
        iconPickerFrame = nil
    end

    -- Calculate dynamic size based on icon count
    local cols = 6
    local iconSize = 36
    local padding = 4
    local margin = 10
    local startY = -32
    local numIcons = #iWR.IconPickerList
    local numRows = math.ceil(numIcons / cols)
    local gridWidth = cols * (iconSize + padding) - padding
    local gridHeight = numRows * (iconSize + padding) - padding
    local popupWidth = gridWidth + margin * 2 + 12
    local popupHeight = math.abs(startY) + gridHeight + 80 -- grid + input + help text

    local popup = iWR:CreateiWRStyleFrame(UIParent, popupWidth, popupHeight, {"CENTER", UIParent, "CENTER"})
    popup:SetFrameStrata("DIALOG")
    StyleSettingsSurface(popup)
    popup:EnableMouse(true)
    popup:SetMovable(true)
    popup:SetScript("OnDragStart", function(self) self:StartMoving() end)
    popup:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    popup:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
    popup:RegisterForDrag("LeftButton")
    iconPickerFrame = popup

    -- Title bar
    local pTitleBar = CreateFrame("Frame", nil, popup, "BackdropTemplate")
    pTitleBar:SetHeight(28)
    pTitleBar:SetPoint("TOPLEFT", popup, "TOPLEFT", 0, 0)
    pTitleBar:SetPoint("TOPRIGHT", popup, "TOPRIGHT", 0, 0)
    StyleSettingsSurface(pTitleBar, true)

    local pTitle = pTitleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    pTitle:SetPoint("LEFT", pTitleBar, "LEFT", 12, 0)
    pTitle:SetText(L["SelectIcon"])

    local pClose = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    pClose:SetPoint("TOPRIGHT", popup, "TOPRIGHT", 0, 0)
    pClose:SetScript("OnClick", function() popup:Hide(); iconPickerFrame = nil end)

    -- Icon grid
    for i, path in ipairs(iWR.IconPickerList) do
        local row = math.floor((i - 1) / cols)
        local col = (i - 1) % cols
        local x = margin + col * (iconSize + padding)
        local yPos = startY - row * (iconSize + padding)

        local btn = CreateFrame("Button", nil, popup)
        btn:SetSize(iconSize, iconSize)
        btn:SetPoint("TOPLEFT", popup, "TOPLEFT", x, yPos)

        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints(btn)
        tex:SetTexture(path)

        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(btn)
        highlight:SetColorTexture(1, 0.59, 0.09, 0.24)

        -- The solid border sits behind the icon, showing only its outer edge.
        local border = btn:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(unpack(iWR.Theme.border))

        btn:SetScript("OnClick", function()
            if not iWRSettings.CustomIcons then iWRSettings.CustomIcons = {} end
            iWRSettings.CustomIcons[typeIndex] = path
            if previewTexture then
                previewTexture:SetTexture(path)
            end
            if onChanged then onChanged() end
            popup:Hide()
            iconPickerFrame = nil
        end)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local name = path:match("([^\\]+)%.?[^\\]*$") or path
            name = name:gsub("%.blp$", "")
            GameTooltip:AddLine(name, 1, 1, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    -- Manual path input (editbox + Set button on same row)
    local inputY = startY - gridHeight - 10

    local manualBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    iWR:StyleEditBox(manualBox)
    manualBox:SetSize(gridWidth - 50, 22)
    manualBox:SetPoint("TOPLEFT", popup, "TOPLEFT", margin + 2, inputY)
    manualBox:SetAutoFocus(false)
    manualBox:SetFontObject(GameFontHighlightSmall)
    manualBox:SetMaxLetters(200)

    local manualBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    StyleSettingsButton(manualBtn)
    manualBtn:SetSize(44, 22)
    manualBtn:SetPoint("LEFT", manualBox, "RIGHT", 4, 0)
    manualBtn:SetText(L["SetButton"])
    manualBtn:SetScript("OnClick", function()
        local path = manualBox:GetText()
        if path and path ~= "" then
            if not iWRSettings.CustomIcons then iWRSettings.CustomIcons = {} end
            iWRSettings.CustomIcons[typeIndex] = path
            if previewTexture then
                previewTexture:SetTexture(path)
            end
            if onChanged then onChanged() end
            popup:Hide()
            iconPickerFrame = nil
        end
    end)

    manualBox:SetScript("OnEnterPressed", function(self)
        manualBtn:Click()
    end)
    manualBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- Help text directly below input
    local helpText = popup:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    helpText:SetPoint("TOPLEFT", manualBox, "BOTTOMLEFT", 0, -4)
    helpText:SetWidth(gridWidth)
    helpText:SetJustifyH("LEFT")
    helpText:SetText(L["IconPathHelpInline"])

    popup:Show()
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                            Static Popup Dialogs                               │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

StaticPopupDialogs["IWR_RESTORE_DATABASE"] = {
    text = "",
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        if iWRDatabaseBackup then
            iWRDatabase = CopyTable(iWRDatabaseBackup)
            iWR:SaveRulesetStorage()
            local info = iWRSettings.iWRDatabaseBackupInfo
            local date = info and info.backupDate or L["UnknownDate"]
            local time = info and info.backupTime or L["UnknownTime"]
            print(L["BackupRestore"] .. date .. L["at"] .. time .. ".")
            iWR:PopulateDatabase()
        else
            print(L["BackupRestoreError"])
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["IWR_RESET_SETTINGS"] = {
    text = L["ResetConfirm"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        for key, value in pairs(iWR.SettingsDefault) do
            if key ~= "MinimapButton" and key ~= "SyncList" then
                iWRSettings[key] = type(value) == "table" and CopyTable(value) or value
            end
        end
        iWR:ResetSharingSession()
        iWR:SaveRulesetStorage()
        if iWR.RefreshLevelColors then iWR:RefreshLevelColors() end
        print(L["SettingsResetSuccess"])
        if iWR.RefreshSettingsPanel then
            iWR:RefreshSettingsPanel()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                           Create Options Panel                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

function iWR:CreateOptionsPanel()

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                        Main Frame                             │
    -- ╰───────────────────────────────────────────────────────────────╯
    local settingsFrame = iWR:CreateiWRStyleFrame(UIParent, 820, 580, {"CENTER", UIParent, "CENTER"})
    settingsFrame:Hide()
    settingsFrame:EnableMouse(true)
    settingsFrame:SetMovable(true)
    settingsFrame:SetFrameStrata("HIGH")
    settingsFrame:SetClampedToScreen(true)
    StyleSettingsSurface(settingsFrame)
    iWR.SettingsFrame = settingsFrame

    -- Shadow
    local shadow = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", settingsFrame, -1, 1)
    shadow:SetPoint("BOTTOMRIGHT", settingsFrame, 1, -1)
    shadow:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 5,
    })
    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

    -- Drag
    settingsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    settingsFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    settingsFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
    settingsFrame:RegisterForDrag("LeftButton", "RightButton")

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                         Title Bar                             │
    -- ╰───────────────────────────────────────────────────────────────╯
    local titleBar = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    titleBar:SetHeight(40)
    titleBar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 1, -1)
    titleBar:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -1, -1)
    StyleSettingsSurface(titleBar, true)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 15, 0)
    titleText:SetText(iWR.Colors.iWR .. "iWillRemember|r  |cFFAAA08C" .. L["SettingsTitle"] .. "|r")

    local closeButton = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() iWR:SettingsClose() end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                     Sidebar Navigation                        │
    -- ╰───────────────────────────────────────────────────────────────╯
    local sidebarWidth = 160

    local sidebar = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    sidebar:SetWidth(sidebarWidth)
    sidebar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -50)
    sidebar:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 10, 30)
    StyleSettingsSurface(sidebar)

    local footer = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footer:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 14, 11)
    footer:SetText(L["SettingsSavedAutomatically"])
    local versionText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    versionText:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -14, 11)
    versionText:SetText("v" .. iWR.Version)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Content Area                            │
    -- ╰───────────────────────────────────────────────────────────────╯
    local contentArea = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -10, 30)
    StyleSettingsSurface(contentArea)

    local pageHeader = CreateFrame("Frame", nil, contentArea, "BackdropTemplate")
    pageHeader:SetPoint("TOPLEFT", 1, -1)
    pageHeader:SetPoint("TOPRIGHT", -1, -1)
    pageHeader:SetHeight(58)
    pageHeader.title = pageHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    pageHeader.title:SetPoint("TOPLEFT", 20, -12)
    pageHeader.subtitle = pageHeader:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    pageHeader.subtitle:SetPoint("TOPLEFT", 20, -34)
    pageHeader.subtitle:SetPoint("TOPRIGHT", -20, -34)
    pageHeader.subtitle:SetJustifyH("LEFT")
    local pageInfo = {
        {L["Tab1General"], L["SettingsGeneralSummary"]},
        {L["Tab2Sync"], L["SettingsSyncSummary"]},
        {L["Tab3Backup"], L["SettingsBackupSummary"]},
        {L["Tab5Customize"], L["SettingsCustomizeSummary"]},
        {L["Tab4About"], L["SettingsAboutSummary"]},
        {L["TabINIFPromo"], L["SettingsCompanionSummary"]},
        {L["TabISTPromo"], L["SettingsCompanionSummary"]},
        {L["TabPlatynator"], L["SettingsNameplateSummary"]},
        {L["TabIRCPromo"], L["SettingsCompanionSummary"]},
    }

    -- Tab content frames with scroll
    local scrollFrames = {}
    local scrollChildren = {}
    -- Match the scroll viewport; wider children would clip controls on the right.
    local contentWidth = 592

    local function CreateTabContent()
        local container = CreateFrame("Frame", nil, contentArea)
        container:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 5, -62)
        container:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -5, 5)
        container:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -22, 0)
        StyleSettingsScroll(scrollFrame)

        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetWidth(contentWidth)
        scrollChild:SetHeight(1) -- Will be set after content is built
        scrollFrame:SetScrollChild(scrollChild)

        -- Mouse wheel on the container
        container:EnableMouseWheel(true)
        container:SetScript("OnMouseWheel", function(_, delta)
            local current = scrollFrame:GetVerticalScroll()
            local maxScroll = scrollChild:GetHeight() - scrollFrame:GetHeight()
            if maxScroll < 0 then maxScroll = 0 end
            local newScroll = current - (delta * 30)
            if newScroll < 0 then newScroll = 0 end
            if newScroll > maxScroll then newScroll = maxScroll end
            scrollFrame:SetVerticalScroll(newScroll)
        end)

        table.insert(scrollFrames, scrollFrame)
        table.insert(scrollChildren, scrollChild)

        return container, scrollChild
    end

    local generalContainer, generalContent = CreateTabContent()
    local syncContainer, syncContent = CreateTabContent()
    local backupContainer, backupContent = CreateTabContent()
    local customizeContainer, customizeContent = CreateTabContent()

    local aboutContainer, aboutContent = CreateTabContent()

    -- Other addon tabs (detection deferred to OnShow)
    local iNIFContainer, iNIFContent = CreateTabContent()
    local iSTContainer, iSTContent = CreateTabContent()
    local platynatorContainer, platynatorContent = CreateTabContent()
    local iRCContainer, iRCContent = CreateTabContent()

    local tabContents = {generalContainer, syncContainer, backupContainer, customizeContainer, aboutContainer, iNIFContainer, iSTContainer, platynatorContainer, iRCContainer}

    local sidebarButtons = {}
    local activeIndex = 1

    local function ShowTab(index)
        if openSettingsDropdown then openSettingsDropdown:Hide() end
        activeIndex = index
        pageHeader.title:SetText(pageInfo[index][1])
        pageHeader.subtitle:SetText(pageInfo[index][2])
        for i, content in ipairs(tabContents) do
            content:SetShown(i == index)
        end
        -- Update sidebar button highlights
        for i, btn in pairs(sidebarButtons) do
            btn.selected = i == index
            btn.selection:SetShown(btn.selected)
            btn.accent:SetShown(btn.selected)
            if btn.selected then btn.text:SetTextColor(1, 0.73, 0.25)
            else btn.text:SetTextColor(0.78, 0.74, 0.65) end
        end
    end

    -- Build sidebar with section headers and tab buttons
    local sidebarItems = {
        {type = "header", label = L["SidebarHeaderiWR"]},
        {type = "tab", label = L["Tab1General"], index = 1},
        {type = "tab", label = L["Tab2Sync"], index = 2},
        {type = "tab", label = L["Tab3Backup"], index = 3},
        {type = "tab", label = L["Tab5Customize"], index = 4},
        {type = "tab", label = L["Tab4About"], index = 5},
    }

    local platynatorLoaded = iWR.IsPlatynatorLoaded and iWR:IsPlatynatorLoaded()
    if platynatorLoaded then
        table.insert(sidebarItems, {type = "tab", label = L["TabPlatynator"], index = 8})
    end

    table.insert(sidebarItems, {type = "header", label = L["SidebarHeaderOtherAddons"]})
    table.insert(sidebarItems, {type = "tab", label = L["TabINIFPromo"], index = 6})
    table.insert(sidebarItems, {type = "tab", label = L["TabISTPromo"], index = 7})
    table.insert(sidebarItems, {type = "tab", label = L["TabIRCPromo"], index = 9})

    local sidebarY = -10
    for _, item in ipairs(sidebarItems) do
        if item.type == "header" then
            local headerText = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerText:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 12, sidebarY - 2)
            headerText:SetText(item.label)
            sidebarY = sidebarY - 20
        else
            local btn = CreateFrame("Button", nil, sidebar)
            btn:SetSize(sidebarWidth - 12, 30)
            btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, sidebarY)

            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", btn, "LEFT", 14, 0)
            text:SetText(item.label)
            btn.text = text
            btn.selection = btn:CreateTexture(nil, "BACKGROUND")
            btn.selection:SetAllPoints(btn)
            btn.selection:SetColorTexture(0.85, 0.52, 0.12, 0.14)
            btn.accent = btn:CreateTexture(nil, "ARTWORK")
            btn.accent:SetPoint("TOPLEFT", 0, -3)
            btn.accent:SetPoint("BOTTOMLEFT", 0, 3)
            btn.accent:SetWidth(2)
            btn.accent:SetColorTexture(1, 0.67, 0.16, 1)

            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints(btn)
            highlight:SetColorTexture(1, 1, 1, 0.08)

            local tabIndex = item.index
            btn:SetScript("OnClick", function()
                ShowTab(tabIndex)
            end)

            sidebarButtons[tabIndex] = btn
            sidebarY = sidebarY - 32
        end
    end

    -- Show first tab by default
    ShowTab(1)

    -- Track checkboxes for RefreshSettingsPanel
    local checkboxRefs = {}

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      General Tab Content                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    local y = -10

    -- Language Settings (always in English so non-English users can find it)
    if GetLocale() ~= "enUS" then
        _, y = CreateSectionHeader(generalContent, iWR.Colors.iWR .. "Language Settings", y)

        local cbForceEnglish
        cbForceEnglish, y = CreateSettingsCheckbox(generalContent, "Force English",
            "|cFF808080Forces the addon to use English text regardless of your game client language. Requires /reload to apply.|r",
            y, "ForceEnglish")
        checkboxRefs.ForceEnglish = cbForceEnglish
        y = y - 4
    end

    -- Display Settings
    _, y = CreateSectionHeader(generalContent, L["DisplaySettings"], y)

    local cbTargetFrame
    cbTargetFrame, y = CreateSettingsCheckbox(generalContent, L["EnhancedFrame"],
        L["DescEnhancedFrame"], y, "UpdateTargetFrame")
    checkboxRefs.UpdateTargetFrame = cbTargetFrame

    local cbChatIcons
    cbChatIcons, y = CreateSettingsCheckbox(generalContent, L["ShowChatIcons"],
        L["DescShowChatIcons"], y, "ShowChatIcons")
    checkboxRefs.ShowChatIcons = cbChatIcons

    local cbGroupFinderNotes
    cbGroupFinderNotes, y = CreateSettingsCheckbox(generalContent, L["ShowGroupFinderNotes"],
        L["DescShowGroupFinderNotes"], y, "ShowGroupFinderNotes", nil,
        function(checked)
            iWRSettings.ShowGroupFinderNotes = checked
            if iWR.RefreshGroupFinderNotes then
                iWR:RefreshGroupFinderNotes()
            end
        end)
    checkboxRefs.ShowGroupFinderNotes = cbGroupFinderNotes

    local cbWhoNotes
    cbWhoNotes, y = CreateSettingsCheckbox(generalContent, L["ShowWhoNotes"] or "Show Notes in Who Search",
        L["DescShowWhoNotes"] or "|cFF808080Shows saved relationship icons beside tracked players in Who search results.|r",
        y, "ShowWhoNotes", nil,
        function(checked)
            iWRSettings.ShowWhoNotes = checked
            if iWR.RefreshWhoNotes then
                iWR:RefreshWhoNotes()
            end
        end)
    checkboxRefs.ShowWhoNotes = cbWhoNotes

    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["SettingsMenuAndHistory"], y)

    local cbSimpleMenu
    cbSimpleMenu, y = CreateSettingsCheckbox(generalContent, L["SimpleMenu"] or "Simple Menu",
        L["DescSimpleMenu"] or "|cFF808080Use five quick buttons with names below the icons to save or clear a note.|r",
        y, "SimpleMenu", nil, function(value) iWR:SetSimpleMenu(value) end)
    checkboxRefs.SimpleMenu = cbSimpleMenu

    local cbGroupLog
    cbGroupLog, y = CreateSettingsCheckbox(generalContent, L["EnableGroupLog"],
        L["DescEnableGroupLog"], y, "GroupLogEnabled")
    checkboxRefs.GroupLogEnabled = cbGroupLog

    -- Warning Settings
    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["WarningSettings"], y)

    local cbSoundWarnings
    local cbGroupWarnings
    cbGroupWarnings, y = CreateSettingsCheckbox(generalContent, L["EnableGroupWarning"],
        L["DescEnableGroupWarning"], y, "GroupWarnings", nil,
        function(checked)
            iWRSettings.GroupWarnings = checked
            if not checked then
                iWRMemory.SoundWarnings = iWRSettings.SoundWarnings
                iWRSettings.SoundWarnings = false
            else
                iWRSettings.SoundWarnings = iWRMemory.SoundWarnings
            end
            -- Update sound checkbox state
            if cbSoundWarnings then
                cbSoundWarnings:SetChecked(iWRSettings.SoundWarnings)
                if checked then
                    cbSoundWarnings:Enable()
                    cbSoundWarnings.Text:SetFontObject(GameFontHighlight)
                else
                    cbSoundWarnings:Disable()
                    cbSoundWarnings.Text:SetFontObject(GameFontDisable)
                end
            end
        end)
    checkboxRefs.GroupWarnings = cbGroupWarnings

    -- Sound Warnings (indented)
    local cbSoundOuter = CreateFrame("CheckButton", nil, generalContent, "InterfaceOptionsCheckButtonTemplate")
    StyleSettingsCheckbox(cbSoundOuter)
    cbSoundOuter:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 40, y)
    cbSoundOuter.Text:SetText(L["EnableSoundWarning"])
    cbSoundOuter.Text:SetFontObject(GameFontHighlight)
    cbSoundOuter:SetChecked(iWRSettings.SoundWarnings)
    cbSoundOuter:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        iWRSettings.SoundWarnings = checked
    end)
    cbSoundWarnings = cbSoundOuter
    checkboxRefs.SoundWarnings = cbSoundOuter

    if not iWRSettings.GroupWarnings then
        cbSoundOuter:Disable()
        cbSoundOuter.Text:SetFontObject(GameFontDisable)
    end

    y = y - 22
    local soundDesc = generalContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    soundDesc:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 68, y)
    soundDesc:SetWidth(460)
    soundDesc:SetJustifyH("LEFT")
    soundDesc:SetText(L["DescEnableSoundWarning"])
    local sdh = soundDesc:GetStringHeight()
    if sdh < 12 then sdh = 12 end
    y = y - sdh - 6

    -- Tooltip Settings
    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["ToolTipSettings"], y)

    local cbAuthor
    cbAuthor, y = CreateSettingsCheckbox(generalContent, L["ShowAuthor"],
        L["DescShowAuthor"], y, "TooltipShowAuthor")
    checkboxRefs.TooltipShowAuthor = cbAuthor

    -- Minimap Settings
    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["MinimapSettings"], y)

    local cbMinimap
    cbMinimap, y = CreateSettingsCheckbox(generalContent, L["ShowMinimapButton"],
        L["DescShowMinimapButton"], y, nil,
        function() return not iWRSettings.MinimapButton.hide end,
        function(checked)
            iWRSettings.MinimapButton.hide = not checked
            if checked then
                LDBIcon:Show("iWillRemember")
            else
                LDBIcon:Hide("iWillRemember")
            end
        end)
    checkboxRefs.ShowMinimapButton = cbMinimap

    -- My Characters (for Mine/Friends filter)
    y = y - 8
    _, y = CreateSectionHeader(generalContent, "My Characters", y)

    local myCharsInfo
    myCharsInfo, y = CreateInfoText(generalContent,
        "|cFF808080Characters registered for the Mine/Friends database filter. Remove names that aren't yours.|r", y, "GameFontDisableSmall")

    -- Character list panel
    local mcPanel = CreateFrame("Frame", nil, generalContent, "BackdropTemplate")
    mcPanel:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 20, y)
    mcPanel:SetSize(250, 80)
    mcPanel:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    StyleSettingsSurface(mcPanel)

    local mcText = mcPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mcText:SetPoint("TOPLEFT", mcPanel, "TOPLEFT", 8, -6)
    mcText:SetWidth(230)
    mcText:SetJustifyH("LEFT")

    local function UpdateMyCharsDisplay()
        local t = {}
        for name in pairs(iWRSettings.MyCharacters or {}) do
            table.insert(t, "|cFF00FF00\226\128\162|r " .. name)
        end
        table.sort(t)
        if #t == 0 then
            mcText:SetText("|cFF808080No characters registered.|r")
        else
            mcText:SetText(table.concat(t, "\n"))
        end
        -- Resize panel to fit content
        local lineCount = math.max(#t, 1)
        mcPanel:SetHeight(math.max(lineCount * 14 + 14, 30))
    end

    UpdateMyCharsDisplay()

    -- Remove dropdown
    local mcRemoveLabel = generalContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mcRemoveLabel:SetPoint("TOPLEFT", mcPanel, "TOPRIGHT", 20, -4)
    mcRemoveLabel:SetText(L["MyCharsRemove"])

    local mcRemoveDropdown = CreateSettingsDropdown(generalContent, 230,
        function()
            local names = {}
            for name in pairs(iWRSettings.MyCharacters or {}) do names[#names + 1] = name end
            table.sort(names)
            return names
        end,
        function() return nil end,
        function(name)
            iWRSettings.MyCharacters[name] = nil
            UpdateMyCharsDisplay()
        end, L["SettingsChooseCharacter"])
    mcRemoveDropdown:SetPoint("TOPLEFT", mcRemoveLabel, "BOTTOMLEFT", 0, -8)

    y = y - math.max(mcPanel:GetHeight(), 60) - 12

    -- Section: Chat Output
    _, y = CreateSectionHeader(generalContent, L["SectionChatOutput"], y - 6)

    local generalChatCb = CreateFrame("CheckButton", nil, generalContent, "InterfaceOptionsCheckButtonTemplate")
    StyleSettingsCheckbox(generalChatCb)
    generalChatCb:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 20, y)
    if not generalChatCb.Text then
        generalChatCb.Text = generalChatCb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        generalChatCb.Text:SetPoint("LEFT", generalChatCb, "RIGHT", 4, 0)
    end
    generalChatCb.Text:SetText(iWR.Colors.Gray .. "General " .. L["ChatFrameAlwaysOn"] .. iWR.Colors.Reset)
    generalChatCb:SetChecked(true)
    generalChatCb:Disable()
    y = y - 22

    if not iWRSettings.ChatFrames then iWRSettings.ChatFrames = {} end
    local skipTabs = { ["Combat Log"] = true, ["Voice"] = true }
    for i = 2, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name and name ~= "" and not skipTabs[name] then
            local frameIndex = i
            local cb = CreateFrame("CheckButton", nil, generalContent, "InterfaceOptionsCheckButtonTemplate")
            StyleSettingsCheckbox(cb)
            cb:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 20, y)
            if not cb.Text then
                cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            end
            cb.Text:SetText(name)
            cb:SetChecked(iWRSettings.ChatFrames[frameIndex] or false)
            cb:SetScript("OnClick", function(self)
                iWRSettings.ChatFrames[frameIndex] = self:GetChecked() and true or false
            end)
            y = y - 22
        end
    end

    scrollChildren[1]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Sync Tab Content                        │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    -- Sync Settings (full width top section)
    _, y = CreateSectionHeader(syncContent, L["SyncSettings"], y)

    local cbSync
    cbSync, y = CreateSettingsCheckbox(syncContent, L["EnableWhitelistSharing"],
        L["WhitelistSharingDescription"], y, "DataSharing", nil, function(value)
            iWRSettings.DataSharing = value
            iWR:ResetSharingSession()
            iWR:RefreshSharingPanel()
        end)
    checkboxRefs.DataSharing = cbSync

    local rulesetText = syncContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rulesetText:SetPoint("TOPLEFT", syncContent, "TOPLEFT", 20, y - 4)
    y = y - 28
    local help
    help, y = CreateInfoText(syncContent, L["WhitelistSharingHelp"], y, "GameFontDisableSmall")

    local nameInput = CreateFrame("EditBox", nil, syncContent, "InputBoxTemplate")
    nameInput:SetSize(300, 28)
    nameInput:SetPoint("TOPLEFT", syncContent, "TOPLEFT", 20, y - 8)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(120)
    iWR:StyleEditBox(nameInput)
    local add = CreateFrame("Button", nil, syncContent, "UIPanelButtonTemplate")
    StyleSettingsButton(add)
    add:SetSize(90, 28)
    add:SetPoint("LEFT", nameInput, "RIGHT", 8, 0)
    add:SetText(L["WhitelistAddPlayer"])
    local feedback = syncContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    feedback:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -5)
    feedback:SetWidth(480)
    feedback:SetJustifyH("LEFT")
    feedback:SetText(L["WhitelistNameHint"])
    local function addContact()
        local ok, reason = iWR:AddSharingContact(nameInput:GetText())
        feedback:SetText(ok and L["WhitelistAdded"] or reason)
        if ok then
            nameInput:SetText("")
            nameInput:ClearFocus()
        end
    end
    add:SetScript("OnClick", addContact)
    iWR:AttachAutocomplete(nameInput, function() return iWR:GetSharingSuggestions() end,
        { onSelect = addContact, onAccept = addContact })

    y = y - 76
    local refresh
    refresh, y = CreateSettingsButton(syncContent, L["WhitelistRefreshStatus"], 150, y, function()
        iWR:RefreshSharingStatus()
    end)
    local share = CreateFrame("Button", nil, syncContent, "UIPanelButtonTemplate")
    StyleSettingsButton(share)
    share:SetSize(150, 26)
    share:SetPoint("LEFT", refresh, "RIGHT", 8, 0)
    share:SetText(L["WhitelistSyncNow"])
    share:SetScript("OnClick", function() iWR:SyncWithWhitelist() end)

    local list = CreateFrame("ScrollFrame", nil, syncContent, "UIPanelScrollFrameTemplate")
    list:SetPoint("TOPLEFT", syncContent, "TOPLEFT", 20, y - 4)
    list:SetPoint("TOPRIGHT", syncContent, "TOPRIGHT", -36, y - 4)
    list:SetHeight(240)
    StyleSettingsScroll(list)
    local content = CreateFrame("Frame", nil, list)
    content:SetSize(480, 240)
    list:SetScrollChild(content)
    local rows = {}
    local empty = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    empty:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -8)
    empty:SetText(L["WhitelistEmpty"])

    function iWR:RefreshSharingPanel()
        rulesetText:SetText(L["WhitelistRuleset"] .. self:GetSharingRulesetLabel())
        local contacts = iWRSettings.SyncList or {}
        empty:SetShown(#contacts == 0)
        for index, contact in ipairs(contacts) do
            local row = rows[index]
            if not row then
                row = CreateFrame("Frame", nil, content, "BackdropTemplate")
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(index - 1) * 34)
                row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(index - 1) * 34)
                row:SetHeight(30)
                StyleSettingsSurface(row)
                row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.name:SetPoint("LEFT", row, "LEFT", 8, 0)
                row.name:SetWidth(240)
                row.name:SetJustifyH("LEFT")
                row.status = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                row.status:SetPoint("RIGHT", row, "RIGHT", -35, 0)
                row.remove = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                StyleSettingsButton(row.remove)
                row.remove:SetSize(22, 22)
                row.remove:SetPoint("RIGHT", row, "RIGHT", -4, 0)
                row.remove:SetText("x")
                row.remove:SetScript("OnClick", function() self:RemoveSharingContact(row.contact.name) end)
                row:EnableMouse(true)
                row:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
                    GameTooltip:SetText(row.contact.name)
                    GameTooltip:AddLine(self:GetSharingPeerStatus(row.contact.name), 1, 0.82, 0.35)
                    GameTooltip:AddLine(row.contact.lastSeen and
                        (L["WhitelistLastSeen"] .. date("%Y-%m-%d %H:%M", row.contact.lastSeen))
                        or L["WhitelistNotSeen"], 0.7, 0.7, 0.7)
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)
                rows[index] = row
            end
            row.contact = contact
            row.name:SetText(contact.name)
            local status = self:GetSharingPeerStatus(contact.name)
            row.status:SetText(status)
            if status == "iWR ready" then row.status:SetTextColor(0.2, 1, 0.3)
            elseif status == "Offline" or status == "Different ruleset" then row.status:SetTextColor(1, 0.35, 0.25)
            else row.status:SetTextColor(0.75, 0.75, 0.75) end
            row:Show()
        end
        for index = #contacts + 1, #rows do rows[index]:Hide() end
        content:SetHeight(math.max(240, #contacts * 34))
    end
    syncContent:HookScript("OnShow", function() iWR:RefreshSharingPanel() end)
    list:SetScript("OnSizeChanged", function(_, width) content:SetWidth(width) end)
    local statusElapsed = 0
    syncContent:HookScript("OnUpdate", function(_, delta)
        statusElapsed = statusElapsed + delta
        if statusElapsed >= 1 then statusElapsed = 0; iWR:RefreshSharingPanel() end
    end)
    iWR:RefreshSharingPanel()
    scrollChildren[2]:SetHeight(math.abs(y) + 270)

    -- Backup settings
    y = -10

    -- Backup Settings
    _, y = CreateSectionHeader(backupContent, L["BackupSettingsHeader"], y)

    local cbBackup
    cbBackup, y = CreateSettingsCheckbox(backupContent, L["EnableBackup"],
        L["DescEnableBackup"], y, "HourlyBackup", nil,
        function(checked)
            iWRSettings.HourlyBackup = checked
            iWR:ToggleHourlyBackup(checked)
        end)
    checkboxRefs.HourlyBackup = cbBackup

    -- Backup info text
    local backupInfoText
    backupInfoText, y = CreateInfoText(backupContent, "", y)
    iWR._backupInfoText = backupInfoText

    local function UpdateBackupInfoDisplay()
        local info = iWRSettings.iWRDatabaseBackupInfo
        if info and info.backupDate and info.backupDate ~= "" and info.backupTime and info.backupTime ~= "" then
            backupInfoText:SetText(L["LastBackup1"] .. info.backupDate .. L["at"] .. info.backupTime)
        else
            backupInfoText:SetText("|cFF808080" .. L["NoBackup"] .. "|r")
        end
    end
    UpdateBackupInfoDisplay()

    y = y - 4

    -- Restore button
    local restoreBtn
    restoreBtn, y = CreateSettingsButton(backupContent, L["RestoreDatabase"], 180, y,
        function()
            local info = iWRSettings.iWRDatabaseBackupInfo
            local date = info and info.backupDate or L["UnknownDate"]
            local time = info and info.backupTime or L["UnknownTime"]
            StaticPopupDialogs["IWR_RESTORE_DATABASE"].text = L["RestoreConfirm"] .. date .. L["at"] .. time .. "."
            StaticPopup_Show("IWR_RESTORE_DATABASE")
        end)

    if not iWRDatabaseBackup or not next(iWRDatabaseBackup) then
        restoreBtn:Disable()
    end

    -- Database Statistics
    y = y - 4
    _, y = CreateSectionHeader(backupContent, L["DatabaseStats"], y)

    local dbStatsText
    dbStatsText, y = CreateInfoText(backupContent, "", y)
    iWR._dbStatsText = dbStatsText

    local function UpdateDatabaseStats()
        local dbCount = 0
        if iWRDatabase then
            for _ in pairs(iWRDatabase) do dbCount = dbCount + 1 end
        end
        local backupCount = 0
        if iWRDatabaseBackup then
            for _ in pairs(iWRDatabaseBackup) do backupCount = backupCount + 1 end
        end
        dbStatsText:SetText(
            iWR.Colors.iWR .. L["DatabaseEntriesLabel"] .. "|r " .. dbCount ..
            "\n" .. iWR.Colors.iWR .. L["BackupEntriesLabel"] .. "|r " .. backupCount
        )
    end
    UpdateDatabaseStats()

    -- Reset Section
    y = y - 8
    _, y = CreateSectionHeader(backupContent, L["ResetSettingsHeader"], y)

    local resetDesc
    resetDesc, y = CreateInfoText(backupContent,
        L["ResetSettingsDesc"],
        y, "GameFontDisableSmall")

    local resetBtn
    resetBtn, y = CreateSettingsButton(backupContent, L["ResetToDefaults"], 200, y,
        function()
            StaticPopup_Show("IWR_RESET_SETTINGS")
        end)

    scrollChildren[3]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                    Customize Tab Content                       │
    -- ╰───────────────────────────────────────────────────────────────╯

    -- Container for all dynamically built customize rows
    local customizeDynamicFrame = CreateFrame("Frame", nil, customizeContent)
    customizeDynamicFrame:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 0, 0)
    customizeDynamicFrame:SetPoint("TOPRIGHT", customizeContent, "TOPRIGHT", 0, 0)
    customizeDynamicFrame:SetHeight(1) -- will be resized

    local customizeRows = {} -- track all dynamic frames for cleanup
    local iconPreviewTextures = {}
    local iconRowLabels = {}
    local labelEditBoxes = {}
    local colorButtons = {}

    local function RefreshLevelColorButtons()
        for level, controls in pairs(colorButtons) do
            StyleSettingsButton(controls.color)
            if controls.swatch then controls.swatch:SetColorTexture(iWR:GetLevelColor(level)) end
            controls.reset:SetEnabled(iWRSettings.LevelColors and iWRSettings.LevelColors[level] ~= nil or false)
            if controls.iconReset then controls.iconReset:SetEnabled(iWRSettings.CustomIcons and iWRSettings.CustomIcons[level] ~= nil or false) end
        end
    end

    local function ShowLevelColorPicker(level)
        if not ColorPickerFrame or not ColorPickerFrame.SetupColorPickerAndShow then
            iWR:DebugMsg("The level color picker is not available on this client.", 1)
            return
        end
        local settings = iWRSettings
        local original = settings.LevelColors and settings.LevelColors[level]
        local r, g, b = iWR:GetLevelColor(level)
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, hasOpacity = false,
            swatchFunc = function()
                if iWRSettings ~= settings or iWR:ResolveLevel(level) ~= level then return end
                local red, green, blue = ColorPickerFrame:GetColorRGB()
                iWR:SetLevelColor(level, red, green, blue)
                RefreshLevelColorButtons()
            end,
            cancelFunc = function()
                settings.LevelColors = settings.LevelColors or {}
                settings.LevelColors[level] = original
                if iWRSettings == settings then
                    iWR:RefreshLevelColors()
                    RefreshLevelColorButtons()
                end
            end,
        })
    end

    local function BuildCustomizeContent()
        -- Clean up previous dynamic content
        for _, frame in ipairs(customizeRows) do
            frame:Hide()
            frame:SetParent(nil)
        end
        wipe(customizeRows)
        wipe(iconPreviewTextures)
        wipe(iconRowLabels)
        wipe(labelEditBoxes)
        wipe(colorButtons)

        local y = -10

        -- Customize info text
        local customizeInfo = customizeContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        customizeInfo:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 25, y)
        customizeInfo:SetWidth(500)
        customizeInfo:SetJustifyH("LEFT")
        customizeInfo:SetText(L["DescCustomizeInfo"])
        customizeRows[#customizeRows + 1] = customizeInfo
        y = y - (customizeInfo:GetStringHeight() + 8)

        -- ── Relation Levels Section ──
        local levelsHeader
        levelsHeader, y = CreateSectionHeader(customizeContent, L["RelationLevelsHeader"], y)
        customizeRows[#customizeRows + 1] = levelsHeader

        local levelsDesc = customizeContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        levelsDesc:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 25, y)
        levelsDesc:SetWidth(500)
        levelsDesc:SetJustifyH("LEFT")
        levelsDesc:SetText(L["DescRelationLevels"] or "|cFF808080Set the number of positive and negative relation levels. The base levels (Superior, Respected, Liked, Disliked, Hated) are always present.|r")
        customizeRows[#customizeRows + 1] = levelsDesc
        y = y - (levelsDesc:GetStringHeight() + 8)

        -- Level count dropdowns row
        local levelRow = CreateFrame("Frame", nil, customizeContent)
        levelRow:SetSize(500, 30)
        levelRow:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 25, y)
        customizeRows[#customizeRows + 1] = levelRow

        local goodLabel = levelRow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        goodLabel:SetPoint("LEFT", levelRow, "LEFT", 0, 0)
        goodLabel:SetText(L["GoodLevels"] or "Positive Levels")

        local function UpdateLevelCount(setting, value)
            iWRSettings[setting] = value
            BuildCustomizeContent()
            if iWR.RebuildSliderTicks then iWR.RebuildSliderTicks() end
            if iWR.UpdateMenuMode then iWR.UpdateMenuMode() end
        end
        local goodDropdown = CreateSettingsDropdown(levelRow, 64,
            function() return {3, 4, 5, 6, 7, 8, 9, 10} end,
            function() return iWRSettings.GoodLevels or iWR.SettingsDefault.GoodLevels end,
            function(value) UpdateLevelCount("GoodLevels", value) end)
        goodDropdown:SetPoint("LEFT", goodLabel, "RIGHT", 12, 0)
        customizeRows[#customizeRows + 1] = goodDropdown.menu

        local badLabel = levelRow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        badLabel:SetPoint("LEFT", levelRow, "LEFT", 280, 0)
        badLabel:SetText(L["BadLevels"] or "Negative Levels")
        local badDropdown = CreateSettingsDropdown(levelRow, 64,
            function() return {2, 3, 4, 5, 6, 7, 8, 9, 10} end,
            function() return iWRSettings.BadLevels or iWR.SettingsDefault.BadLevels end,
            function(value) UpdateLevelCount("BadLevels", value) end)
        badDropdown:SetPoint("LEFT", badLabel, "RIGHT", 12, 0)
        customizeRows[#customizeRows + 1] = badDropdown.menu

        y = y - 40

        -- ── Build active level keys based on current settings ──
        local goodLevels = iWRSettings.GoodLevels or iWR.SettingsDefault.GoodLevels
        local badLevels  = iWRSettings.BadLevels  or iWR.SettingsDefault.BadLevels

        local posKeys, negKeys = iWR.GetLevelKeys(goodLevels, badLevels)
        local activeLevels = {}
        for _, key in ipairs(posKeys) do
            activeLevels[#activeLevels + 1] = key
        end
        for _, key in ipairs(negKeys) do
            activeLevels[#activeLevels + 1] = key
        end

        -- ── Custom Icons Section ──
        y = y - 4
        local iconHeader
        iconHeader, y = CreateSectionHeader(customizeContent, iWR.Colors.iWR .. L["LevelAppearanceHeader"], y)
        customizeRows[#customizeRows + 1] = iconHeader

        local iconDesc = customizeContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        iconDesc:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 25, y)
        iconDesc:SetWidth(500)
        iconDesc:SetJustifyH("LEFT")
        iconDesc:SetText(L["LevelColorsDesc"])
        customizeRows[#customizeRows + 1] = iconDesc
        y = y - (iconDesc:GetStringHeight() + 8)

        local appearanceHeaders = CreateFrame("Frame", nil, customizeContent)
        appearanceHeaders:SetSize(contentWidth - 40, 22)
        appearanceHeaders:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 20, y)
        customizeRows[#customizeRows + 1] = appearanceHeaders
        for _, column in ipairs({ {L["AppearanceRating"], 12}, {L["AppearanceIcon"], 210}, {L["AppearanceColor"], 366} }) do
            local heading = appearanceHeaders:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            heading:SetPoint("LEFT", column[2], 0)
            heading:SetText(column[1])
        end
        y = y - 24

        for index, key in ipairs(activeLevels) do
            local rowFrame = CreateFrame("Frame", nil, customizeContent)
            rowFrame:SetSize(contentWidth - 40, 54)
            rowFrame:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 20, y)
            local background = rowFrame:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints()
            if index % 2 == 0 then background:SetColorTexture(0.055, 0.045, 0.030, 0.85)
            else background:SetColorTexture(0.030, 0.027, 0.022, 0.85) end
            local divider = rowFrame:CreateTexture(nil, "BORDER")
            divider:SetHeight(1)
            divider:SetPoint("BOTTOMLEFT")
            divider:SetPoint("BOTTOMRIGHT")
            divider:SetColorTexture(0.32, 0.25, 0.14, 0.5)
            customizeRows[#customizeRows + 1] = rowFrame

            local iconButton = CreateFrame("Button", nil, rowFrame)
            iconButton:SetSize(36, 36)
            iconButton:SetPoint("LEFT", 10, 0)
            iconButton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
            local preview = iconButton:CreateTexture(nil, "ARTWORK")
            preview:SetSize(32, 32)
            preview:SetPoint("CENTER")
            local currentIcon = iWR:GetIcon(key) or iWR.Icons[key]
            if currentIcon then preview:SetTexture(currentIcon) end
            iconPreviewTextures[key] = preview

            -- Label (colored by rating type)
            local typeColor = iWR.Colors[key] or "|cFFFFFFFF"
            local typeName = iWR:GetTypeName(key)
            local sign = key > 0 and "+" or ""
            local label = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:SetPoint("TOPLEFT", 60, -9)
            label:SetWidth(138)
            label:SetJustifyH("LEFT")
            label:SetWordWrap(false)
            label:SetText(typeColor .. typeName .. "|r")
            iconRowLabels[key] = label
            local rating = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            rating:SetPoint("TOPLEFT", 60, -30)
            rating:SetText(sign .. key)

            local changeBtn = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
            StyleSettingsButton(changeBtn)
            changeBtn:SetSize(88, 26)
            changeBtn:SetPoint("LEFT", rowFrame, "LEFT", 210, 0)
            changeBtn:SetText(L["ChangeIcon"] or "Change")
            local function chooseIcon() ShowIconPicker(key, preview, RefreshLevelColorButtons) end
            changeBtn:SetScript("OnClick", chooseIcon)
            iconButton:SetScript("OnClick", chooseIcon)

            local resetIconBtn = CreateAppearanceReset(rowFrame, L["AppearanceResetIconHint"], function()
                if iWRSettings.CustomIcons then
                    iWRSettings.CustomIcons[key] = nil
                end
                local defaultIcon = iWR.Icons[key]
                if defaultIcon then preview:SetTexture(defaultIcon) end
                RefreshLevelColorButtons()
            end)
            resetIconBtn:SetPoint("LEFT", changeBtn, "RIGHT", 6, 0)

            local selectedLevel = key
            local colorBtn = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
            StyleSettingsButton(colorBtn)
            colorBtn:SetSize(90, 26)
            colorBtn:SetPoint("LEFT", rowFrame, "LEFT", 366, 0)
            colorBtn:SetText(L["AppearanceChooseColor"])
            local colorText = colorBtn:GetFontString()
            colorText:ClearAllPoints()
            colorText:SetPoint("LEFT", 33, 0)
            colorText:SetPoint("RIGHT", -5, 0)
            colorText:SetJustifyH("LEFT")
            local swatch = colorBtn:CreateTexture(nil, "OVERLAY")
            swatch:SetSize(18, 16)
            swatch:SetPoint("LEFT", 8, 0)
            colorBtn:SetScript("OnClick", function() ShowLevelColorPicker(selectedLevel) end)
            colorBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["LevelColorHint"], 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            colorBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            local resetColorBtn = CreateAppearanceReset(rowFrame, L["AppearanceResetColorHint"], function()
                iWR:SetLevelColor(selectedLevel)
                RefreshLevelColorButtons()
            end)
            resetColorBtn:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
            colorButtons[selectedLevel] = { color = colorBtn, reset = resetColorBtn, swatch = swatch, iconReset = resetIconBtn }

            y = y - 55
        end

        -- ── Button Labels Section ──
        y = y - 8
        local labelsHeader
        labelsHeader, y = CreateSectionHeader(customizeContent, L["ButtonLabelsSettings"], y)
        customizeRows[#customizeRows + 1] = labelsHeader

        local labelDesc = customizeContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        labelDesc:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 25, y)
        labelDesc:SetWidth(500)
        labelDesc:SetJustifyH("LEFT")
        labelDesc:SetText(L["DescButtonLabels"])
        customizeRows[#customizeRows + 1] = labelDesc
        y = y - (labelDesc:GetStringHeight() + 8)

        for _, key in ipairs(activeLevels) do
            local typeColor = iWR.Colors[key] or "|cFFFFFFFF"
            local sign = key > 0 and "+" or ""
            local displayLabel = typeColor .. sign .. key .. ":|r"

            local eb, labelStr, newY = CreateSettingsEditBox(customizeContent, displayLabel, y, 280,
                function() return iWRSettings.ButtonLabels and iWRSettings.ButtonLabels[key] or iWR.Types[key] or "" end,
                function(text)
                    if not iWRSettings.ButtonLabels then iWRSettings.ButtonLabels = {} end
                    if text == "" then text = iWR.Types[key] or "" end
                    iWRSettings.ButtonLabels[key] = text
                end)
            labelEditBoxes[key] = eb
            customizeRows[#customizeRows + 1] = eb
            customizeRows[#customizeRows + 1] = labelStr
            y = newY
        end

        -- Reset Labels button
        y = y - 4
        local resetLabelsBtn = CreateFrame("Button", nil, customizeContent, "UIPanelButtonTemplate")
        StyleSettingsButton(resetLabelsBtn, true)
        resetLabelsBtn:SetSize(200, 24)
        resetLabelsBtn:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 20, y)
        resetLabelsBtn:SetText(L["ResetLabels"])
        resetLabelsBtn:SetScript("OnClick", function()
            for _, key in ipairs(activeLevels) do
                local defaultLabel = iWR.Types[key] or ""
                if iWRSettings.ButtonLabels then
                    iWRSettings.ButtonLabels[key] = defaultLabel
                end
                if labelEditBoxes[key] then
                    labelEditBoxes[key]:SetText(defaultLabel)
                end
            end
        end)
        customizeRows[#customizeRows + 1] = resetLabelsBtn
        y = y - 34

        scrollChildren[4]:SetHeight(math.abs(y) + 20)
        RefreshLevelColorButtons()
    end

    -- Build on first load
    BuildCustomizeContent()

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                     iNIF Settings Tab                        │
    -- │              (both variants built, toggled OnShow)            │
    -- ╰───────────────────────────────────────────────────────────────╯

    -- iNIF installed variant
    local iNIFInstalledFrame = CreateFrame("Frame", nil, iNIFContent)
    iNIFInstalledFrame:SetAllPoints(iNIFContent)
    iNIFInstalledFrame:Hide()
    do
        y = -10
        _, y = CreateSectionHeader(iNIFInstalledFrame, L["INIFSettingsHeader"], y)

        local iNIFDesc
        iNIFDesc, y = CreateInfoText(iNIFInstalledFrame,
            L["INIFInstalledDesc1"] .. "\n\n" .. L["INIFInstalledDesc2"],
            y, "GameFontHighlight")

        y = y - 10

        local iNIFButton = CreateFrame("Button", nil, iNIFInstalledFrame, "UIPanelButtonTemplate")
        StyleSettingsButton(iNIFButton)
        iNIFButton:SetSize(180, 28)
        iNIFButton:SetPoint("TOPLEFT", iNIFInstalledFrame, "TOPLEFT", 25, y)
        iNIFButton:SetText(L["INIFOpenSettingsButton"])
        iNIFButton:SetScript("OnClick", function()
            local iNIFFrame = _G["iNIFSettingsFrame"]
            if iNIFFrame then
                local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
                iNIFFrame:ClearAllPoints()
                iNIFFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
                settingsFrame:Hide()
                iNIFFrame:Show()
            end
        end)
    end

    -- iNIF promo variant
    local iNIFPromoFrame = CreateFrame("Frame", nil, iNIFContent)
    iNIFPromoFrame:SetAllPoints(iNIFContent)
    iNIFPromoFrame:Hide()
    do
        y = -10
        _, y = CreateSectionHeader(iNIFPromoFrame, L["INIFPromoHeader"], y)

        local iNIFPromo
        iNIFPromo, y = CreateInfoText(iNIFPromoFrame,
            L["INIFPromoDesc"],
            y, "GameFontHighlight")

        y = y - 4

        local iNIFPromoLink
        iNIFPromoLink, y = CreateInfoText(iNIFPromoFrame,
            L["INIFPromoLink"],
            y, "GameFontDisableSmall")
    end

    scrollChildren[6]:SetHeight(400)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      iSP Settings Tab                         │
    -- │              (both variants built, toggled OnShow)             │
    -- ╰───────────────────────────────────────────────────────────────╯

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      iST Settings Tab                         │
    -- ╰───────────────────────────────────────────────────────────────╯
    local iSTInstalledFrame = CreateFrame("Frame", nil, iSTContent)
    iSTInstalledFrame:SetAllPoints(iSTContent)
    iSTInstalledFrame:Hide()
    do
        y = -10
        _, y = CreateSectionHeader(iSTInstalledFrame, L["ISTSettingsHeader"], y)

        local iSTDesc
        iSTDesc, y = CreateInfoText(iSTInstalledFrame,
            L["ISTInstalledDesc"],
            y, "GameFontHighlight")

        y = y - 10

        local iSTButton = CreateFrame("Button", nil, iSTInstalledFrame, "UIPanelButtonTemplate")
        StyleSettingsButton(iSTButton)
        iSTButton:SetSize(180, 28)
        iSTButton:SetPoint("TOPLEFT", iSTInstalledFrame, "TOPLEFT", 25, y)
        iSTButton:SetText(L["ISTOpenSettingsButton"])
        iSTButton:SetScript("OnClick", function()
            local iSTFrame = _G["iSTSettingsFrame"]
            if iSTFrame then
                local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
                iSTFrame:ClearAllPoints()
                iSTFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
                iSTFrame:Show()
                settingsFrame:Hide()
            end
        end)
    end

    local iSTPromoFrame = CreateFrame("Frame", nil, iSTContent)
    iSTPromoFrame:SetAllPoints(iSTContent)
    iSTPromoFrame:Hide()
    do
        y = -10
        _, y = CreateSectionHeader(iSTPromoFrame, L["ISTPromoHeader"], y)

        local iSTPromo
        iSTPromo, y = CreateInfoText(iSTPromoFrame,
            L["ISTPromoDesc"],
            y, "GameFontHighlight")

        y = y - 4

        local iSTPromoLink
        iSTPromoLink, y = CreateInfoText(iSTPromoFrame,
            L["ISTPromoLink"],
            y, "GameFontDisableSmall")
    end

    scrollChildren[7]:SetHeight(400)

    -- Guild tools have the same installed/settings view as the other addons.
    local iRCInstalledFrame = CreateFrame("Frame", nil, iRCContent)
    iRCInstalledFrame:SetAllPoints(iRCContent)
    iRCInstalledFrame:Hide()
    do
        local _, iRCY = CreateSectionHeader(iRCInstalledFrame, L["IRCSettingsHeader"], -10)
        _, iRCY = CreateInfoText(iRCInstalledFrame, L["IRCInstalledDesc"], iRCY, "GameFontHighlight")
        CreateSettingsButton(iRCInstalledFrame, L["IRCOpenSettingsButton"], 180, iRCY - 10, function()
            local open = SlashCmdList and SlashCmdList.IRC
            if type(open) ~= "function" then return end
            settingsFrame:Hide()
            open("settings")
        end)
    end
    local iRCPromoFrame = CreateFrame("Frame", nil, iRCContent)
    iRCPromoFrame:SetAllPoints(iRCContent)
    iRCPromoFrame:Hide()
    do
        local _, iRCY = CreateSectionHeader(iRCPromoFrame, L["IRCSettingsHeader"], -10)
        _, iRCY = CreateInfoText(iRCPromoFrame, L["IRCPromoDesc"], iRCY, "GameFontHighlight")
        CreateInfoText(iRCPromoFrame, L["IRCPromoLink"], iRCY - 4, "GameFontDisableSmall")
    end
    scrollChildren[9]:SetHeight(400)

    -- Platynator integration is only offered when Platynator is active.
    local platynatorOffsetXSlider
    local platynatorOffsetYSlider
    do
        y = -10
        _, y = CreateSectionHeader(platynatorContent, L["PlatynatorSettings"], y)

        _, y = CreateInfoText(platynatorContent, L["PlatynatorSettingsInfo"], y,
            "GameFontHighlight")
        y = y - 8

        local cbPlatynatorIcons
        cbPlatynatorIcons, y = CreateSettingsCheckbox(platynatorContent,
            L["ShowPlatynatorIcons"], L["DescShowPlatynatorIcons"], y,
            "ShowPlatynatorIcons", nil, function(checked)
                iWRSettings.ShowPlatynatorIcons = checked
                iWR:RefreshPlatynatorNameplates()
            end)
        checkboxRefs.ShowPlatynatorIcons = cbPlatynatorIcons

        y = y - 6
        platynatorOffsetXSlider, y = CreateSettingsSlider(platynatorContent,
            "iWRPlatynatorIconOffsetXSlider", L["PlatynatorIconOffsetX"],
            L["DescPlatynatorIconOffsetX"], y, -50, 50, 1,
            iWRSettings.PlatynatorIconOffsetX, function(value)
                iWRSettings.PlatynatorIconOffsetX = value
                iWR:RefreshPlatynatorNameplates()
            end)

        platynatorOffsetYSlider, y = CreateSettingsSlider(platynatorContent,
            "iWRPlatynatorIconOffsetYSlider", L["PlatynatorIconOffsetY"],
            L["DescPlatynatorIconOffsetY"], y, -50, 50, 1,
            iWRSettings.PlatynatorIconOffsetY, function(value)
                iWRSettings.PlatynatorIconOffsetY = value
                iWR:RefreshPlatynatorNameplates()
            end)

        scrollChildren[8]:SetHeight(math.abs(y) + 20)
    end

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       About Tab Content                       │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    -- About Section
    _, y = CreateSectionHeader(aboutContent, L["AboutHeader"], y)

    y = y - 20

    -- Addon icon centered
    local aboutIcon = aboutContent:CreateTexture(nil, "ARTWORK")
    aboutIcon:SetSize(64, 64)
    aboutIcon:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutIcon:SetTexture(iconPath)
    y = y - 70

    -- Addon info centered
    local aboutTitle = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    aboutTitle:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutTitle:SetText(iWR.Colors.iWR .. "iWillRemember|r " .. iWR.Colors.Green .. "v" .. iWR.Version .. "|r")
    y = y - 20

    local aboutAuthor = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAuthor:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutAuthor:SetText(L["CreatedBy"] .. "|cFF00FFFF" .. iWR.Author .. "|r")
    y = y - 16

    local aboutGameVer = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aboutGameVer:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutGameVer:SetText(iWR.GameVersionName or "")
    y = y - 20

    local aboutInfo = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutInfo:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    aboutInfo:SetWidth(500)
    aboutInfo:SetJustifyH("LEFT")
    aboutInfo:SetText(L["AboutMessageInfo"] .. "\n\n" .. L["AboutMessageEarlyDev"])
    local aih = aboutInfo:GetStringHeight()
    if aih < 14 then aih = 14 end
    y = y - aih - 8

    -- Discord Section
    _, y = CreateSectionHeader(aboutContent, L["DiscordHeader"], y)
    y = y - 2

    local discordDesc = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    discordDesc:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    discordDesc:SetText(L["DiscordLinkMessage"])
    y = y - 16

    local discordBox = CreateFrame("EditBox", nil, aboutContent, "InputBoxTemplate")
    iWR:StyleEditBox(discordBox)
    discordBox:SetSize(280, 22)
    discordBox:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    discordBox:SetAutoFocus(false)
    discordBox:SetText(L["DiscordLink"])
    discordBox:SetFontObject(GameFontHighlight)
    discordBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    discordBox:SetScript("OnEditFocusLost", function(self)
        self:HighlightText(0, 0)
        self:SetText(L["DiscordLink"])
    end)
    discordBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    y = y - 30

    -- Translations Section
    _, y = CreateSectionHeader(aboutContent, "|cffff9716" .. L["Translations"] .. "|r", y)
    y = y - 2

    local translatorText = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    translatorText:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    translatorText:SetText("|T" .. iWR.AddonPath .. "Images\\Locale\\ruRU.blp:16|t |cFFFFFF00ZamestoTV|r - " .. L["Russian"])
    y = y - 18

    local aiNote = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aiNote:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    aiNote:SetText("|cFF808080" .. L["AITranslationNote"] .. "|r")
    y = y - 22

    -- Developer Section
    y = y - 4
    _, y = CreateSectionHeader(aboutContent, L["DeveloperHeader"], y)

    local cbDebug
    cbDebug, y = CreateSettingsCheckbox(aboutContent, L["EnableDebugMode"],
        L["DescEnableDebugMode"],
        y, "DebugMode", nil,
        function(checked)
            iWRSettings.DebugMode = checked
            -- Show/hide version info
            for _, f in ipairs(iWR._debugInfoFrames or {}) do
                f:SetShown(checked)
            end
        end)
    checkboxRefs.DebugMode = cbDebug

    -- Version info (shown only when debug mode on)
    iWR._debugInfoFrames = {}

    local versionLabels = {
        {L["GameVersionLabel"], iWR.GameVersion or "N/A"},
        {L["TOCVersionLabel"], iWR.GameTocVersion or "N/A"},
        {L["BuildVersionLabel"], iWR.GameBuild or "N/A"},
        {L["BuildDateLabel"], iWR.GameBuildDate or "N/A"},
    }

    for _, vl in ipairs(versionLabels) do
        local vText = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        vText:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
        vText:SetText(vl[1] .. vl[2])
        vText:SetShown(iWRSettings.DebugMode)
        table.insert(iWR._debugInfoFrames, vText)
        y = y - 16
    end

    scrollChildren[5]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      Show First Tab                           │
    -- ╰───────────────────────────────────────────────────────────────╯
    ShowTab(1)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       OnShow Refresh                          │
    -- ╰───────────────────────────────────────────────────────────────╯
    settingsFrame:HookScript("OnShow", function()
        UpdateBackupInfoDisplay()
        UpdateDatabaseStats()
        iWR:RefreshSharingPanel()

        -- Refresh all checkbox states
        for key, cb in pairs(checkboxRefs) do
            if key == "ShowMinimapButton" then
                cb:SetChecked(not iWRSettings.MinimapButton.hide)
            elseif iWRSettings[key] ~= nil then
                cb:SetChecked(iWRSettings[key])
            end
        end

        -- Update sound warning state
        if cbSoundWarnings then
            cbSoundWarnings:SetChecked(iWRSettings.SoundWarnings)
            if iWRSettings.GroupWarnings then
                cbSoundWarnings:Enable()
                cbSoundWarnings.Text:SetFontObject(GameFontHighlight)
            else
                cbSoundWarnings:Disable()
                cbSoundWarnings.Text:SetFontObject(GameFontDisable)
            end
        end

        -- Update icon previews and row labels on Customize tab
        RefreshLevelColorButtons()
        for typeKey, tex in pairs(iconPreviewTextures) do
            local icon = iWR:GetIcon(typeKey) or iWR.Icons[typeKey]
            if icon then tex:SetTexture(icon) end
        end
        for typeKey, lbl in pairs(iconRowLabels) do
            local typeColor = iWR.Colors[typeKey] or "|cFFFFFFFF"
            lbl:SetText(typeColor .. iWR:GetTypeName(typeKey) .. "|r")
        end

        -- Update label edit boxes on Customize tab
        for key, eb in pairs(labelEditBoxes) do
            eb:SetText(
                iWRSettings.ButtonLabels and iWRSettings.ButtonLabels[key]
                or iWR.Types[key] or ""
            )
        end

        -- Update debug info visibility
        for _, f in ipairs(iWR._debugInfoFrames or {}) do
            f:SetShown(iWRSettings.DebugMode)
        end

        -- Update restore button
        if restoreBtn then
            if iWRDatabaseBackup and next(iWRDatabaseBackup) then
                restoreBtn:Enable()
            else
                restoreBtn:Disable()
            end
        end

        -- Detect addons and toggle installed/promo views
        local iNIFLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iNeedIfYouNeed")
        iNIFInstalledFrame:SetShown(iNIFLoaded)
        iNIFPromoFrame:SetShown(not iNIFLoaded)
        if sidebarButtons[6] then
            sidebarButtons[6].text:SetText(iNIFLoaded and L["TabINIF"] or L["TabINIFPromo"])
        end

        local iSTLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iSealTwist")
        iSTInstalledFrame:SetShown(iSTLoaded)
        iSTPromoFrame:SetShown(not iSTLoaded)
        if sidebarButtons[7] then
            sidebarButtons[7].text:SetText(iSTLoaded and L["TabIST"] or L["TabISTPromo"])
        end

        local iRCLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iRC")
        iRCInstalledFrame:SetShown(iRCLoaded)
        iRCPromoFrame:SetShown(not iRCLoaded)
        if sidebarButtons[9] then
            sidebarButtons[9].text:SetText(iRCLoaded and L["TabIRC"] or L["TabIRCPromo"])
        end

    end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                   Refresh Settings Panel                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    function iWR:RefreshSettingsPanel()
        RefreshLevelColorButtons()
        for key, cb in pairs(checkboxRefs) do
            if key == "ShowMinimapButton" then
                cb:SetChecked(not iWRSettings.MinimapButton.hide)
            elseif iWRSettings[key] ~= nil then
                cb:SetChecked(iWRSettings[key])
            end
        end
        if cbSoundWarnings then
            cbSoundWarnings:SetChecked(iWRSettings.SoundWarnings)
            if iWRSettings.GroupWarnings then
                cbSoundWarnings:Enable()
                cbSoundWarnings.Text:SetFontObject(GameFontHighlight)
            else
                cbSoundWarnings:Disable()
                cbSoundWarnings.Text:SetFontObject(GameFontDisable)
            end
        end
        if platynatorOffsetXSlider then
            platynatorOffsetXSlider:SetValue(iWRSettings.PlatynatorIconOffsetX
                or iWR.SettingsDefault.PlatynatorIconOffsetX)
        end
        if platynatorOffsetYSlider then
            platynatorOffsetYSlider:SetValue(iWRSettings.PlatynatorIconOffsetY
                or iWR.SettingsDefault.PlatynatorIconOffsetY)
        end
    end

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                   Blizzard Settings Stub                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    local stubPanel = CreateFrame("Frame", "iWRSettingsStub", UIParent)
    stubPanel.name = "iWillRemember"

    local stubTitle = stubPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    stubTitle:SetPoint("TOPLEFT", 16, -16)
    stubTitle:SetText(iWR.Colors.iWR .. "iWillRemember|r " .. iWR.Colors.Green .. "v" .. iWR.Version .. "|r")

    local stubDesc = stubPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    stubDesc:SetPoint("TOPLEFT", stubTitle, "BOTTOMLEFT", 0, -10)
    stubDesc:SetText(L["SettingsPanelStubDesc"])

    local stubButton = CreateFrame("Button", nil, stubPanel, "UIPanelButtonTemplate")
    StyleSettingsButton(stubButton)
    stubButton:SetSize(180, 28)
    stubButton:SetPoint("TOPLEFT", stubDesc, "BOTTOMLEFT", 0, -15)
    stubButton:SetText(L["SettingsTitle"])
    stubButton:SetScript("OnClick", function() iWR:SettingsOpen() end)

    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(stubPanel)
    elseif Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(stubPanel, "iWillRemember")
        Settings.RegisterAddOnCategory(category)
    end
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                          Toggle / Open / Close                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

-- Close other addon settings panels when opening ours
local function CloseOtherAddonSettings()
    local iNIFFrame = _G["iNIFSettingsFrame"]
    if iNIFFrame and iNIFFrame:IsShown() then iNIFFrame:Hide() end

    local iSTFrame = _G["iSTSettingsFrame"]
    if iSTFrame and iSTFrame:IsShown() then iSTFrame:Hide() end
end

function iWR:SettingsToggle()
    if iWR.State.InCombat then
        print(L["InCombat"])
        return
    end
    if iWR.SettingsFrame and iWR.SettingsFrame:IsVisible() then
        iWR.SettingsFrame:Hide()
    elseif iWR.SettingsFrame then
        CloseOtherAddonSettings()
        iWR.SettingsFrame:Show()
    end
end

function iWR:SettingsOpen()
    if iWR.State.InCombat then
        print(L["InCombat"])
        return
    end
    if iWR.SettingsFrame then
        CloseOtherAddonSettings()
        iWR.SettingsFrame:Show()
    end
end

function iWR:SettingsClose()
    if iWR.SettingsFrame then
        iWR.SettingsFrame:Hide()
    end
end
