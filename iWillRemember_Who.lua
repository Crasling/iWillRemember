local whoFrame
local refreshElapsed = 0

local function IsSecret(value)
    return value ~= nil and issecretvalue and issecretvalue(value)
end

local function Trim(value)
    if type(value) ~= "string" then return "" end
    return value:match("^%s*(.-)%s*$") or ""
end

local function RestoreLabel(label)
    if not label or not label.GetText or not label.SetText then return end
    local current = label:GetText()
    if IsSecret(current) then return end
    if label.iWRWhoDisplayText and current == label.iWRWhoDisplayText and label.iWRWhoRawText then
        label:SetText(label.iWRWhoRawText)
    end
    label.iWRWhoDisplayText = nil
    label.iWRWhoRawText = nil
    label.iWRWhoDatabaseKey = nil
end

local function GetWhoResultName(index)
    if C_FriendList and C_FriendList.GetWhoInfo then
        local ok, info = pcall(C_FriendList.GetWhoInfo, index)
        if ok and type(info) == "table" then
            local name = info.fullName or info.name or info.playerName
            if not IsSecret(name) and type(name) == "string" and name ~= "" then return name end
        end
    end

    if GetWhoInfo then
        local values = { pcall(GetWhoInfo, index) }
        if values[1] and not IsSecret(values[2]) and type(values[2]) == "string" then
            return values[2]
        end
    end
end

local function GetWhoResultCount()
    if C_FriendList and C_FriendList.GetNumWhoResults then
        local ok, count = pcall(C_FriendList.GetNumWhoResults)
        if ok and type(count) == "number" then return count end
    end
    if GetNumWhoResults then
        local ok, count = pcall(GetNumWhoResults)
        if ok and type(count) == "number" then return count end
    end
    return 0
end

local function BuildResultLookup()
    local results = {}
    for index = 1, GetWhoResultCount() do
        local name = GetWhoResultName(index)
        if name then
            local databaseKey = iWR:GetPlayerDatabaseKey(name)
            if databaseKey then
                results[databaseKey] = true
            end
        end
    end
    return results
end

local function VisitFontStrings(frame, callback, visited, depth)
    if not frame or visited[frame] or depth > 12 then return end
    visited[frame] = true

    if frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if region and region.IsObjectType and region:IsObjectType("FontString") then
                callback(region)
            end
        end
    end

    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            VisitFontStrings(child, callback, visited, depth + 1)
        end
    end
end

local function UpdateWhoIcons()
    if not whoFrame or not whoFrame:IsShown() then return end
    local resultLookup = BuildResultLookup()

    VisitFontStrings(whoFrame, function(label)
        local text = label:GetText()
        if IsSecret(text) or type(text) ~= "string" or text == "" then return end

        local rawText
        if label.iWRWhoDisplayText == text and label.iWRWhoRawText then
            rawText = label.iWRWhoRawText
        else
            label.iWRWhoDisplayText = nil
            label.iWRWhoRawText = nil
            label.iWRWhoDatabaseKey = nil
            rawText = text
        end

        local plainName = Trim(StripColorCodes(rawText))
        local databaseKey = plainName ~= "" and iWR:GetPlayerDatabaseKey(plainName)
        local data = databaseKey and resultLookup[databaseKey] and iWRDatabase[databaseKey]

        if iWRSettings.ShowWhoNotes ~= false and data then
            local iconPath = iWR:GetChatIcon(data[2])
            local displayText = string.format("|T%s:16:16:0:0|t %s", iconPath, rawText)
            if text ~= displayText then label:SetText(displayText) end
            label.iWRWhoRawText = rawText
            label.iWRWhoDisplayText = displayText
            label.iWRWhoDatabaseKey = databaseKey
        elseif label.iWRWhoDisplayText then
            RestoreLabel(label)
        end
    end, {}, 0)
end

local function AttachWhoFrame()
    if whoFrame or not _G.WhoFrame then return end
    whoFrame = _G.WhoFrame
    whoFrame:HookScript("OnShow", UpdateWhoIcons)
    whoFrame:HookScript("OnUpdate", function(_, elapsed)
        refreshElapsed = refreshElapsed + elapsed
        if refreshElapsed < 0.20 then return end
        refreshElapsed = 0
        UpdateWhoIcons()
    end)
end

function iWR:RefreshWhoNotes()
    AttachWhoFrame()
    if whoFrame then UpdateWhoIcons() end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("WHO_LIST_UPDATE")
eventFrame:SetScript("OnEvent", function()
    AttachWhoFrame()
    if whoFrame and whoFrame:IsShown() then UpdateWhoIcons() end
end)

