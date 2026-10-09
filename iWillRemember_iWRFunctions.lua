-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔ 
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  iWR Functions                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iWR.L

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Chat Frame Output Routing                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iWR:PrintToChat(...)
    local msg = table.concat({tostringall(...)}, " ")
    if ChatFrame1 then ChatFrame1:AddMessage(msg) end
    local frames = iWRSettings and iWRSettings.ChatFrames or {}
    for i = 2, NUM_CHAT_WINDOWS do
        if frames[i] then
            local cf = _G["ChatFrame" .. i]
            if cf then cf:AddMessage(msg) end
        end
    end
end

local print = function(...) iWR:PrintToChat(...) end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              UTF-8 Safe Helpers                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Returns byte length of the first UTF-8 character in a string
local function UTF8FirstCharLen(str)
    if not str or str == "" then return 0 end
    local byte = string.byte(str, 1)
    if byte < 128 then return 1
    elseif byte < 224 then return 2
    elseif byte < 240 then return 3
    else return 4
    end
end

-- Uppercase the first character of a string, UTF-8 safe
-- Only applies upper() to single-byte (ASCII) first chars; leaves multi-byte chars as-is
local function UTF8UcFirst(str)
    if not str or str == "" then return str end
    local len = UTF8FirstCharLen(str)
    if len == 1 then
        return str:sub(1, 1):upper() .. str:sub(2)
    end
    -- Multi-byte first char: return unchanged (WoW already provides correct casing)
    return str
end

-- Print debug message if Debug mode is active
function iWR:DebugMsg(message,level)
    if iWRSettings.DebugMode then
        if level == 3 then
            print(L["DebugInfo"] .. message)
        elseif level == 2 then
            print(L["DebugWarning"] .. message)
        else
            print(L["DebugError"] .. message)
        end
    end
end

function iWR:IsForeverClient()
    local toc = tonumber(iWR.GameTocVersion) or 0
    return toc >= 16000 and toc < 20000
end

local function TrimPlayerName(value)
    if type(value) ~= "string" then return "" end
    return value:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
end

-- Forever has no realms. Blizzard may expose the same two-part character as
-- "Firstname Lastname" through unit APIs and "Firstname-Lastname" in chat/comms.
function iWR:ResolvePlayerIdentity(name, realm)
    name = TrimPlayerName(name)
    realm = TrimPlayerName(realm)

    if self:IsForeverClient() then
        if realm ~= "" and realm ~= "Forever" and name ~= "" and not name:find("[%s%-]") then
            name = name .. " " .. realm
        end
        name = TrimPlayerName(name:gsub("%-", " "))
        name = name:gsub("(%S+)", UTF8UcFirst)
        return name, "Forever"
    end

    return UTF8UcFirst(name), UTF8UcFirst(realm ~= "" and realm or self.CurrentRealm)
end

function iWR:GetPlayerDatabaseKey(name, realm)
    local resolvedName, resolvedRealm = self:ResolvePlayerIdentity(name, realm)
    if resolvedName == "" then return nil end
    return resolvedName .. "-" .. resolvedRealm, resolvedName, resolvedRealm
end

function iWR:GetUnitPlayerIdentity(unit)
    local name, secondName = UnitName(unit)
    if not name then return nil, "Forever" end
    return self:ResolvePlayerIdentity(name, secondName)
end

function iWR:NormalizePlayerDatabaseKey(databaseKey, data)
    if type(databaseKey) ~= "string" then return databaseKey end
    if self:IsForeverClient() then
        local displayName = type(data) == "table" and StripColorCodes(data[4] or "") or ""
        local savedSecondName = type(data) == "table" and TrimPlayerName(data[7]) or ""
        if displayName ~= "" and not displayName:find("[%s%-]")
            and savedSecondName ~= "" and savedSecondName ~= "Forever" then
            return self:GetPlayerDatabaseKey(displayName, savedSecondName)
        end
        if displayName == "" then
            displayName = databaseKey:gsub("%-Forever$", ""):gsub("%-", " ")
        end
        return self:GetPlayerDatabaseKey(displayName)
    end
    local name, realm = databaseKey:match("^([^-]+)%-(.+)$")
    return self:GetPlayerDatabaseKey(name or databaseKey, realm)
end

function iWR:IsSamePlayerName(left, right)
    local leftKey = self:GetPlayerDatabaseKey(left)
    local rightKey = self:GetPlayerDatabaseKey(right)
    return leftKey ~= nil and leftKey == rightKey
end

function iWR:VerifyRealm(playerName)
    return self:GetPlayerDatabaseKey(playerName)
end

-- Get player data
function iWR:GetDatabaseEntry(databaseKey)
    databaseKey = self:NormalizePlayerDatabaseKey(databaseKey)
    return (databaseKey and iWRDatabase[databaseKey]) or {}
end

function iWR:VerifyInputNote(Note)
    if Note ~= L["DefaultNameInput"]
        and Note ~= L["DefaultNoteInput"]
        and Note ~= ""
        and Note ~= nil
    then
        return true
    end
    return false
end

iWR.Theme = iWR.Theme or {
    panel = { 0.025, 0.022, 0.018, 0.98 },
    header = { 0.10, 0.07, 0.035, 0.98 },
    surface = { 0.08, 0.065, 0.05, 0.96 },
    surfaceRaised = { 0.12, 0.085, 0.04, 0.98 },
    border = { 0.42, 0.35, 0.19, 1 },
    borderStrong = { 0.58, 0.43, 0.18, 1 },
    gold = { 1.00, 0.59, 0.09, 1 },
    goldSoft = { 0.78, 0.53, 0.18, 1 },
    danger = { 0.72, 0.20, 0.12, 1 },
    disabled = { 0.42, 0.42, 0.42, 1 },
}

local IWR_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

function iWR:StyleSurface(frame, variant)
    if not frame or not frame.SetBackdrop then return frame end
    local color = self.Theme[variant or "surface"] or self.Theme.surface
    local border = variant == "header" and self.Theme.borderStrong or self.Theme.border
    frame:SetBackdrop(IWR_BACKDROP)
    frame:SetBackdropColor(unpack(color))
    frame:SetBackdropBorderColor(unpack(border))
    return frame
end

local function setButtonVisual(button, active)
    if not button or not button.iWRButtonBg then return end
    local theme = iWR.Theme
    local destructive = button.iWRDestructive
    local enabled = button.IsEnabled == nil or button:IsEnabled()
    local hovered = enabled and button.iWRHovered
    local pressed = enabled and button.iWRPressed
    local background
    local border
    if destructive then
        background = pressed and { 0.22, 0.045, 0.025, 0.98 } or { 0.16, 0.035, 0.025, 0.98 }
        border = hovered and { 0.92, 0.28, 0.14, 1 } or { 0.72, 0.20, 0.12, 1 }
    elseif active then
        background = pressed and { 0.15, 0.10, 0.045, 0.98 } or { 0.12, 0.085, 0.035, 0.98 }
        border = theme.gold
    else
        background = pressed and { 0.12, 0.085, 0.045, 0.98 } or { 0.08, 0.06, 0.035, 0.98 }
        border = hovered and theme.goldSoft or { 0.52, 0.38, 0.17, 1 }
    end
    if button.iWRButtonBackdrop then
        button.iWRButtonBackdrop:SetBackdropColor(unpack(background))
        button.iWRButtonBackdrop:SetBackdropBorderColor(unpack(border))
    else
        button.iWRButtonBg:SetColorTexture(unpack(background))
        button.iWRBorderTop:SetColorTexture(unpack(border))
        button.iWRBorderBottom:SetColorTexture(unpack(border))
        button.iWRBorderLeft:SetColorTexture(unpack(border))
        button.iWRBorderRight:SetColorTexture(unpack(border))
    end
    if button.iWRButtonAccent then
        button.iWRButtonAccent:SetColorTexture(unpack(destructive and theme.danger or theme.gold))
        button.iWRButtonAccent:Hide()
    end
    if button.iWRButtonShine then
        button.iWRButtonShine:Hide()
    end
    button:SetAlpha(enabled and 1 or 0.45)
    local font = (button.GetFontString and button:GetFontString()) or button.text
    if font then
        if destructive then font:SetTextColor(1, 0.55, 0.40)
        else font:SetTextColor(unpack(theme.gold)) end
    end
end

function iWR:StyleButton(button, destructive)
    if not button then return button end
    button.iWRDestructive = destructive == true
    if not button.iWRStyled then
        for _, region in ipairs({ button:GetRegions() }) do
            if region.IsObjectType and region:IsObjectType("Texture") then region:SetAlpha(0) end
        end
        local backdrop = button
        if not button.SetBackdrop then
            local parent = button:GetParent()
            local parentLevel = parent and parent:GetFrameLevel() or 0
            if button:GetFrameLevel() <= parentLevel then button:SetFrameLevel(parentLevel + 1) end
            backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
            backdrop:SetAllPoints(button)
            backdrop:SetFrameStrata(button:GetFrameStrata())
            backdrop:SetFrameLevel(math.max(0, button:GetFrameLevel() - 1))
            button:HookScript("OnShow", function() backdrop:Show() end)
            button:HookScript("OnHide", function() backdrop:Hide() end)
            backdrop:SetShown(button:IsShown())
        end
        backdrop:SetBackdrop(IWR_BACKDROP)
        button.iWRButtonBackdrop = backdrop
        local bg = button:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", 1, -1)
        bg:SetPoint("BOTTOMRIGHT", -1, 1)
        button.iWRButtonBg = bg
        local function borderTexture()
            return button:CreateTexture(nil, "BORDER")
        end
        button.iWRBorderTop = borderTexture()
        button.iWRBorderTop:SetPoint("TOPLEFT", 1, -1)
        button.iWRBorderTop:SetPoint("TOPRIGHT", -1, -1)
        button.iWRBorderTop:SetHeight(1)
        button.iWRBorderBottom = borderTexture()
        button.iWRBorderBottom:SetPoint("BOTTOMLEFT", 1, 1)
        button.iWRBorderBottom:SetPoint("BOTTOMRIGHT", -1, 1)
        button.iWRBorderBottom:SetHeight(1)
        button.iWRBorderLeft = borderTexture()
        button.iWRBorderLeft:SetPoint("TOPLEFT", 1, -1)
        button.iWRBorderLeft:SetPoint("BOTTOMLEFT", 1, 1)
        button.iWRBorderLeft:SetWidth(1)
        button.iWRBorderRight = borderTexture()
        button.iWRBorderRight:SetPoint("TOPRIGHT", -1, -1)
        button.iWRBorderRight:SetPoint("BOTTOMRIGHT", -1, 1)
        button.iWRBorderRight:SetWidth(1)

        local accent = button:CreateTexture(nil, "ARTWORK")
        accent:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
        accent:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)
        accent:SetWidth(2)
        accent:Hide()
        button.iWRButtonAccent = accent

        local shine = button:CreateTexture(nil, "ARTWORK")
        shine:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
        shine:SetPoint("TOPRIGHT", button, "TOPRIGHT", -3, -3)
        shine:SetHeight(1)
        shine:SetColorTexture(1, 0.59, 0.09, 1)
        button.iWRButtonShine = shine

        bg:Hide()
        button.iWRBorderTop:Hide()
        button.iWRBorderBottom:Hide()
        button.iWRBorderLeft:Hide()
        button.iWRBorderRight:Hide()
        accent:Hide()
        shine:Hide()

        local highlight = button:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetPoint("TOPLEFT", 2, -2)
        highlight:SetPoint("BOTTOMRIGHT", -2, 2)
        highlight:SetColorTexture(1, 0.59, 0.09, 0.15)
        button.iWRStyled = true
        if button.HookScript then
            button:HookScript("OnEnter", function(self)
                self.iWRHovered = true
                setButtonVisual(self, self.iWRActive)
            end)
            button:HookScript("OnLeave", function(self)
                self.iWRHovered = false
                self.iWRPressed = false
                setButtonVisual(self, self.iWRActive)
            end)
            button:HookScript("OnMouseDown", function(self)
                self.iWRPressed = true
                setButtonVisual(self, self.iWRActive)
            end)
            button:HookScript("OnMouseUp", function(self)
                self.iWRPressed = false
                setButtonVisual(self, self.iWRActive)
            end)
            button:HookScript("OnEnable", function(self) setButtonVisual(self, self.iWRActive) end)
            button:HookScript("OnDisable", function(self) setButtonVisual(self, self.iWRActive) end)
        end
    end
    setButtonVisual(button, button.iWRActive)
    return button
end

function iWR:SetButtonActive(button, active)
    if not button then return end
    button.iWRActive = active == true
    setButtonVisual(button, button.iWRActive)
end

function iWR:StyleEditBox(editBox)
    if not editBox or editBox.iWRStyled then return editBox end
    for _, region in ipairs({ editBox:GetRegions() }) do
        if region.IsObjectType and region:IsObjectType("Texture") then region:SetAlpha(0) end
    end
    local backdrop = editBox
    if not editBox.SetBackdrop then
        local parent = editBox:GetParent()
        local parentLevel = parent and parent:GetFrameLevel() or 0
        if editBox:GetFrameLevel() <= parentLevel then editBox:SetFrameLevel(parentLevel + 1) end
        backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        backdrop:SetAllPoints(editBox)
        backdrop:SetFrameStrata(editBox:GetFrameStrata())
        backdrop:SetFrameLevel(math.max(0, editBox:GetFrameLevel() - 1))
        editBox:HookScript("OnShow", function() backdrop:Show() end)
        editBox:HookScript("OnHide", function() backdrop:Hide() end)
        backdrop:SetShown(editBox:IsShown())
    end
    backdrop:SetBackdrop(IWR_BACKDROP)
    backdrop:SetBackdropColor(0.025, 0.025, 0.025, 1)
    backdrop:SetBackdropBorderColor(0.48, 0.35, 0.16, 1)
    editBox.iWRInputBackdrop = backdrop
    editBox.iWRStyled = true
    if editBox.SetTextInsets then editBox:SetTextInsets(9, 9, 0, 0) end
    if editBox.SetHighlightColor then editBox:SetHighlightColor(1, 0.59, 0.09, 0.28) end
    editBox:HookScript("OnEditFocusGained", function(self)
        self.iWRInputBackdrop:SetBackdropColor(0.04, 0.035, 0.028, 1)
        self.iWRInputBackdrop:SetBackdropBorderColor(unpack(iWR.Theme.gold))
    end)
    editBox:HookScript("OnEditFocusLost", function(self)
        self.iWRInputBackdrop:SetBackdropColor(0.025, 0.025, 0.025, 1)
        self.iWRInputBackdrop:SetBackdropBorderColor(0.48, 0.35, 0.16, 1)
    end)
    return editBox
end

local function IsMouseOverFrame(frame)
    if not frame or not frame:IsShown() then return false end
    if frame.IsMouseOver then return frame:IsMouseOver() end
    return MouseIsOver and MouseIsOver(frame) or false
end

function iWR:AttachAutocomplete(editBox, provider, options)
    if not editBox or editBox.iWRAutocomplete or type(provider) ~= "function" then return end
    options = options or {}

    local dropdown = CreateFrame("Frame", nil, editBox:GetParent(), "BackdropTemplate")
    dropdown:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, -3)
    dropdown:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT", 0, -3)
    dropdown:SetHeight(128)
    dropdown:SetFrameStrata(options.frameStrata or "FULLSCREEN_DIALOG")
    dropdown:SetFrameLevel(math.max(editBox:GetFrameLevel() + 20, editBox:GetParent():GetFrameLevel() + 20))
    dropdown:SetClampedToScreen(true)
    dropdown:SetBackdrop(IWR_BACKDROP)
    dropdown:SetBackdropColor(0.025, 0.022, 0.018, 1)
    dropdown:SetBackdropBorderColor(1, 0.59, 0.09, 0.90)
    dropdown:EnableMouse(true)
    dropdown:Hide()

    local buttons = {}
    local function SelectEntry(entry)
        if not entry then return end
        editBox.iWRSettingAutocomplete = true
        editBox:SetText(entry.value or entry.label or "")
        editBox.iWRSettingAutocomplete = nil
        editBox:SetCursorPosition(#(editBox:GetText() or ""))
        editBox:ClearFocus()
        dropdown:Hide()
        if options.onSelect then options.onSelect(entry, editBox) end
    end

    for index = 1, (options.maxResults or 5) do
        local button = CreateFrame("Button", nil, dropdown)
        button:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 7, -6 - (index - 1) * 23)
        button:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", -7, -6 - (index - 1) * 23)
        button:SetHeight(23)
        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        button.text:SetPoint("LEFT", button, "LEFT", 7, 0)
        button.text:SetPoint("RIGHT", button, "RIGHT", -7, 0)
        button.text:SetJustifyH("LEFT")
        button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
        button.highlight:SetAllPoints()
        button.highlight:SetColorTexture(1, 0.59, 0.09, 0.18)
        button:SetScript("OnClick", function(self) SelectEntry(self.entry) end)
        buttons[index] = button
    end

    local function UpdateSuggestions()
        local query = StripColorCodes(editBox:GetText() or ""):lower():match("^%s*(.-)%s*$") or ""
        local matches = {}
        if query ~= "" then
            for order, candidate in ipairs(provider() or {}) do
                local entry = type(candidate) == "table" and candidate or { value = tostring(candidate), label = tostring(candidate) }
                local searchText = tostring(entry.search or entry.value or entry.label or ""):lower()
                local position = searchText:find(query, 1, true)
                if position then
                    entry.iWRStarts = position == 1
                    entry.iWROrder = entry.order or order
                    matches[#matches + 1] = entry
                end
            end
            table.sort(matches, function(left, right)
                if left.iWRStarts ~= right.iWRStarts then return left.iWRStarts end
                if left.iWROrder ~= right.iWROrder then return left.iWROrder < right.iWROrder end
                return tostring(left.label or left.value) < tostring(right.label or right.value)
            end)
        end

        for index, button in ipairs(buttons) do
            local entry = matches[index]
            button.entry = entry
            button:SetShown(entry ~= nil)
            if entry then
                local label = entry.label or entry.value or ""
                if entry.detail and entry.detail ~= "" then label = label .. "  |cFF888888" .. entry.detail .. "|r" end
                button.text:SetText(label)
            end
        end
        dropdown:SetShown(editBox:HasFocus() and query ~= "" and matches[1] ~= nil)
    end

    editBox:HookScript("OnTextChanged", function(self)
        if not self.iWRSettingAutocomplete then UpdateSuggestions() end
    end)
    editBox:HookScript("OnEditFocusGained", UpdateSuggestions)
    editBox:HookScript("OnEditFocusLost", function(self)
        C_Timer.After(0, function()
            if not self:HasFocus() and not IsMouseOverFrame(dropdown) then dropdown:Hide() end
        end)
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        dropdown:Hide()
        self:ClearFocus()
    end)
    editBox:SetScript("OnEnterPressed", function(self)
        local first = buttons[1]
        if dropdown:IsShown() and first.entry then SelectEntry(first.entry) else self:ClearFocus() end
    end)

    editBox.iWRAutocomplete = dropdown
    editBox.iWRUpdateAutocomplete = UpdateSuggestions
end

function iWR:CreateiWRStyleFrame(parent, width, height, point, backdrop)
    local frameName = "iWRFrame_" .. tostring(math.random(1, 100000))
    local frame = CreateFrame("Frame", frameName, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint(unpack(point))
    if backdrop then frame:SetBackdrop(backdrop) else self:StyleSurface(frame, "panel") end
    -- Add to UISpecialFrames for ESC functionality
    if not tContains(UISpecialFrames, frame:GetName()) then
        tinsert(UISpecialFrames, frame:GetName())
    end
    return frame
end

-- Resolve a type value to its effective configured level key
-- E.g., with keys {-1, -6, -10}: -4 resolves to -1, -7 resolves to -6
function iWR:ResolveLevel(typeIndex)
    typeIndex = tonumber(typeIndex)
    if not typeIndex or typeIndex == 0 then return typeIndex end

    local goodLevels = iWRSettings and iWRSettings.GoodLevels or iWR.SettingsDefault.GoodLevels
    local badLevels  = iWRSettings and iWRSettings.BadLevels  or iWR.SettingsDefault.BadLevels
    local posKeys, negKeys = iWR.GetLevelKeys(goodLevels, badLevels)

    if typeIndex > 0 then
        -- posKeys sorted descending: {10, 6, 1}
        -- Find first (largest) configured key <= typeIndex
        for _, k in ipairs(posKeys) do
            if k <= typeIndex then
                return k
            end
        end
        return posKeys[#posKeys]
    else
        -- negKeys sorted ascending in abs: {-1, -6, -10}
        -- Find most negative configured key that's still >= typeIndex
        local resolved = negKeys[1]
        for _, k in ipairs(negKeys) do
            if k >= typeIndex then
                resolved = k
            end
        end
        return resolved
    end
end

function iWR:GetTypeName(typeIndex)
    typeIndex = tonumber(typeIndex)
    if not typeIndex then return "" end

    local resolved = iWR:ResolveLevel(typeIndex)
    if not resolved then resolved = typeIndex end

    -- Check custom label for resolved key
    if iWRSettings and iWRSettings.ButtonLabels and iWRSettings.ButtonLabels[resolved]
       and iWRSettings.ButtonLabels[resolved] ~= "" then
        return iWRSettings.ButtonLabels[resolved]
    end

    -- Fall back to default type name for resolved key
    return iWR.Types[resolved] or iWR.Types[typeIndex] or ""
end

function iWR:GetIcon(typeIndex)
    typeIndex = tonumber(typeIndex)
    if not typeIndex then return nil end

    local resolved = iWR:ResolveLevel(typeIndex)
    if not resolved then resolved = typeIndex end

    -- Check custom icon for resolved key
    if iWRSettings and iWRSettings.CustomIcons and iWRSettings.CustomIcons[resolved] then
        return iWRSettings.CustomIcons[resolved]
    end

    -- Fall back to default icon for resolved key
    return iWR.Icons[resolved] or iWR.Icons[typeIndex]
end

function iWR:GetChatIcon(typeIndex)
    typeIndex = tonumber(typeIndex)
    if not typeIndex then return "Interface\\Icons\\INV_Misc_QuestionMark" end

    local resolved = iWR:ResolveLevel(typeIndex)
    if not resolved then resolved = typeIndex end

    -- Check custom icon for resolved key
    if iWRSettings and iWRSettings.CustomIcons and iWRSettings.CustomIcons[resolved] then
        return iWRSettings.CustomIcons[resolved]
    end

    -- Fall back to default chat icon for resolved key
    return iWR.ChatIcons[resolved] or iWR.ChatIcons[typeIndex] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function iWR:VerifyInputName(Name)
    local verifyName = StripColorCodes(Name)
    if verifyName ~= L["DefaultNameInput"]
        and verifyName ~= L["DefaultNoteInput"]
        and verifyName ~= ""
        and verifyName ~= nil
        and not string.find(verifyName, "^%s+$")
        and not string.find(verifyName, "%d")
        and #verifyName >= 3
        and #verifyName <= 80
    then
        return true
    end
    return false
end

function iWR:SaveMinimapPosition(event, buttonName)
    iWRSettings.MinimapButton.minimapPos = LDBIcon.db.iWillRemember_MinimapButton.minimapPos
end

-- Hook into LibDBIcon updates
LDBIcon.RegisterCallback(iWR, "LibDBIcon_Changed", "SaveMinimapPosition")

-- Restore position on load
function iWR:RestoreMinimapPosition()
    if iWRSettings.MinimapButton then
        LDBIcon:Refresh("iWillRemember_MinimapButton", iWRSettings.MinimapButton)
    end
end

-- ╭────────────────────────────────────────╮
-- │      Function: Add note to Tooltip     │
-- ╰────────────────────────────────────────╯
function iWR:AddNoteToGameTooltip(self, ...)
    local name, unit = self:GetUnit()

    -- Secret value guard for retail 12.0+
    local issv = _G.issecretvalue
    if issv and unit and issv(unit) then return end

    -- Check if the unit is valid and is a player
    if not unit or not UnitIsPlayer(unit) then
        return
    end

    -- Get the player's realm and format the database key
    local targetNameWithRealm = GetUnitName(unit, true)
    local targetName = GetUnitName(unit, false)

    -- Secret value guard for name/realm
    if issv and ((targetNameWithRealm and issv(targetNameWithRealm)) or (targetName and issv(targetName))) then return end

    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWR.CurrentRealm
    targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present
    
    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm

    -- Get player data from the database
    local data = iWR:GetDatabaseEntry(databaseKey)
    if not data or next(data) == nil then
        return
    end

    -- Modern tooltip post-calls may run more than once for the same unit.
    if self.iWRNoteDatabaseKey == databaseKey then return end
    self.iWRNoteDatabaseKey = databaseKey

    local typeIndex = tonumber(data[2])
    local note = data[1]
    local author = data[6]
    local date = data[5]
    local typeText = iWR:GetTypeName(typeIndex)
    local iconPath = iWR:GetChatIcon(typeIndex)

    -- Add the note details to the tooltip
    if typeText then
        local icon = iconPath and "|T" .. iconPath .. ":16:16:0:0|t" or ""
        GameTooltip:AddLine(L["NoteToolTip"] .. icon .. iWR.Colors[typeIndex] .. " " .. typeText .. "|r " .. icon)
    end

    if note and note ~= "" then
        if #note <= 30 then
            GameTooltip:AddLine(L["DetailNote"] .. " " .. iWR.Colors[data[2]] .. note, 1, 0.82, 0) -- Add note in tooltip
        else
            local firstLine, secondLine = iWR:splitOnSpace(note, 30) -- Split text on the nearest space
            GameTooltip:AddLine(L["DetailNote"] .. " " .. iWR.Colors[data[2]] .. firstLine, 1, 0.82, 0) -- Add first line
            GameTooltip:AddLine(iWR.Colors[data[2]] .. secondLine, 1, 0.82, 0) -- Add second line
        end
    end

    if author and date and iWRSettings.TooltipShowAuthor then
        GameTooltip:AddLine(iWR.Colors.Default .. L["DetailAuthor"] .. " " .. iWR.Colors[typeIndex] .. author .. iWR.Colors.Default .. " (" .. date .. ")")
    end

    -- Show note count if there is history
    local historyCount = data[10] and #data[10] or 0
    if historyCount > 0 then
        GameTooltip:AddLine(iWR.Colors.Gray .. string.format(L["NotesCount"], historyCount + 1) .. "|r")
    end
end

-- ╭─────────────────────────────────────╮
-- │      Function: Timestamp Compare    │
-- ╰─────────────────────────────────────╯
function iWR:IsNeedToUpdate(CurrDataTime, CompDataTime)
    if tonumber(CurrDataTime) < tonumber(CompDataTime) then
        return true
    end
end

function iWR:ExtractDataBase(Entry)
    local data = iWRDatabase[tostring(Entry)]
    if not data then return end

    local note = data[1]
    local type = tonumber(data[2])
    local name = data[4]
    local date = data[5]
    local author = data[6]
    return note, type, name, date, author
end

-- ╭──────────────────────────────────────╮
-- │      Function: Get Current Time      │
-- ╰──────────────────────────────────────╯
function iWR:GetCurrentTimeByHours()
    -- Extract current time components
    ---@diagnostic disable-next-line: param-type-mismatch
    local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
    -- Calculate the current time in hours
    local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay) * 24 + tonumber(CurrMonth) * 720 + tonumber(CurrYear) * 8640
    -- Format the current date as YYYY-MM-DD
    local CurrentDate = string.format("20".."%02d-%02d-%02d", tonumber(CurrYear), tonumber(CurrMonth), tonumber(CurrDay))
    -- Return both the current time in hours and the formatted current date
    return tonumber(CurrentTime), CurrentDate
end

function iWR:PlayNotificationSound()
    PlaySound(SOUNDKIT.RAID_WARNING, "Master")
end

function iWR:ShowNotificationPopup(matches)
    if iWRSettings.GroupWarnings and #matches > 0 then
        -- Create a notification frame
        local notificationFrame = CreateFrame("Frame", nil, UIParent)
        notificationFrame:SetSize(300, 100 + (#matches - 1) * 20)
        notificationFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)

        -- Add title text
        local title = notificationFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        title:SetPoint("TOP", notificationFrame, "TOP", 0, -10)
        title:SetText(L["GroupWarning"])
        title:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")

        -- Add information for each match
        local lastElement = title
        for _, match in ipairs(matches) do
            local playerInfo = notificationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            playerInfo:SetPoint("TOP", lastElement, "BOTTOM", 0, -10)
            playerInfo:SetText(iWR.Colors.iWR .. match.name .. "|r" .. iWR.Colors.iWR .. " (" .. iWR.Colors[match.relation] .. iWR:GetTypeName(match.relation) .. iWR.Colors.iWR .. ")")
            playerInfo:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

            -- Add note text
            local noteText = notificationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            noteText:SetPoint("TOP", playerInfo, "BOTTOM", 0, -5)
            noteText:SetText(L["DetailNote"] .. " " .. iWR.Colors.Yellow .. match.note .. "|r")
            noteText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

            lastElement = noteText
        end

        -- Fade the frame over 10 seconds
        C_Timer.After(2, function()
            UIFrameFadeOut(notificationFrame, 10, 1, 0)
        end)

        -- Hide the frame once the fade is complete
        C_Timer.After(10, function()
            if notificationFrame:IsShown() then
                notificationFrame:Hide()
            end
        end)

        if iWRSettings.SoundWarnings then
            iWR:PlayNotificationSound()
            iWR:DebugMsg("Warning sound was played.",3)
        end

        notificationFrame:Show()
    end
end

-- ╭──────────────────────────────────────────────╮
-- │      Guild Watchlist: Auto-Import Check     │
-- ╰──────────────────────────────────────────────╯
function iWR:CheckGuildWatchlist(databaseKey, guildName, playerName, playerRealm, classToken, raceToken, factionToken)
    if not iWRSettings.GuildWatchlist or not next(iWRSettings.GuildWatchlist) then return end
    if not guildName or guildName == "" then return end
    if iWRDatabase[databaseKey] then return end
    if iWR:IsSamePlayerName(playerName, iWR:GetUnitPlayerIdentity("player")) then return end

    local watchEntry = iWRSettings.GuildWatchlist[guildName]
    if not watchEntry then return end
    local relationType, noteAuthorOverride, customNote
    if type(watchEntry) == "table" then
        relationType = watchEntry.type
        noteAuthorOverride = watchEntry.author
        customNote = watchEntry.note
    else
        relationType = watchEntry
        noteAuthorOverride = ""
        customNote = ""
        iWRSettings.GuildWatchlist[guildName] = { type = relationType, author = "", note = "" }
    end

    local currentTime, currentDate = iWR:GetCurrentTimeByHours()
    local noteAuthor = (noteAuthorOverride and noteAuthorOverride ~= "") and noteAuthorOverride or iWR:ColorizePlayerNameByClass(iWR:GetUnitPlayerIdentity("player"), select(2, UnitClass("player")))
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(playerName, playerRealm)
    local dbName = classToken and iWR.Colors.Classes[classToken] and (iWR.Colors.Classes[classToken] .. capitalizedName) or (iWR.Colors.Gray .. capitalizedName)

    local importNote = (customNote and customNote ~= "") and customNote or string.format(L["GuildWatchlistDefaultNote"], guildName)

    iWRDatabase[databaseKey] = {
        importNote,             -- [1] Note (custom or auto guild note)
        relationType,       -- [2] Type
        currentTime,        -- [3] Timestamp
        dbName,             -- [4] Display name (colored)
        currentDate,        -- [5] Date
        noteAuthor,         -- [6] Author
        capitalizedRealm,   -- [7] Realm
        factionToken or UnitFactionGroup("target") or "",  -- [8] Faction
        [12] = classToken or "",            -- [12] Class token
        [13] = raceToken or select(2, UnitRace("target")) or "", -- [13] Race token
    }

    print(string.format(L["GuildWatchlistAutoImport"], dbName .. iWR.Colors.Reset, guildName))
    iWR:DebugMsg("Guild Watchlist: Auto-imported " .. capitalizedName .. "-" .. capitalizedRealm .. " (Guild: " .. guildName .. ", Type: " .. relationType .. ")", 3)

    -- Update target frame if we just imported the current target
    iWR:UpdateTargetFrame()
end

function iWR:HandleGroupRosterUpdate(wasInGroup)
    local isInGroup = IsInGroup() -- Check if the player is currently in a group
    if not isInGroup and wasInGroup then
        -- Player has left the group, wipe warned players and session log tracker
        wipe(iWR.WarnedPlayers)
        wipe(iWR.LoggedThisSession)
        iWR:DebugMsg("Player has left the group. Warned players list wiped.", 3)
    else
        iWR:CheckGroupMembersAgainstDatabase()
        iWR:LogGroupMembers()
    end
end


function iWR:CheckGroupMembersAgainstDatabase()
    local numGroupMembers = GetNumGroupMembers()
    local isInRaid = IsInRaid()
    local matches = {}
    local playerName = iWR:GetUnitPlayerIdentity("player") -- Current player's full Forever name

    local maxPartyIndex = isInRaid and numGroupMembers or (numGroupMembers - 1)

    for i = 1, maxPartyIndex do
        local unitID = isInRaid and "raid" .. i or "party" .. i
        local targetName, targetRealm = UnitName(unitID)
        local targetIdentity = targetName and iWR:GetPlayerDatabaseKey(targetName, targetRealm)

        if not targetName then
            iWR:DebugMsg("Could not retrieve name for unitID: " .. unitID, 2)
        elseif targetIdentity and not iWR.WarnedPlayers[targetIdentity] then
            iWR.WarnedPlayers[targetIdentity] = true

            if targetRealm == "" or targetRealm == nil then
                targetRealm = iWR.CurrentRealm
            end

            local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
            local databaseKey = capitalizedName .. "-" .. capitalizedRealm

            if not iWR:IsSamePlayerName(playerName, targetName) then
                if iWRDatabase[databaseKey] then
                    local data = iWR:GetDatabaseEntry(databaseKey)
                    if data and next(data) ~= nil then
                        local relationValue = data[2]
                        if relationValue and relationValue < 0 then
                            local note = data[1] or ""
                            table.insert(matches, { name = data[4], relation = relationValue, note = note })
                        end
                    end
                else
                    -- Guild Watchlist: auto-import if group member's guild is watched
                    local guildName = GetGuildInfo(unitID)
                    if guildName and iWRSettings.GuildWatchlist and iWRSettings.GuildWatchlist[guildName] then
                        local _, classToken = UnitClass(unitID)
                        local _, raceToken = UnitRace(unitID)
                        iWR:CheckGuildWatchlist(databaseKey, guildName, capitalizedName, capitalizedRealm, classToken, raceToken, UnitFactionGroup(unitID))
                        -- Check if auto-imported with negative type for warning
                        if iWRDatabase[databaseKey] then
                            local data = iWR:GetDatabaseEntry(databaseKey)
                            if data and next(data) ~= nil then
                                local relationValue = data[2]
                                if relationValue and relationValue < 0 then
                                    local note = data[1] or ""
                                    table.insert(matches, { name = data[4], relation = relationValue, note = note })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Show a notification popup and print a message if any matches were found
    if #matches > 0 then
        iWR:ShowNotificationPopup(matches)

        -- Construct chat message
        local chatMessage = L["GroupWarning"]
        for _, match in ipairs(matches) do
            chatMessage = chatMessage .. " " .. match.name .. " (" .. iWR.Colors[match.relation] .. iWR:GetTypeName(match.relation) .. iWR.Colors.Reset .. "), "
        end

        -- Print message to chat
        print(chatMessage:sub(1, -3)) -- Remove the trailing comma
    end
end

-- ╭────────────────────────────────────────────────╮
-- │      Group Log: Automatic Member Logging      │
-- ╰────────────────────────────────────────────────╯
function iWR:LogGroupMembers()
    if not iWRSettings.GroupLogEnabled then return end
    if not iWRMemory.GroupLog then iWRMemory.GroupLog = {} end

    local numGroupMembers = GetNumGroupMembers()
    if numGroupMembers <= 1 then return end

    local isInRaid = IsInRaid()
    local playerName = iWR:GetUnitPlayerIdentity("player")
    local maxPartyIndex = isInRaid and numGroupMembers or (numGroupMembers - 1)

    -- Get current zone and instance info
    local zoneName = GetRealZoneText() or ""
    local inInstance, instanceType = IsInInstance()

    for i = 1, maxPartyIndex do
        local unitID = isInRaid and "raid" .. i or "party" .. i
        local targetName, targetRealm = UnitName(unitID)

        -- Skip self, unknown/nil names, and units that don't exist
        if targetName and targetName ~= UNKNOWNOBJECT and targetName ~= "Unknown"
            and UnitExists(unitID) and not UnitIsUnit(unitID, "player") then
            if targetRealm == "" or targetRealm == nil then
                targetRealm = iWR.CurrentRealm
            end

            local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
            local sessionKey = capitalizedName .. "-" .. capitalizedRealm

            -- Skip if already logged this session
            if not iWR.LoggedThisSession[sessionKey] then
                iWR.LoggedThisSession[sessionKey] = true

                -- Get class info
                local _, classToken = UnitClass(unitID)
                local _, raceToken = UnitRace(unitID)

                -- Check if player already has a note in database
                local databaseKey = capitalizedName .. "-" .. capitalizedRealm
                local hasNote = iWRDatabase[databaseKey] ~= nil

                -- Create log entry
                local entry = {
                    name = capitalizedName,
                    realm = capitalizedRealm,
                    class = classToken or "UNKNOWN",
                    race = raceToken or "",
                    faction = UnitFactionGroup(unitID) or "",
                    timestamp = time(),
                    date = date("%Y-%m-%d"),
                    zone = zoneName,
                    isInstance = inInstance or false,
                    instanceType = instanceType or "none",
                    hasNote = hasNote,
                }

                table.insert(iWRMemory.GroupLog, entry)
                iWR:DebugMsg("Group Log: Logged " .. capitalizedName .. "-" .. capitalizedRealm .. " in " .. zoneName, 3)
            end
        end
    end
end

function iWR:UpdateGroupLogZone()
    if not iWRSettings.GroupLogEnabled then return end
    if not iWRMemory.GroupLog then return end
    if not IsInGroup() then return end

    local now = time()
    local window = iWR.CONSTANTS.GROUP_LOG_ZONE_UPDATE_WINDOW
    local zoneName = GetRealZoneText() or ""
    local inInstance, instanceType = IsInInstance()

    -- Update recent entries (within 10 min) that belong to current session
    for i = #iWRMemory.GroupLog, 1, -1 do
        local entry = iWRMemory.GroupLog[i]
        if not entry then break end

        -- Only update entries from this session that are within the time window
        local age = now - (entry.timestamp or 0)
        if age > window then break end -- Entries are chronological, older ones are earlier

        local sessionKey = entry.name .. "-" .. entry.realm
        if iWR.LoggedThisSession[sessionKey] then
            entry.zone = zoneName
            entry.isInstance = inInstance or false
            entry.instanceType = instanceType or "none"
        end
    end
end

function iWR:PruneGroupLog()
    if not iWRMemory.GroupLog then return end
    local maxEntries = iWR.CONSTANTS.MAX_GROUP_LOG_ENTRIES
    while #iWRMemory.GroupLog > maxEntries do
        table.remove(iWRMemory.GroupLog, 1) -- Remove oldest (first) entry
    end
end

function iWR:ClearGroupLog()
    if iWRMemory.GroupLog then
        wipe(iWRMemory.GroupLog)
    end
    iWR:DebugMsg("Group log cleared.", 3)
end

-- ╭────────────────────────────────────────╮
-- │      Function: Update the Tooltip      │
-- ╰────────────────────────────────────────╯
function iWR:UpdateTooltip()
    local tooltip = GameTooltip
    if tooltip:IsVisible() then
        tooltip:Hide()
    end
end

-- Function to create a button
function iWR:CreateRelationButton(parent, size, position, texture, label, onClick)
    -- Create the button
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    self:StyleButton(button)
    button:SetSize(size[1], size[2])
    button:SetPoint(unpack(position))
    button:SetScript("OnClick", onClick)

    -- Add an icon to the button
    local iconTexture = button:CreateTexture(nil, "ARTWORK")
    iconTexture:SetSize(size[1] - 8, size[2] - 8)
    iconTexture:SetPoint("CENTER", button, "CENTER", 0, 0)
    iconTexture:SetTexture(texture)
    button.iconTexture = iconTexture

    -- Add a label below the button
    local buttonLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    buttonLabel:SetPoint("TOP", button, "BOTTOM", 0, -3)
    buttonLabel:SetWidth(size[1] + 4)
    buttonLabel:SetWordWrap(false)
    buttonLabel:SetText(label)

    return button, buttonLabel
end

function iWR:FormatNameAndRealm(name, realm)
    -- Ensure the inputs are strings to prevent errors
    if not name or type(name) ~= "string" then
        iWR:DebugMsg("Format name not string: " .. name or nil,3)
        name = ""
    end
    if not realm or type(realm) ~= "string" then
        iWR:DebugMsg("Format realm not string: " .. realm or nil,3)
        realm = ""
    end
    return self:ResolvePlayerIdentity(name, realm)
end

function iWR:SetTargetFrameShadowedUnitFrames()
    local portraitParent = _G["SUFUnittarget"]
    local shadowunitframes = true;
    if shadowunitframes then
        iWR:DebugMsg("Using Portrait Parent: " .. portraitParent:GetName(), 3)

        -- Get the target's name and realm for database lookup
        local targetNameWithRealm = GetUnitName("target", true)
        local targetName = GetUnitName("target", false)
        local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWR.CurrentRealm
        targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

        -- Format name and realm for database key
        local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
        local databaseKey = capitalizedName .. "-" .. capitalizedRealm

        -- Ensure the database entry exists
        if not iWRDatabase[databaseKey] then
            iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database. [SetTargetFrameShadowedUnitFrames]", 1)
            return
        end

        -- Create or update the custom frame
        if not iWR.customFrame then
            iWR.customFrame = CreateFrame("Frame", nil, portraitParent)
            iWR.customFrame.texture = iWR.customFrame:CreateTexture(nil, "OVERLAY")
        end

        local dragonFrame = iWR.customFrame
        dragonFrame:SetFrameLevel(6)
        dragonFrame:Show()

        local dragonTexture = dragonFrame.texture
        dragonTexture:SetDrawLayer('ARTWORK', 3)

        local targetRelation = iWRDatabase[databaseKey][2]
        local typeName = iWR.Types[targetRelation]

        if typeName == "Superior" then
            dragonTexture:SetTexture('Interface\\Addons\\iWillRemember\\Images\\TargetFrames\\ShadowedUnitFrames\\winged-dragon-elite.blp')
            dragonTexture:SetSize(77, 75)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 81, -12)
            dragonTexture:SetVertexColor(0.3, 0.65, 1, 1)
        elseif typeName == "Respected" then
            dragonTexture:SetTexture('Interface\\Addons\\iWillRemember\\Images\\TargetFrames\\ShadowedUnitFrames\\winged-dragon-elite.blp')
            dragonTexture:SetSize(77, 75)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 81, -12)
            dragonTexture:SetVertexColor(0, 0.9, 0, 1)
        elseif typeName == "Liked" then
            dragonTexture:SetTexture('Interface\\Addons\\iWillRemember\\Images\\TargetFrames\\ShadowedUnitFrames\\dragon-elite.blp')
            dragonTexture:SetSize(77, 75)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 81, -12)
            dragonTexture:SetVertexColor(0, 0.7, 0, 1)
        elseif typeName == "Disliked" then
            dragonTexture:SetTexture('Interface\\Addons\\iWillRemember\\Images\\TargetFrames\\ShadowedUnitFrames\\dragon-elite.blp')
            dragonTexture:SetSize(77, 75)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 81, -12)
            dragonTexture:SetVertexColor(0.7, 0, 0, 1)
        elseif typeName == "Hated" then
            dragonTexture:SetTexture('Interface\\Addons\\iWillRemember\\Images\\TargetFrames\\ShadowedUnitFrames\\winged-dragon-elite.blp')
            dragonTexture:SetSize(77, 75)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 81, -12)
            dragonTexture:SetVertexColor(0.9, 0, 0, 1)
        else
            iWR:DebugMsg("Relationship type is missing. [SetTargetFrameShadowedUnitFrames]", 1)
            dragonFrame:Hide()
        end

        iWR:DebugMsg("Custom frame successfully anchored to:" .. portraitParent:GetName() .. ".", 3)
    else
        iWR:DebugMsg("ShadowedUnitFrames portrait frame not found.", 1)
    end
end

function iWR:SetTargetFrameForeverDragon()
    local portraitParent = _G["TargetFrame"]
    if portraitParent then
        local dragonOffsetX, dragonOffsetY = 6, 0
        local largeDragonOffsetX = 15
        local container = portraitParent.TargetFrameContainer
        local content = portraitParent.TargetFrameContent
        local contentMain = content and content.TargetFrameContentMain
        local portraitAnchor = _G["TargetFramePortrait"]
            or (container and (container.Portrait or container.TargetFramePortrait))
            or (contentMain and (contentMain.Portrait or contentMain.TargetFramePortrait))
            or portraitParent.Portrait
            or portraitParent.portrait
            or portraitParent
        iWR:DebugMsg("Using Portrait Parent: " .. portraitParent:GetName(), 3)

        -- Get the target's name and realm for database lookup
        local targetNameWithRealm = GetUnitName("target", true)
        local targetName = GetUnitName("target", false)
        local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWR.CurrentRealm
        targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

        -- Format name and realm for database key
        local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
        local databaseKey = capitalizedName .. "-" .. capitalizedRealm

        -- Ensure the database entry exists
        if not iWRDatabase[databaseKey] then
            iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database. [SetTargetFrameForeverDragon]", 1)
            return
        end

        -- Create or update the custom frame
        if not iWR.customFrame then
            iWR.customFrame = CreateFrame("Frame", nil, portraitParent)
            iWR.customFrame.texture = iWR.customFrame:CreateTexture(nil, "OVERLAY")
        end

        local dragonFrame = iWR.customFrame
        dragonFrame:SetParent(portraitParent)
        dragonFrame:SetFrameLevel(portraitParent:GetFrameLevel() + 2)
        dragonFrame:Show()

        local dragonTexture = dragonFrame.texture
        -- Bundled Dragonflight-style atlas; DragonFlightUI is not required.
        dragonTexture:SetTexture(iWR.AddonPath .. "Images\\TargetFrames\\Forever\\uiunitframeboss2x.blp")
        dragonTexture:SetDrawLayer('ARTWORK', 3)
        dragonTexture:ClearAllPoints()

        local targetRelation = iWRDatabase[databaseKey][2]
        local typeName = iWR.Types[targetRelation]

        if typeName == "Superior" then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitAnchor, 'CENTER', largeDragonOffsetX, dragonOffsetY)
            dragonTexture:SetVertexColor(0.3, 0.65, 1, 1)
        elseif typeName == "Respected" then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitAnchor, 'CENTER', largeDragonOffsetX, dragonOffsetY)
            dragonTexture:SetVertexColor(0, 0.9, 0, 1)
        elseif typeName == "Liked" then
            dragonTexture:SetTexCoord(0.001953125, 0.314453125, 0.322265625, 0.630859375)
            dragonTexture:SetSize(80, 79)
            dragonTexture:SetPoint('CENTER', portraitAnchor, 'CENTER', dragonOffsetX, dragonOffsetY)
            dragonTexture:SetVertexColor(0, 0.7, 0, 1)
        elseif typeName == "Disliked" then
            dragonTexture:SetTexCoord(0.001953125, 0.314453125, 0.322265625, 0.630859375)
            dragonTexture:SetSize(80, 79)
            dragonTexture:SetPoint('CENTER', portraitAnchor, 'CENTER', dragonOffsetX, dragonOffsetY)
            dragonTexture:SetVertexColor(0.7, 0, 0, 1)
        elseif typeName == "Hated" then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitAnchor, 'CENTER', largeDragonOffsetX, dragonOffsetY)
            dragonTexture:SetVertexColor(0.9, 0, 0, 1)
        else
            iWR:DebugMsg("Relationship type is missing. [SetTargetFrameForeverDragon]", 1)
            dragonFrame:Hide()
        end

        iWR:DebugMsg("Custom frame successfully anchored to:" .. portraitParent:GetName() .. ".", 3)
    else
        iWR:DebugMsg("Default TargetFrame was not found for the dragon overlay.", 1)
    end
end

function iWR:SetTargetFrameDefault()
    -- Validate target existence and ensure it's a player
    if not UnitExists("target") or not UnitIsPlayer("target") then
        iWR:DebugMsg("No valid target found or target is not a player.", 1)
        if iWR.customFrame then iWR.customFrame:Hide() end
        return
    end

    -- Get the target's name and realm for database lookup
    local targetNameWithRealm = GetUnitName("target", true)
    local targetName = GetUnitName("target", false)
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWR.CurrentRealm
    targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm

    -- Ensure the database entry exists
    if not iWRDatabase[databaseKey] then
        iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database. [SetTargetFrameDefault]", 1)
        if iWR.customFrame then iWR.customFrame:Hide() end
        return
    end

    -- Get the target type (index 2 in database entry) and validate
    local targetType = iWRDatabase[databaseKey][2]
    if not targetType or not iWR.TargetFrames[targetType] then
        iWR:DebugMsg("Invalid target type or no texture defined for target type: " .. tostring(targetType), 1)
        if iWR.customFrame then iWR.customFrame:Hide() end
        return
    end

    -- Classic Era has TargetFrameTextureFrameTexture — set it directly
    if TargetFrameTextureFrameTexture then
        TargetFrameTextureFrameTexture:SetTexture(iWR.TargetFrames[targetType])
        iWR.modifiedTargetTexture = true
        iWR:DebugMsg("Default frame updated for target [" .. databaseKey .. "] with type [" .. iWR.Colors[targetType] .. iWR:GetTypeName(targetType) .. "].", 3)
    else
        -- Fallback: use custom overlay frame on TargetFrame
        local portraitParent = _G["TargetFrame"]
        if not portraitParent then
            iWR:DebugMsg("TargetFrame not found for overlay. [SetTargetFrameDefault]", 1)
            return
        end

        if not iWR.customFrame then
            iWR.customFrame = CreateFrame("Frame", nil, portraitParent)
            iWR.customFrame.texture = iWR.customFrame:CreateTexture(nil, "OVERLAY")
        end

        local overlayFrame = iWR.customFrame
        overlayFrame:SetParent(portraitParent)
        overlayFrame:SetFrameLevel(portraitParent:GetFrameLevel() + 2)
        overlayFrame:Show()

        local overlayTexture = overlayFrame.texture
        overlayTexture:ClearAllPoints()
        overlayTexture:SetTexture(iWR.TargetFrames[targetType])
        overlayTexture:SetDrawLayer("ARTWORK", 3)
        overlayTexture:SetAllPoints(portraitParent)
        overlayTexture:Show()

        iWR:DebugMsg("Overlay frame updated for target [" .. databaseKey .. "] with type [" .. iWR.Colors[targetType] .. iWR:GetTypeName(targetType) .. "].", 3)
    end
end

-- ╭────────────────────────────────────────╮
-- │      Function: Add new line if long    │
-- ╰────────────────────────────────────────╯
function iWR:splitOnSpace(text, maxLength)
    -- Find the position of the last space within the maxLength
    local spacePos = text:sub(1, maxLength):match(".*() ")
    if not spacePos then
        spacePos = maxLength -- If no space is found, split at maxLength
    end
    return text:sub(1, spacePos), text:sub(spacePos + 1)
end

-- ╭──────────────────────────────────────────────╮
-- │      Function: Strip Color Codes Function    │
-- ╰──────────────────────────────────────────────╯
function StripColorCodes(input)
    if type(input) ~= "string" then return "" end
    return input:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end

-- ╭────────────────────────────────────────╮
-- │      Colorize Player Name by Class     │
-- ╰────────────────────────────────────────╯
function iWR:ColorizePlayerNameByClass(playerName, class)
    if iWR.Colors.Classes[class] then
        return iWR.Colors.Classes[class] .. playerName .. iWR.Colors.Reset
    else
        return iWR.Colors.iWR .. playerName .. iWR.Colors.Reset
    end
end

-- ╭──────────────────────────────────╮
-- │      Set New Targeting Frame     │
-- ╰──────────────────────────────────╯
function iWR:SetTargetingFrame()
    -- Get target name and realm
    local targetNameWithRealm = GetUnitName("target", true)
    local targetName = GetUnitName("target", false)

    -- Secret value guard for retail 12.0+
    local issv = _G.issecretvalue
    if issv and ((targetNameWithRealm and issv(targetNameWithRealm)) or (targetName and issv(targetName))) then return end

    local targetRealm = select(2, strsplit("-", targetNameWithRealm or ""))
    targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

    -- Use current realm if no realm is found
    if not targetRealm or targetRealm == "" then
        targetRealm = iWR.CurrentRealm
    end

    -- Reset Classic texture only if iWR modified it
    if iWR.modifiedTargetTexture and TargetFrameTextureFrameTexture then
        -- Restore correct texture based on target classification (elite/rare/boss/normal)
        local classification = UnitExists("target") and UnitClassification("target") or "normal"
        if classification == "worldboss" or classification == "boss" then
            TargetFrameTextureFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
        elseif classification == "rareelite" then
            TargetFrameTextureFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite")
        elseif classification == "elite" then
            TargetFrameTextureFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
        elseif classification == "rare" then
            TargetFrameTextureFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare")
        else
            TargetFrameTextureFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
        end
        iWR:DebugMsg("Restored target frame texture for classification: " .. classification, 3)
        iWR.modifiedTargetTexture = false
    end
    if iWR.customFrame then
        iWR.customFrame:Hide()
    end

    -- Only proceed for players
    if not UnitExists("target") or not UnitIsPlayer("target") then
        if UnitExists("target") then
            local classification = UnitClassification("target") or "normal"
            iWR:DebugMsg("Target is NPC [" .. (GetUnitName("target", false) or "Unknown") .. "], classification: " .. classification .. ". Skipping. [SetTargetingFrame]", 3)
        end
        return
    end

    -- Reset note input if Discord link is set (guard for panel not yet created)
    if iWRNoteInput and iWRNoteInput:GetText() == L["DiscordLink"] then
        iWRNoteInput:SetText(L["DefaultNoteInput"])
    end

    -- Format the database key as "Name-Realm"
    local databaseKey, resolvedTargetName, resolvedTargetRealm = iWR:GetPlayerDatabaseKey(targetName, targetRealm)
    targetName, targetRealm = resolvedTargetName, resolvedTargetRealm

    -- Check if the target is in the database
    if not iWRDatabase[databaseKey] then
        local _, class = UnitClass("target")
        local _, race = UnitRace("target")

        -- Guild Watchlist: auto-import if target's guild is watched
        local guildName = GetGuildInfo("target")
        if guildName and iWRSettings.GuildWatchlist and iWRSettings.GuildWatchlist[guildName] then
            iWR:CheckGuildWatchlist(databaseKey, guildName, targetName, targetRealm, class, race, UnitFactionGroup("target"))
        end

        -- Re-check after potential guild import
        if not iWRDatabase[databaseKey] then
            -- Easter egg: auto-add addon author (Anniversary TBC only)
            local toc = tonumber(iWR.GameTocVersion) or 0
            if databaseKey == "Baldvin-Spineshatter" and toc >= 20500 and toc < 30000 and UnitName("player") ~= "Baldvin" then
                local currentTime, currentDate = iWR:GetCurrentTimeByHours()
                local dbName = class and (iWR.Colors.Classes[class] .. "Baldvin") or (iWR.Colors.Gray .. "Baldvin")
                local faction = UnitFactionGroup("target") or ""
                iWRDatabase[databaseKey] = {
                    "iWR Author",                           -- [1] Note
                    10,                                     -- [2] Type (Superior)
                    currentTime,                            -- [3] Timestamp
                    dbName,                                 -- [4] Display name
                    currentDate,                            -- [5] Date
                    iWR.Colors.iWR .. "iWillRemember",      -- [6] Author
                    "Spineshatter",                         -- [7] Realm
                    faction,                                -- [8] Faction
                    [12] = class or "",                     -- [12] Class token
                    [13] = select(2, UnitRace("target")) or "", -- [13] Race token
                }
            else
                if iWRNameInput then
                    iWRNameInput:SetText(class and iWR:ColorizePlayerNameByClass(targetName, class) or targetName)
                end
                -- Reset menu fields if open (target not in database)
                if iWRPanel and iWRPanel:IsVisible() then
                    if iWRNoteInput then iWRNoteInput:SetText(L["DefaultNoteInput"]) end
                    if iWR.SetSliderValue then iWR:SetSliderValue(0) end
                end
                if targetRealm == iWR.CurrentRealm then
                    iWR:DebugMsg("Target [|r" .. (iWR.Colors.Classes[class] or iWR.Colors.Gray) .. targetName .. iWR.Colors.iWR .. "] was not found in Database. [SetTargetingFrame]", 3)
                else
                    iWR:DebugMsg("Target [|r" .. (iWR.Colors.Classes[class] or iWR.Colors.Gray) .. targetName .. iWR.Colors.iWR .. "] from realm [" .. iWR.Colors.Reset .. (targetRealm or "Unknown Realm") .. iWR.Colors.iWR .. "] was not found in Database.", 3)
                end
                return
            end
        end
    end

    -- If the target is in the database and has a valid type
    if iWRDatabase[databaseKey][2] ~= 0 then
        local _, class = UnitClass("target")
        local _, race = UnitRace("target")

        -- Verify and update the class in the database if necessary
        iWR:VerifyTargetClassinDB(databaseKey, class)
        iWRDatabase[databaseKey][12] = class or iWRDatabase[databaseKey][12] or ""
        iWRDatabase[databaseKey][13] = race or iWRDatabase[databaseKey][13] or ""

        -- Update faction if available and missing
        local faction = UnitFactionGroup("target")
        if faction then
            if not iWRDatabase[databaseKey][8] or iWRDatabase[databaseKey][8] == "" then
                iWRDatabase[databaseKey][8] = faction
                print(L["CharNoteStart"] .. iWRDatabase[databaseKey][4] .. L["CharNoteFactionUpdate"])
            end
            iWR:DebugMsg("Target faction: " .. faction, 3)
        end

        -- Set the input box to the colored player name (guard for panel not yet created)
        if iWRNameInput then
            iWRNameInput:SetText(class and iWR:ColorizePlayerNameByClass(targetName, class) or targetName)
        end

        -- Auto-fill menu fields if open (target found in database)
        if iWRPanel and iWRPanel:IsVisible() then
            local data = iWRDatabase[databaseKey]
            if iWRNoteInput and data[1] and data[1] ~= "" then
                iWRNoteInput:SetText(data[1])
            elseif iWRNoteInput then
                iWRNoteInput:SetText(L["DefaultNoteInput"])
            end
            if iWR.SetSliderValue then
                iWR:SetSliderValue(data[2] or 0)
            end
        end

        -- Update the target frame based on settings
        if iWRSettings.UpdateTargetFrame then
            iWR:DebugMsg("TargetFrameType = " .. (iWR.ImagePath or "nil"), 3)
            iWR:SetTargetFrameForeverDragon()
        end

        if targetRealm == iWR.CurrentRealm then
            iWR:DebugMsg("Target [|r" .. (iWR.Colors.Classes[class] or iWR.Colors.Gray) .. targetName .. iWR.Colors.iWR .. "] was found in Database.", 3)
        else
            iWR:DebugMsg("Target [|r" .. (iWR.Colors.Classes[class] or iWR.Colors.Gray) .. targetName .. iWR.Colors.iWR .. "] from realm [" .. iWR.Colors.Reset .. (targetRealm or "Unknown Realm") .. iWR.Colors.iWR .. "] was found in Database.", 3)
        end
    end
end
-- Function to normalize realm names (Handles both spaced and non-spaced versions)
local function NormalizeRealmName(realm)
    if not realm or realm == "" then return iWR.CurrentRealm end

    -- Ensure space is added before capital letters if missing (e.g., "LoneWolf" → "Lone Wolf")
    local formattedRealm = realm:gsub("(%l)(%u)", "%1 %2")

    -- Ensure correct casing (capitalize first letter of each word, UTF-8 safe)
    formattedRealm = formattedRealm:gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()  -- Realm names are ASCII, safe to use upper/lower
    end)

    -- Check if either format exists in the database
    if iWRDatabase[realm] then
        return realm
    elseif iWRDatabase[formattedRealm] then
        return formattedRealm
    end

    -- Default to formatted realm if nothing is found
    return formattedRealm
end

local hookedChatIconFrames = {}
local activeChatIconTooltipFrame
local chatIconTooltipMouseWasEnabled

local function HideChatIconTooltip(chatFrame)
    if activeChatIconTooltipFrame ~= chatFrame then return end
    activeChatIconTooltipFrame = nil
    if GameTooltip and GameTooltip.iWRChatIconOwner == chatFrame then
        GameTooltip.iWRChatIconOwner = nil
        GameTooltip:Hide()
        if chatIconTooltipMouseWasEnabled ~= nil then
            GameTooltip:EnableMouse(chatIconTooltipMouseWasEnabled)
        end
    end
    chatIconTooltipMouseWasEnabled = nil
end

local function HookChatIconTooltip(chatFrame)
    if not chatFrame or not chatFrame.HookScript or hookedChatIconFrames[chatFrame] then return end
    hookedChatIconFrames[chatFrame] = true

    chatFrame:HookScript("OnHyperlinkEnter", function(self, link)
        local databaseKey = type(link) == "string" and link:match("^addon:iWR:(.+)$")
        databaseKey = databaseKey and iWR:NormalizePlayerDatabaseKey(databaseKey)
        local data = databaseKey and iWRDatabase[databaseKey]
        if not data or not GameTooltip then
            HideChatIconTooltip(self)
            return
        end

        activeChatIconTooltipFrame = self
        GameTooltip.iWRChatIconOwner = self
        if chatIconTooltipMouseWasEnabled == nil and GameTooltip.IsMouseEnabled then
            chatIconTooltipMouseWasEnabled = GameTooltip:IsMouseEnabled()
        end
        GameTooltip:EnableMouse(false)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

        local typeIndex = tonumber(data[2]) or 0
        local typeName = iWR:GetTypeName(typeIndex)
        local displayName = StripColorCodes(data[4] or databaseKey)
        GameTooltip:SetText(string.format(L["ChatIconTooltipTitle"], typeName or "iWR"), 1, 0.59, 0.09)
        GameTooltip:AddLine(string.format(L["ChatIconTooltipPlayer"], displayName), 1, 1, 1)
        if data[1] and data[1] ~= "" then
            GameTooltip:AddLine(data[1], 1, 1, 1, true)
        end
        if iWRSettings.TooltipShowAuthor and data[6] and data[6] ~= "" then
            local author = StripColorCodes(data[6])
            local savedDate = data[5] and data[5] ~= "" and (" (" .. data[5] .. ")") or ""
            GameTooltip:AddLine((L["DetailAuthor"] or "Author:") .. " " .. author .. savedDate, 0.75, 0.75, 0.75, true)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["ChatIconTooltipClick"], 1, 0.82, 0, true)
        GameTooltip:Show()
    end)

    chatFrame:HookScript("OnHyperlinkLeave", HideChatIconTooltip)
end

-- Function to add relationship icons to chat messages
local function AddRelationshipIconToChat(self, event, message, author, flags, ...)
    if iWRSettings.ShowChatIcons then
        if not author or author == "" then
            return false, message, author, flags, ...
        end

        local databaseKey, authorName, authorRealm = iWR:GetPlayerDatabaseKey(author)
        if not iWR:IsForeverClient() then
            local parsedName, parsedRealm = string.match(author, "^([^-]+)-?(.*)$")
            authorName = parsedName
            authorRealm = NormalizeRealmName(parsedRealm)
            databaseKey = authorName and (authorName .. "-" .. authorRealm) or nil
        end

        if not authorName or authorName == "" or not databaseKey then
            return false, message, author, flags, ...
        end

        -- Check the database using the constructed key
        if iWRDatabase[databaseKey] and not message:find("|Haddon:iWR:") then
            HookChatIconTooltip(self)
            local iconPath = iWR:GetChatIcon(iWRDatabase[databaseKey][2])

            -- Zero dimensions make WoW scale the inline texture to this chat line's font.
            local iconString = string.format("|T%s:0:0|t", iconPath)
            local clickableLink = string.format("|cFFFFFF00|Haddon:iWR:%s|h%s|h|r", databaseKey, iconString)

            -- Prepend the clickable link to the message
            message = clickableLink .. " " .. message
        end
    end

    -- Ensure the message is returned unchanged if no modifications were made
    return false, message, author, flags, ...
end

function iWR:HandleHyperlink(link, text, button, chatFrame)
    local linkType, playerName = string.split(":", link)
    if linkType == "iWRPlayer" and playerName then
        local databaseKey = iWR:NormalizePlayerDatabaseKey(playerName)
        if databaseKey and iWRDatabase[databaseKey] then
            self:ShowDetailWindow(databaseKey)
        else
            iWR:DebugMsg("No data found for player: [" .. playerName .. "]",3)
        end
        return
    end
end

function iWR:ShowDetailWindow(playerName)
    -- Store row elements for easy updates
    self.detailRows = self.detailRows or {}

    -- Get player data
    local data = iWR:GetDatabaseEntry(playerName)
    if next(data) == nil then
        iWR:DebugMsg("No data found for player: [" .. playerName .. "]",3)
        return
    end

    -- Create the detail frame if it doesn't exist
    if not self.detailFrame then
        self.detailFrame = iWR:CreateiWRStyleFrame(UIParent, 300, 250, {"TOP", UIParent, "TOP", 0, -100})
        self:StyleSurface(self.detailFrame, "panel")
        self.detailFrame:EnableMouse(true)
        self.detailFrame:SetMovable(true)
        self.detailFrame:SetClampedToScreen(true)
        self.detailFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        self.detailFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
        self.detailFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
        self.detailFrame:RegisterForDrag("LeftButton", "RightButton")

        -- Add a shadow effect
        local shadow = CreateFrame("Frame", nil, self.detailFrame, "BackdropTemplate")
        shadow:SetPoint("TOPLEFT", self.detailFrame, -1, 1)
        shadow:SetPoint("BOTTOMRIGHT", self.detailFrame, 1, -1)
        shadow:SetBackdrop({
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 5,
        })
        shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

        -- Add a close button
        local closeButton = CreateFrame("Button", nil, self.detailFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", self.detailFrame, "TOPRIGHT", 0, 0)
        closeButton:SetScript("OnClick", function()
            self.detailFrame:Hide()
        end)

        -- Add a title bar
        local titleBar = CreateFrame("Frame", nil, self.detailFrame, "BackdropTemplate")
        titleBar:SetHeight(31)
        titleBar:SetPoint("TOP", self.detailFrame, "TOP", 0, 0)
        titleBar:SetWidth(self.detailFrame:GetWidth())
        self:StyleSurface(titleBar, "header")

        -- Add a title text
        local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
        titleText:SetText(iWR.Colors.iWR .. L["DetailPlayerDetails"])
        titleText:SetTextColor(0.9, 0.9, 1, 1)

        -- Add a content frame for labels
        self.detailContent = CreateFrame("Frame", nil, self.detailFrame)
        self.detailContent:SetSize(280, 180)
        self.detailContent:SetPoint("TOPLEFT", self.detailFrame, "TOPLEFT", 0, -40)
    end

    -- Clear and reset rows
    for _, row in ipairs(self.detailRows) do
        row:Hide()
    end
    self.detailRows = {}

    -- Populate new content
    local yOffset = -5
    local detailsContent = {}
    local detailSign = data[2] > 0 and "+" or ""
    local detailTypeValue = detailSign .. data[2] .. " — " .. iWR:GetTypeName(data[2])
    local statusValue = data[9] and (iWR.Colors.Gray .. L["StatusPersonal"]) or (iWR.Colors.Green .. L["StatusShared"])
    if data[7] and data[7] ~= iWR.CurrentRealm then
        detailsContent = {
            {label = iWR.Colors.Default .. L["DetailName"] .. iWR.Colors.Reset, value = data[4]..iWR.Colors.Reset.."-"..data[7]},
            {label = iWR.Colors.Default .. L["DetailType"] .. iWR.Colors[data[2]], value = detailTypeValue},
            {label = iWR.Colors.Default .. L["DetailNote"] .. iWR.Colors[data[2]], value = data[1], isNote = true},
            {label = iWR.Colors.Default .. L["DetailAuthor"] .. iWR.Colors.Reset, value = data[6]},
            {label = iWR.Colors.Default .. L["DetailDate"], value = data[5]},
            {label = iWR.Colors.Default .. L["DetailStatus"], value = statusValue},
        }
    else
        detailsContent = {
            {label = iWR.Colors.Default .. L["DetailName"] .. iWR.Colors.Reset, value = data[4]},
            {label = iWR.Colors.Default .. L["DetailType"] .. iWR.Colors[data[2]], value = detailTypeValue},
            {label = iWR.Colors.Default .. L["DetailNote"] .. iWR.Colors[data[2]], value = data[1], isNote = true},
            {label = iWR.Colors.Default .. L["DetailAuthor"] .. iWR.Colors.Reset, value = data[6]},
            {label = iWR.Colors.Default .. L["DetailDate"], value = data[5]},
            {label = iWR.Colors.Default .. L["DetailStatus"], value = statusValue},
        }
    end
    for _, item in ipairs(detailsContent) do
        local row = self.detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row:SetPoint("TOPLEFT", self.detailContent, "TOPLEFT", 10, yOffset)
        row:SetWidth(270)
        row:SetWordWrap(true)
        row:SetText(item.label .. " " .. (item.value or "N/A"))
        row:Show()
        table.insert(self.detailRows, row)
        if item.isNote then
            local noteHeight = row:GetStringHeight()
            yOffset = yOffset - noteHeight - 10
        else
            yOffset = yOffset - 20
        end
    end

    -- Note History section
    if data[10] and #data[10] > 0 then
        yOffset = yOffset - 5
        -- Separator line
        local separator = self.detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        separator:SetPoint("TOPLEFT", self.detailContent, "TOPLEFT", 10, yOffset)
        separator:SetWidth(270)
        separator:SetText(iWR.Colors.iWR .. "--- " .. L["NotesHistory"] .. " " .. iWR.Colors.Gray .. string.format(L["NotesCount"], #data[10] + 1) .. iWR.Colors.iWR .. " ---")
        separator:Show()
        table.insert(self.detailRows, separator)
        yOffset = yOffset - 18

        -- Iterate history from newest to oldest
        for i = #data[10], 1, -1 do
            local h = data[10][i]
            local hNote = h[1] or ""
            local hLevel = h[2] or 0
            local hDate = h[4] or ""
            local hAuthor = h[5] or ""
            local hSign = hLevel > 0 and "+" or ""
            local hTypeName = iWR:GetTypeName(hLevel)

            -- Date + relation level header
            local headerRow = self.detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerRow:SetPoint("TOPLEFT", self.detailContent, "TOPLEFT", 15, yOffset)
            headerRow:SetWidth(260)
            headerRow:SetText(iWR.Colors.Gray .. hDate .. "  " .. iWR.Colors[hLevel] .. hSign .. hLevel .. " — " .. hTypeName .. "  " .. iWR.Colors.Gray .. hAuthor)
            headerRow:Show()
            table.insert(self.detailRows, headerRow)
            yOffset = yOffset - 14

            -- Note text
            if hNote ~= "" then
                local noteRow = self.detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                noteRow:SetPoint("TOPLEFT", self.detailContent, "TOPLEFT", 20, yOffset)
                noteRow:SetWidth(250)
                noteRow:SetWordWrap(true)
                noteRow:SetText(iWR.Colors[hLevel] .. hNote)
                noteRow:Show()
                table.insert(self.detailRows, noteRow)
                local noteHeight = noteRow:GetStringHeight()
                yOffset = yOffset - noteHeight - 6
            else
                yOffset = yOffset - 4
            end
        end
    end

    -- Edit & Remove buttons
    if not self.detailEditBtn then
        self.detailEditBtn = CreateFrame("Button", nil, self.detailContent, "UIPanelButtonTemplate")
        self:StyleButton(self.detailEditBtn)
        self.detailEditBtn:SetSize(80, 22)
        self.detailEditBtn:SetText("Edit")
        self.detailEditBtn:SetNormalFontObject(GameFontNormal)
    end
    if not self.detailRemoveBtn then
        self.detailRemoveBtn = CreateFrame("Button", nil, self.detailContent, "UIPanelButtonTemplate")
        self:StyleButton(self.detailRemoveBtn, true)
        self.detailRemoveBtn:SetSize(80, 22)
        self.detailRemoveBtn:SetText("Remove")
        self.detailRemoveBtn:SetNormalFontObject(GameFontNormal)
    end

    yOffset = yOffset - 10
    self.detailEditBtn:SetPoint("TOPLEFT", self.detailContent, "TOPLEFT", 50, yOffset)
    self.detailRemoveBtn:SetPoint("TOPLEFT", self.detailContent, "TOPLEFT", 170, yOffset)
    self.detailEditBtn:Show()
    self.detailRemoveBtn:Show()

    local capturedKey = playerName
    self.detailEditBtn:SetScript("OnClick", function()
        self.detailFrame:Hide()
        iWR:MenuOpen(data[4])
    end)
    self.detailRemoveBtn:SetScript("OnClick", function()
        StaticPopupDialogs["IWR_DETAIL_REMOVE"] = {
            text = iWR.Colors.iWR .. "Remove " .. (data[4] or capturedKey) .. iWR.Colors.iWR .. " from database?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                local entry = iWRDatabase[capturedKey]
                if entry then
                    iWR:TombstoneEntireEntry(capturedKey, entry)
                end
                iWRDatabase[capturedKey] = nil
                iWR.ExpandedEntries[capturedKey] = nil
                self.detailFrame:Hide()
                iWR:PopulateDatabase()
                iWR:UpdateTargetFrame()
                print(L["CharNoteStart"] .. (data[4] or capturedKey) .. L["CharNoteRemoved"])
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("IWR_DETAIL_REMOVE")
    end)

    local frameHeight = math.abs(yOffset) + 80
    self.detailFrame:SetHeight(frameHeight)
    self.detailFrame:Show()
end

function iWR:UpdateDetailWindow(updatedData)
    -- Update rows dynamically if the detail frame is visible
    if self.detailFrame and self.detailFrame:IsVisible() and self.detailRows then
        for index, row in ipairs(self.detailRows) do
            local item = updatedData[index]
            if item then
                row:SetText(item.label .. " " .. (item.value or "N/A"))
            end
        end
    end
end

function iWR:InitializeSettings()
    for key, value in pairs(iWR.SettingsDefault) do
        if iWRSettings[key] == nil then
            iWRSettings[key] = value
        end
    end

    -- Initialize Group Log in iWRMemory
    if not iWRMemory.GroupLog then
        iWRMemory.GroupLog = {}
    end

    -- Forever identity migration for character lists and sync contacts.
    local normalizedCharacters = {}
    for characterName, enabled in pairs(iWRSettings.MyCharacters or {}) do
        local _, resolvedName = iWR:GetPlayerDatabaseKey(characterName)
        if enabled and resolvedName then normalizedCharacters[resolvedName] = true end
    end
    iWRSettings.MyCharacters = normalizedCharacters

    for _, entry in ipairs(iWRSettings.SyncList or {}) do
        local _, resolvedName = iWR:GetPlayerDatabaseKey(entry.name, entry.realm)
        if resolvedName then entry.name = resolvedName end
        entry.realm = "Forever"
    end

    -- Prune old entries if over limit
    iWR:PruneGroupLog()
end

function iWR:InitializeDatabase()
    local updatedDatabase = {}
    -- Iterate through the existing database keys
    for databaseKey, data in pairs(iWRDatabase) do
        -- Clone the data to avoid reference issues
        local clonedData = {}
        for index, value in pairs(data) do
            clonedData[index] = value
        end
        if iWR:IsForeverClient() then
            local newKey = iWR:NormalizePlayerDatabaseKey(databaseKey, clonedData)
            if newKey then
                local _, resolvedName = iWR:GetPlayerDatabaseKey(newKey:gsub("%-Forever$", ""))
                if resolvedName then
                    local colorCode = type(clonedData[4]) == "string" and clonedData[4]:match("|c%x%x%x%x%x%x%x%x") or nil
                    clonedData[4] = colorCode and (colorCode .. resolvedName .. iWR.Colors.Reset) or resolvedName
                end
                if updatedDatabase[newKey] then
                    local existing = updatedDatabase[newKey]
                    if (tonumber(clonedData[3]) or 0) > (tonumber(existing[3]) or 0) then
                        iWR:MergeNoteHistory(existing, clonedData)
                        updatedDatabase[newKey] = clonedData
                    else
                        iWR:MergeNoteHistory(clonedData, existing)
                    end
                else
                    updatedDatabase[newKey] = clonedData
                end
                clonedData[7] = "Forever"
            end
        -- Check if the key already has a realm (contains "-")
        elseif not strfind(databaseKey, "-") then
            local newKey = databaseKey .. "-" .. iWR.CurrentRealm
            -- Check if the newKey already exists in updatedDatabase
            if not updatedDatabase[newKey] then
                -- Add the new key to updatedDatabase
                updatedDatabase[newKey] = clonedData
                iWR:DebugMsg("New key created: " .. newKey, 3)
            else
                -- If newKey already exists, remove the old key (without realm) from updatedDatabase
                if updatedDatabase[databaseKey] then
                    updatedDatabase[databaseKey] = nil
                    iWR:DebugMsg("Old key removed: " .. databaseKey .. ". New key [" .. newKey .. "] already exists.", 3)
                else
                    iWR:DebugMsg("Conflict detected: Old key [" .. databaseKey .. "] does not exist. Skipping.", 2)
                end
            end
        else
            -- If the key already has a realm, check for duplicates in updatedDatabase
            if not updatedDatabase[databaseKey] then
                updatedDatabase[databaseKey] = clonedData
            else
                -- Remove the duplicate if it exists
                for oldKey, _ in pairs(updatedDatabase) do
                    if oldKey:find(databaseKey .. "$") and oldKey ~= databaseKey then
                        updatedDatabase[oldKey] = nil
                        iWR:DebugMsg("Duplicate key removed: " .. oldKey, 3)
                    end
                end
                iWR:DebugMsg("Key already exists in updated database: " .. databaseKey .. ". Skipping duplicate.", 2)
            end
        end
    end

    -- Replace the original database with the updated one
    iWRDatabase = updatedDatabase

    -- Ensure all entries have default values and set realm in data[7]
    for playerKey, data in pairs(iWRDatabase) do
        -- Ensure data is a table
        if type(data) ~= "table" then
            iWR:DebugMsg("Unexpected data type for key: " .. playerKey .. ". Setting data to default.", 2)
            data = {}
            iWRDatabase[playerKey] = data
        end

        -- Populate missing default values
        for index, defaultValue in ipairs(iWR.DatabaseDefault) do
            if data[index] == nil then
                data[index] = defaultValue
                iWR:DebugMsg("Default value set for index " .. index .. " in key: " .. playerKey, 3)
            end
        end

        -- Extract the realm from the key and assign only if data[7] is not already set and valid
        local _, keyRealm = strsplit("-", playerKey)
        if not data[7] or data[7] == "" or data[7] == iWR.CurrentRealm then
            if keyRealm and keyRealm ~= "" then
                data[7] = keyRealm
            else
                data[7] = iWR:IsForeverClient() and "Forever" or iWR.CurrentRealm
            end
        end

    end

    -- One-time migration: old type values to new slider range
    if not iWRSettings.SliderMigrationDone then
        for playerKey, data in pairs(iWRDatabase) do
            local oldType = data[2]
            if oldType == 3 then
                data[2] = 4         -- Old Liked (3) → mid Liked range
            elseif oldType == 5 then
                data[2] = 9         -- Old Respected (5) → upper Respected range
            elseif oldType == 10 then
                data[2] = 10        -- Old Superior (10) → stays Superior
            elseif oldType == -3 then
                data[2] = -4        -- Old Disliked (-3) → mid Disliked range
            elseif oldType == -5 then
                data[2] = -9        -- Old Hated (-5) → upper Hated range
            end
            -- oldType 1 (Neutral) stays at 1 = now Liked range
            -- oldType 0 (Clear) stays at 0
        end
        iWRSettings.SliderMigrationDone = true
        iWR:DebugMsg("Database migrated to new slider range.", 3)
    end

    -- One-time migration: reset ButtonLabels to match new group boundaries
    if not iWRSettings.ButtonLabelsMigrated then
        iWRSettings.ButtonLabels = {
            [10]  = "Superior",
            [6]   = "Respected",
            [1]   = "Liked",
            [-1]  = "Disliked",
            [-6]  = "Hated",
        }
        iWRSettings.ButtonLabelsMigrated = true
        iWR:DebugMsg("ButtonLabels migrated to new group boundaries.", 3)
    end

    -- Clamp GoodLevels/BadLevels to new minimums (3 positive, 2 negative)
    if iWRSettings.GoodLevels and iWRSettings.GoodLevels < 3 then
        iWRSettings.GoodLevels = 3
    end
    if iWRSettings.BadLevels and iWRSettings.BadLevels < 2 then
        iWRSettings.BadLevels = 2
    end
end

function iWR:RegisterChatFilters()
    local chatEvents = {
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_IGNORED",
        "CHAT_MSG_DND",
        "CHAT_MSG_AFK",
    }

    for _, event in ipairs(chatEvents) do
        ChatFrame_AddMessageEventFilter(event, AddRelationshipIconToChat)
    end
end

function iWR:VerifyTargetClassinDB(databasekey, targetClass)
    if iWRDatabase[databasekey][2] ~= 0 and targetClass then

        -- Get target name and realm
        local targetNameWithRealm = GetUnitName("target", true)
        local targetName = GetUnitName("target", false)
        local targetRealm = select(2, strsplit("-", targetNameWithRealm or ""))
        targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

        -- Use current realm if no realm is found
        if not targetRealm or targetRealm == "" then
            targetRealm = iWR.CurrentRealm
        end
        local _, resolvedTargetName = iWR:GetPlayerDatabaseKey(targetName, targetRealm)
        local storedValue = iWRDatabase[databasekey][4] or ""
        local storedName = StripColorCodes(storedValue)
        local coloredTargetName = iWR:ColorizePlayerNameByClass(resolvedTargetName, targetClass)
        local storedColor = storedValue:match("|c%x%x%x%x%x%x%x%x")
        local targetColor = coloredTargetName:match("|c%x%x%x%x%x%x%x%x")
        if iWR:IsSamePlayerName(resolvedTargetName, storedName)
            and storedColor ~= targetColor then
            iWRDatabase[databasekey][4] = coloredTargetName
            print(L["CharNoteStart"] .. iWRDatabase[databasekey][4] .. L["CharNoteColorUpdate"])
            iWR:PopulateDatabase()
            if iWRSettings.DataSharing ~= false and not iWRDatabase[databasekey][9] then
                wipe(iWR.Cache.DataTable)
                iWR.Cache.DataTable[tostring(databasekey)] = {
                    iWRDatabase[databasekey][1],     --Data[1]
                    iWRDatabase[databasekey][2],     --Data[2]
                    iWRDatabase[databasekey][3],     --Data[3]
                    iWRDatabase[databasekey][4],     --Data[4]
                    iWRDatabase[databasekey][5],     --Data[5]
                    iWRDatabase[databasekey][6],     --Data[6]
                }
                iWR.Cache.Data = iWR:Serialize(iWR.Cache.DataTable)
                iWR:SendNewDBUpdateToFriends()
            end
        end
    end
end

function iWR:UpdateTargetFrame()
    if iWRSettings.UpdateTargetFrame then
        if iWR.UseTargetFrameHook and type(TargetFrame_Update) == "function" then
            TargetFrame_Update(TargetFrame)
        else
            iWR:SetTargetingFrame()
        end
    end
    if iWR.RefreshPlatynatorNameplates then
        iWR:RefreshPlatynatorNameplates()
    end
end

-- Platynator keeps Blizzard's nameplate as the stable owner while replacing its
-- presentation. Anchoring iWR here avoids depending on Platynator's private frames.
function iWR:IsPlatynatorLoaded()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Platynator")
end

local function GetPlatynatorDisplay(namePlate)
    if not namePlate or not namePlate.GetChildren then return nil end
    for _, child in ipairs({namePlate:GetChildren()}) do
        -- Platynator's live display is an unnamed child with its active widget list.
        if type(child.widgets) == "table" and child.InitializeWidgets and child.SetUnit then
            return child
        end
    end
end

local function GetPlatynatorHealthWidget(display)
    for _, widget in ipairs(display.widgets or {}) do
        if widget.kind == "bars" and widget.details and widget.details.kind == "health" then
            return widget
        end
    end
end

function iWR:UpdatePlatynatorNameplate(unitToken)
    if not C_NamePlate or not C_NamePlate.GetNamePlateForUnit or not unitToken then return end

    local namePlate = C_NamePlate.GetNamePlateForUnit(unitToken)
    if not namePlate then return end

    local iconFrame = namePlate.iWRRelationshipIcon
    local shouldShow = iWRSettings.ShowPlatynatorIcons and self:IsPlatynatorLoaded()
    if not shouldShow or not UnitExists(unitToken) or not UnitIsPlayer(unitToken) then
        if iconFrame then iconFrame:Hide() end
        return
    end

    local display = GetPlatynatorDisplay(namePlate)
    if not display then
        if iconFrame then iconFrame:Hide() end
        return
    end

    local playerName, secondName = UnitName(unitToken)
    local issv = _G.issecretvalue
    if not playerName or (issv and (issv(playerName) or (secondName and issv(secondName)))) then
        if iconFrame then iconFrame:Hide() end
        return
    end

    local databaseKey = self:GetPlayerDatabaseKey(playerName, secondName)
    local data = databaseKey and iWRDatabase[databaseKey]
    local texture = data and data[2] and data[2] ~= 0 and self:GetIcon(data[2])
    if not texture then
        if iconFrame then iconFrame:Hide() end
        return
    end

    if not iconFrame then
        iconFrame = CreateFrame("Frame", nil, display)
        iconFrame:SetSize(20, 20)
        iconFrame:SetFrameStrata("HIGH")
        iconFrame:SetFrameLevel(1100)
        iconFrame.texture = iconFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        iconFrame.texture:SetAllPoints()
        namePlate.iWRRelationshipIcon = iconFrame
    end

    iconFrame:SetParent(display)
    iconFrame:ClearAllPoints()
    local offsetX = tonumber(iWRSettings.PlatynatorIconOffsetX)
        or self.SettingsDefault.PlatynatorIconOffsetX
    local offsetY = tonumber(iWRSettings.PlatynatorIconOffsetY)
        or self.SettingsDefault.PlatynatorIconOffsetY
    local healthWidget = GetPlatynatorHealthWidget(display)
    if healthWidget then
        iconFrame:SetPoint("RIGHT", healthWidget, "LEFT", offsetX, offsetY)
    else
        iconFrame:SetPoint("RIGHT", display, "CENTER", -66 + offsetX, offsetY - 4)
    end
    iconFrame.texture:SetTexture(texture)
    iconFrame:Show()
end

function iWR:RefreshPlatynatorNameplates()
    if not C_NamePlate or not C_NamePlate.GetNamePlates then return end
    for _, namePlate in ipairs(C_NamePlate.GetNamePlates() or {}) do
        local unitToken = namePlate.namePlateUnitToken
        if unitToken then
            self:UpdatePlatynatorNameplate(unitToken)
        elseif namePlate.iWRRelationshipIcon then
            namePlate.iWRRelationshipIcon:Hide()
        end
    end
end

-- The Forever guild roster can pass only the first half of a character name to
-- MENU_UNIT_FRIEND. Capture the clicked roster row before Blizzard opens it.
function iWR:HookGuildRosterButtons()
    local container = _G.GuildRosterContainer
    if not container or not container.buttons then return end

    for _, button in ipairs(container.buttons) do
        if not button.iWRGuildRosterHooked then
            button.iWRGuildRosterHooked = true
            button:HookScript("OnMouseDown", function(row, mouseButton)
                if mouseButton ~= "RightButton" or not row.guildIndex then return end
                local name, _, _, _, _, _, _, _, _, _, classToken = GetGuildRosterInfo(row.guildIndex)
                if not name then return end
                local resolvedName = iWR:ResolvePlayerIdentity(name)
                iWR.PendingGuildRosterMenu = {
                    name = resolvedName,
                    classToken = classToken,
                    openedAt = GetTime(),
                }
            end)
        end
    end
end

-- ╭──────────────────────────────╮
-- │      Toggle Menu Window      │
-- ╰──────────────────────────────╯
function iWR:MenuToggle()
    if not iWR.State.InCombat then
        if iWRPanel:IsVisible() then
            iWR:MenuClose()
        else
            iWR:MenuOpen()
        end
    else
        print(L["InCombat"])
        iWR:MenuClose()
    end
end

-- ╭────────────────────────────╮
-- │      Open Menu Window      │
-- ╰────────────────────────────╯
function iWR:MenuOpen(menuName, classToken, raceToken)
    if not iWR.State.InCombat then
        iWRPanel:Show()
        local lookupName, lookupRealm

        -- Preserve identity details supplied by places such as the group log.
        -- The compact editor only contains text fields, so this lets CreateNote
        -- retain the race/class icons after the note is saved.
        iWR.PendingNoteIdentity = nil

        -- Retail 12.0+: contextData values can be secret strings — treat as empty
        local issv = _G.issecretvalue
        if issv and menuName and issv(menuName) then
            menuName = nil
        end

        local rawTargetName = UnitName("target")
        local targetName = iWR:GetUnitPlayerIdentity("target")
        local targetIsSecret = issv and targetName and issv(targetName)
        local namesMatch = false
        if menuName and not targetIsSecret then
            if rawTargetName and iWR:IsSamePlayerName(menuName, rawTargetName) then
                menuName = targetName
            end
            namesMatch = iWR:IsSamePlayerName(menuName, targetName)
        end

        if menuName and menuName ~= "" and not namesMatch then
            local pendingName = StripColorCodes(menuName)
            if not iWR:IsForeverClient() then
                pendingName = strsplit("-", pendingName)
            end
            iWR.PendingNoteIdentity = {
                name = pendingName,
                class = classToken,
                race = raceToken,
            }
            if classToken then
                iWRNameInput:SetText(iWR:ColorizePlayerNameByClass(menuName, classToken))
            else
                iWRNameInput:SetText(menuName)
            end
            iWRNoteInput:SetText(L["DefaultNoteInput"])

            -- Determine database key for slider lookup (strip color codes for clean lookup)
            local cleanName = StripColorCodes(menuName)
            lookupName, lookupRealm = iWR:ResolvePlayerIdentity(cleanName)
        else
            iWRNameInput:SetText(L["DefaultNameInput"])
            iWRNoteInput:SetText(L["DefaultNoteInput"])
            if UnitExists("target") and UnitIsPlayer("target") then
                local playerName, playerSecondName = UnitName("target")
                local nameIsSecret = issv and playerName and issv(playerName)
                if not nameIsSecret then
                    playerName = iWR:ResolvePlayerIdentity(playerName, playerSecondName)
                    local _, class = UnitClass("target")
                    if class then
                        iWRNameInput:SetText(iWR:ColorizePlayerNameByClass(playerName, class))
                    else
                        iWRNameInput:SetText(playerName)
                    end
                    lookupName = playerName
                    local targetRealm = "Forever"
                    local realmIsSecret = issv and targetRealm and issv(targetRealm)
                    if not realmIsSecret then
                        lookupRealm = (targetRealm and targetRealm ~= "") and targetRealm or iWR.CurrentRealm
                    else
                        lookupRealm = iWR.CurrentRealm
                    end
                end
            end
        end

        -- Set slider to existing note's type value, or 0 if no note exists
        local sliderValue = 0
        local isPersonal = false
        if lookupName then
            local capName, capRealm = iWR:FormatNameAndRealm(lookupName, lookupRealm or iWR.CurrentRealm)
            local dbKey = capName .. "-" .. capRealm
            local data = iWRDatabase[dbKey]
            if data and data[2] and data[2] ~= 0 then
                sliderValue = data[2]
                -- Also pre-fill existing note text
                if data[1] and data[1] ~= "" then
                    iWRNoteInput:SetText(data[1])
                end
                isPersonal = data[9] or false
            end
        end
        if iWR.SetSliderValue then
            iWR:SetSliderValue(sliderValue)
        end
        if iWR.SetPersonalCheckbox then
            iWR:SetPersonalCheckbox(isPersonal)
        end
    else
        print(L["InCombat"])
    end
end

-- ╭─────────────────────────────╮
-- │      Close Menu Window      │
-- ╰─────────────────────────────╯
function iWR:MenuClose()
    iWRNameInput:SetText(L["DefaultNameInput"])
    iWRNoteInput:SetText(L["DefaultNoteInput"])
    if iWR.SetPersonalCheckbox then iWR:SetPersonalCheckbox(false) end
    iWRPanel:Hide()
end

-- ╭──────────────────────────────────╮
-- │      Toggle Database Window      │
-- ╰──────────────────────────────────╯
function iWR:DatabaseToggle()
    if not iWR.State.InCombat then
        if iWRDatabaseFrame:IsVisible() then
            iWR:DatabaseClose()
        else
            iWR:DatabaseOpen()
        end
    else
        print(L["InCombat"])
        iWR:DatabaseClose()
    end
end

-- ╭────────────────────────────────╮
-- │      Open Database Window      │
-- ╰────────────────────────────────╯
function iWR:DatabaseOpen()
    if not iWR.State.InCombat then
        iWRDatabaseFrame:Show()
        iWR:ResetDatabaseTab()
        if iWR.ClearDatabaseSearch then iWR:ClearDatabaseSearch() end
        if iWR.ResetDatabaseFilter then iWR:ResetDatabaseFilter() end
        iWRNameInput:SetText(L["DefaultNameInput"])
        iWRNoteInput:SetText(L["DefaultNoteInput"])
        if UnitExists("target") and UnitIsPlayer("target") then
            local playerName, playerSecondName = UnitName("target")
            local issv = _G.issecretvalue
            if not (issv and playerName and issv(playerName)) then
                playerName = iWR:ResolvePlayerIdentity(playerName, playerSecondName)
                local _, class = UnitClass("target")
                if class then
                    iWRNameInput:SetText(iWR:ColorizePlayerNameByClass(playerName, class))
                else
                    iWRNameInput:SetText(playerName)
                end
            end
        end
    else
        print(L["InCombat"])
        iWR:DatabaseClose()
    end
end

-- ╭─────────────────────────────────╮
-- │      Close Database Window      │
-- ╰─────────────────────────────────╯
function iWR:DatabaseClose()
    iWRDatabaseFrame:Hide()
end

-- ╭────────────────────────╮
-- │      Add New Note      │
-- ╰────────────────────────╯
function iWR:AddNewNote(Name, Note, Type, personal)
    iWRNameInput:ClearFocus()
    iWRNoteInput:ClearFocus()
    if iWR:VerifyInputName(Name) then
        if iWR:VerifyInputNote(Note) then
            iWR:CreateNote(Name, tostring(Note), Type, personal)
        else
            iWR:CreateNote(Name, "", Type, personal)
        end
        iWR:PopulateDatabase()
    else
        print(L["NameInputError"])
        iWR:DebugMsg("NameInput error: [|r" .. (Name or "nil") .. iWR.Colors.iWR .. "].")
    end
end

-- ╭──────────────────────╮
-- │      Clear Note      │
-- ╰──────────────────────╯
function iWR:ClearNote(Name)
    -- Validate input name
    if not iWR:VerifyInputName(Name) then
        print(L["ClearInputError"])
        iWR:DebugMsg("NameInput error: [|r" .. (Name or "nil") .. iWR.Colors.iWR .. "].")
        return
    end

    -- Determine target details
    local targetNameWithRealm = GetUnitName("target", true) -- "Name-Realm"
    local targetName = GetUnitName("target", false) -- "Name"
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWR.CurrentRealm
    targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

    local uncoloredName = StripColorCodes(Name)

    -- Determine the final name and realm to use
    local finalName, finalRealm
    if not iWR:IsForeverClient() and string.find(Name, "-") then
        -- Case 1: Input name includes "-"
        finalName, finalRealm = strsplit("-", Name)
        iWR:DebugMsg("Input includes realm. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    elseif targetName and iWR:IsSamePlayerName(targetName, uncoloredName) then
        -- Case 2: Input name matches target name
        finalName = targetName
        finalRealm = targetRealm
        iWR:DebugMsg("Input matches target. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    else
        -- Case 3: Input name does not include realm and does not match target name
        finalName = Name
        finalRealm = iWR.CurrentRealm
        iWR:DebugMsg("Input differs from target. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    end

    -- Validate final target name and realm
    if not finalName or not finalRealm then
        iWR:DebugMsg("Error on Deletion: " .. (finalName or "Nothing") .. ", " .. (finalRealm or "Nothing"), 1)
        return
    end

    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(StripColorCodes(finalName), finalRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm

    -- Check if the key exists in the database
    if iWRDatabase[databaseKey] then
        -- Capture personal flag before deletion
        local wasPersonal = iWRDatabase[databaseKey][9]

        -- Tombstone all note timestamps so they don't return via sync
        iWR:TombstoneEntireEntry(databaseKey, iWRDatabase[databaseKey])

        -- Remove the entry from the iWR database
        print(L["CharNoteStart"] .. iWRDatabase[databaseKey][4] .. L["CharNoteRemoved"])
        iWRDatabase[databaseKey] = nil
        iWR.ExpandedEntries[databaseKey] = nil

        -- Repopulate and update the target frame
        iWR:PopulateDatabase()
        iWR:UpdateTargetFrame()

        -- Notify friends if data sharing is enabled (skip personal notes)
        if iWRSettings.DataSharing ~= false and not wasPersonal then
            iWR:SendRemoveRequestToFriends(databaseKey)
        end
    else
        -- Notify that the name was not found in the database
        print(L["DBNameNotFound1"] .. databaseKey .. L["DBNameNotFound2"])
        iWR:DebugMsg("Deletion failed, key not found: " .. databaseKey, 1)
    end
end

-- ╭──────────────────────────────────────╮
-- │   Function: Tombstone Entire Entry  │
-- ╰──────────────────────────────────────╯
-- When a player is fully removed, tombstone all their note timestamps
-- in iWRSettings.DeletedEntries so sync doesn't resurrect them.
function iWR:TombstoneEntireEntry(databaseKey, entry)
    if not entry then return end
    iWRSettings.DeletedEntries = iWRSettings.DeletedEntries or {}

    local deletedAt = iWR:GetCurrentTimeByHours()
    local timestamps = {}

    -- Tombstone the current note
    if entry[3] then
        timestamps[entry[3]] = true
    end

    -- Tombstone all history notes
    if entry[10] then
        for _, h in ipairs(entry[10]) do
            if h[3] then timestamps[h[3]] = true end
        end
    end

    -- Also include any existing per-entry tombstones
    if entry[11] then
        for ts in pairs(entry[11]) do
            timestamps[ts] = true
        end
    end

    if next(timestamps) then
        iWRSettings.DeletedEntries[databaseKey] = {
            timestamps = timestamps,
            deletedAt = deletedAt,
        }
    end
end

-- Check if an incoming sync entry has all notes tombstoned (fully deleted locally)
function iWR:IsEntryFullyTombstoned(databaseKey, entry)
    if not iWRSettings.DeletedEntries or not iWRSettings.DeletedEntries[databaseKey] then
        return false
    end
    local tombData = iWRSettings.DeletedEntries[databaseKey]
    local deletedAt = tombData.deletedAt or 0
    local timestamps = tombData.timestamps or {}

    -- If any note in the incoming entry is NEWER than our deletion, accept it entirely
    if entry[3] and entry[3] > deletedAt then
        -- Sender created a note after we deleted — clear tombstones and accept
        iWRSettings.DeletedEntries[databaseKey] = nil
        return false
    end
    if entry[10] then
        for _, h in ipairs(entry[10]) do
            if h[3] and h[3] > deletedAt then
                iWRSettings.DeletedEntries[databaseKey] = nil
                return false
            end
        end
    end

    -- All notes are older than our deletion — check if they're tombstoned
    if entry[3] and not timestamps[entry[3]] then
        return false -- has a note we haven't specifically tombstoned
    end
    if entry[10] then
        for _, h in ipairs(entry[10]) do
            if h[3] and not timestamps[h[3]] then
                return false
            end
        end
    end

    return true -- all notes are tombstoned or older than deletion
end

-- Apply global tombstones to an incoming entry, removing tombstoned notes
function iWR:ApplyGlobalTombstones(databaseKey, entry)
    if not iWRSettings.DeletedEntries or not iWRSettings.DeletedEntries[databaseKey] then
        return entry
    end
    local tombData = iWRSettings.DeletedEntries[databaseKey]
    local deletedAt = tombData.deletedAt or 0
    local timestamps = tombData.timestamps or {}

    -- If any note is newer than our deletion time, clear tombstones and accept fully
    local hasNewerNote = false
    if entry[3] and entry[3] > deletedAt then hasNewerNote = true end
    if not hasNewerNote and entry[10] then
        for _, h in ipairs(entry[10]) do
            if h[3] and h[3] > deletedAt then hasNewerNote = true; break end
        end
    end
    if hasNewerNote then
        iWRSettings.DeletedEntries[databaseKey] = nil
        return entry
    end

    -- Merge global tombstones into the entry's [11]
    entry[11] = entry[11] or {}
    for ts in pairs(timestamps) do
        entry[11][ts] = true
    end

    -- Filter out tombstoned history notes
    if entry[10] then
        local filtered = {}
        for _, h in ipairs(entry[10]) do
            if not (h[3] and timestamps[h[3]]) then
                table.insert(filtered, h)
            end
        end
        entry[10] = #filtered > 0 and filtered or nil
    end

    -- If the current note is tombstoned, promote from history or return nil
    if entry[3] and timestamps[entry[3]] then
        if entry[10] and #entry[10] > 0 then
            local promoted = table.remove(entry[10], #entry[10])
            entry[1] = promoted[1]
            entry[2] = promoted[2]
            entry[3] = promoted[3]
            entry[5] = promoted[4]
            entry[6] = promoted[5]
            entry[9] = promoted[6] == true and true or nil
            if #entry[10] == 0 then entry[10] = nil end
        else
            return nil -- all notes tombstoned, don't add to DB
        end
    end

    return entry
end

-- ╭──────────────────────────────────────╮
-- │   Function: Merge Note History      │
-- ╰──────────────────────────────────────╯
-- Merges note histories from two entries for the same player (used in sync).
-- The newerEntry's [1]-[6] and [10] are updated in-place with the merged result.
function iWR:MergeNoteHistory(olderEntry, newerEntry)
    if not olderEntry or not newerEntry then return end

    -- Merge tombstones from both entries: [11] = { [timestamp] = true }
    local tombstones = {}
    if olderEntry[11] then
        for ts in pairs(olderEntry[11]) do tombstones[ts] = true end
    end
    if newerEntry[11] then
        for ts in pairs(newerEntry[11]) do tombstones[ts] = true end
    end

    -- Collect all notes from both entries: {note, relation, timestamp, date, author, personal}
    local allNotes = {}
    local seen = {} -- deduplicate by timestamp

    -- Helper to add a note if not duplicate and not tombstoned
    local function addNote(note, relation, timestamp, date, author, personal)
        if not timestamp then return end
        local key = tostring(timestamp)
        if not seen[key] and not tombstones[timestamp] then
            seen[key] = true
            table.insert(allNotes, { note or "", relation or 0, timestamp, date or "", author or "", personal == true })
        end
    end

    -- Add current notes from both entries
    addNote(olderEntry[1], olderEntry[2], olderEntry[3], olderEntry[5], olderEntry[6], olderEntry[9])
    addNote(newerEntry[1], newerEntry[2], newerEntry[3], newerEntry[5], newerEntry[6], newerEntry[9])

    -- Add history from both entries
    if olderEntry[10] then
        for _, h in ipairs(olderEntry[10]) do
            addNote(h[1], h[2], h[3], h[4], h[5], h[6])
        end
    end
    if newerEntry[10] then
        for _, h in ipairs(newerEntry[10]) do
            addNote(h[1], h[2], h[3], h[4], h[5], h[6])
        end
    end

    -- Sort by timestamp ascending (oldest first)
    table.sort(allNotes, function(a, b) return a[3] < b[3] end)

    -- Cap at MAX_NOTES_PER_PLAYER
    local maxNotes = iWR.CONSTANTS.MAX_NOTES_PER_PLAYER
    while #allNotes > maxNotes do
        table.remove(allNotes, 1) -- remove oldest
    end

    -- Latest note goes into [1]-[6], rest into [10]
    local latest = table.remove(allNotes) -- pop the newest
    if latest then
        newerEntry[1] = latest[1]
        newerEntry[2] = latest[2]
        newerEntry[3] = latest[3]
        newerEntry[5] = latest[4]
        newerEntry[6] = latest[5]
        newerEntry[9] = latest[6] == true and true or nil
    end

    -- Remaining notes become history
    if #allNotes > 0 then
        newerEntry[10] = allNotes
    else
        newerEntry[10] = nil
    end

    -- Store merged tombstones, clean up stale ones (only keep tombstones for timestamps that matter)
    if next(tombstones) then
        newerEntry[11] = tombstones
    else
        newerEntry[11] = nil
    end
end

function iWR:CreateShareableEntry(entry)
    if type(entry) ~= "table" or entry[9] == true then return nil end
    local shared = {}
    for key, value in pairs(entry) do
        if key ~= 10 then shared[key] = value end
    end
    if entry[10] then
        local history = {}
        for _, note in ipairs(entry[10]) do
            if note[6] ~= true then history[#history + 1] = note end
        end
        if history[1] then shared[10] = history end
    end
    return shared
end

-- ╭─────────────────────────────────╮
-- │      Function: Create Note      │
-- ╰─────────────────────────────────╯
function iWR:CreateNote(Name, Note, Type, personal)
    -- Debug logging
    iWR:DebugMsg("New note Name: [|r" .. Name .. iWR.Colors.iWR .. "].", 3)
    iWR:DebugMsg("New note Note: [" .. (Note ~= "" and ("|r" .. Note .. iWR.Colors.iWR) or iWR.Colors.Reset .. "Nothing" .. iWR.Colors.iWR) .. "].", 3)
    iWR:DebugMsg("New note Type: [|r" .. iWR.Colors[Type] .. iWR:GetTypeName(Type) .. iWR.Colors.iWR .. "].", 3)

    local playerName = iWR:GetUnitPlayerIdentity("player")
    local currentTime, currentDate = iWR:GetCurrentTimeByHours()
    local playerUpdate = false

    -- Determine target details
    local targetNameWithRealm = GetUnitName("target", true) -- "Name-Realm"
    local targetName = GetUnitName("target", false) -- "Name"
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWR.CurrentRealm
    targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

    local uncoloredName = StripColorCodes(Name)

    -- Determine the final name and realm to use
    local finalName, finalRealm
    if not iWR:IsForeverClient() and string.find(Name, "-") then
        -- Case 1: Input name includes "-"
        finalName, finalRealm = strsplit("-", Name)
        iWR:DebugMsg("Input includes realm. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    elseif targetName and iWR:IsSamePlayerName(targetName, uncoloredName) then
        -- Case 2: Input name matches target name
        finalName = targetName
        finalRealm = targetRealm
        iWR:DebugMsg("Input matches target. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    else
        -- Case 3: Input name does not include realm and does not match target name
        finalName = Name
        finalRealm = iWR.CurrentRealm
        iWR:DebugMsg("Input differs from target. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    end

    -- Strip color codes and validate name and realm
    finalName = StripColorCodes(finalName)
    if not finalName or not finalRealm then
        iWR:DebugMsg("Error on creation: Name or Realm missing. Name: " .. (finalName or "nil") .. ", Realm: " .. (finalRealm or "nil"), 1)
        return
    end

    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(finalName, finalRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm
    iWR:DebugMsg("Formatted database key: " .. databaseKey, 3)

    -- Clear global tombstones if user is intentionally creating a note for this player
    if iWRSettings.DeletedEntries and iWRSettings.DeletedEntries[databaseKey] then
        iWRSettings.DeletedEntries[databaseKey] = nil
        iWR:DebugMsg("Cleared tombstones for " .. databaseKey .. " (user created new note).", 3)
    end

    -- Determine display name with color
    local dbName = ""
    local noClass = false
    local colorCode = string.match(Name, "|c%x%x%x%x%x%x%x%x")
    if colorCode then
        dbName = colorCode .. capitalizedName
    else
        if iWR:IsSamePlayerName(targetName, capitalizedName) then
            local targetClass = select(2, UnitClass("target"))
            dbName = targetClass and (iWR.Colors.Classes[targetClass] .. capitalizedName)
        else
            dbName = iWR.Colors.Gray .. capitalizedName
            noClass = true
        end
    end

    -- Note author
    local noteAuthor = iWR:ColorizePlayerNameByClass(playerName, select(2, UnitClass("player")))

    -- Check if player exists in the database
    local existingData = iWR:GetDatabaseEntry(databaseKey)
    if next(existingData) ~= nil then
        playerUpdate = true
    end

    -- Capture faction from target (if target matches this note)
    local noteFaction = ""
    local noteClass = existingData[12] or ""
    local noteRace = existingData[13] or ""
    local pendingIdentity = iWR.PendingNoteIdentity
    if pendingIdentity and iWR:IsSamePlayerName(pendingIdentity.name, capitalizedName) then
        noteClass = pendingIdentity.class or noteClass
        noteRace = pendingIdentity.race or noteRace
    end
    local noFaction = true
    if targetName and iWR:IsSamePlayerName(targetName, capitalizedName) then
        noteFaction = UnitFactionGroup("target") or ""
        noteClass = select(2, UnitClass("target")) or noteClass
        noteRace = select(2, UnitRace("target")) or noteRace
    end
    if noteClass == "" and colorCode then
        local normalizedColor = colorCode:upper()
        for classToken, classColor in pairs(iWR.Colors.Classes or {}) do
            if tostring(classColor):sub(1, 10):upper() == normalizedColor then
                noteClass = classToken
                break
            end
        end
    end
    if noteFaction ~= "" then noFaction = false end

    -- Determine personal flag (preserve existing if not explicitly set)
    local personalFlag = personal
    if personalFlag == nil and existingData and next(existingData) ~= nil then
        personalFlag = existingData[9]
    end

    -- Archive existing note into history before overwriting
    local history = nil
    if playerUpdate and existingData[1] then
        history = existingData[10] or {}
        -- Push current note into history: {note, relation, timestamp, date, author, personal}
        table.insert(history, {
            existingData[1],  -- note text
            existingData[2],  -- relation level at that time
            existingData[3],  -- timestamp
            existingData[5],  -- date
            existingData[6],  -- author
            existingData[9] == true, -- personal flag
        })
        -- Enforce max history size (MAX_NOTES_PER_PLAYER - 1, since current note is separate)
        local maxHistory = iWR.CONSTANTS.MAX_NOTES_PER_PLAYER - 1
        while #history > maxHistory do
            table.remove(history, 1) -- remove oldest
        end
        if #history == 0 then history = nil end
    end

    -- Save to the database
    iWRDatabase[databaseKey] = {
        Note,               -- [1]: Note text
        Type,               -- [2]: Note type
        currentTime,        -- [3]: Timestamp
        dbName,             -- [4]: Display name
        currentDate,        -- [5]: Date
        noteAuthor,         -- [6]: Author
        capitalizedRealm,   -- [7]: Realm
        noteFaction ~= "" and noteFaction or (existingData[8] or ""), -- [8]: Faction (preserve existing)
        personalFlag or nil, -- [9]: Personal flag (true = not shared)
        history,            -- [10]: Notes history (nil if single note)
        existingData[11] or nil, -- [11]: Tombstones (preserved from existing entry)
        [12] = noteClass,   -- [12]: Class token
        [13] = noteRace,    -- [13]: Race token
    }
    iWR.PendingNoteIdentity = nil

    -- Update target frame
    iWR:UpdateTargetFrame()

    -- Send sync update if sharing is enabled (skip personal notes)
    if iWRSettings.DataSharing ~= false and not personalFlag then
        wipe(iWR.Cache.DataTable)
        iWR.Cache.DataTable[databaseKey] = iWR:CreateShareableEntry(iWRDatabase[databaseKey])
        iWR.Cache.Data = iWR:Serialize(iWR.Cache.DataTable)
        iWR:SendNewDBUpdateToFriends()
    end

    -- Print confirmation message
    local updateMessage
    if playerUpdate and history then
        updateMessage = L["CharNoteAppended"]
    elseif playerUpdate then
        updateMessage = L["CharNoteUpdated"]
    else
        updateMessage = L["CharNoteCreated"]
    end
    local missingInfo = ""
    if noClass then missingInfo = missingInfo .. iWR.Colors.iWR .. L["CharNoteClassMissing"] end
    if noFaction then missingInfo = missingInfo .. iWR.Colors.iWR .. L["CharNoteFactionMissing"] end
    if capitalizedRealm ~= iWR.CurrentRealm then
        print(L["CharNoteStart"] .. dbName .. iWR.Colors.Reset .. "-" .. capitalizedRealm .. updateMessage .. missingInfo)
    else
        print(L["CharNoteStart"] .. dbName .. updateMessage .. missingInfo)
    end
end

function iWR:ModifyMenuForContext(menuType)
    Menu.ModifyMenu(menuType, function(ownerRegion, rootDescription, contextData)
        -- Exit early if the LFG browser is open
        if LFGBrowseFrame and LFGBrowseFrame:IsVisible() and menuType == "MENU_UNIT_FRIEND" then
            iWR:DebugMsg("Skipping menu modification because LFG browser is visible.", 2)
            return
        end

        -- Extract player details
        local playerName = contextData and contextData.name
        local playerRealm = contextData and contextData.realm
        local playerClass = nil
        local usingGuildRosterIdentity = false

        -- The modern Communities guild window supplies the complete member
        -- record here for both its compact chat list and expanded roster.
        local clubMemberInfo = contextData and contextData.clubMemberInfo
        if clubMemberInfo then
            playerName = clubMemberInfo.name or playerName
            local classID = clubMemberInfo.classID
            local valueIsSecret = _G.issecretvalue
            if classID and not (valueIsSecret and valueIsSecret(classID))
                and C_CreatureInfo and C_CreatureInfo.GetClassInfo then
                local classInfo = C_CreatureInfo.GetClassInfo(classID)
                playerClass = classInfo and classInfo.classFile or nil
            end
        end

        local rosterMenu = iWR.PendingGuildRosterMenu
        if menuType == "MENU_UNIT_FRIEND" and rosterMenu
            and GetTime() - (rosterMenu.openedAt or 0) < 1
            and _G.GuildRosterFrame and GuildRosterFrame:IsShown() then
            playerName = rosterMenu.name
            playerRealm = nil
            playerClass = rosterMenu.classToken
            usingGuildRosterIdentity = true
            iWR.PendingGuildRosterMenu = nil
        end

        -- Retail 12.0+: contextData values can be secret strings — skip iWR menu entry
        local issv = _G.issecretvalue
        if issv and not usingGuildRosterIdentity then
            if (playerName and issv(playerName)) or (playerRealm and issv(playerRealm)) then
                return
            end
            if contextData and contextData.fullName and issv(contextData.fullName) then
                return
            end
        end

        -- Forever's fullName contains both character-name parts (often First-Last).
        if not usingGuildRosterIdentity and contextData and contextData.fullName then
            if iWR:IsForeverClient() then
                playerName = contextData.fullName
                playerRealm = nil
            elseif not playerRealm then
                local extractedName, extractedRealm = strmatch(contextData.fullName, "([^%-]+)%-(.+)")
                if extractedName and extractedRealm then
                    playerName = extractedName
                    playerRealm = extractedRealm
                end
            end
        end

        -- Forever's party menu context may expose only the first name. Prefer
        -- the underlying unit token, whose UnitName value contains the complete
        -- first-and-last character name. Fall back to matching the menu GUID
        -- against the current group when Blizzard omits the token.
        local unitToken
        if not usingGuildRosterIdentity then
            unitToken = contextData and (contextData.unit or contextData.unitToken)
            unitToken = unitToken or (ownerRegion and (ownerRegion.unit or ownerRegion.unitToken))
            if not unitToken and ownerRegion and ownerRegion.GetAttribute then
                local ok, value = pcall(ownerRegion.GetAttribute, ownerRegion, "unit")
                if ok then unitToken = value end
            end
            if issv and unitToken and issv(unitToken) then unitToken = nil end
        end

        local menuGUID = contextData and contextData.guid
        if not usingGuildRosterIdentity and not unitToken and menuGUID and not (issv and issv(menuGUID)) then
            local prefix = IsInRaid() and "raid" or "party"
            local count = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
            for index = 1, count do
                local candidate = prefix .. index
                local ok, guid = pcall(UnitGUID, candidate)
                if ok and guid == menuGUID then
                    unitToken = candidate
                    break
                end
            end
        end

        if unitToken and UnitExists(unitToken) then
            local unitName, unitRealm = iWR:GetUnitPlayerIdentity(unitToken)
            if unitName and unitName ~= "" then
                playerName = unitName
                playerRealm = unitRealm
            end
        end

        -- Final fallback: Default to the player's own realm
        playerRealm = playerRealm or (iWR:IsForeverClient() and "Forever" or GetRealmName())

        -- Debug output
        local _, resolvedName, resolvedRealm = iWR:GetPlayerDatabaseKey(playerName, playerRealm)
        playerName, playerRealm = resolvedName, resolvedRealm
        local fullPlayerName = iWR:IsForeverClient() and playerName or (playerRealm and playerName .. "-" .. playerRealm or playerName)
        iWR:DebugMsg("Right-click menu opened for: [" .. fullPlayerName .. "].", 3)

        -- Create UI elements
        rootDescription:CreateDivider()
        rootDescription:CreateTitle("iWillRemember")
        rootDescription:CreateButton(L["CreateNote"], function()
            local fullEntryName = (playerRealm ~= iWR.CurrentRealm and playerRealm ~= "") and fullPlayerName or playerName
            iWR:MenuOpen(fullEntryName, playerClass)
            iWR:DatabaseClose()
        end)
    end)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Function calls                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Call to register filters
iWR:RegisterChatFilters()

-- Modify the right-click menu for players
iWR:ModifyMenuForContext("MENU_UNIT_PLAYER")
iWR:ModifyMenuForContext("MENU_UNIT_PARTY")
iWR:ModifyMenuForContext("MENU_UNIT_RAID_PLAYER")
iWR:ModifyMenuForContext("MENU_UNIT_ENEMY_PLAYER")
iWR:ModifyMenuForContext("MENU_UNIT_FRIEND") -- Chat and Social Panel (fyrye)
iWR:ModifyMenuForContext("MENU_UNIT_GUILD_MEMBER")
iWR:ModifyMenuForContext("MENU_UNIT_CHAT_ROSTER")
iWR:ModifyMenuForContext("MENU_UNIT_COMMUNITIES_GUILD_MEMBER")
iWR:ModifyMenuForContext("MENU_UNIT_COMMUNITIES_WOW_MEMBER")

