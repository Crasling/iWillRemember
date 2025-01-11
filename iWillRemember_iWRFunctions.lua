-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔ 
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭────────────────────────╮
-- │      List of Types     │
-- ╰────────────────────────╯
iWRBase.Types = {
    [10]    = "Superior",
    [5]     = "Respected",
    [3]     = "Liked",
    [1]     = "Neutral",
    [0]     = "Clear",
    [-3]    = "Disliked",
    [-5]    = "Hated",
    Superior = 10,
    Respected = 5,
    Liked = 3,
    Neutral = 1,
    Clear = 0,
    Disliked = -3,
    Hated = -5,
}

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

if not _G["Blizzard_ItemRef"] then
    _G["Blizzard_ItemRef"] = SetItemRef
end

SetItemRef = function(link, text, button, chatFrame)
    local linkType, playerName = string.split(":", link)
    if linkType == "iWRPlayer" and playerName then
        if iWRDatabase[playerName] then
            iWR:ShowDetailWindow(playerName)
        else
            iWR:DebugMsg("No data found for player: [" .. playerName .. "].")
        end
        return
    end
    return _G["Blizzard_ItemRef"](link, text, button, chatFrame)
end

function iWR:VerifyRealm(playerName)
    if not playerName:find("-") then
        return playerName .. "-" .. iWRcurrentRealm
    else
        return playerName
    end
end

-- Get player data
function iWR:GetDatabaseEntry(playerName)
    return iWRDatabase[playerName] or {}
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
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or GetRealmName()

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
    local typeText = iWRBase.Types[typeIndex]
    local iconPath = iWRBase.ChatIcons[typeIndex] or "Interface\\Icons\\INV_Misc_QuestionMark"

    -- Add the note details to the tooltip
    if typeText then
        local icon = iconPath and "|T" .. iconPath .. ":16:16:0:0|t" or ""
        GameTooltip:AddLine(L["NoteToolTip"] .. icon .. Colors[typeIndex] .. " " .. typeText .. "|r " .. icon)
    end

    if note and note ~= "" then
        GameTooltip:AddLine(Colors.Default .. "Note: " .. Colors[typeIndex] .. note)
    end

    if author and date then
        GameTooltip:AddLine(Colors.Default .. "Author: " .. Colors[typeIndex] .. author .. Colors.Default .. " (" .. date .. ")")
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
            playerInfo:SetText(Colors.iWR .. match.name .. "|r" .. Colors.iWR .. " (" .. Colors[match.relation] .. iWRBase.Types[match.relation] .. Colors.iWR .. ")")
            playerInfo:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

            -- Add note text
            local noteText = notificationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            noteText:SetPoint("TOP", playerInfo, "BOTTOM", 0, -5)
            noteText:SetText("Note: " .. Colors.Yellow .. match.note .. "|r")
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

function iWR:CheckGroupMembersAgainstDatabase()
    wipe(iWRWarnedPlayers)

    local numGroupMembers = GetNumGroupMembers()
    local isInRaid = IsInRaid()
    local matches = {}

    for i = 1, numGroupMembers do
        local unitID = isInRaid and "raid" .. i or "party" .. i
        local playerName = UnitName("player")
        local name, realm = UnitName(unitID)
        if playerName == name then iWRWarnedPlayers[name] = true return end
        if name and not iWRWarnedPlayers[name] then
            -- Get player data
            local data = iWR:GetDatabaseEntry(name)
            if next(data) == nil then
                iWR:DebugMsg("No data found for player in group: [" .. name .. "]",3)
                return
            end
            local relationValue = data[2]
            if relationValue and relationValue < 0 then
                local note = data[1] or ""
                table.insert(matches, { name = name, relation = relationValue, note = note })
                iWRWarnedPlayers[name] = true
            end
        end
    end

    if #matches > 0 then
        iWR:ShowNotificationPopup(matches)
    end
end

-- ╭────────────────────────────────────────╮
-- │      Function: Update the Tooltip      │
-- ╰────────────────────────────────────────╯
function iWR:UpdateTooltip()
    local tooltip = GameTooltip
    if tooltip:IsVisible() then
        tooltip:Hide()
        C_Timer.After(1, function()
            tooltip:Show()
        end)
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

    -- Add a label below the button
    local buttonLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonLabel:SetPoint("TOP", button, "BOTTOM", 0, -5)
    buttonLabel:SetText(label)

    return button, buttonLabel
end

-- ╭────────────────────────────────────────────────────────╮
-- │      Function: Sending Remove Note to Friendslist      │
-- ╰────────────────────────────────────────────────────────╯
function iWR:SendRemoveRequestToFriends(name)
    iWR:UpdateTargetFrame()
    if iWRSettings.DataSharing ~= false then
        local sentTo = {} -- Table to store friend names
        -- Loop through all friends in the friend list
        for i = 1, C_FriendList.GetNumFriends() do
            -- Get friend's info (which includes friendName)
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            -- Extract the friend's name from the table
            local friendName = friendInfo and friendInfo.name
            iWRDataCache = iWR:Serialize(name)
            -- Ensure friendName is valid before sending
            if friendName then
                iWR:SendCommMessage("iWRRemDBUpdate", iWRDataCache, "WHISPER", friendName)
                table.insert(sentTo, friendName)
            else
                iWR:DebugMsg("No friend found at index " .. i .. ".")
            end
        end
        -- Print a single message listing all recipients
        if #sentTo > 0 then
            iWR:DebugMsg("Remove request sent to: " .. table.concat(sentTo, ", "), 3)
        else
            iWR:DebugMsg("No friends available to send the remove request.")
        end
    end
end

function iWR:FormatNameAndRealm(name, realm)
    -- Ensure the inputs are strings to prevent errors
    if not name or type(name) ~= "string" then
        iWR:DebugMsg("Format name not string: " .. name,3)
        name = ""
    end
    if not realm or type(realm) ~= "string" then
        iWR:DebugMsg("Format realm not string: " .. realm,3)
        realm = ""
    end
    local formattedName = name:sub(1, 1):upper() .. name:sub(2):gsub("^%l", string.lower)
    local formattedRealm = realm:sub(1, 1):upper() .. realm:sub(2):gsub("^%l", string.lower)
    return formattedName, formattedRealm
end


function iWR:SetTargetFrameDragonFlightUI()
    local portraitFrame = _G["DragonflightUITargetFrameBackground"] or _G["DragonflightUITargetFrameBorder"]
    if portraitFrame then
        local parent = portraitFrame:GetParent()
        if parent and type(parent.CreateTexture) == "function" then
            -- Get the target's name and realm for database lookup
            local targetNameWithRealm = GetUnitName("target", true)
            local targetName = GetUnitName("target", false)
            local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or GetRealmName()
            
            -- Format name and realm for database key
            local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
            local databaseKey = capitalizedName .. "-" .. capitalizedRealm

            -- Ensure the database entry exists
            if not iWRDatabase[databaseKey] then
                iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database.", 1)
                return
            end

            if not iWR.customFrame then
                iWR.customFrame = parent:CreateTexture(nil, "OVERLAY")
            end

            local customFrame = iWR.customFrame
            customFrame:SetTexture(iWRBase.TargetFrames[iWRDatabase[databaseKey][2]])
            customFrame:SetSize(100, 81)
            customFrame:ClearAllPoints()
            customFrame:SetPoint("CENTER", parent, "CENTER", 54, 8)
            customFrame:Show()

            iWR:DebugMsg("Custom frame successfully anchored to DragonFlightUI frame.", 3)
        else
            iWR:DebugMsg("Parent frame not found or unsupported.")
            iWR:DebugMsg("Parent frame value: " .. tostring(parent))
        end
    else
        iWR:DebugMsg("DragonFlightUI portrait frame not found or unsupported.")
        iWR:DebugMsg("PortraitFrame value: " .. tostring(portraitFrame))
    end
end


function iWR:SetTargetFrameDefault()
    -- Validate target existence and ensure it's a player
    if not UnitExists("target") or not UnitIsPlayer("target") then
        iWR:DebugMsg("No valid target found or target is not a player.", 1)
        return
    end

    -- Get the target's full name with realm and split into name and realm
    local targetNameWithRealm = GetUnitName("target", true)
    local targetName, targetRealm = strsplit("-", targetNameWithRealm or "")

    -- Use the current realm if no realm is specified
    if not targetRealm or targetRealm == "" then
        targetRealm = GetRealmName()
    end

    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm

    -- Check if the target exists in the database
    if not iWRDatabase[databaseKey] then
        iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database.", 1)
        return
    end

    -- Ensure the target frame texture reference exists
    if not TargetFrameTextureFrameTexture then
        iWR:DebugMsg("Default TargetFrameTextureFrameTexture not found.", 1)
        return
    end

    -- Get the target type (index 2 in database entry) and validate
    local targetType = iWRDatabase[databaseKey][2]
    if not targetType or not iWRBase.TargetFrames[targetType] then
        iWR:DebugMsg("Invalid target type or no texture defined for target type: " .. tostring(targetType), 1)
        return
    end

    -- Set the target frame texture
    TargetFrameTextureFrameTexture:SetTexture(iWRBase.TargetFrames[targetType])
    iWR:DebugMsg("Default frame updated for target [" .. databaseKey .. "] with type [" .. targetType .. "].", 3)
end


-- ╭────────────────────────────────────────────────────────╮
-- │      Function: Sending Latest Note to Friendslist      │
-- ╰────────────────────────────────────────────────────────╯
function iWR:SendNewDBUpdateToFriends()
    if iWRSettings.DataSharing ~= false then
        -- Initialize a table to track friends the data is sent to
        local friendsSentTo = {}
        -- Loop through all friends in the friend list
        for i = 1, C_FriendList.GetNumFriends() do
            -- Get friend's info (which includes friendName)
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            -- Extract the friend's name from the table
            local friendName = friendInfo and friendInfo.name
            -- Ensure friendName is valid before sending
            if friendName then
                iWR:SendCommMessage("iWRNewDBUpdate", iWRDataCache, "WHISPER", friendName)
                table.insert(friendsSentTo, friendName)
            else
                iWR:DebugMsg("No valid friend found at index " .. i .. ".", 2)
            end
        end
        -- Generate a single debug message with all recipients
        if #friendsSentTo > 0 then
            local friendListString = table.concat(friendsSentTo, ", ")
            iWR:DebugMsg("Successfully shared new note to: " .. friendListString .. ".", 3)
        else
            iWR:DebugMsg("No valid friends found to share the new note.", 2)
        end
    end
end


-- ╭──────────────────────────────────────────────────────╮
-- │      Function: Sending All Notes to Friendslist      │
-- ╰──────────────────────────────────────────────────────╯
function iWR:SendFullDBUpdateToFriends()
    if iWRSettings.DataSharing ~= false then
        -- Initialize a table to track friends the data is sent to
        local friendsSentTo = {}
        -- Loop through all friends in the friend list
        for i = 1, C_FriendList.GetNumFriends() do
            -- Get friend's info (which includes friendName)
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            -- Extract the friend's name from the table
            local friendName = friendInfo and friendInfo.name
            -- Ensure friendName is valid before sending
            if friendName then
                wipe(iWRDataCacheTable)
                -- Populate DataCacheTable with the full database
                for k, v in pairs(iWRDatabase) do
                    iWRDataCacheTable[k] = v
                end
                -- Serialize the full table
                iWRFullTableToSend = iWR:Serialize(iWRDataCacheTable)
                -- Send the serialized table to the friend
                iWR:SendCommMessage("iWRFullDBUpdate", iWRFullTableToSend, "WHISPER", friendName)
                -- Add the friend's name to the list of recipients
                table.insert(friendsSentTo, friendName)
            end
        end
        -- Generate a single debug message with all recipients
        if #friendsSentTo > 0 then
            local friendListString = table.concat(friendsSentTo, ", ")
            iWR:DebugMsg("Full database sent to: " .. friendListString, 3)
        else
            iWR:DebugMsg("No valid friends found to send the database to.", 2)
        end
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

-- ╭─────────────────────────────────╮
-- │      Function: Verify Friend    │
-- ╰─────────────────────────────────╯
function iWR:VerifyFriend(friendName)
    local numFriends = C_FriendList.GetNumFriends()
    for i = 1, numFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.name == friendName then
            return true
        end
    end
    return false
end

-- ╭──────────────────────────────────────────────╮
-- │      Function: Strip Color Codes Function    │
-- ╰──────────────────────────────────────────────╯
function StripColorCodes(input)
    return input:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end

function iWR:ConvertVersionToNumber(versionString)
    -- Split the version string into its components
    local major, minor, patch = string.match(versionString, "(%d+)%.(%d+)%.(%d+)")
    -- Convert each component to a number and compute a single numerical value
    if major and minor and patch then
        return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
    end
    return 0 -- Return 0 if the version string is invalid
end

-- ╭──────────────────────────────────────────────╮
-- │      Function: Receive Version check         │
-- ╰──────────────────────────────────────────────╯
function iWR:OnVersionCheck(prefix, message, distribution, sender)
    iWR:DebugMsg("Version information successfully received by " .. sender .. ".",3)
    -- Check if the sender is the player itself
    if GetUnitName("player", false) == sender then return end
    -- Convert the version string into a number
    local versionNumber = iWR:ConvertVersionToNumber(Version)
    -- Deserialize the message
    iWRSuccess, RetrievedVersion = iWR:Deserialize(message)
    if not iWRSuccess then
        iWR:DebugMsg("OnVersionCheck Error.")
    else     
        if RetrievedVersion > versionNumber and not iWRVersionMessaged then
            print(L["NewVersionAvailable"])
            iWR:DebugMsg("New version available information from: " .. sender .. ".",3)
            iWRVersionMessaged = true
        end
    end
end

-- ╭──────────────────────────────────────────╮
-- │      Function: Send Version check        │
-- ╰──────────────────────────────────────────╯
function iWR:CheckLatestVersion()
    -- Convert the version string into a number
    local versionNumber = iWR:ConvertVersionToNumber(Version)
    iWR:DebugMsg(Version .. " changed into: " .. versionNumber,3)
    -- Loop through all friends in the friend list
    for i = 1, C_FriendList.GetNumFriends() do
        -- Get friend's info (which includes friendName)
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        -- Extract the friend's name from the table
        local friendName = friendInfo and friendInfo.name
        -- Ensure friendName is valid before printing
        if friendName then
            local VersionCache = iWR:Serialize(versionNumber)
            iWR:SendCommMessage("iWRVersionCheck", VersionCache, "WHISPER", friendName)
        end
    end
end

-- ╭────────────────────────────────────────────╮
-- │      Function: Full Database Update        │
-- ╰────────────────────────────────────────────╯
function iWR:OnFullDBUpdate(prefix, message, distribution, sender)
    if iWRSettings.DataSharing ~= false then
        -- Check if the sender is the player itself
        if GetUnitName("player", false) == sender then return end
        iWR:DebugMsg("Database full update request successfully received by " .. sender .. ".",3)
        -- If the sender is not a friend, skip processing
        if not iWR:VerifyFriend(sender) then
            iWR:DebugMsg("Sender " .. sender .. " is not on the friends list. Ignoring update.",3)
            return
        end
        -- Deserialize the message
        iWRSuccess, FullNotesTable = iWR:Deserialize(message)
        if not iWRSuccess then
            iWR:DebugMsg("OnFullDBUpdate Error.")
        else
            for k, v in pairs(FullNotesTable) do
                if iWRDatabase[k] then
                    if iWR:IsNeedToUpdate((iWRDatabase[k][3]), v[3]) then
                        iWRDatabase[k] = v
                    end
                else
                    iWRDatabase[k] = v
                end
            end
            iWR:UpdateTargetFrame()
            iWR:PopulateDatabase()
            iWR:UpdateTooltip()
            iWR:DebugMsg("Full database data received from: " .. sender .. ".",3)
        end
    end
end

-- ╭──────────────────────────────────╮
-- │      New Database Update         │
-- ╰──────────────────────────────────╯
function iWR:OnNewDBUpdate(prefix, message, distribution, sender)
    if iWRSettings.DataSharing ~= false then
        -- Check if the sender is the player itself
        if GetUnitName("player", false) == sender then return end

        iWR:DebugMsg("Database update request successfully received by " .. sender .. ".",3)

        -- If the sender is not a friend, skip processing
        if not iWR:VerifyFriend(sender) then
            iWR:DebugMsg("Sender " .. sender .. " is not on the friends list. Ignoring update.",3)
            return
        end

        -- Deserialize the message
        iWRSuccess, iWRTempTable = iWR:Deserialize(message)
        if not iWRSuccess then
            iWR:DebugMsg("OnNewDBUpdate Error.")
        else
            for k, v in pairs(iWRTempTable) do
                iWRDatabase[k] = v
            end

            iWR:UpdateTargetFrame()
            iWR:PopulateDatabase()
            iWR:UpdateTooltip()

            iWR:DebugMsg("New database data received from: " .. sender .. ".",3)
        end

        -- Clean up the temporary table
        wipe(iWRTempTable)
    end
end

-- ╭──────────────────────────────────────────╮
-- │      Remove from Database Update         │
-- ╰──────────────────────────────────────────╯
function iWR:OnRemDBUpdate(prefix, message, distribution, sender)
    -- Check if the sender is the player itself
    if GetUnitName("player", false) == sender then return end

    iWR:DebugMsg("Remove request successfully received from " .. sender .. ".",3)

    -- If the sender is not a friend, skip processing
    if not iWR:VerifyFriend(sender) then
        iWR:DebugMsg("Sender " .. sender .. " is not on the friends list. Ignoring update.",3)
        return
    end

    -- Deserialize the message
    local success, noteName = iWR:Deserialize(message)
    if not success then
        iWR:DebugMsg("OnRemoveDBUpdate Error - Failed to deserialize message.")
        return -- Exit early on failure
    end

    -- Ensure NoteName is valid and exists in the database
    if not noteName or not iWRDatabase[noteName] then
        iWR:DebugMsg("Received remove request for a non-existent player: " .. (noteName or "nil") .. ".",3)
        return -- Exit if the player does not exist in the database
    end

    -- Add the request to the queue
    table.insert(iWRRemoveRequestQueue, {NoteName = noteName, Sender = sender})

    iWR:DebugMsg("Added request to queue. Queue size: " .. #iWRRemoveRequestQueue,3)

    -- Process the queue if not in combat and no active popup
    if not iWRisPopupActive and not InCombatLockdown() then
        iWR:ProcessRemoveRequestQueue()
    end
end

function iWR:ProcessRemoveRequestQueue()
    if iWRisPopupActive or #iWRRemoveRequestQueue == 0 then
        iWR:DebugMsg("Cannot process queue or queue is empty. Active popup: " .. tostring(iWRisPopupActive) .. ", Queue size: " .. #iWRRemoveRequestQueue,3)
        return -- Exit if a popup is already active or queue is empty
    end

    -- Mark that a popup is active
    iWRisPopupActive = true

    -- Get the next request from the queue
    local request = table.remove(iWRRemoveRequestQueue, 1)
    local noteName, senderName = request.NoteName, request.Sender

    iWR:DebugMsg("Processing request for: [" .. iWRDatabase[noteName][4] .. Colors.iWR .. "] from sender " .. Colors.Green .. senderName .. Colors.iWR .. ". Remaining queue size: " .. #iWRRemoveRequestQueue,3)

    -- Show the confirmation popup
    StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
        text = Colors.iWR .. "Your friend " .. Colors.Green .. senderName .. Colors.iWR .. " removed |n|n[" .. iWRDatabase[noteName][4] .. Colors.iWR .."]|n|n from their iWR database. Do you also want to remove [" .. iWRDatabase[noteName][4] .. Colors.iWR .."]?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            print(L["CharNoteStart"] .. iWRDatabase[noteName][4] .. L["CharNoteRemoved"])
            iWRDatabase[noteName] = nil
            iWR:PopulateDatabase()
            iWR:UpdateTooltip()
            iWR:UpdateTargetFrame()
        end,
        OnCancel = function()
            iWR:DebugMsg("User chose to keep: [" .. iWRDatabase[noteName][4] .. Colors.iWR .. "], if not removed it will be synced back to friend",3)
        end,
        OnHide = function()
            iWRisPopupActive = false
            if iWRInCombat then
                iWR:DebugMsg("Cannot process next request due to combat.",3)
            else
                iWR:DebugMsg("Popup closed. Processing next request.",3)
                iWR:ProcessRemoveRequestQueue()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("REMOVE_PLAYER_CONFIRM")
end

-- Combat handling to defer popups
local combatEndFrame = CreateFrame("Frame")
combatEndFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatEndFrame:SetScript("OnEvent", function()
    iWR:DebugMsg("Combat ended, processing queued remove requests.",3)
    if not iWRisPopupActive then
        iWR:ProcessRemoveRequestQueue()
    else
        iWR:DebugMsg("Popup already active. Queue size: " .. #iWRRemoveRequestQueue,3)
    end
end)

-- ╭────────────────────────────────────────╮
-- │      Colorize Player Name by Class     │
-- ╰────────────────────────────────────────╯
function iWR:ColorizePlayerNameByClass(playerName, class)
    if Colors.Classes[class] then
        return Colors.Classes[class] .. playerName .. Colors.Reset
    else
        return Colors.iWR .. playerName .. Colors.Reset
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

    -- Remove "(*)" from the target name if it exists
    targetName = targetName and targetName:gsub("%s*%(%*%)", "") or targetName
    targetNameWithRealm = targetNameWithRealm and targetNameWithRealm:gsub("%s*%(%*%)", "") or targetNameWithRealm

    -- Use current realm if no realm is found
    if not targetRealm or targetRealm == "" then
        targetRealm = GetRealmName()
    end

    -- Clear the custom texture if no target or target is not a player
    if not UnitExists("target") or not UnitIsPlayer("target") then
        if iWR.customFrame then
            iWR.customFrame:Hide()
        end
        return
    end

    -- Reset note input if Discord link is set
    if iWRNoteInput:GetText() == L["DiscordLink"] then
        iWRNoteInput:SetText(L["DefaultNoteInput"])
    end

    -- Format the database key as "Name-Realm"
    local databaseKey = targetName .. "-" .. targetRealm

    -- Check if the target is in the database
    if not iWRDatabase[databaseKey] then
        local _, class = UnitClass("target")
        iWRNameInput:SetText(class and iWR:ColorizePlayerNameByClass(targetName, class) or targetName)

        if iWR.customFrame then
            iWR.customFrame:Hide()
        end
        if targetRealm == iWRCurrentRealm then
            iWR:DebugMsg("Target [|r" .. (Colors.Classes[class] or Colors.Gray) .. targetName .. Colors.iWR .. "] was not found in Database.", 3)
        else
            iWR:DebugMsg("Target [|r" .. (Colors.Classes[class] or Colors.Gray) .. targetName .. Colors.iWR .. "] from realm [" .. Colors.Reset .. (targetRealm or "Unknown Realm") .. Colors.iWR .. "] was not found in Database.", 3)
        end
        return
    end

    -- If the target is in the database and has a valid type
    if iWRDatabase[databaseKey][2] ~= 0 then
        local _, class = UnitClass("target")

        -- Verify and update the class in the database if necessary
        iWR:VerifyTargetClassinDB(databaseKey, class)

        -- Set the input box to the colored player name
        iWRNameInput:SetText(class and iWR:ColorizePlayerNameByClass(targetName, class) or targetName)

        -- Update the target frame based on settings
        if iWRSettings.UpdateTargetFrame then
            iWR:DebugMsg("TargetFrameType = " .. (iWRimagePath or "nil"), 3)

            if iWRimagePath == "DragonFlightUI" then
                iWR:SetTargetFrameDragonFlightUI()
            else
                iWR:SetTargetFrameDefault()
            end
        end

        if targetRealm == iWRCurrentRealm then
            iWR:DebugMsg("Target [|r" .. (Colors.Classes[class] or Colors.Gray) .. targetName .. Colors.iWR .. "] was found in Database.", 3)
        else
            iWR:DebugMsg("Target [|r" .. (Colors.Classes[class] or Colors.Gray) .. targetName .. Colors.iWR .. "] from realm [" .. Colors.Reset .. (targetRealm or "Unknown Realm") .. Colors.iWR .. "] was found in Database.", 3)
        end
    end
end

local function AddRelationshipIconToChat(self, event, message, author, flags, ...)
    if iWRSettings.ShowChatIcons then
        local authorName = string.match(author, "^[^-]+") or author
        if iWRDatabase[authorName] then
            -- Get the font size from the current chat frame
            local font, fontSize, fontFlags = self:GetFont()
            local iconSize = math.floor(fontSize * 1.2)
            local iconPath = iWRBase.ChatIcons[iWRDatabase[authorName][2]] or "Interface\\Icons\\INV_Misc_QuestionMark"
            local iconString = "|T" .. iconPath .. ":" .. iconSize .. "|t"
            local clickableLink = "|HiWRPlayer:" .. authorName .. "|h" .. iconString .. "|h"

            message = clickableLink .. " " .. message
        end

        return false, message, author, flags, ...
    else
        return false, message, author, flags, ...
    end
end


function iWR:HandleHyperlink(link, text, button, chatFrame)
    local linkType, playerName = string.split(":", link)
    if linkType == "iWRPlayer" and playerName then
        -- Handle the custom hyperlink for iWRPlayer
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
        self.detailFrame = iWR:CreateiWRStyleFrame(UIParent, 300, 250, {"CENTER", UIParent, "CENTER"})
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
        titleText:SetText(Colors.iWR .. "iWR: Player Details")
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
    if data[7] and data[7] ~= iWRcurrentRealm then
        detailsContent = {
            {label = Colors.Default .. "Name:" .. Colors.Reset, value = data[4]..Colors.Reset.."-"..data[7]},
            {label = Colors.Default .. "Type:" .. Colors[data[2]], value = iWRBase.Types[tonumber(data[2])]},
            {label = Colors.Default .. "Note:" .. Colors[data[2]], value = data[1], isNote = true},
            {label = Colors.Default .. "Author:" .. Colors.Reset, value = data[6]},
            {label = Colors.Default .. "Date:", value = data[5]},
        }
    else
        detailsContent = {
            {label = Colors.Default .. "Name:" .. Colors.Reset, value = data[4]},
            {label = Colors.Default .. "Type:" .. Colors[data[2]], value = iWRBase.Types[tonumber(data[2])]},
            {label = Colors.Default .. "Note:" .. Colors[data[2]], value = data[1], isNote = true},
            {label = Colors.Default .. "Author:" .. Colors.Reset, value = data[6]},
            {label = Colors.Default .. "Date:", value = data[5]},
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

function iWR:BackupDatabase()
    -- Make a copy of the database for backup
    iWRDatabaseBackup = CopyTable(iWRDatabase)
    -- Get the current date and time
    local backupDate = date("%Y-%m-%d")
    local backupTime = date("%H:%M:%S")
    -- Save the backup metadata
    iWRSettings.iWRDatabaseBackupInfo = {
        backupDate = backupDate,
        backupTime = backupTime
    }
    -- Debug message to notify the user
    iWR:DebugMsg("Backup completed on " .. backupDate .. " at " .. backupTime .. "!",3)
end

function iWR:StartHourlyBackup()
    if self.backupTicker then
        iWR:DebugMsg("Hourly backup is already running.",2)
        return
    end

    -- Ticker that runs every hour (3600 seconds)
    self.backupTicker = C_Timer.NewTicker(3600, function()
        iWR:BackupDatabase()
    end)

    iWR:DebugMsg("Hourly backup started.",3)
end

function iWR:StopHourlyBackup()
    if self.backupTicker then
        self.backupTicker:Cancel()
        self.backupTicker = nil
        iWR:DebugMsg("Hourly backup stopped.",3)
    else
        iWR:DebugMsg("No active hourly backup to stop.",2)
    end
end

function iWR:ToggleHourlyBackup(enabled)
    if enabled then
        self:StartHourlyBackup()
    else
        self:StopHourlyBackup()
    end
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
    for key, value in pairs(iWRSettingsDefault) do
        if iWRSettings[key] == nil then
            iWRSettings[key] = value
        end
    end
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
            local newKey = databaseKey .. "-" .. iWRCurrentRealm
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
        for index, defaultValue in ipairs(iWRDatabaseDefault) do
            if data[index] == nil then
                data[index] = defaultValue
                iWR:DebugMsg("Default value set for index " .. index .. " in key: " .. playerKey, 3)
            end
        end

        -- Extract the realm from the key and assign only if data[7] is not already set and valid
        local _, keyRealm = strsplit("-", playerKey)
        if not data[7] or data[7] == "" or data[7] == iWRCurrentRealm then
            if keyRealm and keyRealm ~= "" then
                data[7] = keyRealm
            else
                data[7] = iWRCurrentRealm
            end
        end
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

function iWR:VerifyTargetClassinDB(targetName, targetClass)
    if iWRDatabase[targetName][2] ~= 0 then
        if Colors.Gray .. targetName == iWRDatabase[targetName][4] or targetName == iWRDatabase[targetName][4] then
            iWRDatabase[targetName][4] = iWR:ColorizePlayerNameByClass(targetName, targetClass)
            print(L["CharNoteStart"] .. iWRDatabase[targetName][4] .. L["CharNoteColorUpdate"])
            iWR:PopulateDatabase()
            if iWRSettings.DataSharing ~= false then
                wipe(iWRDataCacheTable)
                iWRDataCacheTable[tostring(targetName)] = {
                    iWRDatabase[targetName][1],     --Data[1]
                    iWRDatabase[targetName][2],     --Data[2]
                    iWRDatabase[targetName][3],     --Data[3]
                    iWRDatabase[targetName][4],     --Data[4]
                    iWRDatabase[targetName][5],     --Data[5]
                    iWRDatabase[targetName][6],     --Data[6]
                }
                iWRDataCache = iWR:Serialize(iWRDataCacheTable)
                iWR:SendNewDBUpdateToFriends()
            end
        end
    end
end

function iWR:UpdateTargetFrame()
    if iWRSettings.UpdateTargetFrame then
        TargetFrame_Update(TargetFrame)
    end
end

-- ╭──────────────────────────────╮
-- │      Toggle Menu Window      │
-- ╰──────────────────────────────╯
function iWR:MenuToggle()
    if not iWRInCombat then
        if iWRPanel:IsVisible() then
            iWR:MenuClose()
        else
            iWR:MenuOpen()
        end
    else
        print(L["InCombat"])
    end
end

-- ╭────────────────────────────╮
-- │      Open Menu Window      │
-- ╰────────────────────────────╯
function iWR:MenuOpen(menuName)
    if not iWRInCombat then
        iWRPanel:Show()
        if menuName ~= "" and menuName and menuName ~= UnitName("target") then
            iWRNameInput:SetText(menuName)
            iWRNoteInput:SetText(L["DefaultNoteInput"])
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
            end
        end
    else
        print(L["InCombat"])
    end
end

-- ╭─────────────────────────────╮
-- │      Close Menu Window      │
-- ╰─────────────────────────────╯
function iWR:MenuClose()
    if not iWRInCombat then
        iWRNameInput:SetText(L["DefaultNameInput"])
        iWRNoteInput:SetText(L["DefaultNoteInput"])
        iWRPanel:Hide()
    else
        print(L["InCombat"])
    end
end

-- ╭──────────────────────────────────╮
-- │      Toggle Database Window      │
-- ╰──────────────────────────────────╯
function iWR:DatabaseToggle()
    if not iWRInCombat then
        if iWRDatabaseFrame:IsVisible() then
            iWR:DatabaseClose()
        else
            iWR:DatabaseOpen()
        end
    else
        print(L["InCombat"])
    end
end

-- ╭────────────────────────────────╮
-- │      Open Database Window      │
-- ╰────────────────────────────────╯
function iWR:DatabaseOpen(Name)
    iWRDatabaseFrame:Show()
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
        iWR:DebugMsg("NameInput error: [|r" .. (Name or "nil") .. Colors.iWR .. "].")
    end
end

-- ╭──────────────────────╮
-- │      Clear Note      │
-- ╰──────────────────────╯
function iWR:ClearNote(Name)
    if iWR:VerifyInputName(Name) then
        local iWRCurrentRealm = GetRealmName()
        local targetName, targetRealm = UnitName("target")
    
        -- Handle cross-realm target
        if targetName and not targetRealm then
            local fullTargetName = UnitName("target")
            if string.find(fullTargetName, "-") then
                targetName, targetRealm = strsplit("-", fullTargetName)
                iWR:DebugMsg("Cross-realm target detected. Name: " .. targetName .. ", Realm: " .. targetRealm, 1)
            else
                targetRealm = iWRCurrentRealm
                iWR:DebugMsg("Target is from the same realm. Using current realm: " .. targetRealm, 3)
            end
        end
    
        -- If the input name matches the target's name but has no realm, assign the target's realm
        if Name == targetName and not string.find(Name, "-") then
            iWR:DebugMsg("Input name matches target. Using target's realm: " .. (targetRealm or "Unknown"), 1)
            targetRealm = targetRealm or iWRCurrentRealm
        end
    
        -- Format name and realm for database key
        if not targetName or not targetRealm then
            iWR:DebugMsg("Error on Creation: "..targetName or "Nothing" .. ". " ..targetRealm or "Nothing")
            return
        end

        -- Format name and realm for database key
        local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
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
            print(Colors.iWR .. " [iWR]: Name [|r" .. databaseKey .. Colors.iWR .. "] does not exist in the database.")
        end
    else
        print(L["ClearInputError"])
        iWR:DebugMsg("NameInput error: [|r" .. (Name or "nil") .. Colors.iWR .. "].")
    end
end

-- ╭─────────────────────────────────╮
-- │      Function: Create Note      │
-- ╰─────────────────────────────────╯
function iWR:CreateNote(Name, Note, Type)
    -- Debug logging
    iWR:DebugMsg("New note Name: [|r" .. Name .. Colors.iWR .. "].", 3)
    iWR:DebugMsg("New note Note: [" .. (Note ~= "" and ("|r" .. Note .. Colors.iWR) or Colors.Reset .. "Nothing" .. Colors.iWR) .. "].", 3)
    iWR:DebugMsg("New note Type: [|r" .. Colors[Type] .. iWRBase.Types[Type] .. Colors.iWR .. "].", 3)

    local playerName = UnitName("player")
    local iWRCurrentRealm = GetRealmName()
    local currentTime, currentDate = iWR:GetCurrentTimeByHours()
    local playerUpdate = false

    -- Determine target details
    local targetNameWithRealm = GetUnitName("target", true) -- "Name-Realm"
    local targetName = GetUnitName("target", false) -- "Name"
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWRCurrentRealm

    -- If input name matches the target name
    if Name == targetName then
        -- Cross-realm handling
        if not targetRealm then
            local fullTargetName = UnitName("target") -- Includes realm if cross-realm
            if string.find(fullTargetName, "-") then
                targetName, targetRealm = strsplit("-", fullTargetName)
                iWR:DebugMsg("Cross-realm target detected. Name: " .. targetName .. ", Realm: " .. targetRealm, 3)
            else
                targetRealm = iWRCurrentRealm
                iWR:DebugMsg("Target is from the same realm. Using current realm: " .. targetRealm, 3)
            end
        end
    else
        -- Handle cases where input Name doesn't match target
        if not string.find(Name, "-") then
            iWR:DebugMsg("Input name missing realm. Using current realm: " .. iWRCurrentRealm, 3)
            targetName = Name
            targetRealm = iWRCurrentRealm
        else
            targetName, targetRealm = strsplit("-", Name)
            iWR:DebugMsg("Input name and realm detected. Name: " .. targetName .. ", Realm: " .. targetRealm, 3)
        end
    end

    targetName = StripColorCodes(targetName)
    local colorCode = string.match(Name, "|c%x%x%x%x%x%x%x%x")
    
    -- Validate name and realm
    if not targetName or not targetRealm then
        iWR:DebugMsg("Error on creation: " .. (targetName or "Nothing") .. ", " .. (targetRealm or "Nothing"), 1)
        return
    end

    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm
    iWR:DebugMsg("Formatted database key: " .. databaseKey, 3)

    -- Determine display name with color
    
    local dbName = ""
    if colorCode then
        dbName = colorCode .. capitalizedName
    elseif Name == targetName then
        local targetClass = select(2, UnitClass("target"))
        dbName = targetClass and (Colors.Classes[targetClass] .. capitalizedName) or (Colors.Gray .. capitalizedName)
    else
        dbName = Colors.Gray .. capitalizedName
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
        wipe(iWRDataCacheTable)
        iWRDataCacheTable[databaseKey] = iWRDatabase[databaseKey]
        iWRDataCache = iWR:Serialize(iWRDataCacheTable)
        iWR:SendNewDBUpdateToFriends()
    end

    -- Print confirmation message
    local updateMessage = playerUpdate and L["CharNoteUpdated"] or L["CharNoteCreated"]
    if capitalizedRealm ~= iWRCurrentRealm then
        print(L["CharNoteStart"] .. dbName .. Colors.Reset .. "-" .. capitalizedRealm .. updateMessage)
    else
        print(L["CharNoteStart"] .. dbName .. updateMessage)
    end
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                                  Options Panel                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯
function iWR:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "iWROptionsPanel", UIParent)
    panel:SetSize(650, 570)
    panel:SetPoint("CENTER", nil, "CENTER")
    panel:Hide()

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", panel, "TOP", 0, -2)
    title:SetText(Title .. Colors.iWR .." Options")

    -- Content Frames
    local optionsPanel = {
        General = CreateFrame("Frame", "$parentGeneralTabContent", panel, "BackdropTemplate"),
        Backup = CreateFrame("Frame", "$parentBackupTabContent", panel, "BackdropTemplate"),
        About = CreateFrame("Frame", "$parentAboutTabContent", panel, "BackdropTemplate"),
    }

    -- Initialize Content Frames
    for name, frame in pairs(optionsPanel) do
        frame:SetSize(panel:GetWidth() - 20, panel:GetHeight() - 50)
        frame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -55)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        frame:SetBackdropBorderColor(0.7, 0.7, 0.8, 1)
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        if name ~= "General" then
            frame:Hide()
        end
    end

    -- ╭───────────────────────╮
    -- │      General Tab      │
    -- ╰───────────────────────╯
    -- Debug Mode Category Title
    local debugCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugCategoryTitle:SetPoint("TOPLEFT", optionsPanel.General, "TOPLEFT", 20, -20)
    debugCategoryTitle:SetText(Colors.iWR .. "Developer Settings")

    -- Debug Mode Checkbox
    local debugCheckbox = CreateFrame("CheckButton", "iWRDebugCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    debugCheckbox:SetPoint("TOPLEFT", debugCategoryTitle, "BOTTOMLEFT", 0, -5)
    debugCheckbox.Text:SetText("Enable Debug Mode")
    debugCheckbox:SetChecked(iWRSettings.DebugMode)
    debugCheckbox:SetScript("OnClick", function(self)
        local isDebugEnabled = self:GetChecked()
        iWRSettings.DebugMode = isDebugEnabled
        iWR:DebugMsg("Debug Mode is activated." .. Colors.Red .. " This is not recommended for common use and will cause a lot of message spam in chat",3)
    end)

    -- Data Sharing Category Title
    local dataSharingCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dataSharingCategoryTitle:SetPoint("TOPLEFT", debugCheckbox, "BOTTOMLEFT", 0, -15)
    dataSharingCategoryTitle:SetText(Colors.iWR .. "Database Sharing Settings")

    -- Data Sharing Checkbox
    local dataSharingCheckbox = CreateFrame("CheckButton", "iWRDataSharingCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    dataSharingCheckbox:SetPoint("TOPLEFT", dataSharingCategoryTitle, "BOTTOMLEFT", 0, -5)
    dataSharingCheckbox.Text:SetText("Enable Database sharing")
    dataSharingCheckbox:SetChecked(iWRSettings.DataSharing)
    dataSharingCheckbox:SetScript("OnClick", function(self)
        iWRSettings.DataSharing = self:GetChecked()
        iWR:DebugMsg("Database Sharing: " .. tostring(iWRSettings.DataSharing),3)
    end)

    -- Target Frame and Chat Icons Category Title
    local targetChatCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetChatCategoryTitle:SetPoint("TOPLEFT", dataSharingCheckbox, "BOTTOMLEFT", 0, -15)
    targetChatCategoryTitle:SetText(Colors.iWR .. "Display Settings")

    -- Target Frames Visibility Checkbox
    local targetFrameCheckbox = CreateFrame("CheckButton", "iWRTargetFrameCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    targetFrameCheckbox:SetPoint("TOPLEFT", targetChatCategoryTitle, "BOTTOMLEFT", 0, -5)
    targetFrameCheckbox.Text:SetText("Enable TargetFrame Update")
    targetFrameCheckbox:SetChecked(iWRSettings.UpdateTargetFrame)
    targetFrameCheckbox:SetScript("OnClick", function(self)
        iWRSettings.UpdateTargetFrame = self:GetChecked()
        iWR:DebugMsg("TargetFrame Update: " .. tostring(iWRSettings.UpdateTargetFrame),3)
    end)

    -- Chat Icon Visibility Checkbox
    local chatIconCheckbox = CreateFrame("CheckButton", "iWRChatIconCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    chatIconCheckbox:SetPoint("TOPLEFT", targetFrameCheckbox, "BOTTOMLEFT", 0, -10)
    chatIconCheckbox.Text:SetText("Show Chat Icons")
    chatIconCheckbox:SetChecked(iWRSettings.ShowChatIcons)
    chatIconCheckbox:SetScript("OnClick", function(self)
        iWRSettings.ShowChatIcons = self:GetChecked()
        iWR:DebugMsg("Chat Icons: " .. tostring(iWRSettings.ShowChatIcons),3)
    end)

    -- Group Warnings Category Title
    local groupWarningCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    groupWarningCategoryTitle:SetPoint("TOPLEFT", chatIconCheckbox, "BOTTOMLEFT", 0, -15)
    groupWarningCategoryTitle:SetText(Colors.iWR .. "Warning Settings")

    -- Group Warning Checkbox
    local groupWarningCheckbox = CreateFrame("CheckButton", "iWRGroupWarningCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    groupWarningCheckbox:SetPoint("TOPLEFT", groupWarningCategoryTitle, "BOTTOMLEFT", 0, -5)
    groupWarningCheckbox.Text:SetText("Enable Group Warnings")
    groupWarningCheckbox:SetChecked(iWRSettings.GroupWarnings)
    groupWarningCheckbox:SetScript("OnClick", function(self)
        local isEnabled = self:GetChecked()
        iWRSettings.GroupWarnings = isEnabled
        soundWarningCheckbox:SetEnabled(isEnabled)
        if iWRSettings.GroupWarnings ~= true then
            iWRMemory.SoundWarnings = iWRSettings.SoundWarnings
            iWRSettings.SoundWarnings = false
        else
            iWRSettings.SoundWarnings = iWRMemory.SoundWarnings
            soundWarningCheckbox:SetChecked(iWRSettings.SoundWarnings)
        end
        iWR:DebugMsg("GroupWarnings: " .. tostring(iWRSettings.GroupWarnings),3)
        iWR:DebugMsg("SoundWarnings: " .. tostring(iWRSettings.SoundWarnings),3)
    end)

    -- Sound Warning Checkbox
    soundWarningCheckbox = CreateFrame("CheckButton", "iWRSoundWarningCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    soundWarningCheckbox:SetPoint("TOPLEFT", groupWarningCheckbox, "BOTTOMLEFT", 30, -3)
    soundWarningCheckbox.Text:SetText("Enable Sound Warnings")
    soundWarningCheckbox:SetChecked(iWRSettings.SoundWarnings)
    soundWarningCheckbox:SetScript("OnClick", function(self)
        iWRSettings.SoundWarnings = self:GetChecked()
        iWR:DebugMsg("SoundWarnings: " .. tostring(iWRSettings.SoundWarnings),3)
    end)

    -- ╭──────────────────────╮
    -- │      Backup Tab      │
    -- ╰──────────────────────╯
    local backupCategoryTitle = optionsPanel.Backup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    backupCategoryTitle:SetPoint("TOPLEFT", optionsPanel.Backup, "TOPLEFT", 20, -20)
    backupCategoryTitle:SetText(Colors.iWR .. "Backup Settings|r")

    -- Backup Checkbox
    local backupCheckbox = CreateFrame("CheckButton", nil, optionsPanel.Backup, "InterfaceOptionsCheckButtonTemplate")
    backupCheckbox:SetPoint("TOPLEFT", backupCategoryTitle, "BOTTOMLEFT", 0, -5)
    backupCheckbox.Text:SetText("Enable Hourly Backup")
    backupCheckbox:SetChecked(iWRSettings.HourlyBackup)
    backupCheckbox:SetScript("OnClick", function(self)
        local isEnabled = self:GetChecked()
        iWRSettings.HourlyBackup = isEnabled
        iWR:ToggleHourlyBackup(isEnabled)
        iWR:DebugMsg("Hourly Backup: " .. tostring(iWRSettings.HourlyBackup),3)
    end)

    local restoreButton = CreateFrame("Button", nil, optionsPanel.Backup, "UIPanelButtonTemplate")
    restoreButton:SetSize(150, 30)
    restoreButton:SetPoint("TOPLEFT", backupCheckbox, "BOTTOMLEFT", 0, -10)
    restoreButton:SetText("Restore Database")
    restoreButton:SetScript("OnClick", function()
        if iWRDatabaseBackup then
            StaticPopupDialogs["CONFIRM_RESTORE_DATABASE"] = {
                text = Colors.Red .. "Are you sure you want to overwrite the current iWR Database with the backup data?|nThis is non-reversible.\n\nBackup made on "
                    .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupDate or "Unknown Date"))
                    .. " at "
                    .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupTime or "Unknown Time")) .. ".",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    iWRDatabase = CopyTable(iWRDatabaseBackup)
                    print(Colors.iWR .. "[iWR]: Database restored from backup made on "
                        .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupDate or "Unknown Date"))
                        .. " at "
                        .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupTime or "Unknown Time"))
                        .. ".")
                    iWR:PopulateDatabase()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("CONFIRM_RESTORE_DATABASE")
        else
            print(Colors.Red .. "[iWR]: No backup found to restore.")
        end
    end)

    -- Backup Info Display
    local backupInfoDisplay = optionsPanel.Backup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    backupInfoDisplay:SetPoint("LEFT", restoreButton, "RIGHT", 10, 0)

    -- Function to Update Restore Button and Backup Info Display
    local function UpdateBackupInfoDisplay()
        if iWRDatabaseBackup and iWRSettings.iWRDatabaseBackupInfo and iWRSettings.iWRDatabaseBackupInfo.backupDate ~= "" and iWRSettings.iWRDatabaseBackupInfo.backupTime ~= "" then
            backupInfoDisplay:SetText("Last Backup: " .. iWRSettings.iWRDatabaseBackupInfo.backupDate .. " at " .. iWRSettings.iWRDatabaseBackupInfo.backupTime)
            restoreButton:Enable()
            restoreButton:SetAlpha(1.0)
        else
            backupInfoDisplay:SetText("No Backup Available")
            restoreButton:Disable()
            restoreButton:SetAlpha(0.5)
        end
    end

    -- Update the display when a new backup is made
    hooksecurefunc(iWR, "BackupDatabase", UpdateBackupInfoDisplay)

    -- Initial Update
    UpdateBackupInfoDisplay()

    -- ╭─────────────────────╮
    -- │      About Tab      │
    -- ╰─────────────────────╯
    -- About Category Title
    local aboutCategoryTitle = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aboutCategoryTitle:SetPoint("TOP", optionsPanel.About, "TOP", 0, -30)
    aboutCategoryTitle:SetText(Colors.iWR .. "About|r")

    -- Addon Name and Version
    local aboutAddonName = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAddonName:SetPoint("TOP", aboutCategoryTitle, "BOTTOM", 0, -10)
    aboutAddonName:SetText(Colors.iWR .. Title)

    -- Author Information
    local aboutAuthor = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAuthor:SetPoint("TOP", aboutAddonName, "BOTTOM", 0, -10)
    aboutAuthor:SetText("Created by: " .. Colors.Cyan .. Author .. Colors.Reset)

    -- Description
    local aboutDescription = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutDescription:SetPoint("TOP", aboutAuthor, "BOTTOM", 0, -30)
    aboutDescription:SetText(Colors.iWR .. "iWillRemember " .. Colors.Reset .. "is an addon designed to help you track and easily share player notes with friends.")

    -- Support Information
    local aboutSupport = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutSupport:SetPoint("TOP", aboutDescription, "BOTTOM", 0, -10)
    aboutSupport:SetText(Colors.iWR .. "iWR " .. Colors.Reset .. "is in early development. Join the Discord for help with issues, questions, or suggestions.")

    -- Discord Link
    local aboutDiscord = CreateFrame("EditBox", nil, optionsPanel.About, "InputBoxTemplate")
    aboutDiscord:SetSize(200, 30)
    aboutDiscord:SetText(L["DiscordLink"])
    aboutDiscord:SetPoint("TOP", aboutSupport, "BOTTOM", 0, -20)
    aboutDiscord:SetAutoFocus(false)
    aboutDiscord:SetTextColor(1, 1, 1, 1)
    aboutDiscord:SetFontObject(GameFontHighlight)
    aboutDiscord:SetJustifyH("CENTER")
    aboutDiscord:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self:GetText() ~= L["DiscordLink"] then
            self:SetText(L["DiscordLink"])
        end
    end)
    aboutDiscord:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Copy this link to join our Discord for support and updates.", 1, 1, 1)
        GameTooltip:Show()
    end)
    aboutDiscord:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    if iWRSettings.DebugMode then
        -- Game Version Label
        local aboutGameVersion = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutGameVersion:SetPoint("TOP", aboutDiscord, "BOTTOM", 0, -20)
        aboutGameVersion:SetText(Colors.iWR .. "Game Version: " .. Colors.Reset .. iWRGameVersion)

        -- TOC Version Label
        local aboutTocVersion = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutTocVersion:SetPoint("TOP", aboutGameVersion, "BOTTOM", 0, -10)
        aboutTocVersion:SetText(Colors.iWR .. "TOC Version: " .. Colors.Reset .. iWRGameTocVersion)

        -- TOC Version Label
        local aboutBuildVersion = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutBuildVersion:SetPoint("TOP", aboutTocVersion, "BOTTOM", 0, -10)
        aboutBuildVersion:SetText(Colors.iWR .. "Build Version: " .. Colors.Reset .. iWRGameBuild)

        -- TOC Version Label
        local aboutBuildDate = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutBuildDate:SetPoint("TOP", aboutBuildVersion, "BOTTOM", 0, -10)
        aboutBuildDate:SetText(Colors.iWR .. "Build Date: " .. Colors.Reset .. iWRGameBuildDate)
    end

    -- Tabs
    local tabs = {
        General = iWR:CreateTab(panel, 1, "General", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == "General")
            end
        end),
        Backup = iWR:CreateTab(panel, 2, "Backup", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == "Backup")
            end
        end),
        About = iWR:CreateTab(panel, 3, "About", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == "About")
            end
        end),
    }

    -- Tab Switching Logic
    PanelTemplates_SetNumTabs(panel, 3)
    PanelTemplates_SetTab(panel, 1)

    -- Register the options panel
    optionsCategory = Settings.RegisterCanvasLayoutCategory(panel, "iWillRemember")
    Settings.RegisterAddOnCategory(optionsCategory)

    -- Return Panel
    return panel
end

-- Function to modify the right-click menu for a given context
function iWR:ModifyMenuForContext(menuType)
    Menu.ModifyMenu(menuType, function(ownerRegion, rootDescription, contextData)
        -- Retrieve the name of the player for whom the menu is opened
        local playerName = contextData and contextData.name

        -- Check if playerName is available and valid
        if playerName then
            iWR:DebugMsg("Right-click menu opened for: [" .. playerName .. "].",3)
        else
            iWR:DebugMsg("No player name found for menu type: [" .. menuType .. "].",2)
        end

        -- Create a divider to visually separate this custom section from other menu items
        rootDescription:CreateDivider()

        -- Create a title for the custom section of the menu, labeled "iWillRemember"
        rootDescription:CreateTitle("iWillRemember")

        -- Add a new button to the menu with the text "Create Note"
        rootDescription:CreateButton("Create Note", function()
            -- Show the iWRPanel and pass the player's name
            iWR:MenuOpen(playerName)
        end)
    end)
end

-- Add Icons to LFG Browser
local lastScanTime = 0
local scanCooldown = 0.1 -- Cooldown time in seconds
function iWR:AddChatIconToLFGResults()
    local currentTime = GetTime() -- Get the current time in seconds
    if currentTime - lastScanTime < scanCooldown then
        iWR:DebugMsg("Skipping scan due to cooldown.",3)
        return
    end

    lastScanTime = currentTime -- Update the last scan time

    local scrollBox = LFGBrowseFrameScrollBox
    if not scrollBox or not scrollBox.ScrollTarget then
        iWR:DebugMsg("LFGBrowseFrameScrollBox or ScrollTarget not found.")
        return
    end

    local children = {scrollBox.ScrollTarget:GetChildren()}

    for _, child in ipairs(children) do
        local nameText
        for _, region in ipairs({child:GetRegions()}) do
            if region and region:GetObjectType() == "FontString" and region:GetText() then
                nameText = region
                break
            end
        end

        if nameText then
            local playerName = nameText:GetText()
            if playerName then
                playerName = playerName:match("^[^-]+")
            end

            if playerName and iWRDatabase[playerName] then
                if not child.chatIcon then
                    iWR:DebugMsg("Adding icon for player: [" .. iWRDatabase[playerName][4] .. "].",3)
                    child.chatIcon = child:CreateTexture(nil, "OVERLAY")
                    child.chatIcon:SetSize(18, 18)
                    child.chatIcon:SetPoint("LEFT", child, "LEFT", 154, 0)
                end
                child.chatIcon:SetTexture(iWRBase.ChatIcons[iWRDatabase[playerName][2]] or "Interface\\Icons\\INV_Misc_QuestionMark")
                child.chatIcon:Show()
            elseif child.chatIcon then
                child.chatIcon:Hide()
            end
        else
            iWR:DebugMsg("No FontString found for this child.",2)
        end
    end
end

local function HookLFGScrollBox()
    if LFGBrowseFrameScrollBox then
        -- Add throttling using a timer
        local lastUpdate = 0
        LFGBrowseFrame:HookScript("OnUpdate", function()
            if GetTime() - lastUpdate >= scanCooldown then
                iWR:AddChatIconToLFGResults()
                lastUpdate = GetTime()
            end
        end)
    else
        iWR:DebugMsg("LFGBrowseFrameScrollBox not available yet.",2)
    end
end

function iWR:InitializeLFGHook()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    frame:SetScript("OnEvent", function(self, event, addon)
        if event == "ADDON_LOADED" and addon == "Blizzard_LookingForGroupUI" then
            HookLFGScrollBox()
            frame:UnregisterEvent("ADDON_LOADED")
         elseif event == "PLAYER_ENTERING_WORLD" then
             C_Timer.After(2, HookLFGScrollBox)
            frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
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

