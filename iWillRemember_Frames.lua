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

local L = iWR.L
local print = function(...) iWR:PrintToChat(...) end

local IWR_RACE_ICONS = {
    HUMAN = "Interface\\Icons\\Achievement_Character_Human_Male",
    DWARF = "Interface\\Icons\\Achievement_Character_Dwarf_Male",
    NIGHTELF = "Interface\\Icons\\Achievement_Character_Nightelf_Male",
    GNOME = "Interface\\Icons\\Achievement_Character_Gnome_Male",
    DRAENEI = "Interface\\Icons\\Achievement_Character_Draenei_Male",
    ORC = "Interface\\Icons\\Achievement_Character_Orc_Male",
    SCOURGE = "Interface\\Icons\\Achievement_Character_Undead_Male",
    TAUREN = "Interface\\Icons\\Achievement_Character_Tauren_Male",
    TROLL = "Interface\\Icons\\Achievement_Character_Troll_Male",
    BLOODELF = "Interface\\Icons\\Achievement_Character_Bloodelf_Male",
}

local IWR_RACE_FACTIONS = {
    HUMAN = "Alliance", DWARF = "Alliance", NIGHTELF = "Alliance", GNOME = "Alliance", DRAENEI = "Alliance",
    ORC = "Horde", SCOURGE = "Horde", TAUREN = "Horde", TROLL = "Horde", BLOODELF = "Horde",
}

local function GetStoredClassToken(data)
    if data and data[12] and data[12] ~= "" then return data[12] end
    local colorCode = data and tostring(data[4] or ""):match("|c%x%x%x%x%x%x%x%x")
    if not colorCode then return nil end
    colorCode = colorCode:upper()
    for classToken, classColor in pairs(iWR.Colors.Classes or {}) do
        if tostring(classColor):sub(1, 10):upper() == colorCode then
            return classToken
        end
    end
end

-- Main Panel
iWRPanel = iWR:CreateiWRStyleFrame(UIParent, 370, 320, {"CENTER", UIParent, "CENTER"})
iWRPanel:Hide()
iWRPanel:EnableMouse(true)
iWRPanel:SetMovable(true)
iWRPanel:SetFrameStrata("MEDIUM")
iWRPanel:SetClampedToScreen(true)
iWR:StyleSurface(iWRPanel, "panel")

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
iWR:StyleSurface(titleBar, "header")

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
titleText:SetPoint("LEFT", titleBar, "LEFT", 14, 0)
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
iWR:StyleSurface(menuContent, "surface")

-- ╭───────────────────────────────────────────╮
-- │          Player Name Input                │
-- ╰───────────────────────────────────────────╯
local playerNameTitle = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
playerNameTitle:SetPoint("TOPLEFT", menuContent, "TOPLEFT", 20, -10)
playerNameTitle:SetText("|cFFEBC77A" .. L["PlayerNameHeader"] .. "|r")

local playerIdentityRow = CreateFrame("Frame", nil, menuContent)
playerIdentityRow:SetSize(310, 26)
playerIdentityRow:SetPoint("TOPLEFT", playerNameTitle, "BOTTOMLEFT", 0, -6)

iWRNameInput = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
iWRNameInput:SetSize(310, 26)
iWRNameInput:SetPoint("TOPLEFT", playerIdentityRow, "TOPLEFT", 0, 0)
iWRNameInput:SetMaxLetters(40)
iWRNameInput:SetAutoFocus(false)
iWRNameInput:SetTextColor(1, 1, 1, 1)
iWRNameInput:SetText(L["DefaultNameInput"])
iWRNameInput:SetFontObject(GameFontHighlight)
iWRNameInput:SetJustifyH("LEFT")
iWR:StyleEditBox(iWRNameInput)

local playerRaceIcon = playerIdentityRow:CreateTexture(nil, "ARTWORK")
playerRaceIcon:SetSize(24, 24)
playerRaceIcon:SetTexCoord(0, 1, 0, 1)
playerRaceIcon:Hide()

local playerFactionIcon = playerIdentityRow:CreateTexture(nil, "OVERLAY")
playerFactionIcon:SetSize(11, 11)
playerFactionIcon:Hide()

local playerClassIcon = playerIdentityRow:CreateTexture(nil, "ARTWORK")
playerClassIcon:SetSize(24, 24)
playerClassIcon:Hide()

local playerFactionStandalone = playerIdentityRow:CreateTexture(nil, "ARTWORK")
playerFactionStandalone:SetSize(22, 22)
playerFactionStandalone:Hide()

local function ResolvePlayerInputIdentity(name)
    name = StripColorCodes(name or "")
    if name == "" or name == L["DefaultNameInput"] then return end

    local function Known(value)
        return value ~= nil and value ~= "" and value ~= "UNKNOWN" and value or nil
    end

    local classToken, raceToken, factionToken
    local databaseKey = iWR:GetPlayerDatabaseKey(name)
    local data = databaseKey and iWRDatabase[databaseKey]
    if data then
        classToken = Known(GetStoredClassToken(data))
        raceToken = Known(data[13])
        factionToken = Known(data[8])
    end

    local pending = iWR.PendingNoteIdentity
    if pending and iWR:IsSamePlayerName(pending.name, name) then
        classToken = classToken or Known(pending.class)
        raceToken = raceToken or Known(pending.race)
        factionToken = factionToken or Known(pending.faction)
    end

    local groupLog = iWRMemory and iWRMemory.GroupLog or {}
    for index = #groupLog, 1, -1 do
        local entry = groupLog[index]
        if entry and iWR:IsSamePlayerName(entry.name, name) then
            classToken = classToken or Known(entry.class)
            raceToken = raceToken or Known(entry.race)
            factionToken = factionToken or Known(entry.faction)
            break
        end
    end

    if UnitExists("target") and UnitIsPlayer("target") then
        local targetName, targetRealm = UnitName("target")
        local secret = issecretvalue and targetName and issecretvalue(targetName)
        local resolvedTargetName
        if targetName and not secret then
            resolvedTargetName = select(2, iWR:GetPlayerDatabaseKey(targetName, targetRealm))
        end
        if not secret and resolvedTargetName and iWR:IsSamePlayerName(resolvedTargetName, name) then
            classToken = classToken or select(2, UnitClass("target"))
            raceToken = raceToken or select(2, UnitRace("target"))
            factionToken = factionToken or UnitFactionGroup("target")
        end
    end

    return classToken, raceToken, factionToken
end

local function UpdatePlayerInputIdentity()
    local classToken, raceToken, factionToken = ResolvePlayerInputIdentity(iWRNameInput:GetText())
    raceToken = raceToken and tostring(raceToken):upper() or nil
    classToken = classToken and tostring(classToken):upper() or nil
    factionToken = factionToken or IWR_RACE_FACTIONS[raceToken]

    playerRaceIcon:Hide()
    playerFactionIcon:Hide()
    playerClassIcon:Hide()
    playerFactionStandalone:Hide()

    local offset = 0
    local raceTexture = IWR_RACE_ICONS[raceToken]
    if raceTexture then
        playerRaceIcon:ClearAllPoints()
        playerRaceIcon:SetPoint("LEFT", playerIdentityRow, "LEFT", offset, 0)
        playerRaceIcon:SetTexture(raceTexture)
        playerRaceIcon:Show()
        offset = offset + 28

        if factionToken == "Horde" or factionToken == "Alliance" then
            playerFactionIcon:ClearAllPoints()
            playerFactionIcon:SetPoint("BOTTOMLEFT", playerRaceIcon, "BOTTOMLEFT", -2, -2)
            playerFactionIcon:SetTexture(factionToken == "Horde"
                and "Interface\\Icons\\INV_BannerPVP_01" or "Interface\\Icons\\INV_BannerPVP_02")
            playerFactionIcon:Show()
        end
    elseif factionToken == "Horde" or factionToken == "Alliance" then
        playerFactionStandalone:ClearAllPoints()
        playerFactionStandalone:SetPoint("LEFT", playerIdentityRow, "LEFT", offset, 0)
        playerFactionStandalone:SetTexture(factionToken == "Horde"
            and "Interface\\Icons\\INV_BannerPVP_01" or "Interface\\Icons\\INV_BannerPVP_02")
        playerFactionStandalone:Show()
        offset = offset + 26
    end

    local classCoords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
    if classCoords then
        playerClassIcon:ClearAllPoints()
        playerClassIcon:SetPoint("LEFT", playerIdentityRow, "LEFT", offset, 0)
        playerClassIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        playerClassIcon:SetTexCoord(unpack(classCoords))
        playerClassIcon:Show()
        offset = offset + 28
    end

    iWRNameInput:ClearAllPoints()
    iWRNameInput:SetPoint("TOPLEFT", playerIdentityRow, "TOPLEFT", offset, 0)
    iWRNameInput:SetSize(310 - offset, 26)
end

iWRNameInput:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        local text = self:GetText()
        local cleanedText = StripColorCodes(text)
        if text ~= cleanedText then
            self:SetText(cleanedText)
        end
    end
    UpdatePlayerInputIdentity()
end)

iWR:AttachAutocomplete(iWRNameInput, function()
    local suggestions = {}
    local seen = {}
    local groupLog = iWRMemory and iWRMemory.GroupLog or {}
    for index = #groupLog, 1, -1 do
        local entry = groupLog[index]
        local name = entry and StripColorCodes(entry.name or "") or ""
        if name ~= "" then
            local databaseKey = iWR:GetPlayerDatabaseKey(name, entry.realm)
            local dedupeKey = databaseKey or name:lower()
            if not seen[dedupeKey] then
                seen[dedupeKey] = true
                local classToken = entry.class
                local classColor = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
                local label = classColor and ("|c" .. classColor.colorStr .. name .. "|r") or name
                local detailParts = {}
                if entry.zone and entry.zone ~= "" then detailParts[#detailParts + 1] = entry.zone end
                if entry.date and entry.date ~= "" then detailParts[#detailParts + 1] = entry.date end
                suggestions[#suggestions + 1] = {
                    value = name,
                    label = label,
                    detail = table.concat(detailParts, " - "),
                    search = name,
                    class = entry.class,
                    race = entry.race,
                    faction = entry.faction,
                }
            end
        end
    end
    return suggestions
end)

-- ╭───────────────────────────────────────────╮
-- │          Note Input                        │
-- ╰───────────────────────────────────────────╯
local noteTitle = menuContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
noteTitle:SetPoint("TOPLEFT", playerIdentityRow, "BOTTOMLEFT", 0, -10)
noteTitle:SetText("|cFFEBC77A" .. L["NoteHeader"] .. "|r")

iWRNoteInput = CreateFrame("EditBox", nil, menuContent, "InputBoxTemplate")
iWRNoteInput:SetSize(310, 26)
iWRNoteInput:SetPoint("TOPLEFT", noteTitle, "BOTTOMLEFT", 0, -6)
iWRNoteInput:SetMultiLine(false)
iWRNoteInput:SetMaxLetters(99)
iWRNoteInput:SetAutoFocus(false)
iWRNoteInput:SetTextColor(1, 1, 1, 1)
iWRNoteInput:SetText(L["DefaultNoteInput"])
iWRNoteInput:SetFontObject(GameFontHighlight)
iWR:StyleEditBox(iWRNoteInput)

-- Relation controls share one contained card in both slider and compact modes.
local relationCard = CreateFrame("Frame", nil, menuContent, "BackdropTemplate")
relationCard:SetPoint("TOPLEFT", iWRNoteInput, "BOTTOMLEFT", -10, -12)
relationCard:SetPoint("TOPRIGHT", iWRNoteInput, "BOTTOMRIGHT", 10, -12)
relationCard:SetHeight(112)
iWR:StyleSurface(relationCard, "surfaceRaised")

-- ╭────────────────────╮
-- │     Help Icon      │
-- ╰────────────────────╯
local helpIcon = CreateFrame("Button", nil, titleBar)
iWR:StyleButton(helpIcon)
helpIcon:SetSize(22, 22)
helpIcon:SetPoint("RIGHT", closeButton, "LEFT", -2, 0)
local helpText = helpIcon:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
helpText:SetPoint("CENTER", helpIcon, "CENTER", 0, 0)
helpText:SetText("?")
helpText:SetTextColor(1, 0.59, 0.09)

helpIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["HelpTooltipTitle"], 1, 0.85, 0.1)
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
local sliderSeparator = relationCard:CreateTexture(nil, "ARTWORK")
sliderSeparator:SetPoint("TOPLEFT", relationCard, "TOPLEFT", 12, -27)
sliderSeparator:SetPoint("TOPRIGHT", relationCard, "TOPRIGHT", -12, -27)
sliderSeparator:SetHeight(1)
sliderSeparator:SetColorTexture(0.78, 0.53, 0.18, 0.45)

-- "Relation Level" section header
local sliderHeader = relationCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sliderHeader:SetPoint("TOPLEFT", relationCard, "TOPLEFT", 12, -9)
sliderHeader:SetText("|cFFEBC77A" .. L["RelationLevelHeader"] .. "|r")

local relationIconFrame = CreateFrame("Frame", nil, relationCard, "BackdropTemplate")
relationIconFrame:SetSize(40, 40)
relationIconFrame:SetPoint("TOPLEFT", relationCard, "TOPLEFT", 12, -36)
iWR:StyleSurface(relationIconFrame, "surface")

-- Type icon (left side, shows current relation level icon)
local sliderIcon = relationIconFrame:CreateTexture(nil, "ARTWORK")
sliderIcon:SetSize(30, 30)
sliderIcon:SetPoint("CENTER", relationIconFrame, "CENTER", 0, 0)
sliderIcon:SetTexture(iWR:GetIcon(0))

-- Custom slider track
local SLIDER_WIDTH = 250
local SLIDER_HEIGHT = 12

local sliderTrack = CreateFrame("Frame", nil, relationCard, "BackdropTemplate")
sliderTrack:SetSize(SLIDER_WIDTH, SLIDER_HEIGHT)
sliderTrack:SetPoint("TOPLEFT", relationCard, "TOPLEFT", 62, -39)
sliderTrack:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
})
sliderTrack:SetBackdropColor(0.025, 0.022, 0.018, 0.95)
sliderTrack:SetBackdropBorderColor(0.42, 0.35, 0.19, 1)

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
thumbTex:SetSize(5, 18)
thumbTex:SetPoint("CENTER")
thumbTex:SetColorTexture(1, 0.59, 0.09, 1)

local thumbGlow = sliderThumb:CreateTexture(nil, "ARTWORK")
thumbGlow:SetSize(11, 20)
thumbGlow:SetPoint("CENTER")
thumbGlow:SetColorTexture(1, 0.59, 0.09, 0.16)

-- Min/Max labels
local sliderLowLabel = relationCard:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
sliderLowLabel:SetPoint("TOPLEFT", sliderTrack, "BOTTOMLEFT", 0, -2)
sliderLowLabel:SetText("|cFF999999-10|r")

local sliderHighLabel = relationCard:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
sliderHighLabel:SetPoint("TOPRIGHT", sliderTrack, "BOTTOMRIGHT", 0, -2)
sliderHighLabel:SetText("|cFF999999+10|r")

-- Value label (centered under slider, shows "±N — TypeName")
local sliderValueText = relationCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sliderValueText:SetPoint("TOP", sliderTrack, "BOTTOM", 0, -11)
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
-- │      Personal Note Checkbox               │
-- ╰──────────────────────────────────────────╯
local isPersonalNote = false

local personalCheckbox = CreateFrame("CheckButton", nil, relationCard, "InterfaceOptionsCheckButtonTemplate")
personalCheckbox:SetPoint("BOTTOMLEFT", relationCard, "BOTTOMLEFT", 59, 5)
personalCheckbox:SetChecked(false)
personalCheckbox:SetScript("OnClick", function(self)
    isPersonalNote = self:GetChecked()
end)

local personalLabel = relationCard:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
personalLabel:SetPoint("LEFT", personalCheckbox, "RIGHT", 0, 0)
personalLabel:SetText("|cFF999999" .. L["PersonalCheckbox"] .. "|r")

function iWR:SetPersonalCheckbox(state)
    isPersonalNote = state and true or false
    personalCheckbox:SetChecked(isPersonalNote)
end

-- ╭──────────────────────────────────────────╮
-- │      Save Note Button                     │
-- ╰──────────────────────────────────────────╯
local saveNoteButton = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
iWR:StyleButton(saveNoteButton)
saveNoteButton:SetText(L["SaveNote"] or "Save Note")
saveNoteButton:SetSize(126, 26)
saveNoteButton:SetPoint("TOP", relationCard, "BOTTOM", -66, -10)
saveNoteButton:SetScript("OnClick", function()
    if currentSliderValue == 0 then
        -- Only clear if the entry already exists; level 0 with no entry does nothing
        local checkName = StripColorCodes(iWRNameInput:GetText() or "")
        local checkRealm = iWR.CurrentRealm
        if not iWR:IsForeverClient() and string.find(checkName, "-") then
            checkName, checkRealm = strsplit("-", checkName)
        end
        if checkName and checkName ~= "" then
            local cName, cRealm = iWR:FormatNameAndRealm(checkName, checkRealm)
            if iWRDatabase[cName .. "-" .. cRealm] then
                iWR:ClearNote(iWRNameInput:GetText())
            end
        end
    else
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), currentSliderValue, isPersonalNote)
    end
end)

local clearNoteButton = CreateFrame("Button", nil, menuContent, "UIPanelButtonTemplate")
iWR:StyleButton(clearNoteButton, true)
clearNoteButton:SetText(L["ClearButton"])
clearNoteButton:SetSize(126, 26)
clearNoteButton:SetPoint("LEFT", saveNoteButton, "RIGHT", 8, 0)
clearNoteButton:SetScript("OnClick", function()
    iWR:ClearNote(iWRNameInput:GetText())
end)

-- ╭──────────────────────────────────────────╮
-- │      Simple Menu (button mode)           │
-- ╰──────────────────────────────────────────╯
local simpleContainer = CreateFrame("Frame", nil, relationCard)
simpleContainer:SetPoint("TOP", relationCard, "TOP", 0, -5)
simpleContainer:SetSize(320, 75)
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
    local containerWidth = 320
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
        iWR:StyleButton(btn, value == 0)
        btn:SetSize(btnSize, btnSize)
        btn:SetPoint("TOP", simpleContainer, "TOP", xOffset, yOffset)
        btn:SetText("")

        btn:SetScript("OnClick", function()
            if value == 0 then
                iWR:ClearNote(iWRNameInput:GetText())
            else
                iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), value, isPersonalNote)
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
            labelText = iWR:GetTypeName(0) ~= "" and iWR:GetTypeName(0) or L["ClearButton"]
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
local openDatabaseButton = CreateFrame("Button", nil, titleBar)
iWR:StyleButton(openDatabaseButton)
openDatabaseButton:SetSize(22, 22)
openDatabaseButton:SetPoint("RIGHT", helpIcon, "LEFT", -3, 0)
openDatabaseButton:SetScript("OnClick", function()
    iWR:DatabaseToggle()
    iWR:PopulateDatabase()
    iWR:MenuClose()
end)

local iconTextureDB = openDatabaseButton:CreateTexture(nil, "ARTWORK")
iconTextureDB:SetSize(16, 16)
iconTextureDB:SetPoint("CENTER", openDatabaseButton, "CENTER", 0, 0)
iconTextureDB:SetTexture(iWR.Icons.Database)

openDatabaseButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["OpenDatabase"], 1, 0.82, 0)
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
        relationIconFrame:Hide()
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

        relationCard:SetHeight(math.max(112, simpleContainer:GetHeight() + 37))
        iWRPanel:SetHeight(282)
    else
        sliderSeparator:Show()
        sliderHeader:Show()
        relationIconFrame:Show()
        sliderTrack:Show()
        sliderThumb:Show()
        sliderLowLabel:Show()
        sliderHighLabel:Show()
        sliderValueText:Show()
        saveNoteButton:Show()
        clearNoteButton:Show()
        simpleContainer:Hide()
        relationCard:SetHeight(112)

        -- Restore the full compact form with footer actions.
        iWRPanel:SetHeight(320)
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
iWRDatabaseFrame:SetScale(math.max(0.6, math.min(2, tonumber(iWRSettings.DatabaseWindowScale) or 1)))
iWR:StyleSurface(iWRDatabaseFrame, "panel")

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

-- iRC-style scale handle. Scaling preserves the database layout while allowing
-- the whole window to be made comfortably larger or smaller.
local dbResizeHandle = CreateFrame("Button", nil, iWRDatabaseFrame)
dbResizeHandle:SetSize(20, 20)
dbResizeHandle:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, "BOTTOMRIGHT", -3, 3)
dbResizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
dbResizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
dbResizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
dbResizeHandle:SetFrameLevel(iWRDatabaseFrame:GetFrameLevel() + 20)
dbResizeHandle:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" then return end
    local x, y = GetCursorPosition()
    self.dragging = true
    self.startX = x
    self.startY = y
    self.startScale = iWRDatabaseFrame:GetScale()
end)
dbResizeHandle:SetScript("OnUpdate", function(self)
    if not self.dragging then return end
    local x, y = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale() or 1
    local delta = ((x - self.startX) - (y - self.startY)) / (2 * uiScale)
    iWRDatabaseFrame:SetScale(math.max(0.6, math.min(2, self.startScale + delta / 625)))
end)
dbResizeHandle:SetScript("OnMouseUp", function(self)
    if not self.dragging then return end
    self.dragging = false
    local scale = math.floor(iWRDatabaseFrame:GetScale() * 20 + 0.5) / 20
    iWRDatabaseFrame:SetScale(scale)
    iWRSettings.DatabaseWindowScale = scale
end)
dbResizeHandle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine("Scale database window", 1, 0.82, 0)
    GameTooltip:AddLine("Drag to resize the entire panel", 0.65, 0.65, 0.65)
    GameTooltip:Show()
end)
dbResizeHandle:SetScript("OnLeave", function() GameTooltip:Hide() end)
iWRDatabaseFrame:HookScript("OnHide", function()
    dbResizeHandle.dragging = false
end)
iWRDatabaseFrame.resizeHandle = dbResizeHandle

-- Create the title bar for the database frame
local dbTitleBar = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbTitleBar:SetSize(iWRDatabaseFrame:GetWidth(), 31)
dbTitleBar:SetPoint("TOP", iWRDatabaseFrame, "TOP", 0, 0)
iWR:StyleSurface(dbTitleBar, "header")

-- Add title text
local dbTitleText = dbTitleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
dbTitleText:SetPoint("CENTER", dbTitleBar, "CENTER", 0, 0)
dbTitleText:SetText(iWR.Colors.iWR .. L["PersonalDatabaseTitle"])
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
iWR:StyleSurface(dbSidebar, "surface")

-- Content area (OptionsPanel style)
local dbContentArea = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbContentArea:SetPoint("TOPLEFT", dbSidebar, "TOPRIGHT", 6, 0)
dbContentArea:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, "BOTTOMRIGHT", -10, 10)
iWR:StyleSurface(dbContentArea, "surface")

-- Forward declaration (used in OnClick before definition)
local ShowDatabaseTab

-- Sidebar button creation helper
local function CreateSidebarButton(parent, label, index, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    iWR:StyleButton(btn)
    btn:SetSize(dbSidebarWidth - 12, 26)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, yOffset)

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
dbEntryCount:SetText("|cFF808080" .. string.format(L["EntriesCount"], 0) .. "|r")

local dbGroupLogBtn = CreateSidebarButton(dbSidebar, L["GroupLogTab"] or "Group Log", 2, -52)
dbSidebarButtons[2] = dbGroupLogBtn

local dbGuildsBtn = CreateSidebarButton(dbSidebar, L["GuildsTab"] or "Guilds", 3, -78)
dbSidebarButtons[3] = dbGuildsBtn

-- Notes container (inside content area)
local notesContainer = CreateFrame("Frame", nil, dbContentArea)
notesContainer:SetPoint("TOPLEFT", dbContentArea, "TOPLEFT", 5, -5)
notesContainer:SetPoint("BOTTOMRIGHT", dbContentArea, "BOTTOMRIGHT", -5, 5)
notesContainer:Show()

-- ╭──────────────────────────────────────────────╮
-- │      Database Filter & Search                 │
-- ╰──────────────────────────────────────────────╯
local dbSearchFilter = ""
local dbNoteFilter = "all" -- "all", "mine", "friends"

-- Filter buttons (left side): All | Mine | Friends
local filterButtons = {}
local filterValues = {"all", "mine", "friends"}
local filterLabels = {L["FilterAll"], L["FilterMine"], L["FilterFriends"]}

local function UpdateFilterButtons()
    for i, btn in ipairs(filterButtons) do
        iWR:SetButtonActive(btn, filterValues[i] == dbNoteFilter)
    end
end

for i = 1, 3 do
    local btn = CreateFrame("Button", nil, notesContainer)
    iWR:StyleButton(btn)
    btn:SetSize(46, 20)
    if i == 1 then
        btn:SetPoint("TOPLEFT", notesContainer, "TOPLEFT", 4, -5)
    else
        btn:SetPoint("LEFT", filterButtons[i - 1], "RIGHT", 2, 0)
    end

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    text:SetText(filterLabels[i])
    btn.text = text

    btn:SetScript("OnClick", function()
        dbNoteFilter = filterValues[i]
        UpdateFilterButtons()
        iWR:PopulateDatabase()
    end)

    filterButtons[i] = btn
end

UpdateFilterButtons()

-- Search (right side): magnifying glass + edit box + X button
local dbSearchIcon = notesContainer:CreateTexture(nil, "ARTWORK")
dbSearchIcon:SetSize(15, 15)
dbSearchIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
dbSearchIcon:SetDesaturated(true)
dbSearchIcon:SetVertexColor(0.78, 0.66, 0.43)

local dbSearchBox = CreateFrame("EditBox", nil, notesContainer, "InputBoxTemplate")
iWR:StyleEditBox(dbSearchBox)
dbSearchBox:SetSize(282, 24)
dbSearchBox:SetPoint("TOPRIGHT", notesContainer, "TOPRIGHT", -4, -3)
dbSearchBox:SetAutoFocus(false)
dbSearchBox:SetMaxLetters(40)
dbSearchBox:SetFontObject(GameFontHighlight)
dbSearchBox:SetTextInsets(31, 28, 0, 0)
dbSearchIcon:SetPoint("LEFT", dbSearchBox, "LEFT", 9, 0)

local dbSearchPlaceholder = dbSearchBox:CreateFontString(nil, "ARTWORK", "GameFontDisable")
dbSearchPlaceholder:SetPoint("LEFT", dbSearchBox, "LEFT", 31, 0)
dbSearchPlaceholder:SetPoint("RIGHT", dbSearchBox, "RIGHT", -28, 0)
dbSearchPlaceholder:SetJustifyH("LEFT")
dbSearchPlaceholder:SetText(L["SearchPlaceholder"])

-- Clear button (X) — appears when search has text
local dbSearchClearBtn = CreateFrame("Button", nil, dbSearchBox)
dbSearchClearBtn:SetSize(22, 20)
dbSearchClearBtn:SetPoint("RIGHT", dbSearchBox, "RIGHT", -2, 0)
local dbSearchClearText = dbSearchClearBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
dbSearchClearText:SetPoint("CENTER", 0, 1)
dbSearchClearText:SetText("x")
dbSearchClearText:SetTextColor(0.72, 0.58, 0.36)
dbSearchClearBtn:SetScript("OnEnter", function()
    dbSearchClearText:SetTextColor(1, 0.59, 0.09)
end)
dbSearchClearBtn:SetScript("OnLeave", function()
    dbSearchClearText:SetTextColor(0.72, 0.58, 0.36)
end)
dbSearchClearBtn:Hide()
dbSearchClearBtn:SetScript("OnClick", function()
    dbSearchBox:SetText("")
    dbSearchBox:ClearFocus()
    dbSearchFilter = ""
    iWR:PopulateDatabase()
end)

dbSearchBox:SetScript("OnTextChanged", function(self, userInput)
    local text = self:GetText()
    dbSearchPlaceholder:SetShown(text == "")
    dbSearchClearBtn:SetShown(text ~= "")
    if userInput then
        dbSearchFilter = text:lower()
        iWR:PopulateDatabase()
    end
end)

dbSearchBox:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    dbSearchFilter = ""
    iWR:PopulateDatabase()
end)

dbSearchBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)

iWR:AttachAutocomplete(dbSearchBox, function()
    local suggestions = {}
    for databaseKey, data in pairs(iWRDatabase or {}) do
        local name = StripColorCodes((type(data) == "table" and data[4]) or databaseKey or "")
        if name ~= "" then
            suggestions[#suggestions + 1] = {
                value = name,
                label = name,
                detail = iWR:GetTypeName(type(data) == "table" and data[2] or 0),
                search = name,
            }
        end
    end
    table.sort(suggestions, function(left, right)
        return left.value:lower() < right.value:lower()
    end)
    return suggestions
end, {
    frameStrata = "DIALOG",
    onSelect = function(entry)
        dbSearchFilter = tostring(entry and entry.value or ""):lower()
        dbSearchPlaceholder:SetShown(dbSearchFilter == "")
        dbSearchClearBtn:SetShown(dbSearchFilter ~= "")
        iWR:PopulateDatabase()
    end,
})

-- Expose for clearing/resetting from DatabaseOpen
function iWR:ClearDatabaseSearch()
    dbSearchFilter = ""
    dbSearchBox:SetText("")
    dbSearchPlaceholder:Show()
    dbSearchClearBtn:Hide()
end

function iWR:ResetDatabaseFilter()
    dbNoteFilter = "all"
    UpdateFilterButtons()
end

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
        iWR:SetButtonActive(btn, i == tabIndex)
    end
end

-- Initialize first tab as active
ShowDatabaseTab(1)

-- Reset to Notes tab (called from DatabaseOpen to always start on Notes)
function iWR:ResetDatabaseTab()
    ShowDatabaseTab(1)
end

-- Notes tab: scrollable frame for database entries
local DB_COL_NAME = 0.40
local DB_COL_LEVEL = 0.16
local DB_COL_NOTE = 0.34
local DB_COL_ACTIONS = 0.10

local dbScrollFrame = CreateFrame("ScrollFrame", nil, notesContainer)
dbScrollFrame:SetPoint("TOPLEFT", notesContainer, "TOPLEFT", 0, -55)
dbScrollFrame:SetPoint("BOTTOMRIGHT", notesContainer, "BOTTOMRIGHT", 0, 45)

-- Create a container for the database entries (this will be scrollable)
local dbContainer = CreateFrame("Frame", nil, dbScrollFrame)
dbContainer:SetSize(dbScrollFrame:GetWidth(), dbScrollFrame:GetHeight())
dbScrollFrame:SetScrollChild(dbContainer)

-- Keep scrolling fully functional without showing Blizzard's scrollbar chrome.
local function ScrollDatabase(delta)
    local current = dbScrollFrame:GetVerticalScroll()
    local maximum = math.max(0, dbContainer:GetHeight() - dbScrollFrame:GetHeight())
    local target = math.max(0, math.min(maximum, current - (delta * 68)))
    dbScrollFrame:SetVerticalScroll(target)
end

dbScrollFrame:EnableMouseWheel(true)
dbScrollFrame:SetScript("OnMouseWheel", function(_, delta)
    ScrollDatabase(delta)
end)
dbContainer:EnableMouseWheel(true)
dbContainer:SetScript("OnMouseWheel", function(_, delta)
    ScrollDatabase(delta)
end)

-- Compact column header aligned to the scrolling rows.
local dbListHeader = CreateFrame("Frame", nil, notesContainer, "BackdropTemplate")
dbListHeader:SetPoint("BOTTOMLEFT", dbScrollFrame, "TOPLEFT", 0, 3)
dbListHeader:SetPoint("BOTTOMRIGHT", dbScrollFrame, "TOPRIGHT", 0, 3)
dbListHeader:SetHeight(22)
iWR:StyleSurface(dbListHeader, "surfaceRaised")

local headerWidth = dbContainer:GetWidth()
local function CreateDatabaseHeader(text, width, anchor, offset)
    local header = CreateFrame("Frame", nil, dbListHeader)
    header:SetSize(width, 20)
    header:SetPoint("TOPLEFT", dbListHeader, "TOPLEFT", offset, -1)
    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint(anchor or "LEFT", header, anchor or "LEFT", anchor == "CENTER" and 0 or 8, 0)
    label:SetText(text)
    label:SetTextColor(0.92, 0.78, 0.48)
    local divider = header:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, -3)
    divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 3)
    divider:SetWidth(1)
    divider:SetColorTexture(0.42, 0.35, 0.19, 0.55)
    return header
end

local headerOffset = 0
CreateDatabaseHeader(L["PlayerNameHeader"], headerWidth * DB_COL_NAME, "LEFT", headerOffset)
headerOffset = headerOffset + headerWidth * DB_COL_NAME
CreateDatabaseHeader(L["DatabaseRelationshipHeader"] or "Relationship", headerWidth * DB_COL_LEVEL, "CENTER", headerOffset)
headerOffset = headerOffset + headerWidth * DB_COL_LEVEL
CreateDatabaseHeader(L["NoteHeader"], headerWidth * DB_COL_NOTE, "LEFT", headerOffset)
headerOffset = headerOffset + headerWidth * DB_COL_NOTE
CreateDatabaseHeader(L["ActionsHeader"] or "Actions", headerWidth * DB_COL_ACTIONS, "CENTER", headerOffset)

-- ╭──────────────────────────────────────────────────╮
-- │      Create the "Clear All" Database Button      │
-- ╰──────────────────────────────────────────────────╯
local clearDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
iWR:StyleButton(clearDatabaseButton, true)
clearDatabaseButton:SetText(L["ClearAllButton"])
clearDatabaseButton:SetSize(math.max(100, clearDatabaseButton:GetTextWidth() + 24), 30)
clearDatabaseButton:SetPoint("BOTTOM", notesContainer, "BOTTOM", -60, 10)
clearDatabaseButton:SetScript("OnClick", function()
    -- Confirm before clearing the database
    StaticPopupDialogs["CLEAR_DATABASE_CONFIRM"] = {
        text = iWR.Colors.Red .. L["ClearDBConfirm"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            iWRDatabase = {}
            print(iWR.Colors.iWR .. L["ClearDBSuccess"])
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
iWR:StyleButton(shareDatabaseButton)
shareDatabaseButton:SetText(L["ShareFullDBButton"])
shareDatabaseButton:SetSize(math.max(100, shareDatabaseButton:GetTextWidth() + 24), 30)
shareDatabaseButton:SetPoint("BOTTOM", notesContainer, "BOTTOM", 60, 10)
shareDatabaseButton:SetScript("OnClick", function()
    -- Check if the database is empty
    if not next(iWRDatabase) then
        print(iWR.Colors.iWR .. L["ShareDBEmpty"])
        return
    end

    -- Confirm before sharing the database
    StaticPopupDialogs["SHARE_DATABASE_CONFIRM"] = {
        text = L["ShareDBConfirm"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            -- Function to share the full database
            iWR:SendFullDBUpdateToFriends()
            print(iWR.Colors.iWR .. L["ShareDBInitiated"])
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SHARE_DATABASE_CONFIRM")
end)

-- ╭─────────────────────────────────────────╮
-- │      Function to Populate Database      │
-- ╰─────────────────────────────────────────╯
function iWR:PopulateDatabase()
    -- Create sub-containers for columns if they don't already exist
    if not dbContainer.col1 then
        dbContainer.col1 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col1:SetSize(dbContainer:GetWidth() * DB_COL_NAME, dbContainer:GetHeight())
        dbContainer.col1:SetPoint("TOPLEFT", dbContainer, "TOPLEFT", 0, 0)
    end

    if not dbContainer.col1b then
        dbContainer.col1b = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col1b:SetSize(dbContainer:GetWidth() * DB_COL_LEVEL, dbContainer:GetHeight())
        dbContainer.col1b:SetPoint("TOPLEFT", dbContainer.col1, "TOPRIGHT", 0, 0)
    end

    if not dbContainer.col2 then
        dbContainer.col2 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col2:SetSize(dbContainer:GetWidth() * DB_COL_NOTE, dbContainer:GetHeight())
        dbContainer.col2:SetPoint("TOPLEFT", dbContainer.col1b, "TOPRIGHT", 0, 0)
    end

    if not dbContainer.col3 then
        dbContainer.col3 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col3:SetSize(dbContainer:GetWidth() * DB_COL_ACTIONS, dbContainer:GetHeight())
        dbContainer.col3:SetPoint("TOPLEFT", dbContainer.col2, "TOPRIGHT", 0, 0)
    end

    -- Reuse main row cells between refreshes. History rows are transient and
    -- remain outside this pool so they can never be mistaken for a player row.
    local reusedFrames = { col1 = {}, col1b = {}, col2 = {}, col3 = {} }
    local function resetColumn(column, pool)
        for _, child in ipairs({column:GetChildren()}) do
            child:Hide()
            if child.iWRDatabaseMainCell then
                table.insert(pool, child)
            end
        end
    end

    resetColumn(dbContainer.col1, reusedFrames.col1)
    resetColumn(dbContainer.col1b, reusedFrames.col1b)
    resetColumn(dbContainer.col2, reusedFrames.col2)
    resetColumn(dbContainer.col3, reusedFrames.col3)

    -- Categorize entries (with optional search and author filter)
    local categorizedData = {}
    local totalEntries = 0
    local filteredEntries = 0
    local myCharacters = iWRSettings and iWRSettings.MyCharacters or {}
    for playerName, data in pairs(iWRDatabase) do
        totalEntries = totalEntries + 1
        local includeEntry = true

        -- Apply author filter (Mine/Friends) — uses MyCharacters to include alts
        if dbNoteFilter == "mine" then
            local authorName = data[6] and StripColorCodes(data[6]) or ""
            local _, normalizedAuthor = iWR:GetPlayerDatabaseKey(authorName)
            if not normalizedAuthor or not myCharacters[normalizedAuthor] then
                includeEntry = false
            end
        elseif dbNoteFilter == "friends" then
            local authorName = data[6] and StripColorCodes(data[6]) or ""
            local _, normalizedAuthor = iWR:GetPlayerDatabaseKey(authorName)
            if normalizedAuthor and myCharacters[normalizedAuthor] then
                includeEntry = false
            end
        end

        -- Apply search filter: match player name or note
        if includeEntry and dbSearchFilter ~= "" then
            local nameMatch = playerName:lower():find(dbSearchFilter, 1, true)
            local noteMatch = data[1] and data[1]:lower():find(dbSearchFilter, 1, true)
            local displayMatch = data[4] and StripColorCodes(data[4]):lower():find(dbSearchFilter, 1, true)
            if not nameMatch and not noteMatch and not displayMatch then
                includeEntry = false
            end
        end

        if includeEntry then
            filteredEntries = filteredEntries + 1
            local category = data[2] or "Uncategorized"
            categorizedData[category] = categorizedData[category] or {}
            table.insert(categorizedData[category], { name = playerName, data = data })
        end
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
    local rowIndex = 0

    local function StyleDatabaseCell(frame, alternate)
        local background = frame.rowBackground or frame:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints(frame)
        if alternate then
            background:SetColorTexture(0.10, 0.072, 0.038, 0.62)
        else
            background:SetColorTexture(0.045, 0.038, 0.028, 0.78)
        end
        background:Show()
        frame.rowBackground = background

        local topBorder = frame.rowTopBorder or frame:CreateTexture(nil, "BORDER")
        topBorder:ClearAllPoints()
        topBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        topBorder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        topBorder:SetHeight(1)
        topBorder:SetColorTexture(0.42, 0.35, 0.19, 0.34)
        topBorder:Show()
        frame.rowTopBorder = topBorder

        local bottomBorder = frame.rowBottomBorder or frame:CreateTexture(nil, "BORDER")
        bottomBorder:ClearAllPoints()
        bottomBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        bottomBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        bottomBorder:SetHeight(1)
        bottomBorder:SetColorTexture(0.42, 0.35, 0.19, 0.22)
        bottomBorder:Show()
        frame.rowBottomBorder = bottomBorder

        if frame.rowSeparator then frame.rowSeparator:Hide() end
    end

    for _, category in ipairs(sortedCategories) do
        if #categorizedData[category] > 0 then
            for _, entry in ipairs(categorizedData[category]) do
                local playerName, data = entry.name, entry.data
                local historyCount = data[10] and #data[10] or 0
                rowIndex = rowIndex + 1
                local alternateRow = rowIndex % 2 == 0

                -- Reuse or create frame in Col1 (Type Icon and Player Name)
                local col1Frame = reusedFrames.col1[rowIndex] or CreateFrame("Frame", nil, dbContainer.col1)
                col1Frame.iWRDatabaseMainCell = true
                col1Frame:ClearAllPoints()
                col1Frame:SetSize(dbContainer.col1:GetWidth(), 48)
                col1Frame:SetPoint("TOPLEFT", dbContainer.col1, "TOPLEFT", 0, yOffset)
                col1Frame:EnableMouse(true)
                col1Frame:Show()
                StyleDatabaseCell(col1Frame, alternateRow)

                -- Row hover highlight (manual, synced across all columns)
                local col1Highlight = col1Frame.highlight or col1Frame:CreateTexture(nil, "ARTWORK")
                col1Highlight:SetAllPoints()
                col1Highlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col1Highlight:Hide()
                col1Frame.highlight = col1Highlight

                local relationAccent = col1Frame.relationAccent or col1Frame:CreateTexture(nil, "ARTWORK")
                relationAccent:ClearAllPoints()
                relationAccent:SetPoint("TOPLEFT", col1Frame, "TOPLEFT", 0, -1)
                relationAccent:SetPoint("BOTTOMLEFT", col1Frame, "BOTTOMLEFT", 0, 1)
                relationAccent:SetWidth(3)
                if data[2] > 0 then
                    relationAccent:SetColorTexture(0.20, 0.78, 0.32, 0.9)
                elseif data[2] < 0 then
                    relationAccent:SetColorTexture(0.92, 0.22, 0.12, 0.9)
                else
                    relationAccent:SetColorTexture(0.72, 0.58, 0.28, 0.75)
                end
                relationAccent:Show()
                col1Frame.relationAccent = relationAccent

                if col1Frame.statusDot then col1Frame.statusDot:Hide() end

                local raceToken = data[13] and tostring(data[13]):upper() or nil
                local raceIcon = col1Frame.raceIcon or col1Frame:CreateTexture(nil, "ARTWORK")
                raceIcon:ClearAllPoints()
                raceIcon:SetSize(24, 24)
                raceIcon:SetPoint("LEFT", col1Frame, "LEFT", 10, 0)
                raceIcon:SetTexture(IWR_RACE_ICONS[raceToken] or "Interface\\Icons\\Achievement_General")
                raceIcon:SetAlpha(IWR_RACE_ICONS[raceToken] and 1 or 0.32)
                raceIcon:Show()
                col1Frame.raceIcon = raceIcon

                -- The faction flag is a small badge so identity icons remain readable.
                local factionIcon = col1Frame.factionIcon or col1Frame:CreateTexture(nil, "OVERLAY")
                factionIcon:ClearAllPoints()
                factionIcon:SetSize(11, 11)
                factionIcon:SetPoint("BOTTOMLEFT", raceIcon, "BOTTOMLEFT", -3, -3)
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

                local classToken = GetStoredClassToken(data)
                local classIcon = col1Frame.classIcon or col1Frame:CreateTexture(nil, "ARTWORK")
                classIcon:ClearAllPoints()
                classIcon:SetSize(24, 24)
                classIcon:SetPoint("LEFT", raceIcon, "RIGHT", 5, 0)
                local classCoords = classToken and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
                if classCoords then
                    classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
                    classIcon:SetTexCoord(unpack(classCoords))
                    classIcon:SetAlpha(1)
                else
                    classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                    classIcon:SetTexCoord(0, 1, 0, 1)
                    classIcon:SetAlpha(0.32)
                end
                classIcon:Show()
                col1Frame.classIcon = classIcon

                -- Older cached rows may still own the previous relationship icon cluster.
                if col1Frame.iconBorder then col1Frame.iconBorder:Hide() end
                if col1Frame.iconTexture then col1Frame.iconTexture:Hide() end
                if col1Frame.lockIcon then col1Frame.lockIcon:Hide() end

                local playerNameText = col1Frame.playerNameText or col1Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                playerNameText:SetFontObject(GameFontHighlight)
                playerNameText:ClearAllPoints()
                playerNameText:SetPoint("TOPLEFT", classIcon, "TOPRIGHT", 9, 1)
                playerNameText:SetPoint("RIGHT", col1Frame, "RIGHT", -8, 0)
                playerNameText:SetJustifyH("LEFT")
                playerNameText:SetWordWrap(false)
                local displayName = data[4]
                local listdisplayName = displayName
                if data[7] and data[7] ~= iWR.CurrentRealm then
                    listdisplayName = displayName .. " (*)"
                    displayName = displayName .. "-" .. data[7]
                end
                local databasekey = playerName

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

                playerNameText:SetText(listdisplayName)
                playerNameText:SetTextColor(1, 1, 1, 1)
                col1Frame.playerNameText = playerNameText

                local identityMeta = col1Frame.identityMeta or col1Frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                identityMeta:ClearAllPoints()
                identityMeta:SetPoint("BOTTOMLEFT", classIcon, "BOTTOMRIGHT", 9, -1)
                identityMeta:SetPoint("RIGHT", col1Frame, "RIGHT", -8, 0)
                identityMeta:SetJustifyH("LEFT")
                identityMeta:SetWordWrap(false)
                local privacyText
                if data[9] then
                    privacyText = "|TInterface\\Icons\\INV_Misc_Key_03:10:10:0:0|t |cFFC7A35A" .. (L["StatusPersonal"] or "Personal") .. "|r"
                else
                    privacyText = "|cFF888888" .. StripColorCodes(data[6] or "Shared") .. "|r"
                end
                identityMeta:SetText(privacyText)
                col1Frame.identityMeta = identityMeta

                -- Shared tooltip for all columns
                local function ShowEntryTooltip(owner)
                    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(listdisplayName, 1, 1, 1)
                    if data[7] then
                        GameTooltip:AddLine(L["DetailServer"] .. " " .. iWR.Colors.Reset .. data[7], 1, 0.82, 0)
                    end
                    if data[8] and data[8] ~= "" then
                        GameTooltip:AddLine(L["DetailFaction"] .. " " .. iWR.Colors.Reset .. data[8], 1, 0.82, 0)
                    end
                    if raceToken then
                        GameTooltip:AddLine("Race: " .. iWR.Colors.Reset .. raceToken, 1, 0.82, 0)
                    end
                    if classToken then
                        GameTooltip:AddLine("Class: " .. iWR.Colors.Reset .. classToken, 1, 0.82, 0)
                    end
                    local ttSign = data[2] > 0 and "+" or ""
                    local ttColor = iWR.Colors[data[2]] or iWR.Colors.Default
                    GameTooltip:AddLine(L["DetailType"] .. " " .. ttColor .. ttSign .. data[2] .. " — " .. iWR:GetTypeName(data[2]), 1, 0.82, 0)
                    if data[1] then
                        GameTooltip:AddLine(L["DetailNote"] .. " " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0)
                    end
                    if data[6] then
                        GameTooltip:AddLine(L["DetailAuthor"] .. " " .. data[6], 1, 0.82, 0)
                    end
                    if data[5] then
                        GameTooltip:AddLine(L["DetailDate"] .. " " .. data[5], 1, 0.82, 0)
                    end
                    if data[9] then
                        GameTooltip:AddLine(L["DetailStatus"] .. " " .. iWR.Colors.Gray .. L["StatusPersonal"], 1, 0.82, 0)
                    end
                    if data[10] and #data[10] > 0 then
                        GameTooltip:AddLine("|cFF808080" .. L["LeftClickNotes"] .. "|r", 0.5, 0.5, 0.5)
                    end
                    if canWhisper then
                        GameTooltip:AddLine("|cFF808080" .. L["RightClickWhisper"] .. "|r", 0.5, 0.5, 0.5)
                    end
                    GameTooltip:Show()
                end

                -- Tooltip and Click for Name column
                col1Frame:SetScript("OnEnter", function()
                    ShowEntryTooltip(col1Frame)
                end)
                col1Frame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                col1Frame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    elseif historyCount > 0 then
                        iWR.ExpandedEntries[databasekey] = not iWR.ExpandedEntries[databasekey]
                        iWR:PopulateDatabase()
                    else
                        iWR:ShowDetailWindow(databasekey)
                    end
                end)

                -- Reuse or create frame in Col1b (Level)
                local col1bFrame = reusedFrames.col1b[rowIndex] or CreateFrame("Frame", nil, dbContainer.col1b)
                col1bFrame.iWRDatabaseMainCell = true
                col1bFrame:ClearAllPoints()
                col1bFrame:SetSize(dbContainer.col1b:GetWidth(), 48)
                col1bFrame:SetPoint("TOPLEFT", dbContainer.col1b, "TOPLEFT", 0, yOffset)
                col1bFrame:Show()
                StyleDatabaseCell(col1bFrame, alternateRow)

                local col1bHighlight = col1bFrame.highlight or col1bFrame:CreateTexture(nil, "ARTWORK")
                col1bHighlight:SetAllPoints()
                col1bHighlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col1bHighlight:Hide()
                col1bFrame.highlight = col1bHighlight

                local levelText = col1bFrame.levelText or col1bFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                levelText:SetFontObject(GameFontHighlight)
                local levelBadge = col1bFrame.levelBadge or col1bFrame:CreateTexture(nil, "ARTWORK")
                levelBadge:ClearAllPoints()
                levelBadge:SetPoint("TOPLEFT", col1bFrame, "TOPLEFT", 5, -7)
                levelBadge:SetPoint("BOTTOMRIGHT", col1bFrame, "BOTTOMRIGHT", -5, 7)
                levelBadge:SetColorTexture(0, 0, 0, 0)
                col1bFrame.levelBadge = levelBadge

                local relationIcon = col1bFrame.relationIcon or col1bFrame:CreateTexture(nil, "OVERLAY")
                relationIcon:ClearAllPoints()
                relationIcon:SetSize(22, 22)
                relationIcon:SetPoint("LEFT", col1bFrame, "LEFT", 11, 0)
                relationIcon:SetTexture(iWR:GetIcon(data[2]) or "Interface\\Icons\\INV_Misc_QuestionMark")
                col1bFrame.relationIcon = relationIcon

                levelText:ClearAllPoints()
                levelText:SetPoint("TOPLEFT", relationIcon, "TOPRIGHT", 7, 2)
                levelText:SetPoint("RIGHT", col1bFrame, "RIGHT", -8, 0)
                levelText:SetJustifyH("LEFT")
                local levelColor = iWR.Colors[data[2]] or iWR.Colors.Default
                local levelSign = data[2] > 0 and "+" or ""
                levelText:SetText(levelColor .. iWR:GetTypeName(data[2]))
                col1bFrame.levelText = levelText

                local scoreText = col1bFrame.scoreText or col1bFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                scoreText:ClearAllPoints()
                scoreText:SetPoint("BOTTOMLEFT", relationIcon, "BOTTOMRIGHT", 7, -1)
                scoreText:SetPoint("RIGHT", col1bFrame, "RIGHT", -8, 0)
                scoreText:SetJustifyH("LEFT")
                scoreText:SetText(levelColor .. levelSign .. data[2] .. "|r")
                col1bFrame.scoreText = scoreText

                -- Reuse or create frame in Col2 (Notes)
                local col2Frame = reusedFrames.col2[rowIndex] or CreateFrame("Frame", nil, dbContainer.col2)
                col2Frame.iWRDatabaseMainCell = true
                col2Frame:ClearAllPoints()
                col2Frame:SetSize(dbContainer.col2:GetWidth(), 48)
                col2Frame:SetPoint("TOPLEFT", dbContainer.col2, "TOPLEFT", 0, yOffset)
                col2Frame:EnableMouse(true)
                col2Frame:Show()
                StyleDatabaseCell(col2Frame, alternateRow)

                local col2Highlight = col2Frame.highlight or col2Frame:CreateTexture(nil, "ARTWORK")
                col2Highlight:SetAllPoints()
                col2Highlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col2Highlight:Hide()
                col2Frame.highlight = col2Highlight

                local noteText = col2Frame.noteText or col2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                noteText:ClearAllPoints()
                noteText:SetPoint("TOPLEFT", col2Frame, "TOPLEFT", 10, -9)
                noteText:SetPoint("RIGHT", col2Frame, "RIGHT", -8, 0)
                noteText:SetJustifyH("LEFT")
                noteText:SetWordWrap(false)
                local noteColor = iWR.Colors[data[2]] or iWR.Colors.Default
                local maxNoteLen = math.max(24, math.floor((dbContainer.col2:GetWidth() - 20) / 6))
                local truncatedNote = data[1] and #data[1] > maxNoteLen and data[1]:sub(1, maxNoteLen - 3) .. "..." or data[1] or ""
                noteText:SetText(truncatedNote ~= "" and (noteColor .. truncatedNote)
                    or ("|cFF666666" .. (L["DatabaseNoteEmpty"] or "No written note") .. "|r"))
                col2Frame.noteText = noteText

                local noteMeta = col2Frame.noteMeta or col2Frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                noteMeta:ClearAllPoints()
                noteMeta:SetPoint("BOTTOMLEFT", col2Frame, "BOTTOMLEFT", 10, 8)
                noteMeta:SetPoint("RIGHT", col2Frame, "RIGHT", -8, 0)
                noteMeta:SetJustifyH("LEFT")
                noteMeta:SetWordWrap(false)
                local historyText = historyCount > 0 and string.format(L["NotesCount"], historyCount + 1)
                    or (L["DatabaseSingleNote"] or "1 note")
                local dateText = data[5] and data[5] ~= "" and ("  |cFF6F6656-|r  " .. data[5]) or ""
                noteMeta:SetText("|cFF888888" .. historyText .. dateText .. "|r")
                col2Frame.noteMeta = noteMeta

                -- Tooltip and Click for Notes column
                col2Frame:SetScript("OnEnter", function()
                    ShowEntryTooltip(col2Frame)
                end)
                col2Frame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                col2Frame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    elseif historyCount > 0 then
                        -- Toggle expand/collapse for entries with note history
                        iWR.ExpandedEntries[databasekey] = not iWR.ExpandedEntries[databasekey]
                        iWR:PopulateDatabase()
                    else
                        iWR:ShowDetailWindow(databasekey)
                    end
                end)

                -- Reuse or create frame in Col3 (Buttons)
                local col3Frame = reusedFrames.col3[rowIndex] or CreateFrame("Frame", nil, dbContainer.col3)
                col3Frame.iWRDatabaseMainCell = true
                col3Frame:ClearAllPoints()
                col3Frame:SetSize(dbContainer.col3:GetWidth(), 48)
                col3Frame:SetPoint("TOPLEFT", dbContainer.col3, "TOPLEFT", 0, yOffset)
                col3Frame:Show()
                StyleDatabaseCell(col3Frame, alternateRow)

                local col3Highlight = col3Frame.highlight or col3Frame:CreateTexture(nil, "ARTWORK")
                col3Highlight:SetAllPoints()
                col3Highlight:SetColorTexture(1, 0.59, 0.09, 0.08)
                col3Highlight:Hide()
                col3Frame.highlight = col3Highlight

                local editButton = col3Frame.editButton or CreateFrame("Button", nil, col3Frame)
                iWR:StyleButton(editButton)
                editButton:ClearAllPoints()
                editButton:SetSize(26, 26)
                editButton:SetPoint("CENTER", col3Frame, "CENTER", -15, 0)
                local editIcon = editButton.icon or editButton:CreateTexture(nil, "ARTWORK")
                editIcon:ClearAllPoints()
                editIcon:SetSize(16, 16)
                editIcon:SetPoint("CENTER")
                editIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_05")
                editButton.icon = editIcon
                editButton:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:AddLine(L["EditButton"] or "Edit", 1, 0.82, 0)
                    GameTooltip:AddLine(listdisplayName, 0.75, 0.75, 0.75)
                    GameTooltip:Show()
                end)
                editButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
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

                local removeButton = col3Frame.removeButton or CreateFrame("Button", nil, col3Frame)
                iWR:StyleButton(removeButton, true)
                removeButton:ClearAllPoints()
                removeButton:SetSize(26, 26)
                removeButton:SetPoint("CENTER", col3Frame, "CENTER", 15, 0)
                local removeIcon = removeButton.icon or removeButton:CreateTexture(nil, "ARTWORK")
                removeIcon:ClearAllPoints()
                removeIcon:SetSize(16, 16)
                removeIcon:SetPoint("CENTER")
                removeIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
                removeButton.icon = removeIcon
                removeButton:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    GameTooltip:AddLine(L["RemoveButton"] or "Remove", 1, 0.35, 0.25)
                    GameTooltip:AddLine(listdisplayName, 0.75, 0.75, 0.75)
                    GameTooltip:Show()
                end)
                removeButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
                removeButton:SetScript("OnClick", function()
                    local removeText
                    if iWRDatabase[databasekey][7] ~= iWR.CurrentRealm then
                        removeText = iWR.Colors.iWR .. string.format(L["RemoveConfirmCrossRealm"], iWRDatabase[databasekey][4], iWRDatabase[databasekey][7])
                    else
                        removeText = iWR.Colors.iWR .. string.format(L["RemoveConfirmSameRealm"], iWRDatabase[databasekey][4])
                    end
                    StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                        text = removeText,
                        button1 = L["Yes"],
                        button2 = L["No"],
                        OnAccept = function()
                            local entry = iWRDatabase[databasekey]
                            local wasPersonal = entry and entry[9]
                            -- Tombstone all note timestamps so they don't return via sync
                            if entry then
                                iWR:TombstoneEntireEntry(databasekey, entry)
                            end
                            print(L["CharNoteStart"] .. entry[4] .. L["CharNoteRemoved"])
                            iWRDatabase[databasekey] = nil
                            iWR.ExpandedEntries[databasekey] = nil
                            iWR:PopulateDatabase()
                            if not wasPersonal then
                                iWR:SendRemoveRequestToFriends(databasekey)
                            end
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
                col1bFrame:SetScript("OnEnter", function()
                    ShowRowHighlight()
                    ShowEntryTooltip(col1bFrame)
                end)
                col1bFrame:SetScript("OnLeave", function()
                    HideRowHighlight()
                    GameTooltip:Hide()
                end)
                col1bFrame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    elseif historyCount > 0 then
                        iWR.ExpandedEntries[databasekey] = not iWR.ExpandedEntries[databasekey]
                        iWR:PopulateDatabase()
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
                col3Frame:SetScript("OnEnter", function()
                    ShowRowHighlight()
                    ShowEntryTooltip(col3Frame)
                end)
                col3Frame:SetScript("OnLeave", function()
                    HideRowHighlight()
                    GameTooltip:Hide()
                end)
                col3Frame:SetScript("OnMouseDown", function(self, button)
                    if button == "RightButton" then
                        WhisperPlayer()
                    end
                end)

                -- Persistent expanded highlight on main row
                local isExpanded = historyCount > 0 and iWR.ExpandedEntries[databasekey]
                if not col1Frame.expandBg then
                    col1Frame.expandBg = col1Frame:CreateTexture(nil, "BACKGROUND")
                    col1Frame.expandBg:SetAllPoints()
                end
                if not col1bFrame.expandBg then
                    col1bFrame.expandBg = col1bFrame:CreateTexture(nil, "BACKGROUND")
                    col1bFrame.expandBg:SetAllPoints()
                end
                if not col2Frame.expandBg then
                    col2Frame.expandBg = col2Frame:CreateTexture(nil, "BACKGROUND")
                    col2Frame.expandBg:SetAllPoints()
                end
                if not col3Frame.expandBg then
                    col3Frame.expandBg = col3Frame:CreateTexture(nil, "BACKGROUND")
                    col3Frame.expandBg:SetAllPoints()
                end
                if isExpanded then
                    col1Frame.expandBg:SetColorTexture(1, 0.59, 0.09, 0.12)
                    col1Frame.expandBg:Show()
                    col1bFrame.expandBg:SetColorTexture(1, 0.59, 0.09, 0.12)
                    col1bFrame.expandBg:Show()
                    col2Frame.expandBg:SetColorTexture(1, 0.59, 0.09, 0.12)
                    col2Frame.expandBg:Show()
                    col3Frame.expandBg:SetColorTexture(1, 0.59, 0.09, 0.12)
                    col3Frame.expandBg:Show()
                else
                    col1Frame.expandBg:Hide()
                    col1bFrame.expandBg:Hide()
                    col2Frame.expandBg:Hide()
                    col3Frame.expandBg:Hide()
                end

                yOffset = yOffset - 52

                -- Expand/collapse sub-rows for note history
                if historyCount > 0 and iWR.ExpandedEntries[databasekey] then
                    local fullWidth = dbContainer.col1:GetWidth() + dbContainer.col1b:GetWidth() + dbContainer.col2:GetWidth() + dbContainer.col3:GetWidth()
                    local capturedDbKey = databasekey

                    -- Helper to create a history sub-row
                    local function CreateHistoryRow(noteText, noteLevel, noteDate, noteAuthor, notePersonal, removeFunc)
                        local subRow = CreateFrame("Frame", nil, dbContainer.col1)
                        subRow:SetSize(fullWidth, 24)
                        subRow:SetPoint("TOPLEFT", dbContainer.col1, "TOPLEFT", 0, yOffset)
                        subRow:Show()

                        -- Background
                        local subBg = subRow:CreateTexture(nil, "BACKGROUND")
                        subBg:SetAllPoints()
                        subBg:SetColorTexture(0.06, 0.05, 0.035, 0.82)

                        -- Accent bar
                        local accentBar = subRow:CreateTexture(nil, "ARTWORK")
                        accentBar:SetSize(2, 18)
                        accentBar:SetPoint("LEFT", subRow, "LEFT", 15, 0)
                        local ar, ag, ab = 0.5, 0.5, 0.5
                        if noteLevel > 0 then ar, ag, ab = 0, 0.8, 0
                        elseif noteLevel < 0 then ar, ag, ab = 0.8, 0, 0 end
                        accentBar:SetColorTexture(ar, ag, ab, 0.6)

                        -- Author
                        local authorFs = subRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        authorFs:SetPoint("LEFT", accentBar, "RIGHT", 6, 0)
                        authorFs:SetWidth(dbContainer.col1:GetWidth() - 32)
                        authorFs:SetJustifyH("LEFT")
                        authorFs:SetWordWrap(false)
                        local authorText = noteAuthor or ""
                        if notePersonal == true then
                            authorText = authorText .. "  |TInterface\\Icons\\INV_Misc_Key_03:10:10:0:0|t |cFFC7A35A"
                                .. (L["StatusPersonal"] or "Personal") .. "|r"
                        end
                        authorFs:SetText(authorText)

                        -- Level
                        local lvlSign = noteLevel > 0 and "+" or ""
                        local lvlColor = iWR.Colors[noteLevel] or iWR.Colors.Default
                        local levelFs = subRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        levelFs:SetPoint("LEFT", subRow, "LEFT", dbContainer.col1:GetWidth(), 0)
                        levelFs:SetText(lvlColor .. lvlSign .. noteLevel)

                        -- Note
                        local truncNote = noteText ~= "" and (#noteText > 35 and noteText:sub(1, 32) .. "..." or noteText) or ""
                        local noteFs = subRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        noteFs:SetPoint("LEFT", subRow, "LEFT", dbContainer.col1:GetWidth() + dbContainer.col1b:GetWidth() + 10, 0)
                        noteFs:SetWidth(dbContainer.col2:GetWidth() - 15)
                        noteFs:SetJustifyH("LEFT")
                        noteFs:SetText(lvlColor .. truncNote)

                        -- Date
                        local dateFs = subRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        dateFs:SetPoint("RIGHT", subRow, "RIGHT", -30, 0)
                        dateFs:SetJustifyH("RIGHT")
                        dateFs:SetText(iWR.Colors.Gray .. (noteDate or ""))

                        -- Hover tooltip showing full note
                        subRow:EnableMouse(true)
                        subRow:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            local typeName = iWR:GetTypeName(noteLevel) or ""
                            GameTooltip:AddLine(lvlColor .. lvlSign .. noteLevel .. " - " .. typeName, 1, 1, 1)
                            if noteText ~= "" then
                                GameTooltip:AddLine(lvlColor .. noteText, 1, 0.82, 0, true)
                            end
                            if noteAuthor and noteAuthor ~= "" then
                                GameTooltip:AddLine(L["DetailAuthor"] .. " " .. noteAuthor, 0.5, 0.5, 0.5)
                            end
                            if noteDate and noteDate ~= "" then
                                GameTooltip:AddLine(L["DetailDate"] .. " " .. noteDate, 0.5, 0.5, 0.5)
                            end
                            if notePersonal == true then
                                GameTooltip:AddLine(L["DetailStatus"] .. " |cFFC7A35A"
                                    .. (L["StatusPersonal"] or "Personal") .. "|r", 1, 0.82, 0)
                            end
                            GameTooltip:Show()
                        end)
                        subRow:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)

                        -- Remove "x" button (far right)
                        local xBtn = CreateFrame("Button", nil, subRow)
                        iWR:StyleButton(xBtn, true)
                        xBtn:SetSize(18, 18)
                        xBtn:SetPoint("RIGHT", subRow, "RIGHT", -8, 0)
                        local xFs = xBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        xFs:SetPoint("CENTER")
                        xFs:SetText(iWR.Colors.Gray .. "x")
                        xBtn:SetScript("OnEnter", function() xFs:SetText("|cFFFF4444x") end)
                        xBtn:SetScript("OnLeave", function() xFs:SetText(iWR.Colors.Gray .. "x") end)
                        xBtn:SetScript("OnClick", function()
                            StaticPopupDialogs["IWR_REMOVE_HISTORY_NOTE"] = {
                                text = iWR.Colors.iWR .. L["RemoveNoteConfirm"],
                                button1 = L["Yes"],
                                button2 = L["No"],
                                OnAccept = removeFunc,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            StaticPopup_Show("IWR_REMOVE_HISTORY_NOTE")
                        end)

                        yOffset = yOffset - 24
                    end

                    -- Header row: "Notes for [PlayerName]"
                    local headerRow = CreateFrame("Frame", nil, dbContainer.col1)
                    headerRow:SetSize(fullWidth, 20)
                    headerRow:SetPoint("TOPLEFT", dbContainer.col1, "TOPLEFT", 0, yOffset)
                    headerRow:Show()

                    local headerBg = headerRow:CreateTexture(nil, "BACKGROUND")
                    headerBg:SetAllPoints()
                    headerBg:SetColorTexture(0.12, 0.1, 0.05, 0.8)

                    local headerText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    headerText:SetPoint("LEFT", headerRow, "LEFT", 18, 0)
                    headerText:SetText(iWR.Colors.iWR .. "--- " .. L["NotesHistory"] .. ": " .. (data[4] or "") .. iWR.Colors.iWR .. " " .. iWR.Colors.Gray .. string.format(L["NotesCount"], historyCount + 1) .. iWR.Colors.iWR .. " ---")
                    yOffset = yOffset - 20

                    -- Latest note (current, from fields [1]-[6]) — with remove that promotes next
                    CreateHistoryRow(data[1] or "", data[2] or 0, data[5] or "", data[6] or "", data[9] == true, function()
                        local entry = iWRDatabase[capturedDbKey]
                        if entry then
                            -- Tombstone the deleted note's timestamp
                            if entry[3] then
                                entry[11] = entry[11] or {}
                                entry[11][entry[3]] = true
                            end
                            if entry[10] and #entry[10] > 0 then
                                -- Promote the most recent history entry to current
                                local promoted = table.remove(entry[10], #entry[10])
                                entry[1] = promoted[1] -- note
                                entry[2] = promoted[2] -- level
                                entry[3] = promoted[3] -- timestamp
                                entry[5] = promoted[4] -- date
                                entry[6] = promoted[5] -- author
                                entry[9] = promoted[6] == true and true or nil -- personal flag
                                if #entry[10] == 0 then entry[10] = nil end
                            else
                                -- Only one note left, remove entire entry
                                iWRDatabase[capturedDbKey] = nil
                                iWR.ExpandedEntries[capturedDbKey] = nil
                            end
                            iWR:PopulateDatabase()
                            iWR:UpdateTargetFrame()
                        end
                    end)

                    -- History entries (oldest to newest = bottom to top)
                    for hi = #data[10], 1, -1 do
                        local h = data[10][hi]
                        local capturedHi = hi
                        local capturedTimestamp = h[3]
                        CreateHistoryRow(h[1] or "", h[2] or 0, h[4] or "", h[5] or "", h[6] == true, function()
                            local entry = iWRDatabase[capturedDbKey]
                            if entry and entry[10] then
                                -- Tombstone the deleted note's timestamp
                                if capturedTimestamp then
                                    entry[11] = entry[11] or {}
                                    entry[11][capturedTimestamp] = true
                                end
                                table.remove(entry[10], capturedHi)
                                if #entry[10] == 0 then entry[10] = nil end
                            end
                            iWR:PopulateDatabase()
                        end)
                    end
                end
            end
        end
    end
    dbContainer:SetHeight(math.abs(yOffset))
    local maxScroll = math.max(0, dbContainer:GetHeight() - dbScrollFrame:GetHeight())
    if dbScrollFrame:GetVerticalScroll() > maxScroll then
        dbScrollFrame:SetVerticalScroll(maxScroll)
    end

    -- Update entry count in sidebar
    if dbSearchFilter ~= "" or dbNoteFilter ~= "all" then
        dbEntryCount:SetText("|cFF808080" .. string.format(L["EntriesFiltered"], filteredEntries, totalEntries) .. "|r")
    else
        dbEntryCount:SetText("|cFF808080" .. string.format(L["EntriesCount"], totalEntries) .. "|r")
    end
end

-- ╭─────────────────────────────────────────────────╮
-- │      Group Log Tab: UI & PopulateGroupLog       │
-- ╰─────────────────────────────────────────────────╯

-- Scroll frame for group log entries (mouse-wheel only; no visual scrollbar).
local glScrollFrame = CreateFrame("ScrollFrame", nil, groupLogContainer)
glScrollFrame:SetPoint("TOPLEFT", groupLogContainer, "TOPLEFT", 0, 0)
glScrollFrame:SetPoint("BOTTOMRIGHT", groupLogContainer, "BOTTOMRIGHT", 0, 45)

local glContainer = CreateFrame("Frame", nil, glScrollFrame)
glContainer:SetSize(glScrollFrame:GetWidth(), glScrollFrame:GetHeight())
glScrollFrame:SetScrollChild(glContainer)

local function ScrollGroupLog(delta)
    local current = glScrollFrame:GetVerticalScroll()
    local maximum = math.max(0, glContainer:GetHeight() - glScrollFrame:GetHeight())
    glScrollFrame:SetVerticalScroll(math.max(0, math.min(maximum, current - (delta * 68))))
end

glScrollFrame:EnableMouseWheel(true)
glScrollFrame:SetScript("OnMouseWheel", function(_, delta) ScrollGroupLog(delta) end)
glContainer:EnableMouseWheel(true)
glContainer:SetScript("OnMouseWheel", function(_, delta) ScrollGroupLog(delta) end)

-- Empty state text
local glEmptyText = groupLogContainer:CreateFontString(nil, "OVERLAY", "GameFontDisable")
glEmptyText:SetPoint("CENTER", groupLogContainer, "CENTER", 0, 20)
glEmptyText:SetText(L["GroupLogEmpty"] or "No players logged yet. Group up and they'll appear here!")
glEmptyText:SetWidth(400)
glEmptyText:Hide()

-- Clear Log button
local clearLogButton = CreateFrame("Button", nil, groupLogContainer, "UIPanelButtonTemplate")
iWR:StyleButton(clearLogButton, true)
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
    local ROW_HEIGHT = 34
    local displayIndex = 0

    -- Display in reverse order (newest first), skip players already in database
    for i = totalEntries, 1, -1 do
        local entry = entries[i]
        if not entry then break end

        -- Skip players that already have a note in the database
        local databaseKey = iWR:GetPlayerDatabaseKey(entry.name, entry.realm)
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

            local rowBackground = row:CreateTexture(nil, "BACKGROUND")
            rowBackground:SetAllPoints(row)
            row.rowBackground = rowBackground

            local separator = row:CreateTexture(nil, "BORDER")
            separator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
            separator:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
            separator:SetHeight(1)
            separator:SetColorTexture(0.42, 0.35, 0.19, 0.28)

            -- Highlight on hover
            local highlight = row:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 0.59, 0.09, 0.08)

            -- Race and class icons
            local raceIcon = row:CreateTexture(nil, "ARTWORK")
            raceIcon:SetSize(20, 20)
            raceIcon:SetPoint("LEFT", row, "LEFT", 8, 0)
            row.raceIcon = raceIcon

            local classIcon = row:CreateTexture(nil, "ARTWORK")
            classIcon:SetSize(20, 20)
            classIcon:SetPoint("LEFT", raceIcon, "RIGHT", 4, 0)
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
            nameText:SetPoint("LEFT", classIcon, "RIGHT", 8, 0)
            nameText:SetWidth(155)
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
            local editBtn = CreateFrame("Button", nil, row)
            iWR:StyleButton(editBtn)
            editBtn:SetSize(24, 24)
            local editIcon = editBtn:CreateTexture(nil, "ARTWORK")
            editIcon:SetSize(16, 16)
            editIcon:SetPoint("CENTER")
            editIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_05")
            row.editBtn = editBtn

            -- Dismiss button
            local dismissBtn = CreateFrame("Button", nil, row)
            iWR:StyleButton(dismissBtn, true)
            dismissBtn:SetSize(24, 24)
            local dismissIcon = dismissBtn:CreateTexture(nil, "ARTWORK")
            dismissIcon:SetSize(16, 16)
            dismissIcon:SetPoint("CENTER")
            dismissIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

            -- Anchor from the right: dismiss first, then editBtn to its left
            dismissBtn:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            editBtn:SetPoint("RIGHT", dismissBtn, "LEFT", -4, 0)
            row.dismissBtn = dismissBtn

            glRowCache[displayIndex] = row
        end

        -- Position the row
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", glContainer, "TOPLEFT", 0, yOffset)
        row:SetPoint("TOPRIGHT", glContainer, "TOPRIGHT", 0, yOffset)
        row:Show()
        row.rowBackground:SetColorTexture(displayIndex % 2 == 0 and 0.12 or 0.035, displayIndex % 2 == 0 and 0.085 or 0.03, displayIndex % 2 == 0 and 0.04 or 0.024, displayIndex % 2 == 0 and 0.34 or 0.62)

        local raceToken = entry.race and tostring(entry.race):upper() or nil
        row.raceIcon:SetTexture(IWR_RACE_ICONS[raceToken] or "Interface\\Icons\\Achievement_General")
        row.raceIcon:SetAlpha(IWR_RACE_ICONS[raceToken] and 1 or 0.32)

        -- Set class icon using CLASS_ICON_TCOORDS
        local classToken = entry.class or "UNKNOWN"
        local tcoords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
        if tcoords then
            row.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            row.classIcon:SetTexCoord(unpack(tcoords))
            row.classIcon:SetAlpha(1)
            row.classIcon:Show()
        else
            row.classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            row.classIcon:SetTexCoord(0, 1, 0, 1)
            row.classIcon:SetAlpha(0.32)
            row.classIcon:Show()
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
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:AddLine(nameColor .. capturedEntry.name .. "-" .. capturedEntry.realm, 1, 1, 1)
            if capturedEntry.race and capturedEntry.race ~= "" then
                GameTooltip:AddLine("Race: " .. capturedEntry.race, 0.75, 0.75, 0.75)
            end
            if capturedEntry.class and capturedEntry.class ~= "" then
                GameTooltip:AddLine("Class: " .. capturedEntry.class, 0.75, 0.75, 0.75)
            end
            GameTooltip:AddLine(L["DetailZone"] .. " " .. (capturedEntry.zone or L["UnknownDate"]), 1, 0.82, 0)
            if capturedEntry.isInstance then
                GameTooltip:AddLine(L["DetailInstanceType"] .. " " .. (capturedEntry.instanceType or "none"), 1, 0.82, 0)
            end
            GameTooltip:AddLine(L["DetailDate"] .. " " .. (capturedEntry.date or ""), 1, 0.82, 0)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Add Note button: open iWR Menu with player name and class pre-filled
        local capturedName = entry.name
        local capturedRealm = entry.realm
        local capturedClass = entry.class
        local capturedRace = entry.race
        row.editBtn:SetScript("OnClick", function()
            local menuName
            if capturedRealm == iWR.CurrentRealm then
                menuName = capturedName
            else
                menuName = capturedName .. "-" .. capturedRealm
            end
            iWR:MenuOpen(menuName, capturedClass, capturedRace)
            iWR:DatabaseClose()
        end)
        row.editBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine(L["GroupLogAddNote"] or "Add Note", 1, 0.82, 0)
            GameTooltip:AddLine(capturedName, 0.75, 0.75, 0.75)
            GameTooltip:Show()
        end)
        row.editBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Dismiss button: remove this entry from the log
        local capturedEntryIndex = i
        row.dismissBtn:SetScript("OnClick", function()
            table.remove(iWRMemory.GroupLog, capturedEntryIndex)
            iWR:PopulateGroupLog()
        end)
        row.dismissBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine(L["GroupLogDismiss"] or "Dismiss", 1, 0.35, 0.25)
            GameTooltip:AddLine(capturedName, 0.75, 0.75, 0.75)
            GameTooltip:Show()
        end)
        row.dismissBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        yOffset = yOffset - ROW_HEIGHT
        end -- end of else (skip players already in DB)
    end

    -- Show empty text if all entries were filtered out (or no entries exist)
    if displayIndex == 0 then
        glEmptyText:Show()
        glContainer:SetHeight(1)
        glScrollFrame:SetVerticalScroll(0)
        return
    end

    glContainer:SetHeight(math.max(math.abs(yOffset), 1))
    local maxScroll = math.max(0, glContainer:GetHeight() - glScrollFrame:GetHeight())
    if glScrollFrame:GetVerticalScroll() > maxScroll then
        glScrollFrame:SetVerticalScroll(maxScroll)
    end
end

-- ╭───────────────────────────────────────────────────────╮
-- │      Guild Watchlist Tab: UI & RefreshGuildWatchlist   │
-- ╰───────────────────────────────────────────────────────╯

local gwFormCard = CreateFrame("Frame", nil, guildWatchContainer, "BackdropTemplate")
gwFormCard:SetPoint("TOPLEFT", guildWatchContainer, "TOPLEFT", 8, -8)
gwFormCard:SetPoint("TOPRIGHT", guildWatchContainer, "TOPRIGHT", -8, -8)
gwFormCard:SetHeight(154)
iWR:StyleSurface(gwFormCard, "surfaceRaised")

-- Header
local gwHeader = gwFormCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
gwHeader:SetPoint("TOPLEFT", gwFormCard, "TOPLEFT", 14, -10)
gwHeader:SetText(L["GuildWatchlistHeader"] or "Guild Watchlist")
gwHeader:SetTextColor(1, 0.59, 0.09)

-- Description
local gwDesc = gwFormCard:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
gwDesc:SetPoint("TOPLEFT", gwHeader, "BOTTOMLEFT", 0, -4)
gwDesc:SetPoint("RIGHT", gwFormCard, "RIGHT", -14, 0)
gwDesc:SetJustifyH("LEFT")
gwDesc:SetText(L["GuildWatchlistDesc"] or "Add a guild name and relation type. Players from watched guilds are auto-imported when targeted or grouped.")

-- Input row: Guild name EditBox
local gwInputLabel = gwFormCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwInputLabel:SetPoint("TOPLEFT", gwFormCard, "TOPLEFT", 14, -58)
gwInputLabel:SetText(L["GuildNameLabel"] or "Guild Name:")
gwInputLabel:SetTextColor(0.92, 0.78, 0.48)

local gwInput = CreateFrame("EditBox", nil, gwFormCard, "InputBoxTemplate")
iWR:StyleEditBox(gwInput)
gwInput:SetSize(300, 22)
gwInput:SetPoint("LEFT", gwInputLabel, "RIGHT", 8, 0)
gwInput:SetAutoFocus(false)
gwInput:SetMaxLetters(60)

-- Add button (same row as guild name input)
local gwAddBtn = CreateFrame("Button", nil, gwFormCard, "UIPanelButtonTemplate")
iWR:StyleButton(gwAddBtn)
gwAddBtn:SetSize(74, 24)
gwAddBtn:SetPoint("LEFT", gwInput, "RIGHT", 8, 0)

-- ╭──────────────────────────────────────────────╮
-- │      Guild Watchlist Relation Slider          │
-- ╰──────────────────────────────────────────────╯
local gwTypeValue = 1 -- default to Liked +1

local gwRelationLabel = gwFormCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwRelationLabel:SetPoint("TOPLEFT", gwFormCard, "TOPLEFT", 14, -91)
gwRelationLabel:SetText(L["RelationLevelHeader"] or "Relation Level")
gwRelationLabel:SetTextColor(0.92, 0.78, 0.48)

local gwRelationIconFrame = CreateFrame("Frame", nil, gwFormCard, "BackdropTemplate")
gwRelationIconFrame:SetSize(28, 28)
gwRelationIconFrame:SetPoint("LEFT", gwRelationLabel, "RIGHT", 10, 0)
iWR:StyleSurface(gwRelationIconFrame, "surface")

-- Type icon (left side)
local gwSliderIcon = gwRelationIconFrame:CreateTexture(nil, "ARTWORK")
gwSliderIcon:SetSize(20, 20)
gwSliderIcon:SetPoint("CENTER", gwRelationIconFrame, "CENTER", 0, 0)
gwSliderIcon:SetTexture(iWR:GetIcon(1))

-- Slider track
local GW_SLIDER_WIDTH = 330
local GW_SLIDER_HEIGHT = 10
local gwCenterX = GW_SLIDER_WIDTH / 2
local gwStepWidth = GW_SLIDER_WIDTH / 20

local gwSliderTrack = CreateFrame("Frame", nil, gwFormCard, "BackdropTemplate")
gwSliderTrack:SetSize(GW_SLIDER_WIDTH, GW_SLIDER_HEIGHT)
gwSliderTrack:SetPoint("LEFT", gwRelationIconFrame, "RIGHT", 10, 0)
gwSliderTrack:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
})
gwSliderTrack:SetBackdropColor(0.025, 0.022, 0.018, 0.95)
gwSliderTrack:SetBackdropBorderColor(0.42, 0.35, 0.19, 1)

-- Fill bar
local gwSliderFill = gwSliderTrack:CreateTexture(nil, "ARTWORK")
gwSliderFill:SetHeight(GW_SLIDER_HEIGHT - 2)
gwSliderFill:SetPoint("TOP", gwSliderTrack, "TOP", 0, -1)
gwSliderFill:SetTexture("Interface\\Buttons\\WHITE8x8")

-- Thumb
local gwSliderThumb = CreateFrame("Frame", nil, gwSliderTrack)
gwSliderThumb:SetSize(12, 16)
gwSliderThumb:SetPoint("CENTER", gwSliderTrack, "LEFT", gwCenterX + gwStepWidth, 0)

local gwThumbTex = gwSliderThumb:CreateTexture(nil, "OVERLAY")
gwThumbTex:SetSize(5, 16)
gwThumbTex:SetPoint("CENTER")
gwThumbTex:SetColorTexture(1, 0.59, 0.09, 1)

local gwThumbGlow = gwSliderThumb:CreateTexture(nil, "ARTWORK")
gwThumbGlow:SetSize(11, 18)
gwThumbGlow:SetPoint("CENTER")
gwThumbGlow:SetColorTexture(1, 0.59, 0.09, 0.16)

-- Min/Max labels
local gwSliderLow = gwFormCard:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
gwSliderLow:SetPoint("TOPLEFT", gwSliderTrack, "BOTTOMLEFT", 0, -1)
gwSliderLow:SetText("|cFF999999-10|r")

local gwSliderHigh = gwFormCard:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
gwSliderHigh:SetPoint("TOPRIGHT", gwSliderTrack, "BOTTOMRIGHT", 0, -1)
gwSliderHigh:SetText("|cFF999999+10|r")

-- Value label
local gwSliderValueText = gwFormCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwSliderValueText:SetPoint("LEFT", gwSliderTrack, "RIGHT", 10, 0)

-- Update slider display
local function UpdateGWSlider(value)
    value = math.floor(value + 0.5)
    if value < -10 then value = -10 end
    if value > 10 then value = 10 end
    if value == 0 then value = 1 end -- skip Clear (0) for guild watchlist
    gwTypeValue = value

    local typeName = iWR:GetTypeName(value)
    local typeColor = iWR.Colors[value] or iWR.Colors.Default

    -- Icon
    gwSliderIcon:SetTexture(iWR:GetIcon(value))

    -- Value label
    local sign = value > 0 and "+" or ""
    gwSliderValueText:SetText(typeColor .. sign .. value .. " — " .. typeName)

    -- Thumb position
    local thumbX = gwCenterX + (value * gwStepWidth)
    gwSliderThumb:ClearAllPoints()
    gwSliderThumb:SetPoint("CENTER", gwSliderTrack, "LEFT", thumbX, 0)

    -- Fill bar
    local r, g, b = 0.5, 0.8, 0.3
    if value < 0 then
        if value <= -6 then
            r, g, b = 1.0, 0.13, 0.13
        else
            r, g, b = 0.99, 0.44, 0.19
        end
    elseif value == 10 then
        r, g, b = 0.30, 0.65, 1.0
    elseif value > 0 then
        r, g, b = 0.50, 0.96, 0.32
    end

    gwSliderFill:Show()
    gwSliderFill:SetVertexColor(r, g, b, 0.7)
    gwSliderFill:ClearAllPoints()
    gwSliderFill:SetHeight(GW_SLIDER_HEIGHT - 2)
    if value > 0 then
        gwSliderFill:SetPoint("LEFT", gwSliderTrack, "LEFT", gwCenterX + 1, 0)
        gwSliderFill:SetWidth(value * gwStepWidth)
    else
        local fillWidth = math.abs(value) * gwStepWidth
        gwSliderFill:SetPoint("RIGHT", gwSliderTrack, "LEFT", gwCenterX - 1, 0)
        gwSliderFill:SetWidth(fillWidth)
    end
end
UpdateGWSlider(1) -- initialize to +1 Liked

-- Click on track
gwSliderTrack:EnableMouse(true)
gwSliderTrack:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        local x = select(1, GetCursorPosition()) / self:GetEffectiveScale()
        local left = self:GetLeft()
        local fraction = (x - left) / GW_SLIDER_WIDTH
        local value = math.floor((-10 + fraction * 20) + 0.5)
        if value == 0 then value = 1 end
        UpdateGWSlider(value)
    end
end)

-- Drag thumb
gwSliderThumb:EnableMouse(true)
gwSliderThumb:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then self.dragging = true end
end)
gwSliderThumb:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then self.dragging = false end
end)

gwSliderTrack:SetScript("OnUpdate", function(self)
    if gwSliderThumb.dragging then
        local x = select(1, GetCursorPosition()) / self:GetEffectiveScale()
        local left = self:GetLeft()
        local fraction = (x - left) / GW_SLIDER_WIDTH
        local value = math.floor((-10 + fraction * 20) + 0.5)
        if value < -10 then value = -10 end
        if value > 10 then value = 10 end
        if value == 0 then value = 1 end
        UpdateGWSlider(value)
    end
end)

-- Scroll wheel
gwSliderTrack:EnableMouseWheel(true)
gwSliderTrack:SetScript("OnMouseWheel", function(self, delta)
    local newValue = gwTypeValue + delta
    if newValue == 0 then newValue = newValue + delta end -- skip 0
    if newValue < -10 then newValue = -10 end
    if newValue > 10 then newValue = 10 end
    UpdateGWSlider(newValue)
end)

-- Default note input
local gwNoteLabel = gwFormCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwNoteLabel:SetPoint("TOPLEFT", gwFormCard, "TOPLEFT", 14, -126)
gwNoteLabel:SetText(L["GuildNoteLabel"] or "Default Note:")
gwNoteLabel:SetTextColor(0.92, 0.78, 0.48)

local gwNoteInput = CreateFrame("EditBox", nil, gwFormCard, "InputBoxTemplate")
iWR:StyleEditBox(gwNoteInput)
gwNoteInput:SetSize(310, 22)
gwNoteInput:SetPoint("LEFT", gwNoteLabel, "RIGHT", 8, 0)
gwNoteInput:SetAutoFocus(false)
gwNoteInput:SetMaxLetters(120)
gwAddBtn:SetText(L["GuildWatchlistAdd"] or "Add")

gwAddBtn:SetScript("OnClick", function()
    local guildName = strtrim(gwInput:GetText())
    if guildName == "" then return end
    if not iWRSettings.GuildWatchlist then iWRSettings.GuildWatchlist = {} end
    local authorName = iWR:ColorizePlayerNameByClass(iWR:GetUnitPlayerIdentity("player"), select(2, UnitClass("player")))
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
gwListBorder:SetPoint("TOPLEFT", gwFormCard, "BOTTOMLEFT", 0, -10)
gwListBorder:SetPoint("BOTTOMRIGHT", guildWatchContainer, "BOTTOMRIGHT", -8, 8)
gwListBorder:SetBackdrop({
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3},
})
iWR:StyleSurface(gwListBorder, "surface")

local gwListHeader = CreateFrame("Frame", nil, gwListBorder, "BackdropTemplate")
gwListHeader:SetPoint("TOPLEFT", gwListBorder, "TOPLEFT", 5, -5)
gwListHeader:SetPoint("TOPRIGHT", gwListBorder, "TOPRIGHT", -5, -5)
gwListHeader:SetHeight(26)
iWR:StyleSurface(gwListHeader, "surfaceRaised")

local gwListTitle = gwListHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
gwListTitle:SetPoint("LEFT", gwListHeader, "LEFT", 10, 0)
gwListTitle:SetText(L["GuildsTab"] or "Guilds")
gwListTitle:SetTextColor(0.92, 0.78, 0.48)

local gwListCount = gwListHeader:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
gwListCount:SetPoint("RIGHT", gwListHeader, "RIGHT", -10, 0)
gwListCount:SetText("0")

local gwScrollFrame = CreateFrame("ScrollFrame", nil, gwListBorder)
gwScrollFrame:SetPoint("TOPLEFT", gwListHeader, "BOTTOMLEFT", 0, -4)
gwScrollFrame:SetPoint("BOTTOMRIGHT", gwListBorder, "BOTTOMRIGHT", -5, 5)

local gwScrollChild = CreateFrame("Frame", nil, gwScrollFrame)
gwScrollChild:SetSize(gwScrollFrame:GetWidth(), 1)
gwScrollFrame:SetScrollChild(gwScrollChild)

local function ScrollGuildWatchlist(delta)
    local current = gwScrollFrame:GetVerticalScroll()
    local maximum = math.max(0, gwScrollChild:GetHeight() - gwScrollFrame:GetHeight())
    gwScrollFrame:SetVerticalScroll(math.max(0, math.min(maximum, current - (delta * 64))))
end

gwScrollFrame:EnableMouseWheel(true)
gwScrollFrame:SetScript("OnMouseWheel", function(_, delta) ScrollGuildWatchlist(delta) end)
gwScrollChild:EnableMouseWheel(true)
gwScrollChild:SetScript("OnMouseWheel", function(_, delta) ScrollGuildWatchlist(delta) end)

local gwEmptyText = gwListBorder:CreateFontString(nil, "OVERLAY", "GameFontDisable")
gwEmptyText:SetPoint("CENTER", gwScrollFrame, "CENTER", 0, 8)
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
        gwListCount:SetText("0")
        gwScrollChild:SetHeight(1)
        gwScrollFrame:SetVerticalScroll(0)
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
    gwListCount:SetText(tostring(#sorted))

    local ROW_HEIGHT = 40
    local yOffset = 0

    for i, entry in ipairs(sorted) do
        local row = CreateFrame("Frame", nil, gwScrollChild)
        row:SetSize(gwScrollChild:GetWidth(), ROW_HEIGHT)
        row:SetPoint("TOPLEFT", gwScrollChild, "TOPLEFT", 0, yOffset)

        local rowBg = row:CreateTexture(nil, "BACKGROUND")
        rowBg:SetAllPoints(row)
        rowBg:SetColorTexture(i % 2 == 0 and 0.12 or 0.035, i % 2 == 0 and 0.085 or 0.03, i % 2 == 0 and 0.04 or 0.024, i % 2 == 0 and 0.34 or 0.62)

        local separator = row:CreateTexture(nil, "BORDER")
        separator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
        separator:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
        separator:SetHeight(1)
        separator:SetColorTexture(0.42, 0.35, 0.19, 0.28)

        local typeColor = iWR.Colors[entry.typeVal] or iWR.Colors.Gray
        local iconBorder = row:CreateTexture(nil, "BORDER")
        iconBorder:SetSize(28, 28)
        iconBorder:SetPoint("LEFT", row, "LEFT", 7, 0)
        iconBorder:SetColorTexture(0.58, 0.43, 0.18, 0.9)

        local relationIcon = row:CreateTexture(nil, "ARTWORK")
        relationIcon:SetSize(24, 24)
        relationIcon:SetPoint("CENTER", iconBorder, "CENTER")
        relationIcon:SetTexture(iWR:GetIcon(entry.typeVal) or "Interface\\Icons\\INV_Misc_QuestionMark")

        -- Guild name and optional default note
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("TOPLEFT", iconBorder, "TOPRIGHT", 9, -1)
        nameText:SetPoint("RIGHT", row, "RIGHT", -150, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetWordWrap(false)
        nameText:SetText(typeColor .. entry.name .. "|r")

        local noteText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        noteText:SetPoint("BOTTOMLEFT", iconBorder, "BOTTOMRIGHT", 9, 1)
        noteText:SetPoint("RIGHT", row, "RIGHT", -150, 0)
        noteText:SetJustifyH("LEFT")
        noteText:SetWordWrap(false)
        local displayNote = entry.note and entry.note ~= "" and entry.note or (L["GuildWatchlistDefaultNote"] and string.format(L["GuildWatchlistDefaultNote"], entry.name) or "")
        noteText:SetText("|cFF777777" .. displayNote .. "|r")

        local typeName = iWR:GetTypeName(entry.typeVal)
        local badge = row:CreateTexture(nil, "ARTWORK")
        badge:SetSize(104, 20)
        badge:SetPoint("RIGHT", row, "RIGHT", -38, 0)
        if entry.typeVal > 0 then
            badge:SetColorTexture(0.08, 0.36, 0.12, 0.72)
        else
            badge:SetColorTexture(0.42, 0.08, 0.05, 0.72)
        end
        local typeLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        typeLabel:SetPoint("CENTER", badge, "CENTER", 0, 0)
        local signStr = entry.typeVal > 0 and "+" or ""
        typeLabel:SetText(typeColor .. signStr .. entry.typeVal .. "  " .. typeName .. "|r")

        local capturedName = entry.name
        local removeBtn = CreateFrame("Button", nil, row)
        iWR:StyleButton(removeBtn, true)
        removeBtn:SetSize(24, 24)
        removeBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        local removeIcon = removeBtn:CreateTexture(nil, "ARTWORK")
        removeIcon:SetSize(16, 16)
        removeIcon:SetPoint("CENTER")
        removeIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        removeBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine(L["RemoveButton"] or "Remove", 1, 0.35, 0.25)
            GameTooltip:AddLine(capturedName, 0.75, 0.75, 0.75)
            GameTooltip:Show()
        end)
        removeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
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
    local maxScroll = math.max(0, gwScrollChild:GetHeight() - gwScrollFrame:GetHeight())
    if gwScrollFrame:GetVerticalScroll() > maxScroll then
        gwScrollFrame:SetVerticalScroll(maxScroll)
    end
end
