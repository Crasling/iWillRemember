local L = iWR.L

local hookedRows = setmetatable({}, { __mode = "k" })
local attachedBrowseFrame
local refreshElapsed = 0
local resultMemberCache = {}
local groupNoteTooltip = _G.iWRGroupFinderNoteTooltip
    or CreateFrame("GameTooltip", "iWRGroupFinderNoteTooltip", UIParent, "GameTooltipTemplate")
groupNoteTooltip:SetClampedToScreen(true)

local function IsSecret(value)
    return value ~= nil and issecretvalue and issecretvalue(value)
end

local function GetRowName(row)
    local label = row and row.Name
    if not label or not label.GetText then return nil end

    local text = label:GetText()
    if IsSecret(text) or type(text) ~= "string" or text == "" then return nil end

    -- Blizzard recycles Group Finder rows. If the visible text is still ours,
    -- use the untouched name retained for this row; otherwise Blizzard has
    -- filled the row with a new result and that text becomes the new source.
    if row.iWRGroupFinderDisplayName == text then
        return row.iWRGroupFinderRawName
    end

    row.iWRGroupFinderDisplayName = nil
    row.iWRGroupFinderRawName = nil
    row.iWRGroupFinderDatabaseKey = nil
    return StripColorCodes(text)
end

local function RestoreRowName(row)
    local label = row and row.Name
    if not label or not label.GetText or not label.SetText then return end

    local current = label:GetText()
    if IsSecret(current) then return end
    if row.iWRGroupFinderDisplayName and current == row.iWRGroupFinderDisplayName
        and row.iWRGroupFinderRawName then
        label:SetText(row.iWRGroupFinderRawName)
    end

    row.iWRGroupFinderDisplayName = nil
    row.iWRGroupFinderRawName = nil
    row.iWRGroupFinderDatabaseKey = nil
end

local function FindRowEntry(row)
    local playerName = GetRowName(row)
    if not playerName then return nil end

    local databaseKey = iWR:GetPlayerDatabaseKey(playerName)
    local data = databaseKey and iWRDatabase[databaseKey]
    if not data then return nil end
    return databaseKey, data, playerName
end

local function AddMemberMatch(matchesByKey, value)
    if type(value) ~= "string" then
        if value and value.GetText then
            local ok, text = pcall(value.GetText, value)
            if not ok then return end
            value = text
        else
            return
        end
    end
    if IsSecret(value) or type(value) ~= "string" or value == "" then return end
    value = StripColorCodes(value):gsub("|T.-|t", "")
    value = value:match("^%s*(.-)%s*$") or ""
    if value == "" then return end

    local databaseKey = iWR:GetPlayerDatabaseKey(value)
    local data = databaseKey and iWRDatabase[databaseKey]
    if data and not matchesByKey[databaseKey] then
        matchesByKey[databaseKey] = {
            key = databaseKey,
            data = data,
            name = StripColorCodes(data[4] or value),
        }
    end
end

local candidateFields = {
    "name", "fullName", "playerName", "memberName", "leaderName",
    "characterName", "displayName", "Name", "FullName", "PlayerName", "MemberName",
}

local containerFields = {
    "members", "memberNames", "players", "memberInfo", "memberInfos",
}

local function AddObjectMatches(matchesByKey, object)
    if type(object) ~= "table" then return end
    for _, field in ipairs(candidateFields) do
        AddMemberMatch(matchesByKey, object[field])
    end
    for _, field in ipairs(containerFields) do
        local container = object[field]
        if type(container) == "table" then
            for _, member in pairs(container) do
                if type(member) == "table" then
                    for _, memberField in ipairs(candidateFields) do
                        AddMemberMatch(matchesByKey, member[memberField])
                    end
                else
                    AddMemberMatch(matchesByKey, member)
                end
            end
        end
    end
end

local function GetResultID(row)
    local elementData
    if row and row.GetElementData then
        local ok, value = pcall(row.GetElementData, row)
        if ok then elementData = value end
    end

    local candidates = {}
    local function AddResultCandidate(value)
        if value ~= nil then candidates[#candidates + 1] = value end
    end
    AddResultCandidate(row and row.searchResultID)
    AddResultCandidate(row and row.resultID)
    AddResultCandidate(row and row.id)
    if type(elementData) == "table" then
        AddResultCandidate(elementData.searchResultID)
        AddResultCandidate(elementData.resultID)
        AddResultCandidate(elementData.id)
    end
    for _, value in ipairs(candidates) do
        if value ~= nil and not IsSecret(value) then return value, elementData end
    end
    return nil, elementData
end

local function AddAPIMatches(matchesByKey, resultID, visibleMemberCount)
    if not resultID or not C_LFGList then return end

    local memberCount = 0
    if C_LFGList.GetSearchResultInfo then
        local ok, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
        if ok and type(info) == "table" then
            AddObjectMatches(matchesByKey, info)
            memberCount = tonumber(info.numMembers or info.numGroupMembers or info.memberCount) or 0
        end
    end

    if not C_LFGList.GetSearchResultMemberInfo then return end
    local resolvedCount = memberCount > 0 and memberCount or (tonumber(visibleMemberCount) or 0)
    local limit = resolvedCount > 0 and math.min(resolvedCount, 40) or 5
    for memberIndex = 1, limit do
        local values = { pcall(C_LFGList.GetSearchResultMemberInfo, resultID, memberIndex) }
        if not values[1] or values[2] == nil then break end
        if type(values[2]) == "table" then
            AddObjectMatches(matchesByKey, values[2])
        else
            -- Forever may return the member name positionally. Every candidate
            -- must exactly match an existing iWR database entry.
            for valueIndex = 2, 18 do
                AddMemberMatch(matchesByKey, values[valueIndex])
            end
        end
    end
end

local function SortedMatches(matchesByKey)
    local matches = {}
    for _, match in pairs(matchesByKey) do matches[#matches + 1] = match end
    table.sort(matches, function(left, right)
        local leftLevel = tonumber(left.data[2]) or 0
        local rightLevel = tonumber(right.data[2]) or 0
        if leftLevel ~= rightLevel then return leftLevel < rightLevel end
        return left.name < right.name
    end)
    return matches
end

local function CollectGroupMatches(row, leaderName)
    local matchesByKey = {}
    AddMemberMatch(matchesByKey, leaderName)

    local resultID, elementData = GetResultID(row)
    AddObjectMatches(matchesByKey, elementData)
    AddObjectMatches(matchesByKey, row and row.data)

    local display = row and row.DataDisplay
    local enumerate = display and display.Enumerate
    AddObjectMatches(matchesByKey, enumerate)
    if enumerate and type(enumerate.Icons) == "table" then
        for _, icon in ipairs(enumerate.Icons) do
            AddObjectMatches(matchesByKey, icon)
            AddObjectMatches(matchesByKey, icon and icon.data)
        end
    end
    local visibleMemberCount = enumerate and type(enumerate.Icons) == "table" and #enumerate.Icons or 0
    AddAPIMatches(matchesByKey, resultID, visibleMemberCount)

    -- Names learned from Forever's native tooltip belong to the listing, not
    -- the recycled visual row. Retain them by resultID while that listing is
    -- present so subsequent refreshes do not discard the group matches.
    local cached = resultID and resultMemberCache[tostring(resultID)]
    if cached and GetTime() - (cached.seenAt or 0) < 600 then
        for _, databaseKey in ipairs(cached.keys or {}) do
            local data = iWRDatabase[databaseKey]
            if data and not matchesByKey[databaseKey] then
                matchesByKey[databaseKey] = {
                    key = databaseKey,
                    data = data,
                    name = StripColorCodes(data[4] or databaseKey),
                }
            end
        end
    end

    return SortedMatches(matchesByKey)
end

local function NativeTooltipForRow()
    local browseTooltip = _G.LFGBrowseSearchEntryTooltip
    if browseTooltip and browseTooltip:IsShown() then return browseTooltip end
    if GameTooltip and GameTooltip:IsShown() then return GameTooltip end
end

local function AddFrameTextMatches(matchesByKey, frame, depth, visited)
    if not frame or depth > 4 or visited[frame] then return end
    visited[frame] = true

    AddMemberMatch(matchesByKey, frame)
    AddObjectMatches(matchesByKey, frame)

    if frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if region and region.IsObjectType and region:IsObjectType("FontString") then
                AddMemberMatch(matchesByKey, region)
            end
        end
    end

    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            AddFrameTextMatches(matchesByKey, child, depth + 1, visited)
        end
    end
end

local function AddNativeTooltipMatches(matchesByKey, tooltip)
    if not tooltip then return end
    local visited = {}
    AddFrameTextMatches(matchesByKey, tooltip.Leader, 0, visited)

    local memberPool = tooltip.memberPool
    if memberPool and memberPool.EnumerateActive then
        for memberFrame in memberPool:EnumerateActive() do
            AddFrameTextMatches(matchesByKey, memberFrame, 0, visited)
        end
    end

    -- Also inspect direct tooltip regions/children for clients whose member
    -- frames are not pooled.
    AddFrameTextMatches(matchesByKey, tooltip, 0, visited)
end

local function AddRowTooltip(row)
    if not row or not row.IsMouseOver or not row:IsMouseOver() then return end

    local nativeTooltip = NativeTooltipForRow()

    -- Some Forever builds keep party member names private in the result API
    -- but already expose them as individual FontStrings in the native tooltip.
    -- Reading those visible labels gives us a safe final fallback on hover.
    local matchesByKey = {}
    for _, match in ipairs(row.iWRGroupFinderMatches or {}) do
        matchesByKey[match.key] = match
    end
    AddNativeTooltipMatches(matchesByKey, nativeTooltip)
    local matches = SortedMatches(matchesByKey)
    row.iWRGroupFinderMatches = matches
    if #matches == 0 then return end

    local keys = {}
    for _, match in ipairs(matches) do keys[#keys + 1] = match.key end
    row.iWRGroupFinderSignature = table.concat(keys, ",")

    local resultID = GetResultID(row)
    if resultID then
        resultMemberCache[tostring(resultID)] = {
            keys = keys,
            seenAt = GetTime(),
        }
        row.iWRGroupFinderSourceKey = tostring(resultID) .. "|" .. tostring(GetRowName(row) or "")
        row.iWRGroupFinderLastScan = GetTime()
    end

    if row.iWRGroupFinderSummary then
        local lowest = tonumber(matches[1].data[2]) or 0
        local summaryIcon = iWR:GetIcon(lowest) or "Interface\\Icons\\INV_Misc_Note_05"
        local color = iWR.Colors[lowest] or iWR.Colors.iWR
        row.iWRGroupFinderSummary:SetText(string.format(
            "|T%s:12:12:0:0|t %siWR: %d noted|r", summaryIcon, color, #matches))
        row.iWRGroupFinderSummary:Show()
    end

    local signature = row.iWRGroupFinderSignature
    if groupNoteTooltip:IsShown() and groupNoteTooltip.iWRGroupFinderSignature == signature
        and groupNoteTooltip:GetOwner() == row then return end
    groupNoteTooltip.iWRGroupFinderSignature = signature
    groupNoteTooltip:SetOwner(row, "ANCHOR_LEFT")
    groupNoteTooltip:ClearLines()

    groupNoteTooltip:AddLine(string.format(L["GroupFinderNotedMembers"] or "iWillRemember: %d noted", #matches), 1, 0.59, 0.09)
    for _, match in ipairs(matches) do
        local data = match.data
        local typeIndex = tonumber(data[2]) or 0
        local relationColor = iWR.Colors[typeIndex] or iWR.Colors.White
        local relationName = iWR:GetTypeName(typeIndex)
        local sign = typeIndex > 0 and "+" or ""
        groupNoteTooltip:AddDoubleLine(match.name, relationColor .. relationName .. " (" .. sign .. typeIndex .. ")|r",
            1, 1, 1, 1, 1, 1)
        if data[1] and data[1] ~= "" then
            groupNoteTooltip:AddLine("  " .. data[1], 0.92, 0.76, 0.35, true)
        end
        if iWRSettings.TooltipShowAuthor and data[6] and data[6] ~= "" then
            local savedDate = data[5] and data[5] ~= "" and (" (" .. data[5] .. ")") or ""
            groupNoteTooltip:AddLine("  " .. (L["DetailAuthor"] or "Author:") .. " "
                .. StripColorCodes(data[6]) .. savedDate, 0.55, 0.55, 0.55, true)
        end
    end
    groupNoteTooltip:Show()
end

local function HookRow(row)
    if not row or hookedRows[row] or not row.HookScript then return end
    hookedRows[row] = true

    row:HookScript("OnEnter", function(self)
        local resultID = GetResultID(self)
        local playerName = GetRowName(self)
        local sourceKey = tostring(resultID or "") .. "|" .. tostring(playerName or "")
        if self.iWRGroupFinderSourceKey ~= sourceKey then
            self.iWRGroupFinderMatches = nil
            self.iWRGroupFinderSignature = nil
            if self.iWRGroupFinderSummary then self.iWRGroupFinderSummary:Hide() end
        end
        C_Timer.After(0, function()
            AddRowTooltip(self)
        end)
    end)
    row:HookScript("OnLeave", function()
        groupNoteTooltip.iWRGroupFinderSignature = nil
        groupNoteTooltip:Hide()
        if GameTooltip then
            GameTooltip.iWRGroupFinderDatabaseKey = nil
            GameTooltip.iWRGroupFinderSignature = nil
        end
        if _G.LFGBrowseSearchEntryTooltip then
            _G.LFGBrowseSearchEntryTooltip.iWRGroupFinderDatabaseKey = nil
            _G.LFGBrowseSearchEntryTooltip.iWRGroupFinderSignature = nil
        end
    end)
end

local function GetGroupSummary(row)
    if row.iWRGroupFinderSummary then return row.iWRGroupFinderSummary end
    local summary = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summary:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 5)
    summary:SetJustifyH("RIGHT")
    summary:SetShadowOffset(1, -1)
    summary:Hide()
    row.iWRGroupFinderSummary = summary
    return summary
end

local function UpdateRow(row)
    HookRow(row)
    local summary = GetGroupSummary(row)

    if iWRSettings.ShowGroupFinderNotes == false then
        RestoreRowName(row)
        row.iWRGroupFinderMatches = nil
        row.iWRGroupFinderSignature = nil
        summary:Hide()
        return
    end

    local playerName = GetRowName(row)
    local resultID = GetResultID(row)
    local sourceKey = tostring(resultID or "") .. "|" .. tostring(playerName or "")
    local now = GetTime()
    local matches
    if row.iWRGroupFinderSourceKey == sourceKey and row.iWRGroupFinderMatches
        and now - (row.iWRGroupFinderLastScan or 0) < 1 then
        matches = row.iWRGroupFinderMatches
    else
        matches = CollectGroupMatches(row, playerName)
        row.iWRGroupFinderSourceKey = sourceKey
        row.iWRGroupFinderLastScan = now
    end
    row.iWRGroupFinderMatches = matches

    local databaseKey, data = FindRowEntry(row)
    if data then
        local icon = iWR:GetIcon(tonumber(data[2]) or 0)
        if icon then
            local displayName = string.format("|T%s:14:14:0:0|t %s", icon, playerName)
            row.iWRGroupFinderRawName = playerName
            row.iWRGroupFinderDisplayName = displayName
            row.iWRGroupFinderDatabaseKey = databaseKey
            if row.Name:GetText() ~= displayName then row.Name:SetText(displayName) end
        else
            RestoreRowName(row)
        end
    else
        RestoreRowName(row)
    end

    if #matches > 0 then
        local lowest = tonumber(matches[1].data[2]) or 0
        local summaryIcon = iWR:GetIcon(lowest) or "Interface\\Icons\\INV_Misc_Note_05"
        local color = iWR.Colors[lowest] or iWR.Colors.iWR
        summary:SetText(string.format("|T%s:12:12:0:0|t %siWR: %d noted|r", summaryIcon, color, #matches))
        summary:Show()

        local keys = {}
        for _, match in ipairs(matches) do keys[#keys + 1] = match.key end
        row.iWRGroupFinderSignature = table.concat(keys, ",")
    else
        summary:Hide()
        row.iWRGroupFinderSignature = nil
    end
end

function iWR:RefreshGroupFinderNotes()
    local browseFrame = _G.LFGBrowseFrame
    local scrollBox = browseFrame and browseFrame.ScrollBox
    if not scrollBox or not scrollBox.ForEachFrame or InCombatLockdown() then return end
    pcall(scrollBox.ForEachFrame, scrollBox, UpdateRow)
end

local function AttachToBrowseFrame()
    local browseFrame = _G.LFGBrowseFrame
    if not browseFrame or attachedBrowseFrame == browseFrame then return end
    attachedBrowseFrame = browseFrame

    browseFrame:HookScript("OnShow", function()
        iWR:RefreshGroupFinderNotes()
    end)

    local updater = CreateFrame("Frame", nil, browseFrame)
    updater:SetScript("OnUpdate", function(_, elapsed)
        refreshElapsed = refreshElapsed + elapsed
        if refreshElapsed < 0.15 then return end
        refreshElapsed = 0
        iWR:RefreshGroupFinderNotes()
    end)

    iWR:RefreshGroupFinderNotes()
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_REGEN_ENABLED")
loader:SetScript("OnEvent", function(_, event)
    AttachToBrowseFrame()
    if event == "PLAYER_REGEN_ENABLED" then
        iWR:RefreshGroupFinderNotes()
    end
end)
