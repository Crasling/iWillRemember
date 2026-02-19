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

function iWR:VerifyRealm(playerName)
    if not playerName:find("-") then
        return playerName .. "-" .. iWR.CurrentRealm
    else
        return playerName
    end
end

-- Get player data
function iWR:GetDatabaseEntry(databaseKey)
    return iWRDatabase[databaseKey] or {}
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

function iWR:CreateiWRStyleFrame(parent, width, height, point, backdrop)
    local frameName = "iWRFrame_" .. tostring(math.random(1, 100000))
    local frame = CreateFrame("Frame", frameName, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint(unpack(point))
    frame:SetBackdrop(backdrop or {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    -- Add to UISpecialFrames for ESC functionality
    if not tContains(UISpecialFrames, frame:GetName()) then
        tinsert(UISpecialFrames, frame:GetName())
    end
    return frame
end

function iWR:GetTypeName(typeIndex)
    typeIndex = tonumber(typeIndex)
    if typeIndex and iWRSettings.ButtonLabels and iWRSettings.ButtonLabels[typeIndex]
       and iWRSettings.ButtonLabels[typeIndex] ~= "" then
        return iWRSettings.ButtonLabels[typeIndex]
    end
    return iWR.Types[typeIndex] or ""
end

function iWR:GetIcon(typeIndex)
    typeIndex = tonumber(typeIndex)
    if typeIndex and iWRSettings.CustomIcons and iWRSettings.CustomIcons[typeIndex] then
        return iWRSettings.CustomIcons[typeIndex]
    end
    return iWR.Icons[typeIndex]
end

function iWR:GetChatIcon(typeIndex)
    typeIndex = tonumber(typeIndex)
    if typeIndex and iWRSettings.CustomIcons and iWRSettings.CustomIcons[typeIndex] then
        return iWRSettings.CustomIcons[typeIndex]
    end
    return iWR.ChatIcons[typeIndex] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function iWR:VerifyInputName(Name)
    local verifyName = StripColorCodes(Name)
    if verifyName ~= L["DefaultNameInput"]
        and verifyName ~= L["DefaultNoteInput"]
        and verifyName ~= ""
        and verifyName ~= nil
        and not string.find(verifyName, "^%s+$")
        and not string.find(verifyName, "%d")
        and not string.find(verifyName, " ")
        and #verifyName >= 3
        and #verifyName <= 40
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

    -- Check if the unit is valid and is a player
    if not unit or not UnitIsPlayer(unit) then
        return
    end

    -- Get the player's realm and format the database key
    local targetNameWithRealm = GetUnitName(unit, true)
    local targetName = GetUnitName(unit, false)
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
            GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. note, 1, 0.82, 0) -- Add note in tooltip
        else
            local firstLine, secondLine = iWR:splitOnSpace(note, 30) -- Split text on the nearest space
            GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. firstLine, 1, 0.82, 0) -- Add first line
            GameTooltip:AddLine(iWR.Colors[data[2]] .. secondLine, 1, 0.82, 0) -- Add second line
        end
    end

    if author and date and iWRSettings.TooltipShowAuthor then
        GameTooltip:AddLine(iWR.Colors.Default .. "Author: " .. iWR.Colors[typeIndex] .. author .. iWR.Colors.Default .. " (" .. date .. ")")
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
            noteText:SetText("Note: " .. iWR.Colors.Yellow .. match.note .. "|r")
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
function iWR:CheckGuildWatchlist(databaseKey, guildName, playerName, playerRealm, classToken)
    if not iWRSettings.GuildWatchlist or not next(iWRSettings.GuildWatchlist) then return end
    if not guildName or guildName == "" then return end
    if iWRDatabase[databaseKey] then return end

    local watchEntry = iWRSettings.GuildWatchlist[guildName]
    if not watchEntry then return end
    local relationType = watchEntry.type

    local currentTime, currentDate = iWR:GetCurrentTimeByHours()
    local noteAuthor = (watchEntry.author and watchEntry.author ~= "") and watchEntry.author or iWR:ColorizePlayerNameByClass(UnitName("player"), select(2, UnitClass("player")))
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(playerName, playerRealm)
    local dbName = classToken and iWR.Colors.Classes[classToken] and (iWR.Colors.Classes[classToken] .. capitalizedName) or (iWR.Colors.Gray .. capitalizedName)

    iWRDatabase[databaseKey] = {
        string.format(L["GuildWatchlistDefaultNote"], guildName),  -- [1] Note (auto guild note)
        relationType,       -- [2] Type
        currentTime,        -- [3] Timestamp
        dbName,             -- [4] Display name (colored)
        currentDate,        -- [5] Date
        noteAuthor,         -- [6] Author
        capitalizedRealm    -- [7] Realm
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
    local playerName = UnitName("player") -- Current player's name for comparison

    local maxPartyIndex = isInRaid and numGroupMembers or (numGroupMembers - 1)

    for i = 1, maxPartyIndex do
        local unitID = isInRaid and "raid" .. i or "party" .. i
        local targetName, targetRealm = UnitName(unitID)

        if not targetName then
            iWR:DebugMsg("Could not retrieve name for unitID: " .. unitID, 2)
        elseif not iWR.WarnedPlayers[targetName] then
            iWR.WarnedPlayers[targetName] = true

            if targetRealm == "" or targetRealm == nil then
                targetRealm = iWR.CurrentRealm
            end

            local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
            local databaseKey = capitalizedName .. "-" .. capitalizedRealm

            if playerName ~= targetName then
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
                        iWR:CheckGuildWatchlist(databaseKey, guildName, capitalizedName, capitalizedRealm, classToken)
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
    local playerName = UnitName("player")
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

                -- Check if player already has a note in database
                local databaseKey = capitalizedName .. "-" .. capitalizedRealm
                local hasNote = iWRDatabase[databaseKey] ~= nil

                -- Create log entry
                local entry = {
                    name = capitalizedName,
                    realm = capitalizedRealm,
                    class = classToken or "UNKNOWN",
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
    local formattedName = name:sub(1, 1):upper() .. name:sub(2):gsub("^%l", string.lower)
    local formattedRealm = realm:sub(1, 1):upper() .. realm:sub(2):gsub("^%l", string.lower)
    return formattedName, formattedRealm
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

function iWR:SetTargetFrameDragonFlightUI()
    local portraitParent = _G["TargetFrame"]
    -- local portrait = _G["TargetFramePortrait"]
    -- TODO: check if dragonflight target unitframe module active
    local dragonflight = true;
    if dragonflight then
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
            iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database. [SetTargetFrameDragonFlightUI]", 1)
            return
        end

        -- Create or update the custom frame
        if not iWR.customFrame then
            iWR.customFrame = CreateFrame("Frame", nil, portraitParent)
            iWR.customFrame.texture = iWR.customFrame:CreateTexture(nil, "OVERLAY")
        end

        local dragonFrame = iWR.customFrame
        dragonFrame:SetFrameLevel(1)
        dragonFrame:Show()

        local dragonTexture = dragonFrame.texture
        -- Steal Classification dragons texture from DragonFlightUI (thanks KarlHeinzSchneider)
        dragonTexture:SetTexture('Interface\\Addons\\DragonflightUI\\Textures\\uiunitframeboss2x')
        dragonTexture:SetDrawLayer('ARTWORK', 3)

        local targetRelation = iWRDatabase[databaseKey][2]
        local typeName = iWR.Types[targetRelation]

        if typeName == "Superior" then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 54.5, 8)
            dragonTexture:SetVertexColor(0.3, 0.65, 1, 1)
        elseif typeName == "Respected" then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 54.5, 8)
            dragonTexture:SetVertexColor(0, 0.9, 0, 1)
        elseif typeName == "Liked" then
            dragonTexture:SetTexCoord(0.001953125, 0.314453125, 0.322265625, 0.630859375)
            dragonTexture:SetSize(80, 79)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 45, 8)
            dragonTexture:SetVertexColor(0, 0.7, 0, 1)
        elseif typeName == "Disliked" then
            dragonTexture:SetTexCoord(0.001953125, 0.314453125, 0.322265625, 0.630859375)
            dragonTexture:SetSize(80, 79)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 45, 8)
            dragonTexture:SetVertexColor(0.7, 0, 0, 1)
        elseif typeName == "Hated" then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 54.5, 8)
            dragonTexture:SetVertexColor(0.9, 0, 0, 1)
        else
            iWR:DebugMsg("Relationship type is missing. [SetTargetFrameDragonFlightUI]", 1)
            dragonFrame:Hide()
        end

        iWR:DebugMsg("Custom frame successfully anchored to:" .. portraitParent:GetName() .. ".", 3)
    else
        iWR:DebugMsg("DragonFlightUI portrait frame not found.", 1)
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
    local databaseKey = targetName .. "-" .. targetRealm

    -- Check if the target is in the database
    if not iWRDatabase[databaseKey] then
        local _, class = UnitClass("target")

        -- Guild Watchlist: auto-import if target's guild is watched
        local guildName = GetGuildInfo("target")
        if guildName and iWRSettings.GuildWatchlist and iWRSettings.GuildWatchlist[guildName] then
            iWR:CheckGuildWatchlist(databaseKey, guildName, targetName, targetRealm, class)
        end

        -- Re-check after potential guild import
        if not iWRDatabase[databaseKey] then
            if iWRNameInput then
                iWRNameInput:SetText(class and iWR:ColorizePlayerNameByClass(targetName, class) or targetName)
            end
            if targetRealm == iWR.CurrentRealm then
                iWR:DebugMsg("Target [|r" .. (iWR.Colors.Classes[class] or iWR.Colors.Gray) .. targetName .. iWR.Colors.iWR .. "] was not found in Database. [SetTargetingFrame]", 3)
            else
                iWR:DebugMsg("Target [|r" .. (iWR.Colors.Classes[class] or iWR.Colors.Gray) .. targetName .. iWR.Colors.iWR .. "] from realm [" .. iWR.Colors.Reset .. (targetRealm or "Unknown Realm") .. iWR.Colors.iWR .. "] was not found in Database.", 3)
            end
            return
        end
    end

    -- If the target is in the database and has a valid type
    if iWRDatabase[databaseKey][2] ~= 0 then
        local _, class = UnitClass("target")

        -- Verify and update the class in the database if necessary
        iWR:VerifyTargetClassinDB(databaseKey, class)

        -- Set the input box to the colored player name (guard for panel not yet created)
        if iWRNameInput then
            iWRNameInput:SetText(class and iWR:ColorizePlayerNameByClass(targetName, class) or targetName)
        end

        -- Update the target frame based on settings
        if iWRSettings.UpdateTargetFrame then
            iWR:DebugMsg("TargetFrameType = " .. (iWR.ImagePath or "nil"), 3)
            if iWR.ImagePath == "DragonFlightUI" then
                iWR:SetTargetFrameDragonFlightUI()
            elseif iWR.ImagePath == "ShadowedUnitFrames" then
                iWR:SetTargetFrameShadowedUnitFrames()
            else
                iWR:SetTargetFrameDefault()
            end
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

    -- Ensure correct casing (capitalize first letter of each word)
    formattedRealm = formattedRealm:gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()
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

-- Function to add relationship icons to chat messages
local function AddRelationshipIconToChat(self, event, message, author, flags, ...)
    if iWRSettings.ShowChatIcons then
        if not author or author == "" then
            return false, message, author, flags, ...
        end

        local authorName, authorRealm = string.match(author, "^([^-]+)-?(.*)$")
        authorRealm = NormalizeRealmName(authorRealm)

        if not authorName or authorName == "" then
            return false, message, author, flags, ...
        end

        -- Construct the key as name-realm
        local databaseKey = authorName .. "-" .. authorRealm

        -- Check the database using the constructed key
        if iWRDatabase[databaseKey] then
            -- Get the font size from the current chat frame
            local font, fontSize = self:GetFont()
            local iconSize = math.floor(fontSize * 1.2)
            local iconPath = iWR:GetChatIcon(iWRDatabase[databaseKey][2])

            -- Create the clickable addon link
            local iconString = string.format("|T%s:%d|t", iconPath, iconSize)
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
        if iWRDatabase[playerName] then
            self:ShowDetailWindow(playerName)
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
        self.detailFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.9)
        self.detailFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
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
        titleBar:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            insets = {left = 5, right = 5, top = 5, bottom = 5},
        })
        titleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

        -- Add a title text
        local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
        titleText:SetText(iWR.Colors.iWR .. "iWR: Player Details")
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
    if data[7] and data[7] ~= iWR.CurrentRealm then
        detailsContent = {
            {label = iWR.Colors.Default .. "Name:" .. iWR.Colors.Reset, value = data[4]..iWR.Colors.Reset.."-"..data[7]},
            {label = iWR.Colors.Default .. "Type:" .. iWR.Colors[data[2]], value = detailTypeValue},
            {label = iWR.Colors.Default .. "Note:" .. iWR.Colors[data[2]], value = data[1], isNote = true},
            {label = iWR.Colors.Default .. "Author:" .. iWR.Colors.Reset, value = data[6]},
            {label = iWR.Colors.Default .. "Date:", value = data[5]},
        }
    else
        detailsContent = {
            {label = iWR.Colors.Default .. "Name:" .. iWR.Colors.Reset, value = data[4]},
            {label = iWR.Colors.Default .. "Type:" .. iWR.Colors[data[2]], value = detailTypeValue},
            {label = iWR.Colors.Default .. "Note:" .. iWR.Colors[data[2]], value = data[1], isNote = true},
            {label = iWR.Colors.Default .. "Author:" .. iWR.Colors.Reset, value = data[6]},
            {label = iWR.Colors.Default .. "Date:", value = data[5]},
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
    local frameHeight = math.abs(yOffset) + 60
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
        -- Check if the key already has a realm (contains "-")
        if not strfind(databaseKey, "-") then
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
                data[7] = iWR.CurrentRealm
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
    if iWRDatabase[databasekey][2] ~= 0 then

        -- Get target name and realm
        local targetNameWithRealm = GetUnitName("target", true)
        local targetName = GetUnitName("target", false)
        local targetRealm = select(2, strsplit("-", targetNameWithRealm or ""))
        targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

        -- Use current realm if no realm is found
        if not targetRealm or targetRealm == "" then
            targetRealm = iWR.CurrentRealm
        end
        if iWR.Colors.Gray .. targetName == iWRDatabase[databasekey][4] or targetName == iWRDatabase[databasekey][4] then
            iWRDatabase[databasekey][4] = iWR:ColorizePlayerNameByClass(targetName, targetClass)
            print(L["CharNoteStart"] .. iWRDatabase[databasekey][4] .. L["CharNoteColorUpdate"])
            iWR:PopulateDatabase()
            if iWRSettings.DataSharing ~= false then
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
function iWR:MenuOpen(menuName, classToken)
    if not iWR.State.InCombat then
        iWRPanel:Show()
        local lookupName, lookupRealm

        if menuName ~= "" and menuName and menuName ~= UnitName("target") then
            if classToken then
                iWRNameInput:SetText(iWR:ColorizePlayerNameByClass(menuName, classToken))
            else
                iWRNameInput:SetText(menuName)
            end
            iWRNoteInput:SetText(L["DefaultNoteInput"])

            -- Determine database key for slider lookup (strip color codes for clean lookup)
            local cleanName = StripColorCodes(menuName)
            if cleanName:find("-") then
                lookupName, lookupRealm = strsplit("-", cleanName)
            else
                lookupName = cleanName
                lookupRealm = iWR.CurrentRealm
            end
        else
            iWRNameInput:SetText(L["DefaultNameInput"])
            iWRNoteInput:SetText(L["DefaultNoteInput"])
            if UnitExists("target") and UnitIsPlayer("target") then
                local playerName = UnitName("target")
                local _, class = UnitClass("target")
                if class then
                    iWRNameInput:SetText(iWR:ColorizePlayerNameByClass(playerName, class))
                else
                    iWRNameInput:SetText(playerName)
                end
                lookupName = playerName
                local targetRealm = select(2, UnitName("target"))
                lookupRealm = (targetRealm and targetRealm ~= "") and targetRealm or iWR.CurrentRealm
            end
        end

        -- Set slider to existing note's type value, or 0 if no note exists
        local sliderValue = 0
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
            end
        end
        if iWR.SetSliderValue then
            iWR:SetSliderValue(sliderValue)
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
        iWRNameInput:SetText(L["DefaultNameInput"])
        iWRNoteInput:SetText(L["DefaultNoteInput"])
        if UnitExists("target") and UnitIsPlayer("target") then
            local playerName = UnitName("target")
            local _, class = UnitClass("target")
            if class then
                iWRNameInput:SetText(iWR:ColorizePlayerNameByClass(playerName, class))
            else
                iWRNameInput:SetText(playerName)
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
function iWR:AddNewNote(Name, Note, Type)
    iWRNameInput:ClearFocus()
    iWRNoteInput:ClearFocus()
    if iWR:VerifyInputName(Name) then
        if iWR:VerifyInputNote(Note) then
            iWR:CreateNote(Name, tostring(Note), Type)
        else
            iWR:CreateNote(Name, "", Type)
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
    if string.find(Name, "-") then
        -- Case 1: Input name includes "-"
        finalName, finalRealm = strsplit("-", Name)
        iWR:DebugMsg("Input includes realm. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    elseif targetName and targetName == uncoloredName then
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
        -- Remove the entry from the iWR database
        print(L["CharNoteStart"] .. iWRDatabase[databaseKey][4] .. L["CharNoteRemoved"])
        iWRDatabase[databaseKey] = nil

        -- Repopulate and update the target frame
        iWR:PopulateDatabase()
        iWR:UpdateTargetFrame()

        -- Notify friends if data sharing is enabled
        if iWRSettings.DataSharing ~= false then
            iWR:SendRemoveRequestToFriends(databaseKey)
        end
    else
        -- Notify that the name was not found in the database
        print(L["DBNameNotFound1"] .. databaseKey .. L["DBNameNotFound2"])
        iWR:DebugMsg("Deletion failed, key not found: " .. databaseKey, 1)
    end
end

-- ╭─────────────────────────────────╮
-- │      Function: Create Note      │
-- ╰─────────────────────────────────╯
function iWR:CreateNote(Name, Note, Type)
    -- Debug logging
    iWR:DebugMsg("New note Name: [|r" .. Name .. iWR.Colors.iWR .. "].", 3)
    iWR:DebugMsg("New note Note: [" .. (Note ~= "" and ("|r" .. Note .. iWR.Colors.iWR) or iWR.Colors.Reset .. "Nothing" .. iWR.Colors.iWR) .. "].", 3)
    iWR:DebugMsg("New note Type: [|r" .. iWR.Colors[Type] .. iWR:GetTypeName(Type) .. iWR.Colors.iWR .. "].", 3)

    local playerName = UnitName("player")
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
    if string.find(Name, "-") then
        -- Case 1: Input name includes "-"
        finalName, finalRealm = strsplit("-", Name)
        iWR:DebugMsg("Input includes realm. Using: Name=" .. finalName .. ", Realm=" .. finalRealm, 3)
    elseif targetName and targetName == uncoloredName then
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

    -- Determine display name with color
    local dbName = ""
    local noClass = false
    local colorCode = string.match(Name, "|c%x%x%x%x%x%x%x%x")
    if colorCode then
        dbName = colorCode .. capitalizedName
    else
        if targetName == capitalizedName then
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

    -- Save to the database
    iWRDatabase[databaseKey] = {
        Note,               -- [1]: Note text
        Type,               -- [2]: Note type
        currentTime,        -- [3]: Timestamp
        dbName,             -- [4]: Display name
        currentDate,        -- [5]: Date
        noteAuthor,         -- [6]: Author
        capitalizedRealm    -- [7]: Realm
    }

    -- Update target frame
    iWR:UpdateTargetFrame()

    -- Send sync update if sharing is enabled
    if iWRSettings.DataSharing ~= false then
        wipe(iWR.Cache.DataTable)
        iWR.Cache.DataTable[databaseKey] = iWRDatabase[databaseKey]
        iWR.Cache.Data = iWR:Serialize(iWR.Cache.DataTable)
        iWR:SendNewDBUpdateToFriends()
    end

    -- Print confirmation message
    local updateMessage = playerUpdate and L["CharNoteUpdated"] or L["CharNoteCreated"]
    if capitalizedRealm ~= iWR.CurrentRealm then
        if noClass then
            print(L["CharNoteStart"] .. dbName .. iWR.Colors.Reset .. "-" .. capitalizedRealm .. updateMessage .. iWR.Colors.iWR .. L["CharNoteClassMissing"])
        else
            print(L["CharNoteStart"] .. dbName .. iWR.Colors.Reset .. "-" .. capitalizedRealm .. updateMessage)
        end
    else
        if noClass then
            print(L["CharNoteStart"] .. dbName .. updateMessage .. iWR.Colors.iWR .. L["CharNoteClassMissing"])
        else
            print(L["CharNoteStart"] .. dbName .. updateMessage)
        end
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

        -- Try extracting realm from fullName (e.g., "Player-Realm")
        if not playerRealm and contextData and contextData.fullName then
            local extractedName, extractedRealm = strmatch(contextData.fullName, "([^%-]+)%-(.+)")
            if extractedName and extractedRealm then
                playerName = extractedName
                playerRealm = extractedRealm
            end
        end

        -- Final fallback: Default to the player's own realm
        playerRealm = playerRealm or GetRealmName()

        -- Debug output
        local fullPlayerName = playerRealm and playerName .. "-" .. playerRealm or playerName
        iWR:DebugMsg("Right-click menu opened for: [" .. fullPlayerName .. "].", 3)

        -- Create UI elements
        rootDescription:CreateDivider()
        rootDescription:CreateTitle("iWillRemember")
        rootDescription:CreateButton("Create Note", function()
            local fullEntryName = (playerRealm ~= iWR.CurrentRealm and playerRealm ~= "") and fullPlayerName or playerName
            iWR:MenuOpen(fullEntryName)
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

