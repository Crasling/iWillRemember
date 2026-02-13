-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            iWR Sync & Communication                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

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
    local versionNumber, isAlphaVersion = iWR:ConvertVersionToNumber(iWR.Version)

    -- Handle alpha versions (versions with a fourth number)
    if isAlphaVersion then
        iWR:DebugMsg("Alpha version detected: " .. iWR.Version .. ".", 2)
        return
    end

    -- Deserialize the message
    local success, retrievedVersion = iWR:Deserialize(message)
    if not success then
        iWR:DebugMsg("OnVersionCheck Error during deserialization.", 1)
    else
        -- Normal behavior for non-alpha versions
        if retrievedVersion > versionNumber and not iWR.State.VersionMessaged then
            print(L["NewVersionAvailable"])
            iWR:DebugMsg("New version available information from: " .. sender .. ".", 3)
            iWR.State.VersionMessaged = true
        end
    end
end

-- ╭──────────────────────────────────────────╮
-- │      Function: Send Version check        │
-- ╰──────────────────────────────────────────╯
function iWR:CheckLatestVersion()
    -- Convert the version string into a number and check if it's an alpha version
    local versionNumber, isAlphaVersion = iWR:ConvertVersionToNumber(iWR.Version)

    -- Handle alpha versions (versions with a fourth number)
    if isAlphaVersion then
        print(L["VersionWarning"])
        iWR:DebugMsg("Alpha version detected: " .. iWR.Version .. ". Version check aborted.", 2)
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

-- ╭────────────────────────────────────────────────────────╮
-- │      Function: Sending Remove Note to Friendslist      │
-- ╰────────────────────────────────────────────────────────╯
function iWR:SendRemoveRequestToFriends(name)
    iWR:UpdateTargetFrame()

    if iWRSettings.DataSharing ~= false then
        local sentTo = {} -- Table to store friend names
        iWR.Cache.Data = iWR:Serialize(name)

        -- Function to send remove request
        local function sendRemoveRequest(targetName)
            if targetName then
                iWR:SendCommMessage("iWRRemDBUpdate", iWR.Cache.Data, "WHISPER", targetName)
                table.insert(sentTo, targetName)
            end
        end

        if iWRSettings.SyncType == "Friends" then
            iWR:DebugMsg("Sync type is 'Friends'. Sending remove request to online friends...", 3)

            for i = 1, C_FriendList.GetNumFriends() do
                local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
                local friendName = friendInfo and friendInfo.name
                local isOnline = friendInfo and friendInfo.connected

                if friendName and isOnline then
                    sendRemoveRequest(friendName)
                end
            end

        elseif iWRSettings.SyncType == "Whitelist" then
            iWR:DebugMsg("Sync type is 'Whitelist'. Sending remove request to whitelisted players...", 3)

            for _, syncEntry in ipairs(iWRSettings.SyncList or {}) do
                local friendInfo = C_FriendList.GetFriendInfo(syncEntry.name)
                local friendName = friendInfo and friendInfo.name
                local isOnline = friendInfo and friendInfo.connected

                if friendName and isOnline then
                    sendRemoveRequest(friendName)
                end
            end
        end

        -- Print a single message listing all recipients
        if #sentTo > 0 then
            iWR:DebugMsg("Remove request sent to: " .. table.concat(sentTo, ", "), 3)
        else
            iWR:DebugMsg("No online recipients available to send the remove request.", 2)
        end
    end
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
                iWR:SendCommMessage("iWRNewDBUpdate", iWR.Cache.Data, "WHISPER", friendName)
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
                -- Track recipient immediately (before async timers)
                table.insert(recipientsSentTo, recipientName)

                wipe(iWR.Cache.DataTable)

                -- Filter database entries for the last 100 days
                for k, v in pairs(iWRDatabase) do
                    local entryTime = v[3]
                    local lastDays = 100 * 24 -- 100 days in hours
                    if currentTime - entryTime <= lastDays then
                        iWR.Cache.DataTable[k] = v
                    end
                end

                -- Serialize the data
                local serializedData = iWR:Serialize(iWR.Cache.DataTable)
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
        iWR.Cache.Success, iWR.Cache.TempTable = iWR:Deserialize(message)
        if not iWR.Cache.Success then
            iWR:DebugMsg("OnNewDBUpdate Deserialization failed. Invalid data received from " .. sender .. ".", 1)
            iWR:DebugMsg("ErrorCode: " .. tostring(iWR.Cache.TempTable), 1)
        else
            for k, v in pairs(iWR.Cache.TempTable) do
                iWRDatabase[k] = v
            end

            iWR:UpdateTargetFrame()
            iWR:PopulateDatabase()
            iWR:UpdateTooltip()

            iWR:DebugMsg("Successfully synced new database data from: " .. sender .. ".",3)
        end

        -- Clean up the temporary table
        wipe(iWR.Cache.TempTable)
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
    table.insert(iWR.Queues.RemoveRequests, {NoteName = noteName, Sender = sender})

    iWR:DebugMsg("Added request to queue. Queue size: " .. #iWR.Queues.RemoveRequests,3)

    -- Process the queue if not in combat and no active popup
    if not iWR.State.PopupActive and not InCombatLockdown() then
        iWR:ProcessRemoveRequestQueue()
    end
end

function iWR:ProcessRemoveRequestQueue()
    if iWR.State.PopupActive or #iWR.Queues.RemoveRequests == 0 then
        iWR:DebugMsg("Cannot process queue or queue is empty. Active popup: " .. tostring(iWR.State.PopupActive) .. ", Queue size: " .. #iWR.Queues.RemoveRequests,3)
        return -- Exit if a popup is already active or queue is empty
    end

    -- Mark that a popup is active
    iWR.State.PopupActive = true

    -- Get the next request from the queue
    local request = table.remove(iWR.Queues.RemoveRequests, 1)
    local noteName, senderName = request.NoteName, request.Sender

    iWR:DebugMsg("Processing request for: [" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWR.Colors.iWR .. "] from sender " .. iWR.Colors.Green .. senderName .. iWR.Colors.iWR .. ". Remaining queue size: " .. #iWR.Queues.RemoveRequests,3)
    if iWRDatabase[noteName][7] ~= iWR.CurrentRealm then
        -- Show the confirmation popup
        StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
            text = iWR.Colors.iWR .. "Your friend " .. iWR.Colors.Green .. senderName .. iWR.Colors.iWR .. " removed |n|n[" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWR.Colors.iWR .. "]|n|n from their iWR database. Do you also want to remove [" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWR.Colors.iWR .."]?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                print(L["CharNoteStart"] .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWR.Colors.iWR .. L["CharNoteRemoved"])
                iWRDatabase[noteName] = nil
                iWR:PopulateDatabase()
                iWR:UpdateTooltip()
                iWR:UpdateTargetFrame()
            end,
            OnCancel = function()
                iWR:DebugMsg("User chose to keep: [" .. iWRDatabase[noteName][4] .. "-" .. iWRDatabase[noteName][7] .. iWR.Colors.iWR .. "], if not removed it will be synced back to friend",3)
            end,
            OnHide = function()
                iWR.State.PopupActive = false
                if iWR.State.InCombat then
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
            text = iWR.Colors.iWR .. "Your friend " .. iWR.Colors.Green .. senderName .. iWR.Colors.iWR .. " removed |n|n[" .. iWRDatabase[noteName][4] .. iWR.Colors.iWR .."]|n|n from their iWR database. Do you also want to remove [" .. iWRDatabase[noteName][4] .. iWR.Colors.iWR .."]?",
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
                iWR:DebugMsg("User chose to keep: [" .. iWRDatabase[noteName][4] .. iWR.Colors.iWR .. "], if not removed it will be synced back to friend",3)
            end,
            OnHide = function()
                iWR.State.PopupActive = false
                if iWR.State.InCombat then
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
    if not iWR.State.PopupActive then
        iWR:ProcessRemoveRequestQueue()
    else
        iWR:DebugMsg("Popup already active. Queue size: " .. #iWR.Queues.RemoveRequests,3)
    end
end)

-- ╭──────────────────────────────────────────────────╮
-- │      Function: Ensure Whitelist in Friends       │
-- ╰──────────────────────────────────────────────────╯
function iWR:EnsureWhitelistedPlayersInFriends()
    if not iWRSettings.SyncList or #iWRSettings.SyncList == 0 then
        iWR:DebugMsg("Whitelist is empty. No players to add to the friends list.", 2)
        return
    end

    if not iWRSettings.SyncType == "Whitelist"then
        iWR:DebugMsg("SyncType is not Whitelist. Do not check whitelist.", 2)
        return
    end

    iWR:EnsureWhitelistHasRealm()
    local currentRealm = GetRealmName()
    iWR:DebugMsg("Checking if whitelisted players from realm [" .. currentRealm .. "] are in the friends list...", 3)

    -- Get current friends list
    local friends = {}
    for i = 1, C_FriendList.GetNumFriends() do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.name then
            friends[friendInfo.name] = true
        end
    end

    -- Track added friends
    local addedFriends = {}

    -- Loop through the whitelist and add players if they're missing & from the same realm
    for _, entry in ipairs(iWRSettings.SyncList) do
        if entry.name and entry.realm == currentRealm and not friends[entry.name] then
            C_FriendList.AddFriend(entry.name)
            table.insert(addedFriends, entry.name)
            iWR:DebugMsg("Added " .. entry.name .. " to the friends list (whitelisted, same realm).", 3)
        end
    end

    -- Print message if any friends were added
    if #addedFriends > 0 then
        print(L["WhitelistFriendsAdded"])
    end
end

function iWR:EnsureWhitelistHasRealm()
    if not iWRSettings.SyncList or #iWRSettings.SyncList == 0 then
        iWR:DebugMsg("Whitelist is empty. No entries to check.", 2)
        return
    end

    local currentRealm = GetRealmName()
    local updatedEntries = 0

    for _, entry in ipairs(iWRSettings.SyncList) do
        if entry.name and (not entry.realm or entry.realm == "") then
            entry.realm = currentRealm
            updatedEntries = updatedEntries + 1
            iWR:DebugMsg("Updated whitelist entry: " .. entry.name .. " now assigned to realm [" .. currentRealm .. "].", 3)
        end
    end

    if updatedEntries > 0 then
        iWR:DebugMsg("Whitelist check complete. Updated " .. updatedEntries .. " entries with realm.", 3)
    else
        iWR:DebugMsg("All whitelist entries already have a realm assigned.", 3)
    end
end
