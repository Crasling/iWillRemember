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
        return playerName .. "-" .. iWRCurrentRealm
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
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWRCurrentRealm
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
    local typeText = iWRBase.Types[typeIndex]
    local iconPath = iWRBase.ChatIcons[typeIndex] or "Interface\\Icons\\INV_Misc_QuestionMark"

    -- Add the note details to the tooltip
    if typeText then
        local icon = iconPath and "|T" .. iconPath .. ":16:16:0:0|t" or ""
        GameTooltip:AddLine(L["NoteToolTip"] .. icon .. iWRBase.Colors[typeIndex] .. " " .. typeText .. "|r " .. icon)
    end

    if note and note ~= "" then
        if #note <= 30 then
            GameTooltip:AddLine("Note: " .. iWRBase.Colors[data[2]] .. note, 1, 0.82, 0) -- Add note in tooltip
        else
            local firstLine, secondLine = iWR:splitOnSpace(note, 30) -- Split text on the nearest space
            GameTooltip:AddLine("Note: " .. iWRBase.Colors[data[2]] .. firstLine, 1, 0.82, 0) -- Add first line
            GameTooltip:AddLine(iWRBase.Colors[data[2]] .. secondLine, 1, 0.82, 0) -- Add second line
        end
    end

    if author and date and iWRSettings.TooltipShowAuthor then
        GameTooltip:AddLine(iWRBase.Colors.Default .. "Author: " .. iWRBase.Colors[typeIndex] .. author .. iWRBase.Colors.Default .. " (" .. date .. ")")
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
            playerInfo:SetText(iWRBase.Colors.iWR .. match.name .. "|r" .. iWRBase.Colors.iWR .. " (" .. iWRBase.Colors[match.relation] .. iWRBase.Types[match.relation] .. iWRBase.Colors.iWR .. ")")
            playerInfo:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

            -- Add note text
            local noteText = notificationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            noteText:SetPoint("TOP", playerInfo, "BOTTOM", 0, -5)
            noteText:SetText("Note: " .. iWRBase.Colors.Yellow .. match.note .. "|r")
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

function iWR:HandleGroupRosterUpdate(wasInGroup)
    local isInGroup = IsInGroup() -- Check if the player is currently in a group
    if not isInGroup and wasInGroup then
        -- Player has left the group, wipe warned players
        wipe(iWRWarnedPlayers)
        iWR:DebugMsg("Player has left the group. Warned players list wiped.", 3)
    else
        iWR:CheckGroupMembersAgainstDatabase()
    end
end


function iWR:CheckGroupMembersAgainstDatabase()
    local numGroupMembers = GetNumGroupMembers()
    local isInRaid = IsInRaid()
    local matches = {}
    local playerName = UnitName("player") -- Current player's name for comparison

    for i = 1, numGroupMembers do
        local unitID = isInRaid and "raid" .. i or "party" .. i
        local targetName, targetRealm = UnitName(unitID)

        if targetName and not iWRWarnedPlayers[targetName] then
            -- Use current player's realm if `targetRealm` is nil
            if targetRealm == "" or targetRealm == nil then
                targetRealm = iWRCurrentRealm
            end
            
            -- Format name and realm for the database key
            local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
            local databaseKey = capitalizedName .. "-" .. capitalizedRealm

            -- Skip the current player
            if playerName == targetName then
                iWRWarnedPlayers[targetName] = true
            elseif databaseKey and not iWRWarnedPlayers[targetName] then
                -- Check the database for this key
                if iWRDatabase[databaseKey] then
                    local data = iWR:GetDatabaseEntry(databaseKey)
                    if data and next(data) ~= nil then
                        local relationValue = data[2]
                        if relationValue and relationValue < 0 then
                            local note = data[1] or ""
                            table.insert(matches, { name = data[4], relation = relationValue, note = note })
                            iWRWarnedPlayers[targetName] = true
                        end
                    else
                        iWR:DebugMsg("No data found for player in group: [" .. targetName .. "]", 3)
                    end
                else
                    iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database. [CheckGroupMembersAgainstDatabase]", 3)
                end
            end
        else
            iWR:DebugMsg("Could not retrieve name for unitID: " .. unitID, 2)
        end
    end

    -- Show a notification popup if any matches were found
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
            -- Get friend's info (which includes friendName and connected status)
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            -- Extract the friend's name and connection status
            local friendName = friendInfo and friendInfo.name
            local isOnline = friendInfo and friendInfo.connected
            iWRDataCache = iWR:Serialize(name)
            -- Ensure friendName is valid and the friend is online before sending
            if friendName and isOnline then
                iWR:SendCommMessage("iWRRemDBUpdate", iWRDataCache, "WHISPER", friendName)
                table.insert(sentTo, friendName)
            elseif friendName and not isOnline then
                -- Nothing
            else
                iWR:DebugMsg("No friend found at index " .. i .. ".", 1)
            end
        end
        -- Print a single message listing all recipients
        if #sentTo > 0 then
            iWR:DebugMsg("Remove request sent to online friends: " .. table.concat(sentTo, ", "), 3)
        else
            iWR:DebugMsg("No online friends available to send the remove request.", 2)
        end
    end
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
        local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWRCurrentRealm
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
        dragonFrame:SetFrameLevel(2)
        dragonFrame:Show()

        local dragonTexture = dragonFrame.texture
        -- Steal Classification dragons texture from DragonFlightUI (thanks KarlHeinzSchneider)
        dragonTexture:SetTexture('Interface\\Addons\\DragonflightUI\\Textures\\uiunitframeboss2x')
        dragonTexture:SetDrawLayer('ARTWORK', 3)

        local targetRelation = iWRDatabase[databaseKey][2]

        if targetRelation == iWRBase.Types["Respected"] then
            dragonTexture:SetTexCoord(0.001953125, 0.388671875, 0.001953125, 0.31835937)
            dragonTexture:SetSize(99, 81)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 54.5, 8)
            dragonTexture:SetVertexColor(0, 0.9, 0, 1)
        elseif targetRelation == iWRBase.Types["Liked"] then
            dragonTexture:SetTexCoord(0.001953125, 0.314453125, 0.322265625, 0.630859375)
            dragonTexture:SetSize(80, 79)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 45, 8)
            dragonTexture:SetVertexColor(0, 0.7, 0, 1)
        elseif targetRelation == iWRBase.Types["Disliked"] then
            dragonTexture:SetTexCoord(0.001953125, 0.314453125, 0.322265625, 0.630859375)
            dragonTexture:SetSize(80, 79)
            dragonTexture:SetPoint('CENTER', portraitParent, 'CENTER', 45, 8)
            dragonTexture:SetVertexColor(0.7, 0, 0, 1)
        elseif targetRelation == iWRBase.Types["Hated"] then
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
        return
    end

    -- Get the target's name and realm for database lookup
    local targetNameWithRealm = GetUnitName("target", true)
    local targetName = GetUnitName("target", false)
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWRCurrentRealm
    targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

    -- Format name and realm for database key
    local capitalizedName, capitalizedRealm = iWR:FormatNameAndRealm(targetName, targetRealm)
    local databaseKey = capitalizedName .. "-" .. capitalizedRealm

    -- Ensure the database entry exists
    if not iWRDatabase[databaseKey] then
        iWR:DebugMsg("Target [" .. databaseKey .. "] not found in the database. [SetTargetFrameDefault]", 1)
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
    iWR:DebugMsg("Default frame updated for target [" .. databaseKey .. "] with type [" .. iWRBase.Colors[targetType] .. iWRBase.Types[targetType] .. "].", 3)
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
            -- Get friend's info (which includes friendName and online status)
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            local friendName = friendInfo and friendInfo.name
            local isOnline = friendInfo and friendInfo.connected

            -- Ensure friendName is valid and the friend is online before sending
            if friendName and isOnline then
                iWR:SendCommMessage("iWRNewDBUpdate", iWRDataCache, "WHISPER", friendName)
                table.insert(friendsSentTo, friendName)
            elseif friendName and not isOnline then
                -- Nothing
            else
                iWR:DebugMsg("No valid friend found at index " .. i .. ".", 1)
            end
        end

        -- Generate a single debug message with all recipients
        if #friendsSentTo > 0 then
            local friendListString = table.concat(friendsSentTo, ", ")
            iWR:DebugMsg("Successfully shared new note to: " .. friendListString .. ".", 3)
        else
            iWR:DebugMsg("No online friends found to share the new note.", 2)
        end
    end
end

-- ╭──────────────────────────────────────────────────────╮
-- │      Function: Sending All Notes to Friendslist      │
-- ╰──────────────────────────────────────────────────────╯
function iWR:SendFullDBUpdateToFriends()
    if iWRSettings.DataSharing ~= false then
        iWR:DebugMsg("Starting full database sync process... This can take up to a couple minutes depending on database size.", 3)

        -- Get the current time
        local currentTime, _ = iWR:GetCurrentTimeByHours()

        -- Initialize a table to track friends the data is sent to
        local recipientsSentTo = {}

        -- Function to send chunks
        local function sendChunksToRecipient(recipientName)
            if recipientName then
                wipe(iWRDataCacheTable)

                -- Filter database entries for the last 100 days
                for k, v in pairs(iWRDatabase) do
                    local entryTime = v[3]
                    local lastDays = 100 * 24 -- 100 days in hours
                    if currentTime - entryTime <= lastDays then
                        iWRDataCacheTable[k] = v
                    end
                end

                -- Serialize the data
                local serializedData = iWR:Serialize(iWRDataCacheTable)
                if not serializedData then
                    iWR:DebugMsg("Serialization failed. Could not send data to: " .. recipientName, 1)
                    return
                end

                -- Split data into chunks
                local chunkSize = 240
                local totalChunks = math.ceil(#serializedData / chunkSize)

                -- Notify the recipient about the incoming chunks
                iWR:SendCommMessage("iWRFullDBUpdate", "START:" .. totalChunks, "WHISPER", recipientName)
                iWR:DebugMsg("Notified recipient " .. recipientName .. " of " .. totalChunks .. " chunks.", 3)

                -- Send chunks with a delay to prevent throttling
                for i = 1, totalChunks do
                    local chunk = serializedData:sub((i - 1) * chunkSize + 1, i * chunkSize)
                    C_Timer.After(1 * i, function()
                        iWR:SendCommMessage("iWRFullDBUpdate", "CHUNK:" .. i .. ":" .. chunk, "WHISPER", recipientName)
                        iWR:DebugMsg("Sent chunk " .. i .. "/" .. totalChunks .. " to " .. recipientName, 3)
                    end)
                end

                -- Notify completion with a delay after the last chunk
                C_Timer.After(1 * (totalChunks + 1), function()
                    iWR:SendCommMessage("iWRFullDBUpdate", "END", "WHISPER", recipientName)
                    iWR:DebugMsg("Database chunks sent to: " .. recipientName, 3)
                    table.insert(recipientsSentTo, recipientName)
                end)
            else
                iWR:DebugMsg("Invalid recipient name.", 1)
            end
        end

        -- Handle SyncType logic
        if iWRSettings.SyncType == "Friends" then
            iWR:DebugMsg("Sync type is 'Friends'. Gathering online friends...", 3)
            for i = 1, C_FriendList.GetNumFriends() do
                local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
                local friendName = friendInfo and friendInfo.name
                local isOnline = friendInfo and friendInfo.connected

                if friendName and isOnline then
                    sendChunksToRecipient(friendName)
                end
            end
        elseif iWRSettings.SyncType == "Whitelist" then
            iWR:DebugMsg("Sync type is 'Whitelist'. Processing sync list...", 3)
            for _, syncEntry in ipairs(iWRSettings.SyncList or {}) do
                if syncEntry.name then
                    -- Check if the player is online
                    local friendInfo = C_FriendList.GetFriendInfo(syncEntry.name)
                    local isOnline = friendInfo and friendInfo.connected
                    if isOnline then
                        sendChunksToRecipient(syncEntry.name)
                    else
                        iWR:DebugMsg("Whitelist target " .. syncEntry.name .. " is offline. Skipping...", 3)
                    end
                else
                    iWR:DebugMsg("Invalid entry in whitelist. Name is missing.", 1)
                end
            end
        end

        -- Debug message
        if #recipientsSentTo > 0 then
            iWR:DebugMsg(L["FullDBSendSuccess"] .. table.concat(recipientsSentTo, ", "), 3)
        else
            iWR:DebugMsg("No recipients found to send the database to.", 2)
        end
    else
        iWR:DebugMsg("Data sharing is disabled. Sync process aborted.", 2)
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

-- ╭──────────────────────────────────────────────────╮
-- │      Function: Convert Version to Number         │
-- ╰──────────────────────────────────────────────────╯
function iWR:ConvertVersionToNumber(versionString)
    -- Split the version string into its components
    local major, minor, patch, build = string.match(versionString, "(%d+)%.(%d+)%.(%d+)%.?(%d*)")
    -- Convert each component to a number and compute a single numerical value
    if major and minor and patch then
        local hasBuild = build and build ~= ""
        return tonumber(major) * 1000000 + tonumber(minor) * 10000 + tonumber(patch) * 100 + (tonumber(build) or 0), hasBuild
    end
    return 0, false -- Return 0 and false if the version string is invalid
end


-- ╭──────────────────────────────────────────────╮
-- │      Function: Receive Version check         │
-- ╰──────────────────────────────────────────────╯
function iWR:OnVersionCheck(prefix, message, distribution, sender)
    iWR:DebugMsg("Version information successfully received by " .. sender .. ".", 3)

    -- Check if the sender is the player itself
    if GetUnitName("player", false) == sender then return end

    -- Convert the version string into a number and check if it's an alpha version
    local versionNumber, isAlphaVersion = iWR:ConvertVersionToNumber(Version)

    -- Handle alpha versions (versions with a fourth number)
    if isAlphaVersion then
        iWR:DebugMsg("Alpha version detected: " .. Version .. ".", 2)
        return
    end

    -- Deserialize the message
    local success, retrievedVersion = iWR:Deserialize(message)
    if not success then
        iWR:DebugMsg("OnVersionCheck Error during deserialization.", 1)
    else
        -- Normal behavior for non-alpha versions
        if retrievedVersion > versionNumber and not iWRVersionMessaged then
            print(L["NewVersionAvailable"])
            iWR:DebugMsg("New version available information from: " .. sender .. ".", 3)
            iWRVersionMessaged = true
        end
    end
end


-- ╭──────────────────────────────────────────╮
-- │      Function: Send Version check        │
-- ╰──────────────────────────────────────────╯
function iWR:CheckLatestVersion()
    -- Convert the version string into a number and check if it's an alpha version
    local versionNumber, isAlphaVersion = iWR:ConvertVersionToNumber(Version)

    -- Handle alpha versions (versions with a fourth number)
    if isAlphaVersion then
        print(iWRBase.Colors.iWR .. "[iWR]: " .. iWRBase.Colors.Yellow.. "WARNING" .. iWRBase.Colors.iWR .. ": This is an alpha version and can be unstable and cause issues with your database. If you do not want to run this version, please downgrade to the latest release.")
        iWR:DebugMsg("Alpha version detected: " .. Version .. ". Version check aborted.", 2)
        return
    end

    -- Loop through all friends in the friend list
    for i = 1, C_FriendList.GetNumFriends() do
        -- Get friend's info (which includes friendName and connected status)
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        local friendName = friendInfo and friendInfo.name
        local isOnline = friendInfo and friendInfo.connected

        -- Ensure friendName is valid and the friend is online before sending
        if friendName and isOnline then
            local VersionCache = iWR:Serialize(versionNumber)
            iWR:SendCommMessage("iWRVersionCheck", VersionCache, "WHISPER", friendName)
            iWR:DebugMsg("Version check sent to: " .. friendName, 3)
        elseif friendName and not isOnline then
            -- Nothing
        else
            iWR:DebugMsg("No valid friend found at index " .. i .. ".", 1)
        end
    end
end

-- ╭────────────────────────────────────────────╮
-- │      Function: Full Database Update        │
-- ╰────────────────────────────────────────────╯
function iWR:OnFullDBUpdate(prefix, message, distribution, sender)
    if iWRSettings.DataSharing ~= false then
        if GetUnitName("player", false) == sender then return end

        -- Verify the sender
        local isValidSender = false
        if iWRSettings.SyncType == "Friends" then
            isValidSender = iWR:VerifyFriend(sender)
        elseif iWRSettings.SyncType == "Whitelist" then
            for _, entry in ipairs(iWRSettings.SyncList or {}) do
                if entry.name == sender and entry.type == "wow" then
                    isValidSender = true
                    break
                end
            end
        end

        if not isValidSender then
            iWR:DebugMsg("Unauthorized sender: " .. sender, 2)
            return
        end

        -- Handle chunked data
        if message:match("^START:") then
            local totalChunks = tonumber(message:match("^START:(%d+)"))
            iWR.ReceivingChunks = { total = totalChunks, received = {}, count = 0 }
            iWR:DebugMsg("Preparing to receive " .. totalChunks .. " chunks from " .. sender, 3)
            print(L["FullDBRetrieve"] .. string.format("%.1f", math.abs(totalChunks / 60)) .. " minutes")
        elseif message:match("^CHUNK:") then
            local chunkIndex, chunkData = message:match("^CHUNK:(%d+):(.*)")
            chunkIndex = tonumber(chunkIndex)

            if iWR.ReceivingChunks and chunkIndex and chunkData then
                if not iWR.ReceivingChunks.received[chunkIndex] then
                    iWR.ReceivingChunks.received[chunkIndex] = chunkData
                    iWR.ReceivingChunks.count = iWR.ReceivingChunks.count + 1
                    iWR:DebugMsg("Received chunk " .. chunkIndex .. "/" .. iWR.ReceivingChunks.total .. " from " .. sender, 3)
                else
                    iWR:DebugMsg("Duplicate chunk received: " .. chunkIndex .. " from " .. sender, 2)
                end
            end

        elseif message == "END" then
            if iWR.ReceivingChunks and iWR.ReceivingChunks.count == iWR.ReceivingChunks.total then
                -- Concatenate and process data
                local fullData = table.concat(iWR.ReceivingChunks.received)
                local success, FullNotesTable = iWR:Deserialize(fullData)

                if success then
                    for k, v in pairs(FullNotesTable) do
                        if iWRDatabase[k] then
                            if iWR:IsNeedToUpdate(iWRDatabase[k][3], v[3]) then
                                iWRDatabase[k] = v
                            end
                        else
                            iWRDatabase[k] = v
                        end
                    end
                    iWR:UpdateTargetFrame()
                    iWR:PopulateDatabase()
                    iWR:UpdateTooltip()
                    print(L["FullDBRetrieveSuccess"] .. sender .. ".", 3)
                else
                    iWR:DebugMsg("Deserialization failed.", 1)
                end
            else
                iWR:DebugMsg("Mismatch in received chunks: expected " .. iWR.ReceivingChunks.total .. ", got " .. iWR.ReceivingChunks.count, 2)
            end
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
            iWR:DebugMsg("Sender " .. sender .. " is not on the friends list. Ignoring sync request.",3)
            return
        end

        -- Deserialize the message
        iWRSuccess, iWRTempTable = iWR:Deserialize(message)
        if not iWRSuccess then
            iWR:DebugMsg("OnNewDBUpdate Deserialization failed. Invalid data received from " .. sender .. ".", 1)
            iWR:DebugMsg("ErrorCode: " .. tostring(iWRTempTable), 1)
        else
            for k, v in pairs(iWRTempTable) do
                iWRDatabase[k] = v
            end

            iWR:UpdateTargetFrame()
            iWR:PopulateDatabase()
            iWR:UpdateTooltip()

            iWR:DebugMsg("Successfully synced new database data from: " .. sender .. ".",3)
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
        iWR:DebugMsg("Sender " .. sender .. " is not on the friends list. Ignoring sync request.",3)
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

    iWR:DebugMsg("Processing request for: [" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWRBase.Colors.iWR .. "] from sender " .. iWRBase.Colors.Green .. senderName .. iWRBase.Colors.iWR .. ". Remaining queue size: " .. #iWRRemoveRequestQueue,3)
    if iWRDatabase[noteName][7] ~= iWRCurrentRealm then
        -- Show the confirmation popup
        StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
            text = iWRBase.Colors.iWR .. "Your friend " .. iWRBase.Colors.Green .. senderName .. iWRBase.Colors.iWR .. " removed |n|n[" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWRBase.Colors.iWR .. "]|n|n from their iWR database. Do you also want to remove [" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWRBase.Colors.iWR .."]?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                print(L["CharNoteStart"] .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWRBase.Colors.iWR .. L["CharNoteRemoved"])
                iWRDatabase[noteName] = nil
                iWR:PopulateDatabase()
                iWR:UpdateTooltip()
                iWR:UpdateTargetFrame()
            end,
            OnCancel = function()
                iWR:DebugMsg("User chose to keep: [" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWRBase.Colors.iWR .. "], if not removed it will be synced back to friend",3)
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
    else
        -- Show the confirmation popup
        StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
            text = iWRBase.Colors.iWR .. "Your friend " .. iWRBase.Colors.Green .. senderName .. iWRBase.Colors.iWR .. " removed |n|n[" .. iWRDatabase[noteName][4] .. iWRBase.Colors.iWR .."]|n|n from their iWR database. Do you also want to remove [" .. iWRDatabase[noteName][4] .. iWRBase.Colors.iWR .."]?",
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
                iWR:DebugMsg("User chose to keep: [" .. iWRDatabase[noteName][4] .. iWRBase.Colors.iWR .. "], if not removed it will be synced back to friend",3)
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
    end
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
    if iWRBase.Colors.Classes[class] then
        return iWRBase.Colors.Classes[class] .. playerName .. iWRBase.Colors.Reset
    else
        return iWRBase.Colors.iWR .. playerName .. iWRBase.Colors.Reset
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
        targetRealm = iWRCurrentRealm
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
            iWR:DebugMsg("Target [|r" .. (iWRBase.Colors.Classes[class] or iWRBase.Colors.Gray) .. targetName .. iWRBase.Colors.iWR .. "] was not found in Database. [SetTargetingFrame]", 3)
        else
            iWR:DebugMsg("Target [|r" .. (iWRBase.Colors.Classes[class] or iWRBase.Colors.Gray) .. targetName .. iWRBase.Colors.iWR .. "] from realm [" .. iWRBase.Colors.Reset .. (targetRealm or "Unknown Realm") .. iWRBase.Colors.iWR .. "] was not found in Database.", 3)
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
            iWR:DebugMsg("Target [|r" .. (iWRBase.Colors.Classes[class] or iWRBase.Colors.Gray) .. targetName .. iWRBase.Colors.iWR .. "] was found in Database.", 3)
        else
            iWR:DebugMsg("Target [|r" .. (iWRBase.Colors.Classes[class] or iWRBase.Colors.Gray) .. targetName .. iWRBase.Colors.iWR .. "] from realm [" .. iWRBase.Colors.Reset .. (targetRealm or "Unknown Realm") .. iWRBase.Colors.iWR .. "] was found in Database.", 3)
        end
    end
end

-- Function to add relationship icons to chat messages
local function AddRelationshipIconToChat(self, event, message, author, flags, ...)
    if iWRSettings.ShowChatIcons then
        -- Extract author name and realm
        local authorName, authorRealm = string.match(author, "^([^-]+)-?(.*)$")
        authorRealm = authorRealm ~= "" and authorRealm or iWRCurrentRealm -- Use current realm if none provided

        if not authorName then
            iWR:DebugMsg("AddRelationshipIconToChat tried to add icon to message with missing authorName")
            return false, message, author, flags, ...
        end
        if not authorRealm then
            iWR:DebugMsg("AddRelationshipIconToChat tried to add icon to message with missing authorRealm")
            return false, message, author, flags, ...
        end

        -- Construct the key as name-realm
        local databaseKey = authorName .. "-" .. authorRealm

        -- Check the database using the constructed key
        if iWRDatabase[databaseKey] then
            -- Get the font size from the current chat frame
            local font, fontSize = self:GetFont()
            local iconSize = math.floor(fontSize * 1.2)
            local iconPath = iWRBase.ChatIcons[iWRDatabase[databaseKey][2]] or "Interface\\Icons\\INV_Misc_QuestionMark"

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
        self.detailFrame = iWR:CreateiWRStyleFrame(UIParent, 300, 250, {"TOP", UIParent, "TOP"})
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
        titleText:SetText(iWRBase.Colors.iWR .. "iWR: Player Details")
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
    if data[7] and data[7] ~= iWRCurrentRealm then
        detailsContent = {
            {label = iWRBase.Colors.Default .. "Name:" .. iWRBase.Colors.Reset, value = data[4]..iWRBase.Colors.Reset.."-"..data[7]},
            {label = iWRBase.Colors.Default .. "Type:" .. iWRBase.Colors[data[2]], value = iWRBase.Types[tonumber(data[2])]},
            {label = iWRBase.Colors.Default .. "Note:" .. iWRBase.Colors[data[2]], value = data[1], isNote = true},
            {label = iWRBase.Colors.Default .. "Author:" .. iWRBase.Colors.Reset, value = data[6]},
            {label = iWRBase.Colors.Default .. "Date:", value = data[5]},
        }
    else
        detailsContent = {
            {label = iWRBase.Colors.Default .. "Name:" .. iWRBase.Colors.Reset, value = data[4]},
            {label = iWRBase.Colors.Default .. "Type:" .. iWRBase.Colors[data[2]], value = iWRBase.Types[tonumber(data[2])]},
            {label = iWRBase.Colors.Default .. "Note:" .. iWRBase.Colors[data[2]], value = data[1], isNote = true},
            {label = iWRBase.Colors.Default .. "Author:" .. iWRBase.Colors.Reset, value = data[6]},
            {label = iWRBase.Colors.Default .. "Date:", value = data[5]},
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
        iWR:DebugMsg("Automatic backup is already running.",2)
        return
    end

    -- Ticker that runs every hour (3600 seconds)
    self.backupTicker = C_Timer.NewTicker(3600, function()
        iWR:BackupDatabase()
    end)

    iWR:DebugMsg("Automatic backup started.",3)
end

function iWR:StopHourlyBackup()
    if self.backupTicker then
        self.backupTicker:Cancel()
        self.backupTicker = nil
        iWR:DebugMsg("Automatic backup stopped.",3)
    else
        iWR:DebugMsg("No active Automatic backup to stop.",2)
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

function iWR:VerifyTargetClassinDB(databasekey, targetClass)
    if iWRDatabase[databasekey][2] ~= 0 then

        -- Get target name and realm
        local targetNameWithRealm = GetUnitName("target", true)
        local targetName = GetUnitName("target", false)
        local targetRealm = select(2, strsplit("-", targetNameWithRealm or ""))
        targetName = targetName and targetName:match("^(.-)%s*%(%*%)$") or targetName -- Remove (*) if present

        -- Use current realm if no realm is found
        if not targetRealm or targetRealm == "" then
            targetRealm = iWRCurrentRealm
        end
        if iWRBase.Colors.Gray .. targetName == iWRDatabase[databasekey][4] or targetName == iWRDatabase[databasekey][4] then
            iWRDatabase[databasekey][4] = iWR:ColorizePlayerNameByClass(targetName, targetClass)
            print(L["CharNoteStart"] .. iWRDatabase[databasekey][4] .. L["CharNoteColorUpdate"])
            iWR:PopulateDatabase()
            if iWRSettings.DataSharing ~= false then
                wipe(iWRDataCacheTable)
                iWRDataCacheTable[tostring(databasekey)] = {
                    iWRDatabase[databasekey][1],     --Data[1]
                    iWRDatabase[databasekey][2],     --Data[2]
                    iWRDatabase[databasekey][3],     --Data[3]
                    iWRDatabase[databasekey][4],     --Data[4]
                    iWRDatabase[databasekey][5],     --Data[5]
                    iWRDatabase[databasekey][6],     --Data[6]
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
        iWR:DebugMsg("NameInput error: [|r" .. (Name or "nil") .. iWRBase.Colors.iWR .. "].")
    end
end

-- ╭──────────────────────╮
-- │      Clear Note      │
-- ╰──────────────────────╯
function iWR:ClearNote(Name)
    -- Validate input name
    if not iWR:VerifyInputName(Name) then
        print(L["ClearInputError"])
        iWR:DebugMsg("NameInput error: [|r" .. (Name or "nil") .. iWRBase.Colors.iWR .. "].")
        return
    end

    -- Determine target details
    local targetNameWithRealm = GetUnitName("target", true) -- "Name-Realm"
    local targetName = GetUnitName("target", false) -- "Name"
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWRCurrentRealm
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
        finalRealm = iWRCurrentRealm
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
        print(iWRBase.Colors.iWR .. "[iWR]: Name [|r" .. databaseKey .. iWRBase.Colors.iWR .. "] does not exist in the database.")
        iWR:DebugMsg("Deletion failed, key not found: " .. databaseKey, 1)
    end
end

-- ╭─────────────────────────────────╮
-- │      Function: Create Note      │
-- ╰─────────────────────────────────╯
function iWR:CreateNote(Name, Note, Type)
    -- Debug logging
    iWR:DebugMsg("New note Name: [|r" .. Name .. iWRBase.Colors.iWR .. "].", 3)
    iWR:DebugMsg("New note Note: [" .. (Note ~= "" and ("|r" .. Note .. iWRBase.Colors.iWR) or iWRBase.Colors.Reset .. "Nothing" .. iWRBase.Colors.iWR) .. "].", 3)
    iWR:DebugMsg("New note Type: [|r" .. iWRBase.Colors[Type] .. iWRBase.Types[Type] .. iWRBase.Colors.iWR .. "].", 3)

    local playerName = UnitName("player")
    local currentTime, currentDate = iWR:GetCurrentTimeByHours()
    local playerUpdate = false

    -- Determine target details
    local targetNameWithRealm = GetUnitName("target", true) -- "Name-Realm"
    local targetName = GetUnitName("target", false) -- "Name"
    local targetRealm = select(2, strsplit("-", targetNameWithRealm or "")) or iWRCurrentRealm
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
        finalRealm = iWRCurrentRealm
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
            dbName = targetClass and (iWRBase.Colors.Classes[targetClass] .. capitalizedName)
        else
            dbName = iWRBase.Colors.Gray .. capitalizedName
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
        wipe(iWRDataCacheTable)
        iWRDataCacheTable[databaseKey] = iWRDatabase[databaseKey]
        iWRDataCache = iWR:Serialize(iWRDataCacheTable)
        iWR:SendNewDBUpdateToFriends()
    end

    -- Print confirmation message
    local updateMessage = playerUpdate and L["CharNoteUpdated"] or L["CharNoteCreated"]
    if capitalizedRealm ~= iWRCurrentRealm then
        if noClass then
            print(L["CharNoteStart"] .. dbName .. iWRBase.Colors.Reset .. "-" .. capitalizedRealm .. updateMessage .. iWRBase.Colors.iWR .. " Class information is missing, will be added the next time player is targeted.")
        else
            print(L["CharNoteStart"] .. dbName .. iWRBase.Colors.Reset .. "-" .. capitalizedRealm .. updateMessage)
        end
    else
        if noClass then
            print(L["CharNoteStart"] .. dbName .. updateMessage .. iWRBase.Colors.iWR .. " Class information is missing, will be added the next time player is targeted.")
        else
            print(L["CharNoteStart"] .. dbName .. updateMessage)
        end
    end
end

-- Function to modify the right-click menu for a given context
function iWR:ModifyMenuForContext(menuType)
    Menu.ModifyMenu(menuType, function(ownerRegion, rootDescription, contextData)
        -- Exit early if the LFG browser is visible
        if LFGBrowseFrame and LFGBrowseFrame:IsVisible() and menuType == "MENU_UNIT_FRIEND" then
            iWR:DebugMsg("Skipping menu modification because LFG browser is visible.", 2)
            return
        end

        -- Retrieve the name of the player for whom the menu is opened
        local playerName = contextData and contextData.name

        -- Check if playerName is available and valid
        if playerName then
            iWR:DebugMsg("Right-click menu opened for: [" .. playerName .. "].", 3)
        else
            iWR:DebugMsg("No player name found for menu type: [" .. menuType .. "].", 2)
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

