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

local iconPath = iWR.AddonPath .. "Images\\Logo_iWR.blp"

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper Functions                                 │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local function CreateSectionHeader(parent, text, yOffset)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    header:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
    })
    header:SetBackdropColor(0.15, 0.15, 0.2, 0.6)

    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(1)
    accent:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    accent:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    accent:SetColorTexture(1, 0.59, 0.09, 0.4)

    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", header, "LEFT", 8, 0)
    label:SetText(text)

    return header, yOffset - 28
end

local function CreateSettingsCheckbox(parent, label, descText, yOffset, settingKey, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
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

    local nextY = yOffset - 22
    if descText and descText ~= "" then
        local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 48, nextY)
        desc:SetWidth(480)
        desc:SetJustifyH("LEFT")
        desc:SetText(descText)
        local height = desc:GetStringHeight()
        if height < 12 then height = 12 end
        nextY = nextY - height - 6
    end

    return cb, nextY
end

local function CreateSettingsButton(parent, text, width, yOffset, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, 26)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    btn:SetText(text)
    btn:SetScript("OnClick", onClick)
    return btn, yOffset - 34
end

local function CreateSettingsDropdown(parent, label, yOffset, width, initFunc)
    local labelStr = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    labelStr:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset)
    labelStr:SetText(label)

    local dropdown = CreateFrame("Frame", "iWRDropdown_" .. label:gsub("%s", ""), parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset - 16)
    UIDropDownMenu_SetWidth(dropdown, width or 160)
    UIDropDownMenu_Initialize(dropdown, initFunc)

    return dropdown, labelStr, yOffset - 52
end

local function CreateInfoText(parent, text, yOffset, fontObj)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObj or "GameFontHighlight")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset)
    fs:SetWidth(500)
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

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                             Icon Picker Popup                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local iconPickerFrame = nil

local function ShowIconPicker(typeIndex, previewTexture)
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
    popup:SetBackdropColor(0.05, 0.05, 0.1, 0.98)
    popup:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
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
    pTitleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    pTitleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

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
        highlight:SetColorTexture(1, 1, 1, 0.3)

        local border = btn:CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(0.4, 0.4, 0.5, 0.5)
        border:SetDrawLayer("OVERLAY", -1)

        btn:SetScript("OnClick", function()
            if not iWRSettings.CustomIcons then iWRSettings.CustomIcons = {} end
            iWRSettings.CustomIcons[typeIndex] = path
            if previewTexture then
                previewTexture:SetTexture(path)
            end
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
    manualBox:SetSize(gridWidth - 50, 22)
    manualBox:SetPoint("TOPLEFT", popup, "TOPLEFT", margin + 2, inputY)
    manualBox:SetAutoFocus(false)
    manualBox:SetFontObject(GameFontHighlightSmall)
    manualBox:SetMaxLetters(200)

    local manualBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
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
    local settingsFrame = iWR:CreateiWRStyleFrame(UIParent, 750, 520, {"CENTER", UIParent, "CENTER"})
    settingsFrame:Hide()
    settingsFrame:EnableMouse(true)
    settingsFrame:SetMovable(true)
    settingsFrame:SetFrameStrata("HIGH")
    settingsFrame:SetClampedToScreen(true)
    settingsFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    settingsFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
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
    titleBar:SetHeight(31)
    titleBar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    titleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(iWR.Colors.iWR .. "iWillRemember" .. iWR.Colors.Green .. " v" .. iWR.Version)

    local closeButton = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function() iWR:SettingsClose() end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                     Sidebar Navigation                        │
    -- ╰───────────────────────────────────────────────────────────────╯
    local sidebarWidth = 150

    local sidebar = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    sidebar:SetWidth(sidebarWidth)
    sidebar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -35)
    sidebar:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 10, 10)
    sidebar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    sidebar:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    sidebar:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Content Area                            │
    -- ╰───────────────────────────────────────────────────────────────╯
    local contentArea = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 6, 0)
    contentArea:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -10, 10)
    contentArea:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    contentArea:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    contentArea:SetBackdropColor(0.08, 0.08, 0.1, 0.95)

    -- Tab content frames with scroll
    local scrollFrames = {}
    local scrollChildren = {}
    -- Content area is ~574px wide (750 - 10 left - 150 sidebar - 6 gap - 10 right - borders)
    local contentWidth = 550

    local function CreateTabContent()
        local container = CreateFrame("Frame", nil, contentArea)
        container:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 5, -5)
        container:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -5, 5)
        container:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -22, 0)

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

    -- iNIF and iSP tabs (detection deferred to OnShow)
    local iNIFContainer, iNIFContent = CreateTabContent()
    local iSPContainer, iSPContent = CreateTabContent()

    local tabContents = {generalContainer, syncContainer, backupContainer, customizeContainer, aboutContainer, iNIFContainer, iSPContainer}

    local sidebarButtons = {}
    local activeIndex = 1

    local function ShowTab(index)
        activeIndex = index
        for i, content in ipairs(tabContents) do
            content:SetShown(i == index)
        end
        -- Update sidebar button highlights
        for i, btn in ipairs(sidebarButtons) do
            if i == index then
                btn.bg:SetColorTexture(1, 0.59, 0.09, 0.25)
                btn.text:SetFontObject(GameFontHighlight)
            else
                btn.bg:SetColorTexture(0, 0, 0, 0)
                btn.text:SetFontObject(GameFontNormal)
            end
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

    table.insert(sidebarItems, {type = "header", label = L["SidebarHeaderOtherAddons"]})
    table.insert(sidebarItems, {type = "tab", label = L["TabINIFPromo"], index = 6})
    table.insert(sidebarItems, {type = "tab", label = L["TabISPPromo"], index = 7})

    local sidebarY = -6
    for _, item in ipairs(sidebarItems) do
        if item.type == "header" then
            local headerText = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerText:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 12, sidebarY - 2)
            headerText:SetText(item.label)
            sidebarY = sidebarY - 20
        else
            local btn = CreateFrame("Button", nil, sidebar)
            btn:SetSize(sidebarWidth - 12, 26)
            btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, sidebarY)

            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(btn)
            bg:SetColorTexture(0, 0, 0, 0)
            btn.bg = bg

            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", btn, "LEFT", 14, 0)
            text:SetText(item.label)
            btn.text = text

            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints(btn)
            highlight:SetColorTexture(1, 1, 1, 0.08)

            local tabIndex = item.index
            btn:SetScript("OnClick", function()
                ShowTab(tabIndex)
            end)

            sidebarButtons[tabIndex] = btn
            sidebarY = sidebarY - 28
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

    -- Group Log
    local cbGroupLog
    cbGroupLog, y = CreateSettingsCheckbox(generalContent, L["EnableGroupLog"],
        L["DescEnableGroupLog"], y, "GroupLogEnabled")
    checkboxRefs.GroupLogEnabled = cbGroupLog

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
                LDBIcon:Show("iWillRemember_MinimapButton")
            else
                LDBIcon:Hide("iWillRemember_MinimapButton")
            end
        end)
    checkboxRefs.ShowMinimapButton = cbMinimap

    scrollChildren[1]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Sync Tab Content                        │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    -- Sync Settings (full width top section)
    _, y = CreateSectionHeader(syncContent, L["SyncSettings"], y)

    local cbSync
    cbSync, y = CreateSettingsCheckbox(syncContent, L["EnableSync"],
        L["DescEnableSync"], y, "DataSharing")
    checkboxRefs.DataSharing = cbSync

    -- Sync Mode Dropdown
    local syncDropdown, _, syncDropdownY
    syncDropdown, _, y = CreateSettingsDropdown(syncContent, L["SyncModeLabel"], y, 160,
        function(frame, level)
            local info = UIDropDownMenu_CreateInfo()
            info.func = function(self)
                iWRSettings.SyncType = self.value
                UIDropDownMenu_SetSelectedValue(frame, self.value)
                UIDropDownMenu_SetText(frame, self.value == "Whitelist" and L["OnlyWhitelist"] or L["AllFriends"])
            end

            info.text = L["AllFriends"]
            info.value = "Friends"
            info.checked = (iWRSettings.SyncType == "Friends")
            UIDropDownMenu_AddButton(info, level)

            info.text = L["OnlyWhitelist"]
            info.value = "Whitelist"
            info.checked = (iWRSettings.SyncType == "Whitelist")
            UIDropDownMenu_AddButton(info, level)
        end)

    local syncModeText = (iWRSettings.SyncType == "Whitelist") and L["OnlyWhitelist"] or L["AllFriends"]
    UIDropDownMenu_SetText(syncDropdown, syncModeText)

    -- Sync Help
    local syncHelp
    syncHelp, y = CreateInfoText(syncContent, L["HelpSync"], y, "GameFontDisableSmall")

    -- ── Side-by-side: Left = dropdowns, Right = whitelist ──
    local splitY = y - 8
    -- Content width: 750 total - 10 left - 10 right - 150 sidebar - 6 gap - border insets ~ 560
    local halfWidth = 270

    -- LEFT SIDE: Add/Remove dropdowns
    local addFriendLabel = syncContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    addFriendLabel:SetPoint("TOPLEFT", syncContent, "TOPLEFT", 15, splitY)
    addFriendLabel:SetText(L["AddtoWhitelist"])

    local addFriendDropdown = CreateFrame("Frame", "iWRDropdown_AddFriend", syncContent, "UIDropDownMenuTemplate")
    addFriendDropdown:SetPoint("TOPLEFT", addFriendLabel, "BOTTOMLEFT", -20, -2)
    UIDropDownMenu_SetWidth(addFriendDropdown, halfWidth - 50)

    local removeFriendLabel = syncContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    removeFriendLabel:SetPoint("TOPLEFT", addFriendDropdown, "BOTTOMLEFT", 20, -8)
    removeFriendLabel:SetText(L["RemoveFromWhitelist"])

    local removeFriendDropdown = CreateFrame("Frame", "iWRDropdown_RemoveFriend", syncContent, "UIDropDownMenuTemplate")
    removeFriendDropdown:SetPoint("TOPLEFT", removeFriendLabel, "BOTTOMLEFT", -20, -2)
    UIDropDownMenu_SetWidth(removeFriendDropdown, halfWidth - 50)

    -- RIGHT SIDE: Whitelist panel with scrollframe
    local wlPanel = CreateFrame("Frame", nil, syncContent, "BackdropTemplate")
    wlPanel:SetPoint("TOPLEFT", syncContent, "TOP", 5, splitY)
    wlPanel:SetSize(halfWidth, 200)
    wlPanel:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    wlPanel:SetBackdropColor(0.08, 0.08, 0.1, 0.8)
    wlPanel:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.6)

    local wlTitle = wlPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wlTitle:SetPoint("TOPLEFT", wlPanel, "TOPLEFT", 10, -6)
    wlTitle:SetText(L["WhiteListTitle"] .. " (" .. iWR.CurrentRealm .. ")")

    local wlScrollFrame = CreateFrame("ScrollFrame", nil, wlPanel, "UIPanelScrollFrameTemplate")
    wlScrollFrame:SetPoint("TOPLEFT", wlPanel, "TOPLEFT", 8, -22)
    wlScrollFrame:SetPoint("BOTTOMRIGHT", wlPanel, "BOTTOMRIGHT", -28, 6)

    local wlScrollChild = CreateFrame("Frame", nil, wlScrollFrame)
    wlScrollChild:SetWidth(230)
    wlScrollChild:SetHeight(600)
    wlScrollFrame:SetScrollChild(wlScrollChild)

    local whitelistText = wlScrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    whitelistText:SetPoint("TOPLEFT", wlScrollChild, "TOPLEFT", 4, -4)
    whitelistText:SetWidth(220)
    whitelistText:SetJustifyH("LEFT")
    iWR._whitelistText = whitelistText

    -- Mouse wheel on the whitelist panel
    wlPanel:EnableMouseWheel(true)
    wlPanel:SetScript("OnMouseWheel", function(_, delta)
        local current = wlScrollFrame:GetVerticalScroll()
        local maxScroll = wlScrollChild:GetHeight() - wlScrollFrame:GetHeight()
        if maxScroll < 0 then maxScroll = 0 end
        local newScroll = current - (delta * 20)
        if newScroll < 0 then newScroll = 0 end
        if newScroll > maxScroll then newScroll = maxScroll end
        wlScrollFrame:SetVerticalScroll(newScroll)
    end)

    local function UpdateWhitelistDisplay()
        local t = {}
        for _, v in ipairs(iWRSettings.SyncList or {}) do
            if v.realm == iWR.CurrentRealm then
                table.insert(t, "|cFF00FF00\226\128\162|r " .. v.name)
            end
        end
        if #t == 0 then
            whitelistText:SetText(L["NoFriendsWhitelist"])
        else
            whitelistText:SetText(table.concat(t, "\n"))
        end
    end

    UpdateWhitelistDisplay()

    UIDropDownMenu_Initialize(addFriendDropdown, function(frame, level)
        C_FriendList.ShowFriends()
        local currentRealm = GetRealmName()
        local numFriends = C_FriendList.GetNumFriends()
        for i = 1, numFriends do
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            if friendInfo and friendInfo.name then
                local isInWhitelist = false
                for _, entry in ipairs(iWRSettings.SyncList or {}) do
                    if entry.name == friendInfo.name and entry.realm == currentRealm then
                        isInWhitelist = true
                        break
                    end
                end
                if not isInWhitelist then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = friendInfo.name
                    info.value = friendInfo.name
                    info.func = function(self)
                        if not iWRSettings.SyncList then iWRSettings.SyncList = {} end
                        table.insert(iWRSettings.SyncList, {
                            name = self.value,
                            realm = currentRealm,
                            type = "wow",
                        })
                        UpdateWhitelistDisplay()
                        UIDropDownMenu_SetText(frame, "")
                        CloseDropDownMenus()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end)

    UIDropDownMenu_Initialize(removeFriendDropdown, function(frame, level)
        local currentRealm = GetRealmName()
        for _, entry in ipairs(iWRSettings.SyncList or {}) do
            if entry.realm == currentRealm then
                local info = UIDropDownMenu_CreateInfo()
                info.text = entry.name
                info.value = entry.name
                info.func = function(self)
                    for i, e in ipairs(iWRSettings.SyncList or {}) do
                        if e.name == self.value and e.realm == currentRealm then
                            table.remove(iWRSettings.SyncList, i)
                            break
                        end
                    end
                    UpdateWhitelistDisplay()
                    UIDropDownMenu_SetText(frame, "")
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Set sync tab scroll height (splitY is the top of the side-by-side area, plus ~210 for the panels)
    scrollChildren[2]:SetHeight(math.abs(splitY) + 220)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      Backup Tab Content                       │
    -- ╰───────────────────────────────────────────────────────────────╯
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
            iWR.Colors.iWR .. "Database Entries:|r " .. dbCount ..
            "\n" .. iWR.Colors.iWR .. "Backup Entries:|r " .. backupCount
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
    y = -10

    -- Customize info text (local/visual only)
    local customizeInfo
    customizeInfo, y = CreateInfoText(customizeContent, L["DescCustomizeInfo"], y, "GameFontDisableSmall")

    -- Custom Icons Section
    _, y = CreateSectionHeader(customizeContent, L["CustomIconsSettings"] or (iWR.Colors.iWR .. "Custom Icons"), y)

    local iconDesc
    iconDesc, y = CreateInfoText(customizeContent,
        L["DescCustomIcons"] or "|cFF808080Choose custom icons for each rating. Changes apply to buttons, tooltips, and database displays.|r",
        y, "GameFontDisableSmall")

    local iconPreviewTextures = {}
    local iconRowLabels = {}

    local iconTypes = {
        {key = 5,  label = iWR:GetTypeName(5)},
        {key = 3,  label = iWR:GetTypeName(3)},
        {key = -3, label = iWR:GetTypeName(-3)},
        {key = -5, label = iWR:GetTypeName(-5)},
    }

    for _, it in ipairs(iconTypes) do
        y = y - 4

        -- Row container
        local rowFrame = CreateFrame("Frame", nil, customizeContent)
        rowFrame:SetSize(500, 36)
        rowFrame:SetPoint("TOPLEFT", customizeContent, "TOPLEFT", 20, y)

        -- Icon preview
        local preview = rowFrame:CreateTexture(nil, "ARTWORK")
        preview:SetSize(32, 32)
        preview:SetPoint("LEFT", rowFrame, "LEFT", 0, 0)
        local currentIcon = iWR:GetIcon(it.key) or iWR.Icons[it.key]
        if currentIcon then
            preview:SetTexture(currentIcon)
        end
        iconPreviewTextures[it.key] = preview

        -- Label (colored by rating type)
        local typeColor = iWR.Colors[it.key] or "|cFFFFFFFF"
        local label = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", preview, "RIGHT", 10, 0)
        label:SetWidth(100)
        label:SetJustifyH("LEFT")
        label:SetText(typeColor .. it.label .. "|r")
        iconRowLabels[it.key] = label

        -- Change button
        local changeBtn = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
        changeBtn:SetSize(70, 24)
        changeBtn:SetPoint("LEFT", label, "RIGHT", 10, 0)
        changeBtn:SetText(L["ChangeIcon"] or "Change")
        changeBtn:SetScript("OnClick", function()
            ShowIconPicker(it.key, preview)
        end)

        -- Reset button
        local resetIconBtn = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
        resetIconBtn:SetSize(60, 24)
        resetIconBtn:SetPoint("LEFT", changeBtn, "RIGHT", 6, 0)
        resetIconBtn:SetText(L["ResetIcon"] or "Reset")
        resetIconBtn:SetScript("OnClick", function()
            if iWRSettings.CustomIcons then
                iWRSettings.CustomIcons[it.key] = nil
            end
            local defaultIcon = iWR.Icons[it.key]
            if defaultIcon then
                preview:SetTexture(defaultIcon)
            end
        end)

        y = y - 38
    end

    -- Button Labels Section (moved from General tab)
    y = y - 8
    _, y = CreateSectionHeader(customizeContent, L["ButtonLabelsSettings"], y)

    local labelDesc
    labelDesc, y = CreateInfoText(customizeContent, L["DescButtonLabels"], y, "GameFontDisableSmall")

    local labelEditBoxes = {}

    local labelTypes = {
        {key = 5,  label = iWR.Colors[5] .. "Respected:|r"},
        {key = 3,  label = iWR.Colors[3] .. "Liked:|r"},
        {key = -3, label = iWR.Colors[-3] .. "Disliked:|r"},
        {key = -5, label = iWR.Colors[-5] .. "Hated:|r"},
    }

    for _, lt in ipairs(labelTypes) do
        local eb, _, newY = CreateSettingsEditBox(customizeContent, lt.label, y, 150,
            function() return iWRSettings.ButtonLabels and iWRSettings.ButtonLabels[lt.key] or iWR.Types[lt.key] or "" end,
            function(text)
                if not iWRSettings.ButtonLabels then iWRSettings.ButtonLabels = {} end
                if text == "" then text = iWR.SettingsDefault.ButtonLabels[lt.key] end
                iWRSettings.ButtonLabels[lt.key] = text
            end)
        labelEditBoxes[lt.key] = eb
        y = newY
    end

    y = y - 4
    local resetLabelsBtn
    resetLabelsBtn, y = CreateSettingsButton(customizeContent, L["ResetLabels"], 200, y,
        function()
            for _, lt in ipairs(labelTypes) do
                iWRSettings.ButtonLabels[lt.key] = iWR.SettingsDefault.ButtonLabels[lt.key]
                if labelEditBoxes[lt.key] then
                    labelEditBoxes[lt.key]:SetText(iWR.SettingsDefault.ButtonLabels[lt.key])
                end
            end
        end)

    scrollChildren[4]:SetHeight(math.abs(y) + 20)

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

    -- iSP installed variant
    local iSPInstalledFrame = CreateFrame("Frame", nil, iSPContent)
    iSPInstalledFrame:SetAllPoints(iSPContent)
    iSPInstalledFrame:Hide()
    do
        y = -10
        _, y = CreateSectionHeader(iSPInstalledFrame, L["ISPSettingsHeader"], y)

        local iSPDesc
        iSPDesc, y = CreateInfoText(iSPInstalledFrame,
            L["ISPInstalledDesc1"] .. "\n\n" .. L["ISPInstalledDesc2"],
            y, "GameFontHighlight")

        y = y - 10

        local iSPButton = CreateFrame("Button", nil, iSPInstalledFrame, "UIPanelButtonTemplate")
        iSPButton:SetSize(180, 28)
        iSPButton:SetPoint("TOPLEFT", iSPInstalledFrame, "TOPLEFT", 25, y)
        iSPButton:SetText(L["ISPOpenSettingsButton"])
        iSPButton:SetScript("OnClick", function()
            local iSPFrame = _G["iSPSettingsFrame"]
            if iSPFrame then
                local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
                iSPFrame:ClearAllPoints()
                iSPFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
                settingsFrame:Hide()
                iSPFrame:Show()
            end
        end)
    end

    -- iSP promo variant
    local iSPPromoFrame = CreateFrame("Frame", nil, iSPContent)
    iSPPromoFrame:SetAllPoints(iSPContent)
    iSPPromoFrame:Hide()
    do
        y = -10
        _, y = CreateSectionHeader(iSPPromoFrame, L["ISPPromoHeader"], y)

        local iSPPromo
        iSPPromo, y = CreateInfoText(iSPPromoFrame,
            L["ISPPromoDesc"],
            y, "GameFontHighlight")

        y = y - 4

        local iSPPromoLink
        iSPPromoLink, y = CreateInfoText(iSPPromoFrame,
            L["ISPPromoLink"],
            y, "GameFontDisableSmall")
    end

    scrollChildren[7]:SetHeight(400)

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
        UpdateWhitelistDisplay()

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
        for typeKey, tex in pairs(iconPreviewTextures) do
            local icon = iWR:GetIcon(typeKey) or iWR.Icons[typeKey]
            if icon then tex:SetTexture(icon) end
        end
        for typeKey, lbl in pairs(iconRowLabels) do
            local typeColor = iWR.Colors[typeKey] or "|cFFFFFFFF"
            lbl:SetText(typeColor .. iWR:GetTypeName(typeKey) .. "|r")
        end

        -- Update label edit boxes on Customize tab
        for _, lt in ipairs(labelTypes) do
            if labelEditBoxes[lt.key] then
                labelEditBoxes[lt.key]:SetText(
                    iWRSettings.ButtonLabels and iWRSettings.ButtonLabels[lt.key]
                    or iWR.Types[lt.key] or ""
                )
            end
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

        local iSPLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iSoundPlayer")
        iSPInstalledFrame:SetShown(iSPLoaded)
        iSPPromoFrame:SetShown(not iSPLoaded)
        if sidebarButtons[7] then
            sidebarButtons[7].text:SetText(iSPLoaded and L["TabISP"] or L["TabISPPromo"])
        end

    end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                   Refresh Settings Panel                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    function iWR:RefreshSettingsPanel()
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

    local iSPFrame = _G["iSPSettingsFrame"]
    if iSPFrame and iSPFrame:IsShown() then iSPFrame:Hide() end
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
