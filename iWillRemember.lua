-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Namespace                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Name, AddOn = ...
local Title = select(2, C_AddOns.GetAddOnInfo(Name)):gsub("%s*v?[%d%.]+$", "")
local Version = C_AddOns.GetAddOnMetadata(Name, "Version")
local Author = C_AddOns.GetAddOnMetadata(Name, "Author")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                        Libs                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iWR = LibStub("AceAddon-3.0"):NewAddon("iWR", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("iWR")
local LDBroker = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Variables                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Local Variables
local Success
local DataCache
local addonpath = "Classic"
local TempTable = {}
local DataCacheTable = {}
local DataTimeTable = {}
local iWRBase = {}
local InCombat

iWRDatabase = {}
iWRSettings = {}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Colors = {
    -- Standard Colors
    iWR = "|cffff9716",
    White = "|cFFFFFFFF",
    Black = "|cFF000000",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Blue = "|cFF0000FF",
    Yellow = "|cFFFFFF00",
    Cyan = "|cFF00FFFF",
    Magenta = "|cFFFF00FF",
    Orange = "|cFFFFA500",
    Gray = "|cFF808080",

    [10]    = "|cff80f451", -- Superior Colour
    [5]     = "|cff80f451", -- Respected Colour
    [3]     = "|cff80f451", -- Liked Colour
    [1]     = "|cff80f451", -- Neutral Colour
    [-3]    = "|cfffb9038", -- Disliked Colour
    [-5]    = "|cffff2121", -- Hated Colour

    -- WoW Class Colors
    Classes = {
        WARRIOR = "|cFFC79C6E",
        PALADIN = "|cFFF58CBA",
        HUNTER = "|cFFABD473",
        ROGUE = "|cFFFFF569",
        PRIEST = "|cFFFFFFFF",
        SHAMAN = "|cFF0070DE",
        MAGE = "|cFF40C7EB",
        WARLOCK = "|cFF8788EE",
        DRUID = "|cFFFF7D0A",
    },

    -- Reset Color
    Reset = "|r"
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                    Set Paths                                   │
-- ├──────────────────────────┬─────────────────────────────────────────────────────╯
-- │      Check what UI       │
-- ╰──────────────────────────╯
if C_AddOns.IsAddOnLoaded("EasyFrames") then
    addonpath = "EasyFrames"    -- EasyFrames path
end

-- ╭───────────────────────────────────╮
-- │      List of Targeting Frames     │
-- ╰───────────────────────────────────╯
iWRBase.TargetFrames = {
    [10]    = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Superior.blp",
    [5]     = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Respected.blp",
    [3]     = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Liked.blp",
    [1]     = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Neutral.blp",
    [-3]    = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Disliked.blp",
    [-5]    = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Hated.blp",
}

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

-- ╭────────────────────────╮
-- │      List of Icons     │
-- ╰────────────────────────╯
iWRBase.Icons = {
    iWRIcon = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\iWRIcon.blp",
    Database = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Database.blp",
    [10]    = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Superior.blp",
    [5]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Respected.blp",
    [3]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Liked.blp",
    [1]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Neutral.blp",
    [0]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Clear.blp",
    [-3]    = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Disliked.blp",
    [-5]    = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Hated.blp",
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                    Functions                                   │
-- ├───────────────────────┬────────────────────────────────────────────────────────╯
-- │      Create Note      │
-- ╰───────────────────────╯
function iWR:InputNotEmpty(Text)
    if Text ~= L["DefaultNameInput"] and Text ~= L["DefaultNoteInput"] and Text ~= "" and Text ~= nil and not string.find(Text, "^%s+$") then
        return true
    end
    return false
end

-- Add Tooltip
function iWR:AddNoteToGameTooltip(self,...)
    local name, unit = self:GetUnit();
    if (not unit) then
        local mFocus = GetMouseFocus();
        if (mFocus) and (mFocus.unit) then
            unit = mFocus.unit;
        else
            return
        end
    end

    if (UnitIsPlayer(unit)) then    
        if iWRDatabase[tostring(name)] then
            -- Add the type icon and note to the tooltip
            local iconPath = iWRBase.Icons[tonumber(iWRDatabase[tostring(name)][2])]
            if iconPath then
                local icon = "|T" .. iconPath .. ":16:16:0:0|t" -- Create the icon string (16x16 size)
                GameTooltip:AddLine(Colors.iWR .. L["NoteToolTip"] .. icon .. Colors[tonumber(iWRDatabase[tostring(name)][2])]  .. " " ..  tostring(iWRBase.Types[iWRDatabase[tostring(name)][2]]) .. "|r" .. " "  .. icon)
            else
                GameTooltip:AddLine(Colors.iWR ..  L["NoteToolTip"] .. tostring(iWRBase.Types[iWRDatabase[tostring(name)][2]]) .. "|r")
            end
            if iWRDatabase[tostring(name)][1] and iWRDatabase[tostring(name)][1] ~= "" then
                GameTooltip:AddLine(Colors.iWR .. "Note: " .. Colors[tonumber(iWRDatabase[tostring(name)][2])] .. tostring(iWRDatabase[tostring(name)][1]) .. "|r")
            end
        end
    end
end

-- ╭───────────────────────────╮
-- │      Timestamp Compare    │
-- ╰───────────────────────────╯
local function IsNeedToUpdate(CurrDataTime, CompDataTime)
    if tonumber(CurrDataTime) < tonumber(CompDataTime) then
        return true
    end
end

-- ╭────────────────────────────╮
-- │      Get Current Time      │
-- ╰────────────────────────────╯
local function GetCurrentTimeByHours()
    -- Extract current time components
    local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
    -- Calculate the current time in hours
    local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay) * 24 + tonumber(CurrMonth) * 720 + tonumber(CurrYear) * 8640
    -- Format the current date as YYYY-MM-DD
    local CurrentDate = string.format("20".."%02d-%02d-%02d", tonumber(CurrYear), tonumber(CurrMonth), tonumber(CurrDay))
    -- Return both the current time in hours and the formatted current date
    return tonumber(CurrentTime), CurrentDate
end

-- ╭──────────────────────────────╮
-- │      Update the Tooltip      │
-- ╰──────────────────────────────╯
function iWR:UpdateTooltip()
    local tooltip = GameTooltip
    if tooltip:IsVisible() then
        tooltip:Hide() -- Hide it first
        tooltip:Show() -- Trigger it to show again with updated info
    end
end

-- ╭──────────────────────────────────────────────╮
-- │      Sending Latest Note to Friendslist      │
-- ╰──────────────────────────────────────────────╯
function iWR:SendNewDBUpdateToFriends()
    -- Loop through all friends in the friend list
    for i = 1, C_FriendList.GetNumFriends() do
        -- Get friend's info (which includes friendName)
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        -- Extract the friend's name from the table
        local friendName = friendInfo and friendInfo.name
        -- Ensure friendName is valid before printing
        if friendName then
            iWR:SendCommMessage("iWRNewDBUpdate", DataCache, "WHISPER", friendName)
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: Successfully shared new note to: " .. friendName)
            end
        else
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: No friend found at index " .. i)
            end
        end
    end
end

-- ╭────────────────────────────────────────────╮
-- │      Sending All Notes to Friendslist      │
-- ╰────────────────────────────────────────────╯
function iWR:SendFullDBUpdateToFriends()
    -- Loop through all friends in the friend list
    for i = 1, C_FriendList.GetNumFriends() do
        -- Get friend's info (which includes friendName)
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        -- Extract the friend's name from the table
        local friendName = friendInfo and friendInfo.name
        -- Ensure friendName is valid before printing
        if friendName then
            wipe(DataTimeTable)
            local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
            local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay)*24 + tonumber(CurrMonth)*720 + tonumber(CurrYear)*8640
            for k,v in pairs(iWRDatabase) do
                if (iWRDatabase[k][3] - CurrentTime) > -800 then --// Update only recent 33 days (800 h)
                    DataTimeTable[k] = iWRDatabase[k]
                end
            end       
            TimeTableToSend = iWR:Serialize(DataTimeTable)
            iWR:SendCommMessage("iWRFullDBUpdate", TimeTableToSend, "WHISPER", friendName)
        end
    end
end

local function splitOnSpace(text, maxLength)
    -- Find the position of the last space within the maxLength
    local spacePos = text:sub(1, maxLength):match(".*() ")
    if not spacePos then
        spacePos = maxLength -- If no space is found, split at maxLength
    end
    return text:sub(1, spacePos), text:sub(spacePos + 1)
end

-- ╭────────────────────────────────────╮
-- │      Strip Color Codes Function    │
-- ╰────────────────────────────────────╯
local function StripColorCodes(input)
    return input:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end

-- ╭──────────────────────────────────╮
-- │      Full Database Update        │
-- ╰──────────────────────────────────╯
function iWR:OnFullDBUpdate(prefix, message, distribution, sender)
    -- Check if the sender is the player itself
    if GetUnitName("player", false) == sender then return end

    -- Verify the sender is on the friends list
    local isFriend = false
    local numFriends = C_FriendList.GetNumFriends()
    for i = 1, numFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.name == sender then
            isFriend = true
            break
        end
    end

    -- If the sender is not a friend, skip processing
    if not isFriend then
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Sender " .. sender .. " is not on the friends list. Ignoring update.")
        end
        return
    end

    -- Deserialize the message
    Success, FullNotesTable = iWR:Deserialize(message)
    if not Success then
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: OnFullDBUpdate Error")
        end
    else
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Data received from: " .. sender)
        end
        for k, v in pairs(FullNotesTable) do
            if iWRDatabase[k] then
                if IsNeedToUpdate((iWRDatabase[k][3]), v[3]) then
                    iWRDatabase[k] = v
                end
            else
                iWRDatabase[k] = v
            end
        end

        local targetName = UnitName("target")
        if targetName and targetName ~= "" and NoteName == targetName then
            TargetFrame_Update(TargetFrame)
        end

        iWR:PopulateDatabase()
        iWR:UpdateTooltip()
    end
end


-- ╭──────────────────────────────────╮
-- │      New Database Update         │
-- ╰──────────────────────────────────╯
function iWR:OnNewDBUpdate(prefix, message, distribution, sender)
    -- Check if the sender is the player itself
    if GetUnitName("player", false) == sender then return end

    -- Verify the sender is on the friends list
    local isFriend = false
    local numFriends = C_FriendList.GetNumFriends()
    for i = 1, numFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.name == sender then
            isFriend = true
            break
        end
    end

    -- If the sender is not a friend, skip processing
    if not isFriend then
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Sender " .. sender .. " is not on the friends list. Ignoring update.")
        end
        return
    end

    -- Deserialize the message
    Success, TempTable = iWR:Deserialize(message)
    if not Success then
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: OnNewDBUpdate Error")
        end
    else
        for k, v in pairs(TempTable) do
            iWRDatabase[k] = v
        end

        local targetName = UnitName("target")
        if targetName and targetName ~= "" and NoteName == targetName then
            TargetFrame_Update(TargetFrame)
        end

        iWR:PopulateDatabase()
        iWR:UpdateTooltip()

        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Data received from: " .. sender)
        end
    end

    -- Clean up the temporary table
    wipe(TempTable)
end


-- ╭────────────────────────────────────────╮
-- │      Colorize Player Name by Class     │
-- ╰────────────────────────────────────────╯
local function ColorizePlayerNameByClass(playerName, class)
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
    if not iWRDatabase[GetUnitName("target", false)] then
        if UnitExists("target") and UnitIsPlayer("target") then
            local playerName = UnitName("target")
            local _, class = UnitClass("target")
            if class then
                iWRNameInput:SetText(ColorizePlayerNameByClass(playerName, class))
            else
                iWRNameInput:SetText(playerName)
            end
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: Player [|r" .. Colors.Classes[class] .. playerName .. "|r|cffff9716] was not found in Database")
            end
        end
        return
    end

    if iWRDatabase[tostring(GetUnitName("target", false))][2] ~= 0 then
        if UnitExists("target") and UnitIsPlayer("target") then
            local playerName = UnitName("target")
            local _, class = UnitClass("target")
            if class then
                iWRNameInput:SetText(ColorizePlayerNameByClass(playerName, class))
            else
                iWRNameInput:SetText(playerName)
            end
            TargetFrameTextureFrameTexture:SetTexture(iWRBase.TargetFrames[iWRDatabase[tostring(GetUnitName("target", false))][2]]);
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: Player [|r" .. Colors.Classes[class] .. playerName .. "|r|cffff9716] was found in Database")
            end
        end
    end
end

local function AddRelationshipIconToChat(self, event, message, author, flags, ...)
    -- Extract the base player name without the realm
    local authorName = string.match(author, "^[^-]+") or author

    -- Check if the author exists in your database
    if iWRDatabase[authorName] then
        local iconPath = iWRBase.Icons[iWRDatabase[authorName][2]] or "Interface\\Icons\\INV_Misc_QuestionMark"
        local iconString = "|T" .. iconPath .. ":12|t"
        flags = iconString
    end

    -- Return the modified message and the original author
    return false, message, author, flags, ...
end

local function RegisterChatFilters()
    local events = {
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_RAID",
        "CHAT_MSG_WHISPER",
    }

    for _, event in ipairs(events) do
        ChatFrame_AddMessageEventFilter(event, AddRelationshipIconToChat)
    end
end

-- ╭──────────────────────────────╮
-- │      Toggle Menu Window      │
-- ╰──────────────────────────────╯
function iWR:MenuToggle()
    if not InCombat then
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
function iWR:MenuOpen(Name)
    if not InCombat then
        iWRPanel:Show()
        iWRNameInput:SetText(L["DefaultNameInput"])
        iWRNoteInput:SetText(L["DefaultNoteInput"])
        if UnitExists("target") and UnitIsPlayer("target") then
            local playerName = UnitName("target")
            local _, class = UnitClass("target")
            if class then
                iWRNameInput:SetText(ColorizePlayerNameByClass(playerName, class))
            else
                iWRNameInput:SetText(playerName)
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
    if not InCombat then
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
    if not InCombat then
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
            iWRNameInput:SetText(ColorizePlayerNameByClass(playerName, class))
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
    if iWR:InputNotEmpty(Name) then
        if iWR:InputNotEmpty(Note) then
            local playerName = GetUnitName("player")
            iWR:CreateNote(Name, tostring(Note), Type)
        else
            iWR:CreateNote(Name, "", Type)
        end
        iWR:PopulateDatabase()
    else
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: NameInput error: [|r" .. (Name or "nil") .. "|cffff9716]")
        end
    end
end

-- ╭──────────────────────╮
-- │      Clear Note      │
-- ╰──────────────────────╯
function iWR:ClearNote(Name)
    if iWR:InputNotEmpty(Name) then
        -- Remove color codes from the name
        local uncoloredName = StripColorCodes(Name)

        if iWRDatabase[uncoloredName] then
            -- Remove the entry from the database
            iWRDatabase[uncoloredName] = nil
            iWR:PopulateDatabase()

            local targetName = UnitName("target")
            if uncoloredName == targetName then
                TargetFrame_Update(TargetFrame)
            end

            print(L["CharNoteStart"] .. Name .. "|cffff9716] removed from database.")
        else
            -- Notify that the name was not found in the database
            print("|cffff9716[iWR]: Name [|r" .. Name .. "|cffff9716] does not exist in the database.")
        end
    else
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: NameInput error: [|r" .. (Name or "nil") .. "|cffff9716]")
        end
    end
end


-- ╭───────────────────────────╮
-- │      Create New Note      │
-- ╰───────────────────────────╯
function iWR:CreateNote(Name, Note, Type)
    if DebugMsg then
        print("|cffff9716[iWR]: DEBUG: New note Name: [|r" .. Name .. "|cffff9716]")
        print("|cffff9716[iWR]: DEBUG: New note Note: [|r" .. Note .. "|cffff9716]")
        print("|cffff9716[iWR]: DEBUG: New note Type: [|r" .. Type .. "|cffff9716]")
    end

    local colorCode = string.match(Name, "|c%x%x%x%x%x%x%x%x")
    local NoteAuthor 
    local playerName = UnitName("player")
    local _, class = UnitClass("player")
    if class then
        NoteAuthor = ColorizePlayerNameByClass(playerName, class)
    else
        NoteAuthor = playerName
    end
    -- Remove color codes from the name
    local uncoloredName = StripColorCodes(Name)

        local upperName = uncoloredName:upper()
        local lowerName = uncoloredName:lower()
        local capitalizedName = upperName:sub(1, 1) .. lowerName:sub(2)

        -- Use the modified name
        NoteName = capitalizedName

        local currentTime, currentDate = GetCurrentTimeByHours()
    -- Save to database using uncolored name
    iWRDatabase[NoteName] = {
        Note,
        Type,
        currentTime,
        Name,
        currentDate,
        NoteAuthor,
    }

    local targetName = UnitName("target")
    if NoteName == targetName then
        TargetFrame_Update(TargetFrame)
    end

    if iWRSettings.DataSharing ~= false then
        wipe(DataCacheTable)
        DataCacheTable[tostring(NoteName)] = {
            Note,
            Type,
            currentTime,
            Name,
            currentDate,
            NoteAuthor,
        }
        DataCache = iWR:Serialize(DataCacheTable)
        iWR:SendNewDBUpdateToFriends()
    end
    if colorCode ~= nil then 
        print(L["CharNoteStart"] .. colorCode .. NoteName .. L["CharNoteEnd"])
    else
        print(L["CharNoteStart"] .. NoteName .. L["CharNoteEnd"])
    end
end


-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                      Frames                                    │
-- ├─────────────────────────────┬──────────────────────────────────────────────────╯
-- │      Create Main Panel      │
-- ╰─────────────────────────────╯
iWRPanel = CreateFrame("Frame", "SettingsMenu", UIParent, "BackdropTemplate")

iWRPanel:SetSize(350, 250)
iWRPanel:Hide()
iWRPanel:SetPoint("CENTER", UIParent, "CENTER")
iWRPanel:EnableMouse()
iWRPanel:SetMovable(true)
iWRPanel:SetFrameStrata("MEDIUM")
iWRPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
iWRPanel:RegisterForDrag("LeftButton", "RightButton")
iWRPanel:SetClampedToScreen(true)
iWRPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
iWRPanel:SetBackdropColor(0, 0, 0, 1) -- Background color
iWRPanel:SetBackdropBorderColor(1, 1, 1, 1) -- Border color

-- ╭──────────────────────────────────╮
-- │      Create Main Panel title     │
-- ╰──────────────────────────────────╯
local titleBar = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
titleBar:SetHeight(30)
titleBar:SetPoint("TOP", iWRPanel, "TOP", 0, 0)
titleBar:SetWidth(iWRPanel:GetWidth())
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1)

-- ╭─────────────────────────────────╮
-- │      Main Panel title text      │
-- ╰─────────────────────────────────╯
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
titleText:SetText("iWillRemember Menu v" .. Version)
titleText:SetTextColor(1, 1, 1, 1) -- White text

-- ╭───────────────────────────────────╮
-- │      Main Panel close button      │
-- ╰───────────────────────────────────╯
local closeButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", iWRPanel, "TOPRIGHT", -5, -5)
closeButton:SetText("X")
closeButton:SetScript("OnClick", function()
    iWR:MenuClose()
end)

-- ╭───────────────────────────────────────────╮
-- │      Main Panel Name And Note Inputs      │
-- ╰───────────────────────────────────────────╯
local playerNameTitle = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playerNameTitle:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
playerNameTitle:SetText("Player Name")
playerNameTitle:SetTextColor(1, 1, 1, 1)

iWRNameInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNameInput:SetSize(150, 30)
iWRNameInput:SetPoint("TOP", playerNameTitle, "BOTTOM", 0, -1)
iWRNameInput:SetMaxLetters(20)
iWRNameInput:SetAutoFocus(false)
iWRNameInput:SetTextColor(1, 1, 1, 1)
iWRNameInput:SetText(L["DefaultNameInput"])
iWRNameInput:SetJustifyH("CENTER")  -- Center horizontally
iWRNameInput:SetJustifyV("MIDDLE")  -- Center vertically

-- Clear the text when focused and it matches the default text
iWRNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNameInput"] then
        self:SetText("")  -- Clear the default text
    end
end)

-- Reset to default text if left empty
iWRNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetText(L["DefaultNameInput"])  -- Reset to default text
    end
end)

local noteTitle = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
noteTitle:SetPoint("TOP", iWRNameInput, "BOTTOM", 0, -10)
noteTitle:SetText("Personalized note about chosen player")
noteTitle:SetTextColor(1, 1, 1, 1) -- White text

iWRNoteInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNoteInput:SetSize(250, 30)
iWRNoteInput:SetPoint("TOP", noteTitle, "BOTTOM", 0, -3)
iWRNoteInput:SetMultiLine(false)
iWRNoteInput:SetMaxLetters(66)
iWRNoteInput:SetAutoFocus(false)
iWRNoteInput:SetTextColor(1, 1, 1, 1)
iWRNoteInput:SetText(L["DefaultNoteInput"])

-- Clear the text when focused and it matches the default text
iWRNoteInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNoteInput"] then
        self:SetText("")  -- Clear the default text
    end
end)

-- Reset to default text if left empty
iWRNoteInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetText(L["DefaultNoteInput"])  -- Reset to default text
    end
end)

-- ╭────────────────────────────────────────────╮
-- │      Add Help Icon with Tooltip Below      │
-- │               the Title Bar               │
-- ╰────────────────────────────────────────────╯
local helpIcon = CreateFrame("Button", nil, iWRPanel)
helpIcon:SetSize(20, 20)
helpIcon:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -10, -5)

-- Add the question mark icon texture
local helpIconTexture = helpIcon:CreateTexture(nil, "ARTWORK")
helpIconTexture:SetAllPoints(helpIcon)
helpIconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

-- Create a tooltip for the help icon
helpIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("How do I use iWillRemember", 1, 1, 1)
    GameTooltip:AddLine(L["HelpUse"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpSync"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpClear"], 1, 0.82, 0, true)
    GameTooltip:Show()
end)

helpIcon:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)


-- Create a transparent frame to detect clicks outside the edit boxes
local clickAwayFrame = CreateFrame("Frame", nil, UIParent)
clickAwayFrame:SetAllPoints(UIParent) -- Cover the entire screen
clickAwayFrame:EnableMouse(true) -- Enable mouse detection
clickAwayFrame:Hide() -- Initially hidden

-- On click, unfocus both edit boxes
clickAwayFrame:SetScript("OnMouseDown", function()
    iWRNameInput:ClearFocus()
    iWRNoteInput:ClearFocus()
    clickAwayFrame:Hide() -- Hide the frame after the click
end)

-- Show the frame when the edit boxes gain focus
local function OnFocusGained()
    clickAwayFrame:Show()
end

-- Hook focus gained for both edit boxes
iWRNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNameInput"] then
        self:SetText("") -- Clear default text
    end
    OnFocusGained()
end)

iWRNoteInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNoteInput"] then
        self:SetText("") -- Clear default text
    end
    OnFocusGained()
end)

-- Reset to default text if left empty
iWRNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetText(L["DefaultNameInput"])
    end
end)

iWRNoteInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetText(L["DefaultNoteInput"])
    end
end)

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Hated      │
-- ╰─────────────────────────────────────╯
local button1 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button1:SetSize(53, 62)
button1:SetPoint("TOP", iWRNoteInput, "BOTTOM", 120, -10)
button1:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Hated"])

end)

-- Add an icon to the button using the iWRBase.Icons table
local iconTexture1 = button1:CreateTexture(nil, "ARTWORK")
iconTexture1:SetSize(45, 45)
iconTexture1:SetPoint("CENTER", button1, "CENTER", 0, 0)
iconTexture1:SetTexture(iWRBase.Icons[iWRBase.Types["Hated"]])

-- Add a label below the button
local button1Label = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
button1Label:SetPoint("TOP", button1, "BOTTOM", 0, -5)
button1Label:SetText("Hated")

-- ╭────────────────────────────────────────╮
-- │      Main Panel Set Type Disliked      │
-- ╰────────────────────────────────────────╯
local button2 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button2:SetSize(53, 62)
button2:SetPoint("TOP", iWRNoteInput, "BOTTOM", 60, -10)
button2:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Disliked"])
end)

-- Add an icon to button 2
local iconTexture2 = button2:CreateTexture(nil, "ARTWORK")
iconTexture2:SetSize(45, 45)
iconTexture2:SetPoint("CENTER", button2, "CENTER", 0, 0)
iconTexture2:SetTexture(iWRBase.Icons[iWRBase.Types["Disliked"]])

-- Add a label below the button
local button2Label = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
button2Label:SetPoint("TOP", button2, "BOTTOM", 0, -5)
button2Label:SetText("Disliked")

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Liked      │
-- ╰─────────────────────────────────────╯
local button3 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button3:SetSize(53, 62)
button3:SetPoint("TOP", iWRNoteInput, "BOTTOM", 0, -10)
button3:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Liked"])
end)

-- Add an icon to button 3
local iconTexture3 = button3:CreateTexture(nil, "ARTWORK")
iconTexture3:SetSize(45, 45)
iconTexture3:SetPoint("CENTER", button3, "CENTER", 0, 0)
iconTexture3:SetTexture(iWRBase.Icons[iWRBase.Types["Liked"]])

-- Add a label below the button
local button3Label = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
button3Label:SetPoint("TOP", button3, "BOTTOM", 0, -5)
button3Label:SetText("Liked")

-- ╭─────────────────────────────────────────╮
-- │      Main Panel Set Type Respected      │
-- ╰─────────────────────────────────────────╯
local button4 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button4:SetSize(53, 62)
button4:SetPoint("TOP", iWRNoteInput, "BOTTOM", -60, -10)
button4:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Respected"])
end)

-- Add an icon to button 4
local iconTexture4 = button4:CreateTexture(nil, "ARTWORK")
iconTexture4:SetSize(45, 45)
iconTexture4:SetPoint("CENTER", button4, "CENTER", 0, 0)
iconTexture4:SetTexture(iWRBase.Icons[iWRBase.Types["Respected"]])

-- Add a label below the button
local button4Label = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
button4Label:SetPoint("TOP", button4, "BOTTOM", 0, -5)
button4Label:SetText("Respected")

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Clear      │
-- ╰─────────────────────────────────────╯
local button5 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button5:SetSize(53, 62)
button5:SetPoint("TOP", iWRNoteInput, "BOTTOM", -120, -10)
button5:SetScript("OnClick", function()
    iWR:ClearNote(iWRNameInput:GetText())
end)

-- Add an icon to button 5
local iconTexture5 = button5:CreateTexture(nil, "ARTWORK")
iconTexture5:SetSize(45, 45)
iconTexture5:SetPoint("CENTER", button5, "CENTER", 0, 0)
iconTexture5:SetTexture(iWRBase.Icons[iWRBase.Types["Clear"]])

-- Add a label below the button
local button5Label = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
button5Label:SetPoint("TOP", button5, "BOTTOM", 0, -5)
button5Label:SetText("Clear")

-- ╭────────────────────────────────────────╮
-- │      Button to Open the Database       │
-- ╰────────────────────────────────────────╯
local openDatabaseButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
openDatabaseButton:SetSize(34, 34)
openDatabaseButton:SetPoint("TOP", iWRNameInput, "BOTTOM", -140, 45)
openDatabaseButton:SetScript("OnClick", function()
    iWR:DatabaseToggle()
    iWR:PopulateDatabase()
end)

-- Add an icon to the openDatabaseButton
local iconTextureDB = openDatabaseButton:CreateTexture(nil, "ARTWORK")
iconTextureDB:SetSize(25, 25)
iconTextureDB:SetPoint("CENTER", openDatabaseButton, "CENTER", 0, 0)
iconTextureDB:SetTexture(iWRBase.Icons.Database)

-- Add a label below the button
local openDatabaseButtonLabel = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
openDatabaseButtonLabel:SetPoint("TOP", openDatabaseButton, "BOTTOM", 0, -5)
openDatabaseButtonLabel:SetText("Open DB")


-- Create a new frame to display the database
iWRDatabaseFrame = CreateFrame("Frame", "DatabaseFrame", UIParent, "BackdropTemplate")
iWRDatabaseFrame:SetSize(400, 500)
iWRDatabaseFrame:Hide()
iWRDatabaseFrame:SetPoint("CENTER", UIParent, "CENTER")
iWRDatabaseFrame:EnableMouse()
iWRDatabaseFrame:SetMovable(true)
iWRDatabaseFrame:SetFrameStrata("MEDIUM")
iWRDatabaseFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
iWRDatabaseFrame:RegisterForDrag("LeftButton", "RightButton")
iWRDatabaseFrame:SetClampedToScreen(true)
iWRDatabaseFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
iWRDatabaseFrame:SetBackdropColor(0, 0, 0, 1) -- Background color
iWRDatabaseFrame:SetBackdropBorderColor(1, 1, 1, 1) -- Border color

-- Create the title bar for the database frame
local dbTitleBar = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbTitleBar:SetHeight(30)
dbTitleBar:SetPoint("TOP", iWRDatabaseFrame, "TOP", 0, 0)
dbTitleBar:SetWidth(iWRDatabaseFrame:GetWidth())

-- Set title bar background and border
dbTitleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
dbTitleBar:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Dark gray background

-- Add title text to the database title bar
local dbTitleText = dbTitleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dbTitleText:SetPoint("CENTER", dbTitleBar, "CENTER", 0, 0)
dbTitleText:SetText("iWillRemember Personal Database")
dbTitleText:SetTextColor(1, 1, 1, 1) -- White text

-- Create a scrollable frame to list database entries
local dbScrollFrame = CreateFrame("ScrollFrame", nil, iWRDatabaseFrame, "UIPanelScrollFrameTemplate")
dbScrollFrame:SetPoint("TOP", dbTitleBar, "BOTTOM", -20, -5)
dbScrollFrame:SetSize(350, 420)

-- Create a container for the database entries (this will be scrollable)
local dbContainer = CreateFrame("Frame", nil, dbScrollFrame)
dbContainer:SetSize(360, 500) -- Make sure it's larger than the scroll area
dbScrollFrame:SetScrollChild(dbContainer)

-- Create a close button for the database frame
local dbCloseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelButtonTemplate")
dbCloseButton:SetSize(20, 20)
dbCloseButton:SetPoint("TOPRIGHT", iWRDatabaseFrame, "TOPRIGHT", -5, -5)
dbCloseButton:SetText("X")
dbCloseButton:SetScript("OnClick", function()
    iWR:DatabaseClose()
end)

-- ╭─────────────────────────────────────────╮
-- │      Function to Populate Database      │
-- ╰─────────────────────────────────────────╯
function iWR:PopulateDatabase()
    -- Clear the container first by hiding all existing child frames
    for _, child in ipairs({dbContainer:GetChildren()}) do
        child:Hide()
    end

    -- Categorize entries
    local categorizedData = {}
    for playerName, data in pairs(iWRDatabase) do
        local category = data[2] or "Uncategorized"
        categorizedData[category] = categorizedData[category] or {}
        table.insert(categorizedData[category], { name = playerName, data = data })
    end

    -- Sort categories and entries alphabetically (descending)
    local sortedCategories = {}
    for category in pairs(categorizedData) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories, function(a, b)
        return a > b -- Reverse alphabetical for categories
    end)

    for _, category in ipairs(sortedCategories) do
        table.sort(categorizedData[category], function(a, b)
            return a.name < b.name
        end)
    end

    -- Iterate over categorized data and create entries
    local yOffset = -5
    for _, category in ipairs(sortedCategories) do
        -- Add category label
        local categoryLabel = dbContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        categoryLabel:SetPoint("TOPLEFT", dbContainer, "TOPLEFT", 5, yOffset)
        yOffset = yOffset - 20

        for _, entry in ipairs(categorizedData[category]) do
            local playerName, data = entry.name, entry.data

            -- Create a frame to hold the player name, icon, and buttons
            local entryFrame = CreateFrame("Frame", nil, dbContainer)
            entryFrame:SetSize(340, 30)
            entryFrame:SetPoint("TOP", dbContainer, "TOP", 0, yOffset)

            -- Add the icon for the type
            local iconTexture = entryFrame:CreateTexture(nil, "ARTWORK")
            iconTexture:SetSize(20, 20)
            iconTexture:SetPoint("LEFT", entryFrame, "LEFT", 5, 0)

            -- Set the icon texture based on the type in `iWRBase.Types`
            local typeIcon = iWRBase.Icons[data[2]]
            if typeIcon then
                iconTexture:SetTexture(typeIcon)
            else
                iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback icon if no match is found
            end

            -- Truncate the note if it exceeds the character limit
            local truncatedNote = StripColorCodes(data[1])
            if truncatedNote and #truncatedNote > 15 then
                truncatedNote = truncatedNote:sub(1, 12) .. "..."
            end

            -- Create the player name text with truncated note
            local playerNameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            playerNameText:SetPoint("LEFT", iconTexture, "RIGHT", 5, 0)
            if data[1] ~= "" then
                playerNameText:SetText(data[4] .. Colors.iWR .. " (" .. Colors[data[2]] .. truncatedNote .. Colors.iWR .. ")")
            else
                playerNameText:SetText(data[4])
            end
            playerNameText:SetTextColor(1, 1, 1, 1) -- White text

            -- Tooltip functionality
            entryFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(entryFrame, "ANCHOR_RIGHT")
                GameTooltip:AddLine(data[4], 1, 1, 1) -- Title (Player Name)
                if #data[1] <= 30 then
                    GameTooltip:AddLine("Note: " .. Colors[data[2]] .. data[1], 1, 0.82, 0) -- Add note in tooltip
                else
                    local firstLine, secondLine = splitOnSpace(data[1], 30) -- Split text on the nearest space
                    GameTooltip:AddLine("Note: " .. Colors[data[2]] .. firstLine, 1, 0.82, 0) -- Add first line
                    GameTooltip:AddLine(Colors[data[2]] .. secondLine, 1, 0.82, 0) -- Add second line
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

            -- Create the Edit button for each player
            local editButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
            editButton:SetSize(50, 30)
            editButton:SetPoint("RIGHT", entryFrame, "RIGHT", -60, 0)
            editButton:SetText("Edit")

            -- Store playerName and note in the button
            editButton.playerName = data[4]
            editButton.note = data[1]

            -- OnClick event to set inputs and open the menu
            editButton:SetScript("OnClick", function(self)
                iWR:MenuOpen(self.playerName)
                iWRNameInput:SetText(self.playerName)
                iWRNoteInput:SetText(self.note or "")
            end)

            -- Create the Remove button for each player
            local removeButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
            removeButton:SetSize(60, 30)
            removeButton:SetPoint("RIGHT", entryFrame, "RIGHT", 0, 0)
            removeButton:SetText("Remove")
            removeButton:SetScript("OnClick", function()
                StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                    text = "Are you sure you want to remove " .. playerName .. " from the database?",
                    button1 = "Yes",
                    button2 = "No",
                    OnAccept = function()
                        iWRDatabase[playerName] = nil
                        print(L["CharNoteStart"] .. playerName .. "|cffff9716] removed from database.")
                        iWR:PopulateDatabase()
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                    preferredIndex = 3,
                }
                StaticPopup_Show("REMOVE_PLAYER_CONFIRM")
            end)

            -- Add a divider below the current entry
            local divider = entryFrame:CreateTexture(nil, "BACKGROUND")
            divider:SetPoint("BOTTOMLEFT", entryFrame, "BOTTOMLEFT", 0, -2)
            divider:SetPoint("BOTTOMRIGHT", entryFrame, "BOTTOMRIGHT", 0, -2)
            divider:SetHeight(1)
            divider:SetColorTexture(0.3, 0.3, 0.3, 1)

            yOffset = yOffset - 40
        end
    end
end

-- ╭──────────────────────────────────────────────────╮
-- │      Create the "Clear All" Database Button      │
-- ╰──────────────────────────────────────────────────╯
local clearDatabaseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelButtonTemplate")
clearDatabaseButton:SetSize(100, 30)
clearDatabaseButton:SetPoint("BOTTOM", iWRDatabaseFrame, "BOTTOM", -60, 10)
clearDatabaseButton:SetText("Clear All")
clearDatabaseButton:SetScript("OnClick", function()
    -- Confirm before clearing the database
    StaticPopupDialogs["CLEAR_DATABASE_CONFIRM"] = {
        text = "Are you sure you want to clear all data in the database?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            -- Clear the database
            iWRDatabase = {}
            print("|cffff9716[iWR]: Database cleared.")
            -- Refresh the display
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
local shareDatabaseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelButtonTemplate")
shareDatabaseButton:SetSize(100, 30)
shareDatabaseButton:SetPoint("BOTTOM", iWRDatabaseFrame, "BOTTOM", 60, 10)
shareDatabaseButton:SetText("Share Full DB")
shareDatabaseButton:SetScript("OnClick", function()
    -- Check if the database is empty
    if not next(iWRDatabase) then
        print("|cffff9716[iWR]: The database is empty. Nothing to share.")
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
            print("|cffff9716[iWR]: Full database shared.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SHARE_DATABASE_CONFIRM")
end)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Event Handlers                                │
-- ├──────────────────────┬─────────────────────────────────────────────────────────╯
-- │      On Startup      │
-- ╰──────────────────────╯
function iWR:OnEnable()
    -- Secure hooks to add custom behavior
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update", "SetTargetingFrame")
    
    -- Activate DataSharing
    iWR:RegisterComm("iWRFullDBUpdate", "OnFullDBUpdate")
    iWR:RegisterComm("iWRNewDBUpdate", "OnNewDBUpdate")

    local playerName = GetUnitName("player")

    if playerName == false then
        DebugMsg = true
        print(L["DevLoad"])
    else
        DebugMsg = false
    end
    

    -- Print a message to the chat frame when the addon is loaded
    print(L["iWRLoaded"] .. " v" .. Version)

    -- Create the main launcher button
    LDBroker:NewDataObject("iWillRemember_DataObject", {
        type = "launcher",
        text = "iWillRemember",
        icon = iWRBase.Icons.iWRIcon,
        OnClick = function(clickedframe, button)

        end,
    })

-- Create the minimap button (DataObject for the minimap button)
local minimapButton = LDBroker:NewDataObject("iWillRemember_MinimapButton", {
    type = "data source",
    text = "iWillRemember",
    icon = iWRBase.Icons.iWRIcon,
    OnClick = function(self, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            iWR:DatabaseToggle()
            iWR:PopulateDatabase()
        elseif button == "LeftButton" then
            iWR:MenuToggle()
        elseif button == "RightButton" then
            --Nothing
        end
    end,

    -- Tooltip handling
    OnTooltipShow = function(tooltip)
        -- Name
        tooltip:SetText("|cffff9716iWillRemember v" .. Version, 1, 1, 1)

        -- Desc
        tooltip:AddLine(" ", 1, 1, 1) 
        tooltip:AddLine(L["MinimapButtonLeftClick"], 1, 1, 1)
        tooltip:AddLine(L["MinimapButtonShiftLeftClick"], 1, 1, 1)

        -- Make visible
        tooltip:Show()  -- Make sure the tooltip is displayed
    end,
    })

    -- Register the minimap button with LibDBIcon
    LDBIcon:Register("iWillRemember_MinimapButton", minimapButton, {
        hide = false,
        lock = false,
        minimapPos = -30,
        radius = 80,
    })

-- Function to modify the right-click menu for a given context
local function ModifyMenuForContext(menuType)
    Menu.ModifyMenu(menuType, function(ownerRegion, rootDescription, contextData)
        -- Retrieve the name of the player for whom the menu is opened
        local playerName = contextData.name
        local unitToken = contextData.unitToken

        -- Check if playerName is available and valid
        if playerName then
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: Right-click menu opened for:", playerName)
            end
        else
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: No player name found for menu type:", menuType)
            end
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

-- Call to register filters
RegisterChatFilters()
-- Modify the right-click menu for players
ModifyMenuForContext("MENU_UNIT_PLAYER")
ModifyMenuForContext("MENU_UNIT_PARTY")
ModifyMenuForContext("MENU_UNIT_RAID_PLAYER")
ModifyMenuForContext("MENU_UNIT_ENEMY_PLAYER")
end

-- ╭────────────────────────────────────────────╮
-- │      Event Handler for Combat Events      │
-- ╰────────────────────────────────────────────╯
local combatEventFrame = CreateFrame("Frame")
InCombat = false
combatEventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        InCombat = true
        iWRPanel:Hide()
        iWRDatabaseFrame:Hide()
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Entered combat, UI interaction disabled.")
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        InCombat = false
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Left combat, UI interaction enabled.")
        end
    end
end)
combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- ╭──────────────────────────────────╮
-- │      Event Handler for Login     │
-- ╰──────────────────────────────────╯
local frame = CreateFrame("Frame")
frame:RegisterEvent("FRIENDLIST_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN") -- To handle when you log in

-- Event handler function
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "FRIENDLIST_UPDATE" then
        iWR:SendFullDBUpdateToFriends()
    elseif event == "PLAYER_LOGIN" then
        iWR:SendFullDBUpdateToFriends()
    end
end)
