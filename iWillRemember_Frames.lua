-- ═══════════════════════════════════════════════════════════════════════
-- ██╗ ██╗    ██╗ ██████╗     ███████╗ ██████╗   █████╗  ███╗   ███╗ ███████╗ ███████╗
-- ╚═╝ ██║    ██║ ██╔══██╗    ██╔════╝ ██╔══██╗ ██╔══██╗ ████╗ ████║ ██╔════╝ ██╔════╝
-- ██║ ██║ █╗ ██║ ██████╔╝    █████╗   ██████╔╝ ███████║ ██╔████╔██║ █████╗   ███████╗
-- ██║ ██║███╗██║ ██  ██╔     ██╔══╝   ██  ██╔  ██╔══██║ ██║╚██╔╝██║ ██╔══╝   ╚════██║
-- ██║ ╚███╔███╔╝ ██   ██╗    ██║      ██   ██  ██║  ██║ ██║ ╚═╝ ██║ ███████╗ ███████║
-- ╚═╝  ╚══╝╚══╝  ╚══════╝    ╚═╝      ╚═════╝  ╚═╝  ╚═╝ ╚═╝     ╚═╝ ╚══════╝ ╚══════╝
-- ═══════════════════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                      Frames                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Main Panel
iWRPanel = iWR:CreateiWRStyleFrame(UIParent, 350, 260, {"CENTER", UIParent, "CENTER"})
iWRPanel:Hide()
iWRPanel:EnableMouse(true)
iWRPanel:SetMovable(true)
iWRPanel:SetFrameStrata("MEDIUM")
iWRPanel:SetClampedToScreen(true)
iWRPanel:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
iWRPanel:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)

-- Shadow
local shadow = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
shadow:SetPoint("TOPLEFT", iWRPanel, -1, 1)
shadow:SetPoint("BOTTOMRIGHT", iWRPanel, 1, -1)
shadow:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 5,
})
shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

-- Drag
iWRPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
iWRPanel:RegisterForDrag("LeftButton", "RightButton")

-- ╭──────────────────────────────────╮
-- │             Title Bar            │
-- ╰──────────────────────────────────╯
local titleBar = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
titleBar:SetHeight(31)
titleBar:SetPoint("TOPLEFT", iWRPanel, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", iWRPanel, "TOPRIGHT", 0, 0)
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

local closeButton = CreateFrame("Button", nil, iWRPanel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", iWRPanel, "TOPRIGHT", 0, 0)
closeButton:SetScript("OnClick", function() iWR:MenuClose() end)

-- ╭──────────────────────────────────╮
-- │          Content Area            │
-- ╰──────────────────────────────────╯
local menuContent = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
menuContent:SetPoint("TOPLEFT", iWRPanel, "TOPLEFT", 10, -35)
menuContent:SetPoint("BOTTOMRIGHT", iWRPanel, "BOTTOMRIGHT", -10, 10)
menuContent:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
menuContent:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
menuContent:SetBackdropColor(0.08, 0.08, 0.1, 0.95)

-- ╭───────────────────────────────────────────╮
-- │          Player Name Input                │
-- ╰───────────────────────────────────────────╯
local playerNameTitle = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
playerNameTitle:SetPoint("TOP", menuContent, "TOP", 0, -10)
playerNameTitle:SetText("|cFFCCCCCCPlayer Name|r")

iWRNameInput = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
iWRNameInput:SetSize(200, 25)
iWRNameInput:SetPoint("TOP", playerNameTitle, "BOTTOM", 0, -3)
iWRNameInput:SetMaxLetters(40)
iWRNameInput:SetAutoFocus(false)
iWRNameInput:SetTextColor(1, 1, 1, 1)
iWRNameInput:SetText(L["DefaultNameInput"])
iWRNameInput:SetFontObject(GameFontHighlight)
iWRNameInput:SetJustifyH("CENTER")

iWRNameInput:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        local text = self:GetText()
        local cleanedText = StripColorCodes(text)
        if text ~= cleanedText then
            self:SetText(cleanedText)
        end
    end
end)

-- ╭───────────────────────────────────────────╮
-- │          Note Input                        │
-- ╰───────────────────────────────────────────╯
local noteTitle = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
noteTitle:SetPoint("TOP", iWRNameInput, "BOTTOM", 0, -8)
noteTitle:SetText("|cFFCCCCCCNote|r")

iWRNoteInput = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
iWRNoteInput:SetSize(280, 25)
iWRNoteInput:SetPoint("TOP", noteTitle, "BOTTOM", 0, -3)
iWRNoteInput:SetMultiLine(false)
iWRNoteInput:SetMaxLetters(99)
iWRNoteInput:SetAutoFocus(false)
iWRNoteInput:SetTextColor(1, 1, 1, 1)
iWRNoteInput:SetText(L["DefaultNoteInput"])
iWRNoteInput:SetFontObject(GameFontHighlight)

-- ╭────────────────────╮
-- │     Help Icon      │
-- ╰────────────────────╯
local helpIcon = CreateFrame("Button", nil, menuContent)
helpIcon:SetSize(20, 20)
helpIcon:SetPoint("TOPRIGHT", menuContent, "TOPRIGHT", -8, -8)
helpIcon:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")

helpIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("How do I use iWillRemember", 1, 0.85, 0.1)
    GameTooltip:AddLine(L["HelpUse"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpSync"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpClear"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpSettings"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpDiscord"], 1, 0.82, 0, true)
    GameTooltip:Show()
end)
helpIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
helpIcon:SetScript("OnClick", function()
    if not iWR:VerifyInputName(iWRNameInput:GetText()) then
        iWRNoteInput:SetText("https://discord.gg/8nnt25aw8B")
        print(L["DiscordCopiedToNote"])
    end
end)

-- ╭─────────────────────────╮
-- │     Focus Handling      │
-- ╰─────────────────────────╯
local clickAwayFrame = CreateFrame("Frame", nil, UIParent)
clickAwayFrame:SetAllPoints(UIParent)
clickAwayFrame:EnableMouse(true)
clickAwayFrame:SetFrameStrata("BACKGROUND")
clickAwayFrame:Hide()

clickAwayFrame:SetScript("OnMouseDown", function()
    iWRNameInput:ClearFocus()
    iWRNoteInput:ClearFocus()
    clickAwayFrame:Hide()
end)

function iWR:OnFocusGained()
    clickAwayFrame:Show()
end

iWRNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNameInput"] then self:SetText("") end
    iWR:OnFocusGained()
end)
iWRNoteInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNoteInput"] then self:SetText("") end
    iWR:OnFocusGained()
end)
iWRNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(L["DefaultNameInput"]) end
end)
iWRNoteInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then self:SetText(L["DefaultNoteInput"]) end
end)

-- ╭──────────────────────────────────────────╮
-- │      Relation Level Slider               │
-- ╰──────────────────────────────────────────╯

-- Separator line below note input
local sliderSeparator = menuContent:CreateTexture(nil, "ARTWORK")
sliderSeparator:SetSize(280, 1)
sliderSeparator:SetPoint("TOP", iWRNoteInput, "BOTTOM", 0, -10)
sliderSeparator:SetColorTexture(0.4, 0.4, 0.5, 0.4)

-- "Relation Level" section header
local sliderHeader = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sliderHeader:SetPoint("TOP", sliderSeparator, "BOTTOM", 0, -4)
sliderHeader:SetText("|cFFCCCCCCRelation Level|r")

-- Type icon (left side, shows current relation level icon)
local sliderIcon = menuContent:CreateTexture(nil, "ARTWORK")
sliderIcon:SetSize(30, 30)
sliderIcon:SetPoint("LEFT", menuContent, "LEFT", 10, -52)
sliderIcon:SetTexture(iWR:GetIcon(0))

-- Custom slider track
local SLIDER_WIDTH = 230
local SLIDER_HEIGHT = 12
local SLIDER_Y_OFFSET = -6

local sliderTrack = CreateFrame("Frame", nil, menuContent, "BackdropTemplate")
sliderTrack:SetSize(SLIDER_WIDTH, SLIDER_HEIGHT)
sliderTrack:SetPoint("TOP", sliderHeader, "BOTTOM", 8, SLIDER_Y_OFFSET)
sliderTrack:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
})
sliderTrack:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
sliderTrack:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

-- Colored fill bar (fills from center outward based on value)
local sliderFill = sliderTrack:CreateTexture(nil, "ARTWORK")
sliderFill:SetHeight(SLIDER_HEIGHT - 2)
sliderFill:SetPoint("TOP", sliderTrack, "TOP", 0, -1)
sliderFill:SetTexture("Interface\\Buttons\\WHITE8x8")

-- Tick marks at relation level boundaries (dynamic)
local centerX = SLIDER_WIDTH / 2
local stepWidth = SLIDER_WIDTH / 20 -- 20 steps from -10 to +10
local sliderTicks = {}

local function RebuildSliderTicks()
    -- Hide existing ticks
    for _, tick in ipairs(sliderTicks) do
        tick:Hide()
    end
    wipe(sliderTicks)

    -- Get active level keys from settings
    local goodLevels = (iWRSettings and iWRSettings.GoodLevels) or iWR.SettingsDefault.GoodLevels
    local badLevels  = (iWRSettings and iWRSettings.BadLevels)  or iWR.SettingsDefault.BadLevels
    local posKeys, negKeys = iWR.GetLevelKeys(goodLevels, badLevels)

    -- Create ticks at each level key position
    local tickPositions = {}
    for _, key in ipairs(posKeys) do tickPositions[#tickPositions + 1] = key end
    for _, key in ipairs(negKeys) do tickPositions[#tickPositions + 1] = key end

    for _, value in ipairs(tickPositions) do
        local tick = sliderTrack:CreateTexture(nil, "OVERLAY")
        tick:SetSize(1, SLIDER_HEIGHT)
        tick:SetPoint("CENTER", sliderTrack, "LEFT", centerX + (value * stepWidth), 0)
        tick:SetColorTexture(0.5, 0.5, 0.5, 0.6)
        sliderTicks[#sliderTicks + 1] = tick
    end
end

RebuildSliderTicks()
iWR.RebuildSliderTicks = RebuildSliderTicks

-- Thumb (draggable knob)
local sliderThumb = CreateFrame("Frame", nil, sliderTrack)
sliderThumb:SetSize(14, 18)
sliderThumb:SetPoint("CENTER", sliderTrack, "LEFT", centerX, 0)

local thumbTex = sliderThumb:CreateTexture(nil, "OVERLAY")
thumbTex:SetAllPoints()
thumbTex:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

-- Min/Max labels
local sliderLowLabel = menuContent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
sliderLowLabel:SetPoint("TOPLEFT", sliderTrack, "BOTTOMLEFT", 0, -2)
sliderLowLabel:SetText("|cFF999999-10|r")

local sliderHighLabel = menuContent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
sliderHighLabel:SetPoint("TOPRIGHT", sliderTrack, "BOTTOMRIGHT", 0, -2)
sliderHighLabel:SetText("|cFF999999+10|r")

-- Value label (centered under slider, shows "±N — TypeName")
local sliderValueText = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sliderValueText:SetPoint("TOP", sliderTrack, "BOTTOM", 0, -12)
sliderValueText:SetText(iWR.Colors.Default .. "0 — Clear")

-- Current slider value storage
local currentSliderValue = 0
local UpdateSimpleHighlight -- forward declaration

-- Update display: icon, fill bar, thumb position, label
local function UpdateSliderDisplay(value)
    value = math.floor(value + 0.5)
    if value < -10 then value = -10 end
    if value > 10 then value = 10 end
    currentSliderValue = value

    local typeName = iWR:GetTypeName(value)
    local typeColor = iWR.Colors[value] or iWR.Colors.Default

    -- Update icon
    sliderIcon:SetTexture(iWR:GetIcon(value))

    -- Update value label
    if value == 0 then
        sliderValueText:SetText(iWR.Colors.Default .. "0 — " .. typeName)
    else
        local sign = value > 0 and "+" or ""
        sliderValueText:SetText(typeColor .. sign .. value .. " — " .. typeName)
    end

    -- Update thumb position
    local thumbX = centerX + (value * stepWidth)
    sliderThumb:ClearAllPoints()
    sliderThumb:SetPoint("CENTER", sliderTrack, "LEFT", thumbX, 0)

    -- Update fill bar (from center to thumb)
    local r, g, b = 0.5, 0.8, 0.3 -- default green
    if value < 0 then
        if value <= -6 then
            r, g, b = 1.0, 0.13, 0.13  -- Hated red
        else
            r, g, b = 0.99, 0.44, 0.19 -- Disliked orange
        end
    elseif value == 10 then
        r, g, b = 0.30, 0.65, 1.0      -- Superior blue
    elseif value > 0 then
        r, g, b = 0.50, 0.96, 0.32     -- Liked/Respected green
    end

    if value == 0 then
        sliderFill:Hide()
    else
        sliderFill:Show()
        sliderFill:SetVertexColor(r, g, b, 0.7)
        sliderFill:ClearAllPoints()
        sliderFill:SetHeight(SLIDER_HEIGHT - 2)
        if value > 0 then
            sliderFill:SetPoint("LEFT", sliderTrack, "LEFT", centerX + 1, 0)
            sliderFill:SetWidth(value * stepWidth)
        else
            local fillWidth = math.abs(value) * stepWidth
            sliderFill:SetPoint("RIGHT", sliderTrack, "LEFT", centerX - 1, 0)
            sliderFill:SetWidth(fillWidth)
        end
    end
end

-- Expose so MenuOpen can set slider value from outside
function iWR:SetSliderValue(value)
    UpdateSliderDisplay(value)
    UpdateSimpleHighlight(value)
end

-- Click on track to set value
sliderTrack:EnableMouse(true)
sliderTrack:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        local x = select(1, GetCursorPosition()) / self:GetEffectiveScale()
        local left = self:GetLeft()
        local fraction = (x - left) / SLIDER_WIDTH
        local value = math.floor((-10 + fraction * 20) + 0.5)
        UpdateSliderDisplay(value)
    end
end)

-- Drag on thumb
sliderThumb:EnableMouse(true)
sliderThumb:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self.dragging = true
    end
end)

sliderThumb:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self.dragging = false
    end
end)

-- Global OnUpdate for drag handling
sliderTrack:SetScript("OnUpdate", function(self)
    if sliderThumb.dragging then
        local x = select(1, GetCursorPosition()) / self:GetEffectiveScale()
        local left = self:GetLeft()
        local fraction = (x - left) / SLIDER_WIDTH
        local value = math.floor((-10 + fraction * 20) + 0.5)
        if value < -10 then value = -10 end
        if value > 10 then value = 10 end
        UpdateSliderDisplay(value)
    end
end)

-- Scroll wheel on slider
sliderTrack:SetScript("OnMouseWheel", function(self, delta)
    local newValue = currentSliderValue + delta
    if newValue < -10 then newValue = -10 end
    if newValue > 10 then newValue = 10 end
    UpdateSliderDisplay(newValue)
end)
sliderTrack:EnableMouseWheel(true)

-- ╭──────────────────────────────────────────╮
-- │      Save Note Button                     │
-- ╰──────────────────────────────────────────╯
local saveNoteButton = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
saveNoteButton:SetSize(100, 24)
saveNoteButton:SetPoint("TOP", sliderValueText, "BOTTOM", -52, -6)
saveNoteButton:SetText(L["SaveNote"] or "Save Note")
saveNoteButton:SetScript("OnClick", function()
    if currentSliderValue == 0 then
        iWR:ClearNote(iWRNameInput:GetText())
    else
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), currentSliderValue)
    end
end)

local clearNoteButton = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
clearNoteButton:SetSize(100, 24)
clearNoteButton:SetPoint("TOP", sliderValueText, "BOTTOM", 52, -6)
clearNoteButton:SetText("Clear")
clearNoteButton:SetScript("OnClick", function()
    iWR:ClearNote(iWRNameInput:GetText())
end)

-- ╭──────────────────────────────────────────╮
-- │      Simple Menu (button mode)           │
-- ╰──────────────────────────────────────────╯
local simpleContainer = CreateFrame("Frame", nil, menuContent)
simpleContainer:SetPoint("TOP", iWRNoteInput, "BOTTOM", 0, -10)
simpleContainer:SetSize(300, 75)
simpleContainer:Hide()

local simpleButtons = {}

-- Build simple menu with classic fixed buttons: Hated, Disliked, Clear, Liked, Respected
local function BuildSimpleMenu()
    -- Hide and release existing buttons
    for _, btn in ipairs(simpleButtons) do
        if btn.label then btn.label:Hide() end
        btn:Hide()
    end
    wipe(simpleButtons)

    -- Fixed classic button order: Hated(-6), Disliked(-1), Clear(0), Liked(+1), Respected(+6)
    local btnValues = {-6, -1, 0, 1, 6}

    local totalButtons = #btnValues

    -- Dynamic sizing based on button count
    local btnSize, iconSize, spacing, labelFont
    if totalButtons <= 7 then
        btnSize  = 53
        iconSize = 45
        spacing  = 60
        labelFont = "GameFontNormalSmall"
    elseif totalButtons <= 13 then
        btnSize  = 42
        iconSize = 34
        spacing  = 48
        labelFont = "GameFontNormalSmall"
    else
        btnSize  = 34
        iconSize = 26
        spacing  = 40
        labelFont = "GameFontNormalTiny"
    end

    -- Calculate grid layout
    local containerWidth = 300
    local maxPerRow = math.floor(containerWidth / spacing)
    if maxPerRow < 1 then maxPerRow = 1 end
    local rows = math.ceil(totalButtons / maxPerRow)
    local rowHeight = btnSize + 18  -- button + label + gap
    local containerHeight = rows * rowHeight + 4

    simpleContainer:SetSize(containerWidth, containerHeight)

    -- Create buttons in grid
    for idx, value in ipairs(btnValues) do
        local row = math.floor((idx - 1) / maxPerRow)
        local col = (idx - 1) % maxPerRow
        local buttonsInThisRow = math.min(maxPerRow, totalButtons - row * maxPerRow)

        -- Center each row
        local rowWidth = buttonsInThisRow * spacing
        local rowStartX = -rowWidth / 2 + spacing / 2
        local xOffset = rowStartX + col * spacing
        local yOffset = -(row * rowHeight) - 2

        local btn = CreateFrame("Button", nil, simpleContainer, "UIPanelButtonTemplate")
        btn:SetSize(btnSize, btnSize)
        btn:SetPoint("TOP", simpleContainer, "TOP", xOffset, yOffset)
        btn:SetText("")

        btn:SetScript("OnClick", function()
            if value == 0 then
                iWR:ClearNote(iWRNameInput:GetText())
            else
                iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), value)
            end
        end)

        -- Icon texture
        local iconTex = btn:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(iconSize, iconSize)
        iconTex:SetPoint("CENTER", btn, "CENTER", 0, 0)
        iconTex:SetTexture(iWR:GetIcon(value))
        btn.iconTexture = iconTex

        -- Label under button (numeric for values, "Clear" for 0)
        local btnLabel = simpleContainer:CreateFontString(nil, "OVERLAY", labelFont)
        btnLabel:SetPoint("TOP", btn, "BOTTOM", 0, -2)
        btnLabel:SetWidth(spacing)
        btnLabel:SetWordWrap(false)

        local labelText
        if value == 0 then
            labelText = iWR:GetTypeName(0) ~= "" and iWR:GetTypeName(0) or "Clear"
        elseif value > 0 then
            labelText = "+" .. value
        else
            labelText = tostring(value)
        end
        btnLabel:SetText(labelText)
        btn.label = btnLabel

        -- Tooltip showing category name + value
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            local typeName = iWR:GetTypeName(value)
            local color = iWR.Colors[value] or iWR.Colors.Default
            if value == 0 then
                GameTooltip:SetText(color .. typeName .. "|r")
            else
                local sign = value > 0 and "+" or ""
                GameTooltip:SetText(color .. typeName .. " (" .. sign .. value .. ")|r")
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Highlight texture for active state
        local activeBg = btn:CreateTexture(nil, "BACKGROUND")
        activeBg:SetAllPoints()
        activeBg:SetColorTexture(1, 0.59, 0.09, 0.3)
        activeBg:Hide()
        btn.activeBg = activeBg
        btn.typeValue = value

        simpleButtons[#simpleButtons + 1] = btn
    end
end

-- Highlight the matching simple button for current value (exact match)
UpdateSimpleHighlight = function(value)
    for _, btn in ipairs(simpleButtons) do
        if btn.typeValue == value and value ~= 0 then
            btn.activeBg:Show()
        else
            btn.activeBg:Hide()
        end
    end
end

-- Open Database button (top-left of content area)
local openDatabaseButton = CreateFrame("Button", nil, menuContent)
openDatabaseButton:SetSize(26, 26)
openDatabaseButton:SetPoint("TOPLEFT", menuContent, "TOPLEFT", 6, -6)
openDatabaseButton:SetScript("OnClick", function()
    iWR:DatabaseToggle()
    iWR:PopulateDatabase()
    iWR:MenuClose()
end)

local iconTextureDB = openDatabaseButton:CreateTexture(nil, "ARTWORK")
iconTextureDB:SetSize(22, 22)
iconTextureDB:SetPoint("CENTER", openDatabaseButton, "CENTER", 0, 0)
iconTextureDB:SetTexture(iWR.Icons.Database)

openDatabaseButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Open Database", 1, 0.82, 0)
    GameTooltip:Show()
end)
openDatabaseButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Highlight on hover for DB button
local dbHighlight = openDatabaseButton:CreateTexture(nil, "HIGHLIGHT")
dbHighlight:SetAllPoints()
dbHighlight:SetColorTexture(1, 1, 1, 0.15)

-- Toggle simple/slider mode and reset on panel show
local function UpdateMenuMode()
    if iWRSettings and iWRSettings.SimpleMenu then
        sliderSeparator:Hide()
        sliderHeader:Hide()
        sliderIcon:Hide()
        sliderTrack:Hide()
        sliderThumb:Hide()
        sliderLowLabel:Hide()
        sliderHighLabel:Hide()
        sliderValueText:Hide()
        saveNoteButton:Hide()
        clearNoteButton:Hide()

        -- Build dynamic buttons and resize panel
        BuildSimpleMenu()
        simpleContainer:Show()

        -- Resize panel height: base 185 + simple menu height
        local menuHeight = simpleContainer:GetHeight()
        iWRPanel:SetHeight(185 + menuHeight)
    else
        sliderSeparator:Show()
        sliderHeader:Show()
        sliderIcon:Show()
        sliderTrack:Show()
        sliderThumb:Show()
        sliderLowLabel:Show()
        sliderHighLabel:Show()
        sliderValueText:Show()
        saveNoteButton:Show()
        clearNoteButton:Show()
        simpleContainer:Hide()

        -- Restore default panel height
        iWRPanel:SetHeight(260)
    end
end

-- Expose for options panel to trigger rebuild when level counts change
iWR.UpdateMenuMode = UpdateMenuMode

iWRPanel:HookScript("OnShow", function()
    UpdateSliderDisplay(0)
    UpdateMenuMode()
end)

-- Create Tab
function iWR:CreateTab(panel, index, name, onClick)
    -- Create the tab
    local tab = CreateFrame("Button", "$parentTab" .. index, panel, "OptionsFrameTabButtonTemplate")
    tab:SetText(name)
    tab:SetID(index)

    -- Adjust the positioning of the tabs to the top of the panel
    if index == 1 then
        tab:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -20)
    else
        tab:SetPoint("LEFT", "$parentTab" .. (index - 1), "RIGHT", -5, 0)
    end

    -- Adjust the tab size
    tab:SetScale(1.3)
    tab:SetHeight(25)

    -- Ensure the font string (text) follows the tab movement
    local fontString = tab:GetFontString()
    if fontString then
        fontString:ClearAllPoints()
        fontString:SetPoint("CENTER", tab, "CENTER")
    end
    tab:SetScript("OnClick", function()
        PanelTemplates_SetTab(panel, index)
        if onClick then
        onClick()
        fontString:SetPoint("CENTER", tab, "CENTER", 0, -2)
        end
    end)
        PanelTemplates_TabResize(tab, 0)
    return tab
end

-- Create a new frame to display the database
iWRDatabaseFrame = iWR:CreateiWRStyleFrame(UIParent, 800, 450, {"CENTER", UIParent, "CENTER"})
iWRDatabaseFrame:Hide()
iWRDatabaseFrame:EnableMouse(true)
iWRDatabaseFrame:SetMovable(true)
iWRDatabaseFrame:SetFrameStrata("HIGH")
iWRDatabaseFrame:SetClampedToScreen(true)
iWRDatabaseFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
iWRDatabaseFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)

-- Add a shadow effect
local dbShadow = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbShadow:SetPoint("TOPLEFT", iWRDatabaseFrame, -1, 1)
dbShadow:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, 1, -1)
dbShadow:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 5,
})
dbShadow:SetBackdropBorderColor(0, 0, 0, 0.8)

-- Drag and Drop functionality
iWRDatabaseFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
iWRDatabaseFrame:RegisterForDrag("LeftButton", "RightButton")

-- Create the title bar for the database frame
local dbTitleBar = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbTitleBar:SetSize(iWRDatabaseFrame:GetWidth(), 31)
dbTitleBar:SetPoint("TOP", iWRDatabaseFrame, "TOP", 0, 0)
dbTitleBar:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = {left = 5, right = 5, top = 5, bottom = 5},
})
dbTitleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

-- Add title text
local dbTitleText = dbTitleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
dbTitleText:SetPoint("CENTER", dbTitleBar, "CENTER", 0, 0)
dbTitleText:SetText(iWR.Colors.iWR .. "iWillRemember Personal Database")
dbTitleText:SetTextColor(0.9, 0.9, 1, 1)

-- Create a close button for the database frame
local dbCloseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelCloseButton")
dbCloseButton:SetPoint("TOPRIGHT", iWRDatabaseFrame, "TOPRIGHT", 0, 0)
dbCloseButton:SetScript("OnClick", function()
    iWR:DatabaseClose()
end)

-- ╭──────────────────────────────────────────╮
-- │      Database Frame Sidebar + Content    │
-- ╰──────────────────────────────────────────╯
local dbActiveTab = 1
local dbSidebarWidth = 130
local dbSidebarButtons = {}

-- Sidebar (OptionsPanel style)
local dbSidebar = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbSidebar:SetWidth(dbSidebarWidth)
dbSidebar:SetPoint("TOPLEFT", iWRDatabaseFrame, "TOPLEFT", 10, -35)
dbSidebar:SetPoint("BOTTOMLEFT", iWRDatabaseFrame, "BOTTOMLEFT", 10, 10)
dbSidebar:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3},
})
dbSidebar:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
dbSidebar:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)

-- Content area (OptionsPanel style)
local dbContentArea = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbContentArea:SetPoint("TOPLEFT", dbSidebar, "TOPRIGHT", 6, 0)
dbContentArea:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, "BOTTOMRIGHT", -10, 10)
dbContentArea:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
dbContentArea:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
dbContentArea:SetBackdropColor(0.08, 0.08, 0.1, 0.95)

-- Forward declaration (used in OnClick before definition)
local ShowDatabaseTab

-- Sidebar button creation helper
local function CreateSidebarButton(parent, label, index, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(dbSidebarWidth - 12, 26)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, yOffset)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(btn)
    bg:SetColorTexture(0, 0, 0, 0)
    btn.bg = bg

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", btn, "LEFT", 14, 0)
    text:SetText(label)
    btn.text = text

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(btn)
    highlight:SetColorTexture(1, 1, 1, 0.08)

    btn:SetScript("OnClick", function()
        ShowDatabaseTab(index)
    end)

    return btn
end

-- Sidebar buttons
local dbNotesBtn = CreateSidebarButton(dbSidebar, L["NotesTab"] or "Notes", 1, -8)
dbSidebarButtons[1] = dbNotesBtn

-- Entry count text (under Notes button)
local dbEntryCount = dbSidebar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
dbEntryCount:SetPoint("TOPLEFT", dbNotesBtn, "BOTTOMLEFT", 14, -2)
dbEntryCount:SetText("|cFF8080800 entries|r")

local dbGroupLogBtn = CreateSidebarButton(dbSidebar, L["GroupLogTab"] or "Group Log", 2, -52)
dbSidebarButtons[2] = dbGroupLogBtn

local dbGuildsBtn = CreateSidebarButton(dbSidebar, L["GuildsTab"] or "Guilds", 3, -78)
dbSidebarButtons[3] = dbGuildsBtn

-- Notes container (inside content area)
local notesContainer = CreateFrame("Frame", nil, dbContentArea)
notesContainer:SetPoint("TOPLEFT", dbContentArea, "TOPLEFT", 5, -5)
notesContainer:SetPoint("BOTTOMRIGHT", dbContentArea, "BOTTOMRIGHT", -5, 5)
notesContainer:Show()

-- Group Log container (inside content area)
local groupLogContainer = CreateFrame("Frame", nil, dbContentArea)
groupLogContainer:SetPoint("TOPLEFT", dbContentArea, "TOPLEFT", 5, -5)
groupLogContainer:SetPoint("BOTTOMRIGHT", dbContentArea, "BOTTOMRIGHT", -5, 5)
groupLogContainer:Hide()

-- Guild Watchlist container (inside content area)
local guildWatchContainer = CreateFrame("Frame", nil, dbContentArea)
guildWatchContainer:SetPoint("TOPLEFT", dbContentArea, "TOPLEFT", 5, -5)
guildWatchContainer:SetPoint("BOTTOMRIGHT", dbContentArea, "BOTTOMRIGHT", -5, 5)
guildWatchContainer:Hide()

-- ShowDatabaseTab: sidebar-based tab switching
ShowDatabaseTab = function(tabIndex)
    dbActiveTab = tabIndex
    notesContainer:SetShown(tabIndex == 1)
    groupLogContainer:SetShown(tabIndex == 2)
    guildWatchContainer:SetShown(tabIndex == 3)
    if tabIndex == 2 then
        iWR:PopulateGroupLog()
    elseif tabIndex == 3 then
        iWR:RefreshGuildWatchlist()
    end
    for i, btn in ipairs(dbSidebarButtons) do
        if i == tabIndex then
            btn.bg:SetColorTexture(1, 0.59, 0.09, 0.25)
            btn.text:SetFontObject(GameFontHighlight)
        else
            btn.bg:SetColorTexture(0, 0, 0, 0)
            btn.text:SetFontObject(GameFontNormal)
        end
    end
end

-- Initialize first tab as active
ShowDatabaseTab(1)

-- Reset to Notes tab (called from DatabaseOpen to always start on Notes)
function iWR:ResetDatabaseTab()
    ShowDatabaseTab(1)
end

-- Notes tab: scrollable frame for database entries
local dbScrollFrame = CreateFrame("ScrollFrame", nil, notesContainer, "UIPanelScrollFrameTemplate")
dbScrollFrame:SetPoint("TOPLEFT", notesContainer, "TOPLEFT", 0, 0)
dbScrollFrame:SetPoint("BOTTOMRIGHT", notesContainer, "BOTTOMRIGHT", -22, 45)

-- Create a container for the database entries (this will be scrollable)
local dbContainer = CreateFrame("Frame", nil, dbScrollFrame)
dbContainer:SetSize(dbScrollFrame:GetWidth()+10, dbScrollFrame:GetHeight()+10)
dbScrollFrame:SetScrollChild(dbContainer)

-- ╭──────────────────────────────────────────────────╮
-- │      Create the "Clear All" Database Button      │
-- ╰──────────────────────────────────────────────────╯
local clearDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
clearDatabaseButton:SetSize(100, 30)
clearDatabaseButton:SetPoint("BOTTOM", notesContainer, "BOTTOM", -60, 10)
clearDatabaseButton:SetText("Clear All")
clearDatabaseButton:SetScript("OnClick", function()
    -- Confirm before clearing the database
    StaticPopupDialogs["CLEAR_DATABASE_CONFIRM"] = {
        text = iWR.Colors.Red .. "Are you sure you want to clear the current iWR Database?|nThis is non-reversible.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            iWRDatabase = {}
            print(iWR.Colors.iWR .. "[iWR]: Database cleared.")
            iWR:PopulateDatabase()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("CLEAR_DATABASE_CONFIRM")
end)

-- ╭─────────────────────────────────────────────╮
-- │      Create the "Share Full DB" Button      │
-- ╰─────────────────────────────────────────────╯
local shareDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
shareDatabaseButton:SetSize(100, 30)
shareDatabaseButton:SetPoint("BOTTOM", notesContainer, "BOTTOM", 60, 10)
shareDatabaseButton:SetText("Share Full DB")
shareDatabaseButton:SetScript("OnClick", function()
    -- Check if the database is empty
    if not next(iWRDatabase) then
        print(iWR.Colors.iWR .. "[iWR]: The database is empty. Nothing to share.")
        return
    end

    -- Confirm before sharing the database
    StaticPopupDialogs["SHARE_DATABASE_CONFIRM"] = {
        text = "Are you sure you want to share the entire database?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            -- Function to share the full database
            iWR:SendFullDBUpdateToFriends()
            print(iWR.Colors.iWR .. "[iWR]: Full database sync process initiated. This can take up to a few minutes.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SHARE_DATABASE_CONFIRM")
end)

-- ╭───────────────────────────────────────────────╮
-- │      Create the "Search Database" Button      │
-- ╰───────────────────────────────────────────────╯
local searchDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
searchDatabaseButton:SetSize(30, 30)
searchDatabaseButton:SetPoint("BOTTOMLEFT", notesContainer, "BOTTOMLEFT", 10, 10)

local searchTexture = searchDatabaseButton:CreateTexture(nil, "ARTWORK")
searchTexture:SetAllPoints()
searchTexture:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03") -- Magnifying glass texture
searchDatabaseButton:SetNormalTexture(searchTexture)

searchDatabaseButton:SetScript("OnClick", function()
    -- Check if the SearchResultsFrame already exists and is visible
    if SearchResultsFrame and SearchResultsFrame:IsVisible() then
        SearchResultsFrame:Hide()
        -- Clear all child frames from the SearchResultsFrame
        for _, child in ipairs({SearchResultsFrame:GetChildren()}) do
            ---@diagnostic disable-next-line: undefined-field
            child:Hide()
            ---@diagnostic disable-next-line: undefined-field
            child:SetParent(nil)
        end
        if NoResultsText then
            NoResultsText:Hide()
            NoResultsText:SetParent(nil)
            NoResultsText = nil
        end
        if TooManyText then
            TooManyText:Hide()
            TooManyText:SetParent(nil)
            TooManyText = nil
        end
        if SearchTitle then
            SearchTitle:Hide()
            SearchTitle:SetParent(nil)
            SearchTitle = nil
        end
    end

    -- Prompt for search input
    StaticPopupDialogs["SEARCH_DATABASE"] = {
        text = "Enter the name of the player to search:",
        button1 = "Search",
        button2 = "Cancel",
        hasEditBox = true,
        OnAccept = function(self)
            local eb = self.editBox or self.EditBox
            local searchQuery = eb and eb:GetText()
            if searchQuery and searchQuery ~= "" then
                local foundEntries = {}
                for playerName, data in pairs(iWRDatabase) do
                    if string.find(string.lower(playerName), string.lower(searchQuery)) then
                        table.insert(foundEntries, {name = playerName, data = data})
                    end
                end

                -- Create the SearchResultsFrame if it doesn't already exist
                if not SearchResultsFrame then
                    SearchResultsFrame = iWR:CreateiWRStyleFrame(iWRDatabaseFrame, 280, 400, {"RIGHT", iWRDatabaseFrame, "RIGHT", 280, 0})
                    SearchResultsFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.9)
                    SearchResultsFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
                end

                -- Clear previous content
                for _, child in ipairs({SearchResultsFrame:GetChildren()}) do
                    ---@diagnostic disable-next-line: undefined-field
                    child:Hide()
                    ---@diagnostic disable-next-line: undefined-field
                    child:SetParent(nil)
                    if NoResultsText then
                        NoResultsText:Hide()
                        NoResultsText:SetParent(nil)
                        NoResultsText = nil
                    end
                    if TooManyText then
                        TooManyText:Hide()
                        TooManyText:SetParent(nil)
                        TooManyText = nil
                    end
                    if SearchTitle then
                        SearchTitle:Hide()
                        SearchTitle:SetParent(nil)
                        SearchTitle = nil
                    end
                end
                SearchResultsFrame:Show()

                -- Add title to the search results
                SearchTitle = SearchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                SearchTitle:SetPoint("TOP", SearchResultsFrame, "TOP", 0, -10)
                SearchTitle:SetText("Search Results for: " .. searchQuery)

                if #foundEntries > 0 then
                    local maxEntries = 7
                    for index, entry in ipairs(foundEntries) do
                        if index > maxEntries then
                            TooManyText = SearchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                            TooManyText:SetPoint("TOP", SearchResultsFrame, "TOP", 0, -40 * (maxEntries + 1))
                            TooManyText:SetText("Too many results, refine your search.")
                            break
                        end

                        local playerName, data = entry.name, entry.data

                        -- Create a frame for each entry
                        local entryFrame = CreateFrame("Frame", nil, SearchResultsFrame, "BackdropTemplate")
                        entryFrame:SetSize(230, 30)
                        entryFrame:SetPoint("TOP", SearchResultsFrame, "TOP", 0, -40 * index)

                        -- Add the icon for the type
                        local iconTexture = entryFrame:CreateTexture(nil, "ARTWORK")
                        iconTexture:SetSize(20, 20)
                        iconTexture:SetPoint("LEFT", entryFrame, "LEFT", -5, 0)

                        -- Set the icon texture
                        local typeIcon = iWR:GetIcon(data[2])
                        if typeIcon then
                            iconTexture:SetTexture(typeIcon)
                        else
                            iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback icon
                        end

                        -- Add player name and note
                        local entryText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        entryText:SetPoint("LEFT", iconTexture, "RIGHT", 5, 0)
                        if data[7] ~= iWR.CurrentRealm then
                            entryText:SetText(data[4]..iWR.Colors.Reset.."-"..data[7])
                        else
                            entryText:SetText(data[4])
                        end

                        -- Tooltip functionality
                        entryFrame:SetScript("OnEnter", function()
                            ---@diagnostic disable-next-line: param-type-mismatch
                            GameTooltip:SetOwner(entryFrame, "ANCHOR_RIGHT")
                            if data[7] ~= iWR.CurrentRealm then
                                GameTooltip:AddLine(data[4]..iWR.Colors.Reset.."-"..data[7], 1, 1, 1) -- Title (Player Name)
                            else
                                GameTooltip:AddLine(data[4], 1, 1, 1) -- Title (Player Name)
                            end
                            if #data[1] <= 30 then
                                GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0) -- Add note in tooltip
                            else
                                local firstLine, secondLine = iWR:splitOnSpace(data[1], 30) -- Split text on the nearest space
                                GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. firstLine, 1, 0.82, 0) -- Add first line
                                GameTooltip:AddLine(iWR.Colors[data[2]] .. secondLine, 1, 0.82, 0) -- Add second line
                            end
                            if data[6] ~= "" and data[6] ~= nil then
                                GameTooltip:AddLine("Author: " .. data[6], 1, 0.82, 0) -- Add author in tooltip
                            end
                            if data[5] ~= "" and data[5] ~= nil then
                                GameTooltip:AddLine("Date: " .. data[5], 1, 0.82, 0) -- Add date in tooltip
                            end
                            GameTooltip:Show()
                        end)
                        entryFrame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)

                        -- Add Edit button
                        local editButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
                        editButton:SetSize(50, 30)
                        editButton:SetPoint("RIGHT", entryFrame, "RIGHT", -50, 0)
                        editButton:SetText("Edit")
                        editButton.playerName = data[4] or playerName
                        editButton.note = data[1]
                        editButton:SetScript("OnClick", function(self)
                            iWR:MenuOpen(self.playerName)
                            iWRNameInput:SetText(self.playerName)
                            iWRNoteInput:SetText(self.note or "")
                        end)

                        -- Add Remove button
                        local removeButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
                        removeButton:SetSize(60, 30)
                        removeButton:SetPoint("RIGHT", editButton, "RIGHT", 60, 0)
                        removeButton:SetText("Remove")
                        removeButton:SetScript("OnClick", function()
                            local removeText
                            if iWRDatabase[playerName][7] ~= iWR.CurrentRealm then
                                removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. "-" .. iWRDatabase[playerName][7] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                            else
                                removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                            end
                            StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                                text = removeText,
                                button1 = "Yes",
                                button2 = "No",
                                OnAccept = function()
                                    print(L["CharNoteStart"] .. iWRDatabase[playerName][4]  .. L["CharNoteRemoved"])
                                    iWRDatabase[playerName] = nil
                                    if SearchResultsFrame then
                                        SearchResultsFrame:Hide()
                                    end
                                    iWR:PopulateDatabase()
                                    iWR:SendRemoveRequestToFriends(playerName)
                                end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            StaticPopup_Show("REMOVE_PLAYER_CONFIRM")
                        end)
                    end
                else
                    NoResultsText = SearchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    NoResultsText:SetPoint("CENTER", SearchResultsFrame, "CENTER", 0, 0)
                    NoResultsText:SetText("No players found for: " .. searchQuery)
                end

                local closeResultsButton = CreateFrame("Button", nil, SearchResultsFrame, "UIPanelButtonTemplate")
                closeResultsButton:SetSize(80, 24)
                closeResultsButton:SetPoint("BOTTOM", SearchResultsFrame, "BOTTOM", 0, 20)
                closeResultsButton:SetText("Close")
                closeResultsButton:SetScript("OnClick", function()
                    SearchResultsFrame:Hide()
                    for _, child in ipairs({SearchResultsFrame:GetChildren()}) do
                        ---@diagnostic disable-next-line: undefined-field
                        child:Hide()
                        ---@diagnostic disable-next-line: undefined-field
                        child:SetParent(nil)
                        if NoResultsText then
                            NoResultsText:Hide()
                            NoResultsText:SetParent(nil)
                            NoResultsText = nil
                        end
                        if TooManyText then
                            TooManyText:Hide()
                            TooManyText:SetParent(nil)
                            TooManyText = nil
                        end
                        if SearchTitle then
                            SearchTitle:Hide()
                            SearchTitle:SetParent(nil)
                            SearchTitle = nil
                        end
                    end
                end)
            end
        end,
        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if eb then
                eb:SetMaxLetters(15)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SEARCH_DATABASE")
end)

-- ╭─────────────────────────────────────────╮
-- │      Function to Populate Database      │
-- ╰─────────────────────────────────────────╯
function iWR:PopulateDatabase()
    -- Create sub-containers for columns if they don't already exist
    if not dbContainer.col1 then
        dbContainer.col1 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col1:SetSize(dbContainer:GetWidth() * 0.28, dbContainer:GetHeight())
        dbContainer.col1:SetPoint("TOPLEFT", dbContainer, "TOPLEFT", 0, 0)
    end

    if not dbContainer.col1b then
        dbContainer.col1b = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col1b:SetSize(dbContainer:GetWidth() * 0.07, dbContainer:GetHeight())
        dbContainer.col1b:SetPoint("TOPLEFT", dbContainer.col1, "TOPRIGHT", 0, 0)
    end

    if not dbContainer.col2 then
        dbContainer.col2 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col2:SetSize(dbContainer:GetWidth() * 0.40, dbContainer:GetHeight())
        dbContainer.col2:SetPoint("TOPLEFT", dbContainer.col1b, "TOPRIGHT", 0, 0)
    end

    if not dbContainer.col3 then
        dbContainer.col3 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col3:SetSize(dbContainer:GetWidth() * 0.25, dbContainer:GetHeight())
        dbContainer.col3:SetPoint("TOPLEFT", dbContainer.col2, "TOPRIGHT", 0, 0)
    end

    -- Reuse or hide existing frames in columns
    local function resetColumn(column)
        for _, child in ipairs({column:GetChildren()}) do
            child:Hide()
        end
    end

    resetColumn(dbContainer.col1)
    resetColumn(dbContainer.col1b)
    resetColumn(dbContainer.col2)
    resetColumn(dbContainer.col3)

    -- Categorize entries
    local categorizedData = {}
    for playerName, data in pairs(iWRDatabase) do
        local category = data[2] or "Uncategorized"
        categorizedData[category] = categorizedData[category] or {}
        table.insert(categorizedData[category], { name = playerName, data = data })
    end

    -- Sort categories in the correct order
    local sortedCategories = {}
    for category in pairs(categorizedData) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories, function(a, b) return a > b end)

    for _, category in ipairs(sortedCategories) do
        table.sort(categorizedData[category], function(a, b)
            return a.name < b.name
        end)
    end

    -- Iterate over categorized data and create or reuse frames
    local yOffset = -5
    local reusedFrames = { col1 = {}, col1b = {}, col2 = {}, col3 = {} }

    for _, category in ipairs(sortedCategories) do
        if #categorizedData[category] > 0 then
            for _, entry in ipairs(categorizedData[category]) do
                local playerName, data = entry.name, entry.data

                -- Reuse or create frame in Col1 (Type Icon and Player Name)
                local col1Frame = reusedFrames.col1[#reusedFrames.col1 + 1] or CreateFrame("Frame", nil, dbContainer.col1)
                col1Frame:SetSize(dbContainer.col1:GetWidth(), 30)
                col1Frame:SetPoint("TOPLEFT", dbContainer.col1, "TOPLEFT", 0, yOffset)
                col1Frame:Show()
                table.insert(reusedFrames.col1, col1Frame)

                -- Row hover highlight (manual, synced across all columns)
                local col1Highlight = col1Frame.highlight or col1Frame:CreateTexture(nil, "ARTWORK")
                col1Highlight:SetAllPoints()
                col1Highlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col1Highlight:Hide()
                col1Frame.highlight = col1Highlight

                -- Online status dot
                local statusDot = col1Frame.statusDot or col1Frame:CreateTexture(nil, "OVERLAY")
                statusDot:SetSize(6, 6)
                statusDot:SetPoint("LEFT", col1Frame, "LEFT", 3, 0)
                statusDot:SetTexture("Interface\\BUTTONS\\WHITE8x8")

                local strippedName = StripColorCodes(data[4])
                local isOnline = false

                -- Check group/raid
                if IsInGroup() or IsInRaid() then
                    local numMembers = GetNumGroupMembers()
                    for gi = 1, numMembers do
                        local unit = IsInRaid() and ("raid" .. gi) or ("party" .. gi)
                        if UnitExists(unit) and UnitName(unit) == strippedName then
                            isOnline = UnitIsConnected(unit)
                            break
                        end
                    end
                end

                -- Check guild
                if not isOnline and IsInGuild() then
                    local numGuild = GetNumGuildMembers()
                    for gi = 1, numGuild do
                        local gName, _, _, _, _, _, _, _, online = GetGuildRosterInfo(gi)
                        if gName then
                            local shortName = Ambiguate(gName, "short")
                            if shortName == strippedName then
                                isOnline = online
                                break
                            end
                        end
                    end
                end

                -- Check friends list
                if not isOnline then
                    local numFriends = C_FriendList.GetNumFriends()
                    for fi = 1, numFriends do
                        local info = C_FriendList.GetFriendInfoByIndex(fi)
                        if info and info.name == strippedName then
                            isOnline = info.connected
                            break
                        end
                    end
                end

                if isOnline then
                    statusDot:SetVertexColor(0, 1, 0, 1)
                else
                    statusDot:SetVertexColor(0.4, 0.4, 0.4, 0.5)
                end
                statusDot:Show()
                col1Frame.statusDot = statusDot

                -- Faction icon (Horde/Alliance flag)
                local factionIcon = col1Frame.factionIcon or col1Frame:CreateTexture(nil, "ARTWORK")
                factionIcon:SetSize(14, 14)
                factionIcon:SetPoint("LEFT", statusDot, "RIGHT", 3, 0)
                if data[8] == "Horde" then
                    factionIcon:SetTexture("Interface\\Icons\\INV_BannerPVP_01")
                    factionIcon:Show()
                elseif data[8] == "Alliance" then
                    factionIcon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
                    factionIcon:Show()
                else
                    factionIcon:Hide()
                end
                col1Frame.factionIcon = factionIcon

                local iconTexture = col1Frame.iconTexture or col1Frame:CreateTexture(nil, "ARTWORK")
                iconTexture:SetSize(20, 20)
                iconTexture:SetPoint("LEFT", factionIcon, "RIGHT", 3, 0)
                iconTexture:SetTexture(iWR:GetIcon(data[2]) or "Interface\\Icons\\INV_Misc_QuestionMark")
                col1Frame.iconTexture = iconTexture

                local playerNameText = col1Frame.playerNameText or col1Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                playerNameText:SetPoint("LEFT", iconTexture, "RIGHT", 10, 0)
                local displayName = data[4]
                local listdisplayName = displayName
                if data[7] and data[7] ~= iWR.CurrentRealm then
                    listdisplayName = displayName .. " (*)"
                    displayName = displayName .. "-" .. data[7]
                end
                local databasekey = StripColorCodes(data[4]) .. "-" .. data[7]

                -- Whisper helper for this row
                local playerFaction = UnitFactionGroup("player")
                local canWhisper = not data[8] or data[8] == "" or data[8] == playerFaction
                local function WhisperPlayer()
                    if not canWhisper then return end
                    local whisperName = StripColorCodes(data[4])
                    if data[7] and data[7] ~= iWR.CurrentRealm then
                        whisperName = whisperName .. "-" .. data[7]
                    end
                    ChatFrame_OpenChat("/w " .. whisperName .. " ")
                end

                playerNameText:SetText(iWR.Colors.iWR .. string.format("%-16s", listdisplayName))
                playerNameText:SetTextColor(1, 1, 1, 1)
                col1Frame.playerNameText = playerNameText

                -- Tooltip and Click for Name column
                col1Frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(col1Frame, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(listdisplayName, 1, 1, 1)
                    if data[7] then
                        GameTooltip:AddLine("Server: " .. iWR.Colors.Reset .. data[7], 1, 0.82, 0)
                    end
                    if data[8] and data[8] ~= "" then
                        GameTooltip:AddLine("Faction: " .. iWR.Colors.Reset .. data[8], 1, 0.82, 0)
                    end
                    local ttSign = data[2] > 0 and "+" or ""
                    local ttColor = iWR.Colors[data[2]] or iWR.Colors.Default
                    GameTooltip:AddLine("Type: " .. ttColor .. ttSign .. data[2] .. " — " .. iWR:GetTypeName(data[2]), 1, 0.82, 0)
                    if data[1] then
                        GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0)
                    end
                    if data[6] then
                        GameTooltip:AddLine("Author: " .. data[6], 1, 0.82, 0)
                    end
                    if data[5] then
                        GameTooltip:AddLine("Date: " .. data[5], 1, 0.82, 0)
                    end
                    if canWhisper then
                        GameTooltip:AddLine("|cFF808080Right-click to whisper|r", 0.5, 0.5, 0.5)
                    end
                    GameTooltip:Show()
                end)
                col1Frame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                col1Frame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    else
                        iWR:ShowDetailWindow(databasekey)
                    end
                end)

                -- Reuse or create frame in Col1b (Level)
                local col1bFrame = reusedFrames.col1b[#reusedFrames.col1b + 1] or CreateFrame("Frame", nil, dbContainer.col1b)
                col1bFrame:SetSize(dbContainer.col1b:GetWidth(), 30)
                col1bFrame:SetPoint("TOPLEFT", dbContainer.col1b, "TOPLEFT", 0, yOffset)
                col1bFrame:Show()
                table.insert(reusedFrames.col1b, col1bFrame)

                local col1bHighlight = col1bFrame.highlight or col1bFrame:CreateTexture(nil, "ARTWORK")
                col1bHighlight:SetAllPoints()
                col1bHighlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col1bHighlight:Hide()
                col1bFrame.highlight = col1bHighlight

                local levelText = col1bFrame.levelText or col1bFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                levelText:SetPoint("CENTER", col1bFrame, "CENTER", 0, 0)
                local levelColor = iWR.Colors[data[2]] or iWR.Colors.Default
                local levelSign = data[2] > 0 and "+" or ""
                levelText:SetText(levelColor .. levelSign .. data[2])
                col1bFrame.levelText = levelText

                -- Reuse or create frame in Col2 (Notes)
                local col2Frame = reusedFrames.col2[#reusedFrames.col2 + 1] or CreateFrame("Frame", nil, dbContainer.col2)
                col2Frame:SetSize(dbContainer.col2:GetWidth(), 30)
                col2Frame:SetPoint("TOPLEFT", dbContainer.col2, "TOPLEFT", 0, yOffset)
                col2Frame:Show()
                table.insert(reusedFrames.col2, col2Frame)

                local col2Highlight = col2Frame.highlight or col2Frame:CreateTexture(nil, "ARTWORK")
                col2Highlight:SetAllPoints()
                col2Highlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col2Highlight:Hide()
                col2Frame.highlight = col2Highlight

                local noteText = col2Frame.noteText or col2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                noteText:SetPoint("LEFT", col2Frame, "LEFT", 10, 0)
                local noteColor = iWR.Colors[data[2]] or iWR.Colors.Default
                local truncatedNote = data[1] and #data[1] > 30 and data[1]:sub(1, 27) .. "..." or data[1] or ""
                noteText:SetText(noteColor .. truncatedNote)
                col2Frame.noteText = noteText

                -- Tooltip and Click for Notes column
                col2Frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(col2Frame, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(listdisplayName, 1, 1, 1)
                    if data[7] then
                        GameTooltip:AddLine("Server: " .. iWR.Colors.Reset .. data[7], 1, 0.82, 0)
                    end
                    local ttSign = data[2] > 0 and "+" or ""
                    local ttColor = iWR.Colors[data[2]] or iWR.Colors.Default
                    GameTooltip:AddLine("Type: " .. ttColor .. ttSign .. data[2] .. " — " .. iWR:GetTypeName(data[2]), 1, 0.82, 0)
                    if data[1] then
                        GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0)
                    end
                    if data[6] then
                        GameTooltip:AddLine("Author: " .. data[6], 1, 0.82, 0)
                    end
                    if data[5] then
                        GameTooltip:AddLine("Date: " .. data[5], 1, 0.82, 0)
                    end
                    GameTooltip:Show()
                end)
                col2Frame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                col2Frame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    else
                        iWR:ShowDetailWindow(databasekey)
                    end
                end)

                -- Reuse or create frame in Col3 (Buttons)
                local col3Frame = reusedFrames.col3[#reusedFrames.col3 + 1] or CreateFrame("Frame", nil, dbContainer.col3)
                col3Frame:SetSize(dbContainer.col3:GetWidth(), 30)
                col3Frame:SetPoint("TOPLEFT", dbContainer.col3, "TOPLEFT", 0, yOffset)
                col3Frame:Show()
                table.insert(reusedFrames.col3, col3Frame)

                local col3Highlight = col3Frame.highlight or col3Frame:CreateTexture(nil, "ARTWORK")
                col3Highlight:SetAllPoints()
                col3Highlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col3Highlight:Hide()
                col3Frame.highlight = col3Highlight

                local editButton = col3Frame.editButton or CreateFrame("Button", nil, col3Frame, "UIPanelButtonTemplate")
                editButton:SetSize(50, 24)
                editButton:SetPoint("LEFT", col3Frame, "LEFT", 10, 0)
                editButton:SetText("Edit")
                editButton:SetScript("OnClick", function()
                    -- Check if databaseKey[7] matches the current realm
                    if data[7] == iWR.CurrentRealm then
                        -- Open with data[4]
                        iWR:MenuOpen(data[4])
                        if data[1] ~= "" or data[1] ~= nil then
                            iWRNoteInput:SetText(data[1])
                        end
                    else
                        -- Open with data[4] concatenated with "-" and data[7]
                        iWR:MenuOpen(data[4] .. "-" .. data[7])
                        if data[1] ~= "" or data[1] ~= nil then
                            iWRNoteInput:SetText(data[1])
                        end
                    end
                    -- Close the database menu
                    iWR:DatabaseClose()
                end)
                col3Frame.editButton = editButton

                local removeButton = col3Frame.removeButton or CreateFrame("Button", nil, col3Frame, "UIPanelButtonTemplate")
                removeButton:SetSize(60, 24)
                removeButton:SetPoint("LEFT", editButton, "RIGHT", 10, 0)
                removeButton:SetText("Remove")
                removeButton:SetScript("OnClick", function()
                    local removeText
                    if iWRDatabase[databasekey][7] ~= iWR.CurrentRealm then
                        removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[databasekey][4] .. "-" .. iWRDatabase[databasekey][7] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                    else
                        removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[databasekey][4] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                    end
                    StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                        text = removeText,
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            print(L["CharNoteStart"] .. iWRDatabase[databasekey][4]  .. L["CharNoteRemoved"])
                            iWRDatabase[databasekey] = nil
                            if SearchResultsFrame then
                                SearchResultsFrame:Hide()
                            end
                            iWR:PopulateDatabase()
                            iWR:SendRemoveRequestToFriends(databasekey)
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("REMOVE_PLAYER_CONFIRM")
                end)
                col3Frame.removeButton = removeButton

                -- Link all columns in this row for synced hover highlight
                local rowFrames = { col1Frame, col1bFrame, col2Frame, col3Frame }
                local function ShowRowHighlight()
                    for _, f in ipairs(rowFrames) do
                        if f.highlight then f.highlight:Show() end
                    end
                end
                local function HideRowHighlight()
                    for _, f in ipairs(rowFrames) do
                        if f.highlight then f.highlight:Hide() end
                    end
                end

                -- Hook synced highlights into existing OnEnter/OnLeave
                local col1OrigEnter = col1Frame:GetScript("OnEnter")
                local col1OrigLeave = col1Frame:GetScript("OnLeave")
                col1Frame:SetScript("OnEnter", function(self, ...)
                    ShowRowHighlight()
                    if col1OrigEnter then col1OrigEnter(self, ...) end
                end)
                col1Frame:SetScript("OnLeave", function(self, ...)
                    HideRowHighlight()
                    if col1OrigLeave then col1OrigLeave(self, ...) end
                end)

                col1bFrame:EnableMouse(true)
                col1bFrame:SetScript("OnEnter", function() ShowRowHighlight() end)
                col1bFrame:SetScript("OnLeave", function() HideRowHighlight() end)
                col1bFrame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    else
                        iWR:ShowDetailWindow(databasekey)
                    end
                end)

                local col2OrigEnter = col2Frame:GetScript("OnEnter")
                local col2OrigLeave = col2Frame:GetScript("OnLeave")
                col2Frame:SetScript("OnEnter", function(self, ...)
                    ShowRowHighlight()
                    if col2OrigEnter then col2OrigEnter(self, ...) end
                end)
                col2Frame:SetScript("OnLeave", function(self, ...)
                    HideRowHighlight()
                    if col2OrigLeave then col2OrigLeave(self, ...) end
                end)

                col3Frame:EnableMouse(true)
                col3Frame:SetScript("OnEnter", function() ShowRowHighlight() end)
                col3Frame:SetScript("OnLeave", function() HideRowHighlight() end)
                col3Frame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    end
                end)

                yOffset = yOffset - 30
            end
        end
    end
    dbContainer:SetHeight(math.abs(yOffset))

    -- Update entry count in sidebar
    local entryCount = math.floor(math.abs(yOffset + 5) / 30)
    dbEntryCount:SetText("|cFF808080" .. entryCount .. " entries|r")
end

-- ╭─────────────────────────────────────────────────╮
-- │      Group Log Tab: UI & PopulateGroupLog       │
-- ╰─────────────────────────────────────────────────╯

-- Scroll frame for group log entries
local glScrollFrame = CreateFrame("ScrollFrame", nil, groupLogContainer, "UIPanelScrollFrameTemplate")
glScrollFrame:SetPoint("TOPLEFT", groupLogContainer, "TOPLEFT", 0, 0)
glScrollFrame:SetPoint("BOTTOMRIGHT", groupLogContainer, "BOTTOMRIGHT", -22, 45)

local glContainer = CreateFrame("Frame", nil, glScrollFrame)
glContainer:SetSize(glScrollFrame:GetWidth() + 10, glScrollFrame:GetHeight() + 10)
glScrollFrame:SetScrollChild(glContainer)

-- Empty state text
local glEmptyText = groupLogContainer:CreateFontString(nil, "OVERLAY", "GameFontDisable")
glEmptyText:SetPoint("CENTER", groupLogContainer, "CENTER", 0, 20)
glEmptyText:SetText(L["GroupLogEmpty"] or "No players logged yet. Group up and they'll appear here!")
glEmptyText:SetWidth(400)
glEmptyText:Hide()

-- Clear Log button
local clearLogButton = CreateFrame("Button", nil, groupLogContainer, "UIPanelButtonTemplate")
clearLogButton:SetSize(100, 30)
clearLogButton:SetPoint("BOTTOM", groupLogContainer, "BOTTOM", 0, 10)
clearLogButton:SetText(L["GroupLogClearAll"] or "Clear Log")
clearLogButton:SetScript("OnClick", function()
    StaticPopupDialogs["IWR_CLEAR_GROUP_LOG"] = {
        text = L["GroupLogClearConfirm"] or "Are you sure you want to clear the entire group log?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            iWR:ClearGroupLog()
            iWR:PopulateGroupLog()
            print(iWR.Colors.iWR .. (L["GroupLogCleared"] or "[iWR]: Group log cleared."))
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("IWR_CLEAR_GROUP_LOG")
end)

-- Reusable row frames for group log
local glRowCache = {}

function iWR:PopulateGroupLog()
    if not iWRMemory or not iWRMemory.GroupLog then return end

    -- Hide all cached rows first
    for _, row in ipairs(glRowCache) do
        row:Hide()
    end

    local entries = iWRMemory.GroupLog
    local totalEntries = #entries

    -- Hide empty text initially (may show later if all entries are filtered)
    glEmptyText:Hide()

    local yOffset = -5
    local ROW_HEIGHT = 30
    local displayIndex = 0

    -- Display in reverse order (newest first), skip players already in database
    for i = totalEntries, 1, -1 do
        local entry = entries[i]
        if not entry then break end

        -- Skip players that already have a note in the database
        local databaseKey = entry.name .. "-" .. entry.realm
        if iWRDatabase[databaseKey] then
            -- Player already has a note, don't show in Group Log
        else

        displayIndex = displayIndex + 1

        -- Reuse or create row frame
        local row = glRowCache[displayIndex]
        if not row then
            row = CreateFrame("Frame", nil, glContainer)
            row:SetHeight(ROW_HEIGHT)
            row:SetPoint("TOPLEFT", glContainer, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", glContainer, "TOPRIGHT", 0, 0)
            row:EnableMouse(true)

            -- Highlight on hover
            local highlight = row:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 0.59, 0.09, 0.08)

            -- Class icon
            local classIcon = row:CreateTexture(nil, "ARTWORK")
            classIcon:SetSize(20, 20)
            classIcon:SetPoint("LEFT", row, "LEFT", 10, 0)
            classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            row.classIcon = classIcon

            -- Has-note indicator (small icon)
            local noteIndicator = row:CreateTexture(nil, "ARTWORK")
            noteIndicator:SetSize(14, 14)
            noteIndicator:SetPoint("LEFT", classIcon, "RIGHT", 2, 0)
            noteIndicator:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
            noteIndicator:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            noteIndicator:Hide()
            row.noteIndicator = noteIndicator

            -- Player name
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", classIcon, "RIGHT", 20, 0)
            nameText:SetWidth(140)
            nameText:SetJustifyH("LEFT")
            row.nameText = nameText

            -- Zone name
            local zoneText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            zoneText:SetPoint("LEFT", nameText, "RIGHT", 5, 0)
            zoneText:SetWidth(160)
            zoneText:SetJustifyH("LEFT")
            row.zoneText = zoneText

            -- Date
            local dateText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            dateText:SetPoint("LEFT", zoneText, "RIGHT", 5, 0)
            dateText:SetWidth(80)
            dateText:SetJustifyH("LEFT")
            row.dateText = dateText

            -- Add Note button
            local editBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            editBtn:SetSize(75, 22)
            editBtn:SetPoint("RIGHT", row, "RIGHT", -70, 0)
            editBtn:SetText(L["GroupLogAddNote"] or "Add Note")
            row.editBtn = editBtn

            -- Dismiss button
            local dismissBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            dismissBtn:SetSize(55, 22)
            dismissBtn:SetPoint("RIGHT", row, "RIGHT", -10, 0)
            dismissBtn:SetText(L["GroupLogDismiss"] or "Dismiss")
            row.dismissBtn = dismissBtn

            glRowCache[displayIndex] = row
        end

        -- Position the row
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", glContainer, "TOPLEFT", 0, yOffset)
        row:SetPoint("TOPRIGHT", glContainer, "TOPRIGHT", 0, yOffset)
        row:Show()

        -- Set class icon using CLASS_ICON_TCOORDS
        local classToken = entry.class or "UNKNOWN"
        local tcoords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
        if tcoords then
            row.classIcon:SetTexCoord(unpack(tcoords))
            row.classIcon:Show()
        else
            row.classIcon:Hide()
        end

        -- Player name with class color
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
        local nameColor = classColor and ("|c" .. classColor.colorStr) or iWR.Colors.Default
        row.nameText:SetText(nameColor .. entry.name)

        -- Zone with instance indicator
        local zoneStr = entry.zone or ""
        if entry.isInstance then
            local instanceLabel = ""
            if entry.instanceType == "party" then
                instanceLabel = " |cFF00CCFF(Dungeon)|r"
            elseif entry.instanceType == "raid" then
                instanceLabel = " |cFFFF8800(Raid)|r"
            elseif entry.instanceType == "pvp" then
                instanceLabel = " |cFFFF0000(BG)|r"
            elseif entry.instanceType == "arena" then
                instanceLabel = " |cFFFF0000(Arena)|r"
            else
                instanceLabel = " |cFF808080(Instance)|r"
            end
            zoneStr = zoneStr .. instanceLabel
        end
        row.zoneText:SetText(zoneStr)

        -- Date
        row.dateText:SetText(entry.date or "")

        -- Note indicator no longer needed (players with notes are filtered out)
        row.noteIndicator:Hide()

        -- Tooltip on hover
        local capturedEntry = entry
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(nameColor .. capturedEntry.name .. "-" .. capturedEntry.realm, 1, 1, 1)
            GameTooltip:AddLine("Zone: " .. (capturedEntry.zone or "Unknown"), 1, 0.82, 0)
            if capturedEntry.isInstance then
                GameTooltip:AddLine("Instance Type: " .. (capturedEntry.instanceType or "none"), 1, 0.82, 0)
            end
            GameTooltip:AddLine("Date: " .. (capturedEntry.date or ""), 1, 0.82, 0)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Add Note button: open iWR Menu with player name and class pre-filled
        local capturedName = entry.name
        local capturedRealm = entry.realm
        local capturedClass = entry.class
        row.editBtn:SetScript("OnClick", function()
            local menuName
            if capturedRealm == iWR.CurrentRealm then
                menuName = capturedName
            else
                menuName = capturedName .. "-" .. capturedRealm
            end
            iWR:MenuOpen(menuName, capturedClass)
            iWR:DatabaseClose()
        end)

        -- Dismiss button: remove this entry from the log
        local capturedEntryIndex = i
        row.dismissBtn:SetScript("OnClick", function()
            table.remove(iWRMemory.GroupLog, capturedEntryIndex)
            iWR:PopulateGroupLog()
        end)

        yOffset = yOffset - ROW_HEIGHT
        end -- end of else (skip players already in DB)
    end

    -- Show empty text if all entries were filtered out (or no entries exist)
    if displayIndex == 0 then
        glEmptyText:Show()
        glContainer:SetHeight(1)
        return
    end

    glContainer:SetHeight(math.max(math.abs(yOffset), 1))
end

-- ╭───────────────────────────────────────────────────────╮
-- │      Guild Watchlist Tab: UI & RefreshGuildWatchlist   │
-- ╰───────────────────────────────────────────────────────╯

-- Header
local gwHeader = guildWatchContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
gwHeader:SetPoint("TOPLEFT", guildWatchContainer, "TOPLEFT", 10, -10)
gwHeader:SetText(L["GuildWatchlistHeader"] or "Guild Watchlist")

-- Description
local gwDesc = guildWatchContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
gwDesc:SetPoint("TOPLEFT", gwHeader, "BOTTOMLEFT", 0, -4)
gwDesc:SetWidth(550)
gwDesc:SetJustifyH("LEFT")
gwDesc:SetText(L["GuildWatchlistDesc"] or "Add a guild name and relation type. Players from watched guilds are auto-imported when targeted or grouped.")

-- Input row: Guild name EditBox
local gwInputLabel = guildWatchContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwInputLabel:SetPoint("TOPLEFT", gwDesc, "BOTTOMLEFT", 0, -12)
gwInputLabel:SetText(L["GuildNameLabel"] or "Guild Name:")

local gwInput = CreateFrame("EditBox", nil, guildWatchContainer, "InputBoxTemplate")
gwInput:SetSize(250, 20)
gwInput:SetPoint("LEFT", gwInputLabel, "RIGHT", 8, 0)
gwInput:SetAutoFocus(false)
gwInput:SetMaxLetters(60)

-- Type cycling button
local gwTypeValue = 1 -- default to Liked +1
local gwTypeBtn = CreateFrame("Button", nil, guildWatchContainer, "UIPanelButtonTemplate")
gwTypeBtn:SetSize(120, 22)
gwTypeBtn:SetPoint("LEFT", gwInput, "RIGHT", 8, 0)

local typeOrder = {-6, -1, 1, 6, 10}
local typeOrderIndex = 3 -- starts at +1 (Liked)

local function UpdateGWTypeButton()
    gwTypeValue = typeOrder[typeOrderIndex]
    local typeName = iWR:GetTypeName(gwTypeValue)
    local typeColor = iWR.Colors[gwTypeValue] or iWR.Colors.Gray
    gwTypeBtn:SetText(typeColor .. typeName .. "|r")
end
UpdateGWTypeButton()

gwTypeBtn:SetScript("OnClick", function()
    typeOrderIndex = (typeOrderIndex % #typeOrder) + 1
    UpdateGWTypeButton()
end)

-- Default note input
local gwNoteLabel = guildWatchContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwNoteLabel:SetPoint("TOPLEFT", gwInputLabel, "BOTTOMLEFT", 0, -8)
gwNoteLabel:SetText(L["GuildNoteLabel"] or "Default Note:")

local gwNoteInput = CreateFrame("EditBox", nil, guildWatchContainer, "InputBoxTemplate")
gwNoteInput:SetSize(250, 20)
gwNoteInput:SetPoint("LEFT", gwNoteLabel, "RIGHT", 8, 0)
gwNoteInput:SetAutoFocus(false)
gwNoteInput:SetMaxLetters(120)

-- Add button
local gwAddBtn = CreateFrame("Button", nil, guildWatchContainer, "UIPanelButtonTemplate")
gwAddBtn:SetSize(60, 22)
gwAddBtn:SetPoint("LEFT", gwNoteInput, "RIGHT", 8, 0)
gwAddBtn:SetText(L["GuildWatchlistAdd"] or "Add")

gwAddBtn:SetScript("OnClick", function()
    local guildName = strtrim(gwInput:GetText())
    if guildName == "" then return end
    if not iWRSettings.GuildWatchlist then iWRSettings.GuildWatchlist = {} end
    local authorName = iWR:ColorizePlayerNameByClass(UnitName("player"), select(2, UnitClass("player")))
    local noteText = strtrim(gwNoteInput:GetText())
    iWRSettings.GuildWatchlist[guildName] = { type = gwTypeValue, author = authorName, note = noteText }
    gwInput:SetText("")
    gwNoteInput:SetText("")
    gwInput:ClearFocus()
    gwNoteInput:ClearFocus()
    iWR:RefreshGuildWatchlist()
    print(string.format(L["GuildWatchlistAdded"], guildName, iWR:GetTypeName(gwTypeValue)))
end)

gwInput:SetScript("OnEnterPressed", function()
    gwNoteInput:SetFocus()
end)

gwNoteInput:SetScript("OnEnterPressed", function()
    gwAddBtn:Click()
end)

-- Scrollable list area
local gwListBorder = CreateFrame("Frame", nil, guildWatchContainer, "BackdropTemplate")
gwListBorder:SetPoint("TOPLEFT", gwNoteLabel, "BOTTOMLEFT", -5, -12)
gwListBorder:SetPoint("BOTTOMRIGHT", guildWatchContainer, "BOTTOMRIGHT", -10, 10)
gwListBorder:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3},
})
gwListBorder:SetBackdropColor(0.04, 0.04, 0.06, 0.8)
gwListBorder:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)

local gwScrollFrame = CreateFrame("ScrollFrame", nil, gwListBorder, "UIPanelScrollFrameTemplate")
gwScrollFrame:SetPoint("TOPLEFT", gwListBorder, "TOPLEFT", 5, -5)
gwScrollFrame:SetPoint("BOTTOMRIGHT", gwListBorder, "BOTTOMRIGHT", -25, 5)

local gwScrollChild = CreateFrame("Frame", nil, gwScrollFrame)
gwScrollChild:SetSize(gwScrollFrame:GetWidth(), 1)
gwScrollFrame:SetScrollChild(gwScrollChild)

local gwEmptyText = guildWatchContainer:CreateFontString(nil, "OVERLAY", "GameFontDisable")
gwEmptyText:SetPoint("CENTER", gwListBorder, "CENTER", 0, 0)
gwEmptyText:SetText(L["GuildWatchlistEmpty"] or "No guilds in watchlist.")

-- Refresh function
function iWR:RefreshGuildWatchlist()
    -- Clear existing rows
    local children = {gwScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    if not iWRSettings.GuildWatchlist or not next(iWRSettings.GuildWatchlist) then
        gwEmptyText:Show()
        gwScrollChild:SetHeight(1)
        return
    end

    gwEmptyText:Hide()

    -- Sort alphabetically
    local sorted = {}
    for guildName, data in pairs(iWRSettings.GuildWatchlist) do
        local typeVal, author, note
        if type(data) == "table" then
            typeVal = data.type
            author = data.author
            note = data.note or ""
        else
            typeVal = data
            author = ""
            note = ""
            iWRSettings.GuildWatchlist[guildName] = { type = typeVal, author = "", note = "" }
        end
        table.insert(sorted, {name = guildName, typeVal = typeVal, author = author, note = note})
    end
    table.sort(sorted, function(a, b) return a.name:lower() < b.name:lower() end)

    local ROW_HEIGHT = 24
    local yOffset = 0

    for i, entry in ipairs(sorted) do
        local row = CreateFrame("Frame", nil, gwScrollChild)
        row:SetSize(gwScrollChild:GetWidth(), ROW_HEIGHT)
        row:SetPoint("TOPLEFT", gwScrollChild, "TOPLEFT", 0, yOffset)

        -- Alternating row background
        if i % 2 == 0 then
            local rowBg = row:CreateTexture(nil, "BACKGROUND")
            rowBg:SetAllPoints(row)
            rowBg:SetColorTexture(1, 1, 1, 0.03)
        end

        -- Guild name (colored by type)
        local typeColor = iWR.Colors[entry.typeVal] or iWR.Colors.Gray
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("LEFT", row, "LEFT", 8, 0)
        nameText:SetText(typeColor .. entry.name .. "|r")

        -- Note text (truncated)
        if entry.note and entry.note ~= "" then
            local noteText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            noteText:SetPoint("LEFT", nameText, "RIGHT", 8, 0)
            local displayNote = #entry.note > 30 and (entry.note:sub(1, 27) .. "...") or entry.note
            noteText:SetText("|cFF808080" .. displayNote .. "|r")
        end

        -- Type label
        local typeName = iWR:GetTypeName(entry.typeVal)
        local typeLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        typeLabel:SetPoint("RIGHT", row, "RIGHT", -40, 0)
        local signStr = entry.typeVal > 0 and "+" or ""
        typeLabel:SetText(typeColor .. "[" .. signStr .. entry.typeVal .. " " .. typeName .. "]|r")

        -- Remove button
        local capturedName = entry.name
        local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        removeBtn:SetSize(22, 22)
        removeBtn:SetPoint("RIGHT", row, "RIGHT", -5, 0)
        removeBtn:SetText("X")
        removeBtn:SetNormalFontObject(GameFontNormalSmall)
        removeBtn:SetScript("OnClick", function()
            if iWRSettings.GuildWatchlist then
                iWRSettings.GuildWatchlist[capturedName] = nil
            end
            iWR:RefreshGuildWatchlist()
            print(string.format(L["GuildWatchlistRemoved"], capturedName))
        end)

        yOffset = yOffset - ROW_HEIGHT
    end

    gwScrollChild:SetHeight(math.max(math.abs(yOffset), 1))
end
