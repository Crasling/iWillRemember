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
local CurrDataTime
local CompDataTime
local Success
local DataCache
local addonpath = "Classic"
local TempTable = {}
local DataCacheTable = {}
local DataTimeTable = {}
local isInitialized = false
local iWRBase = {}

iWRDatabase = {}
iWRSettings = {}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Initialization                                 │
-- ├───────────────────────────┬────────────────────────────────────────────────────╯
-- │      Only done once       │
-- ╰───────────────────────────╯

-- Check if a different UI Frame is used
local addonpath = "Classic"     -- default path

if C_AddOns.IsAddOnLoaded("EasyFrames") then
    addonpath = "EasyFrames"    -- EasyFrames path
end

-- ╭───────────────────────────────────╮
-- │      List of Targeting Frames     │
-- ╰───────────────────────────────────╯
iWRBase.TargetFrames = {
    [10]    = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Superior.blp",
    [5]     = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\BestFriend.blp",
    [3]     = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Friend.blp",
    [1]     = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Neutral.blp",
    [-3]    = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Unpleasant.blp",
    [-5]    = "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Hostile.blp",
}

-- ╭────────────────────────────────╮
-- │      List of General Icons     │
-- ╰────────────────────────────────╯
iWRBase.Icons = {
    [10]    = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Superior.blp",
    [5]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\BestFriends.blp",
    [3]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Friend.blp",
    [1]     = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Neutral.blp",
    [-3]    = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Unpleasant.blp",
    [-5]    = "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Hostile.blp",
}

-- ╭──────────────────────────────╮
-- │      List of Panel Icons     │
-- ╰──────────────────────────────╯
iWRBase.PanelIcons = {
    [10]    = "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Superior.blp",
    [5]     = "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\BestFriends.blp",
    [3]     = "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Friend.blp",
    [1]     = "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Neutral.blp",
    [-3]    = "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Unpleasant.blp",
    [-5]    = "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Hostile.blp",
}

-- ╭─────────────────────────╮
-- │      List of Colors     │
-- ╰─────────────────────────╯
iWRBase.Color = {
    [10]    = "|cff80f451", -- Superior Colour
    [5]     = "|cff80f451", -- BestFriend Colour
    [3]     = "|cff80f451", -- Friend Colour
    [1]     = "|cff80f451", -- Neutral Colour
    [-3]    = "|cfffb9038", -- Unpleasant Colour
    [-5]    = "|cffff2121", -- Hostile Colour
}

-- ╭────────────────────────╮
-- │      List of Types     │
-- ╰────────────────────────╯
iWRBase.Types = {
    [10]    = "Superior",
    [5]     = "BestFriend",
    [3]     = "Friend",
    [1]     = "Neutral",
    [0]     = "Clear",
    [-3]    = "Unpleasant",
    [-5]    = "Hostile",
    Superior = 10,
    BestFriend = 5,
    Friend = 3,
    Neutral = 1,
    Unpleasant = -3,
    Hostile = -5,
}



-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                    Functions                                   │
-- ├───────────────────────┬───────────────────────────────────────────────────────╯
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
        end
    end

    if (UnitIsPlayer(unit)) then    
        if iWRDatabase[tostring(name)] then
            if tonumber(iWRDatabase[tostring(name)][1]) then
                if tonumber(iWRDatabase[tostring(name)][1]) > 1 and tonumber(iWRDatabase[tostring(name)][1]) <= getn(L["iWRBase.TargetFrames"]) then
                    GameTooltip:AddLine(L["iWRBase.Types"][tonumber(iWRDatabase[tostring(name)][1])])
                end
            else
                GameTooltip:AddLine(iWRBase.Color[tonumber(iWRDatabase[tostring(name)][2])] .. L["NoteToolTip"] .. tostring(iWRDatabase[tostring(name)][1]).."|r")
            end
        end
    end
end

-- Time Compare
local function IsNeedToUpdate(CurrDataTime, CompDataTime)
    if tonumber(CurrDataTime) < tonumber(CompDataTime) then
        return true
    end
end

-- ╭──────────────────────────╮
-- │      Get Current Time    │
-- ╰──────────────────────────╯
local function GetCurrentTimeByHours()
    local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
    local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay)*24 + tonumber(CurrMonth)*720 + tonumber(CurrYear)*8640
        return tonumber(CurrentTime)
    end

-- Sending Latest note only to friendslist
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

function iWR:OnFullDBUpdate(prefix, message, distribution, sender)
    if GetUnitName("player", false) == sender then return end
        Success, FullNotesTable = iWR:Deserialize(message)

        if not Success then
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: OnFullDBUpdate Error")
            end
        else
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: DataReceived from: " .. sender)
            end
            for k,v in pairs(FullNotesTable) do
                if iWRDatabase[k] then
                    if IsNeedToUpdate((iWRDatabase[k][3]), v[3]) then
                        iWRDatabase[k] = v
                    end
                else
                    iWRDatabase[k] = v
                end
            end
        end
    end

function iWR:OnNewDBUpdate(prefix, message, distribution, sender)
    if GetUnitName("player", false) == sender then return end
        Success, TempTable = iWR:Deserialize(message)

        if not Success then
            if DebugMsg then
                print("|cffff9716[iWR]: DEBUG: OnNewDBUpdate Error")
            end
        else
          for k,v in pairs(TempTable) do
                iWRDatabase[k] = v
          end
          if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: DataReceived from: " .. sender)
          end
        end
        wipe(TempTable)
    end

-- ╭──────────────────────────────────╮
-- │      Set New Targeting Frame     │
-- ╰──────────────────────────────────╯
function iWR:SetTargetingFrame()
    if not iWRDatabase[GetUnitName("target", false)] then
        local targetName = GetUnitName("target")
        if UnitIsPlayer("target") then
            if DebugMsg then
                
                print("|cffff9716[iWR]: DEBUG: Player [|r" .. targetName .. "|cffff9716] was not found in Database")
            end
        end
        return
    end

    if iWRDatabase[tostring(GetUnitName("target", false))][2] ~= 0 then
        local targetName = GetUnitName("target")
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Player [|r" .. targetName .. "|cffff9716] was found in Database")
        end
        TargetFrameTextureFrameTexture:SetTexture(iWRBase.TargetFrames[iWRDatabase[tostring(GetUnitName("target", false))][2]]);
    end
end

-- ╭──────────────────────────────╮
-- │      Toggle Menu Window      │
-- ╰──────────────────────────────╯
function iWR:MenuToggle()
    if iWRPanel:IsVisible() then
        iWR:MenuClose()
    else
        iWR:MenuOpen()
    end
end

-- ╭────────────────────────────╮
-- │      Open Menu Window      │
-- ╰────────────────────────────╯
function iWR:MenuOpen(Name)
    iWRPanel:Show()
    iWRNameInput:SetText(L["DefaultNameInput"])
    iWRNoteInput:SetText(L["DefaultNoteInput"])
    if Name and Name ~= "" then
        iWRNameInput:SetText(Name)
    elseif UnitExists("target") and UnitIsPlayer("target") then
        iWRNameInput:SetText(UnitName("target"))
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

-- ╭────────────────────────╮
-- │      Add New Note      │
-- ╰────────────────────────╯
function iWR:AddNewNote(Name,Note,Type)
    if iWR:InputNotEmpty(Name) then
        if iWR:InputNotEmpty(Note) then
            iWR:CreateNote(Name,Note,Type)
        else
            iWR:CreateNote(Name,"",Type)
        end
    else
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: NameInput error: [|r" .. Name .. "|cffff9716]")
        end
    end
end

-- ╭──────────────────────╮
-- │      Clear Note      │
-- ╰──────────────────────╯
function iWR:ClearNote(Name)
    if iWR:InputNotEmpty(Name) then
        iWRDatabase[Name] = nil
        local targetName = UnitName("target")
            if Name == targetName then
                TargetFrame_Update(TargetFrame)
            end
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: Database information [|r" .. Name .. "|cffff9716] cleared.")
        end
    else
        if DebugMsg then
            print("|cffff9716[iWR]: DEBUG: NameInput error: [|r" .. Name .. "|cffff9716]")
        end
    end
end

-- ╭───────────────────────────╮
-- │      Create New Note      │
-- ╰───────────────────────────╯
function iWR:CreateNote(Name,Note,Type)
    if DebugMsg then
        print("|cffff9716[iWR]: DEBUG: New note Name: [|r" .. Name .. "|cffff9716]")
        print("|cffff9716[iWR]: DEBUG: New note Note: [|r" .. Note .. "|cffff9716]")
        print("|cffff9716[iWR]: DEBUG: New note Type: [|r" .. Type .. "|cffff9716]")
    end
    iWRDatabase[Name] = {
        Note,
        Type,
        GetCurrentTimeByHours(),
    }

    local targetName = UnitName("target")
        if Name == targetName then
            TargetFrame_Update(TargetFrame)
        end

    if iWRSettings.DataSharing ~= false then
        wipe(DataCacheTable)
        DataCacheTable[tostring(Name)] = {
            Note,
            Type,
            GetCurrentTimeByHours(),
        }
    DataCache = iWR:Serialize(DataCacheTable)
    iWR:SendNewDBUpdateToFriends()
    end
print("|cffff9716Character note: [|r" .. tostring(Name) .. "|cffff9716] created.|r")
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                      Frames                                    │
-- ├─────────────────────────────┬──────────────────────────────────────────────────╯
-- │      Create Main Panel      │
-- ╰─────────────────────────────╯
iWRPanel = CreateFrame("Frame", "SettingsMenu", UIParent, "BackdropTemplate")

-- Set panel size
iWRPanel:SetSize(350, 300)

-- Initially hide the panel
iWRPanel:Hide()

-- Position the panel at the center of the screen
iWRPanel:SetPoint("CENTER", UIParent, "CENTER")

-- Enable mouse interaction and make it movable
iWRPanel:EnableMouse()
iWRPanel:SetMovable(true)

-- Set the frame strata
iWRPanel:SetFrameStrata("MEDIUM")

-- Set up drag functionality
iWRPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)

-- Allow the frame to be dragged with both mouse buttons
iWRPanel:RegisterForDrag("LeftButton", "RightButton")

-- Keep the panel clamped to the screen
iWRPanel:SetClampedToScreen(true)

-- Set the panel's backdrop (background and border)
iWRPanel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
iWRPanel:SetBackdropColor(0, 0, 0, 1) -- Background color
iWRPanel:SetBackdropBorderColor(1, 1, 1, 1) -- Border color

-- Create the title bar
local titleBar = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
titleBar:SetHeight(30)
titleBar:SetPoint("TOP", iWRPanel, "TOP", 0, 0)
titleBar:SetWidth(iWRPanel:GetWidth())

-- Set title bar background and border
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1) -- Dark gray background

-- Add title text to the title bar
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
titleText:SetText("iWillRemember Menu")
titleText:SetTextColor(1, 1, 1, 1) -- White text

-- Create the close button (X)
local closeButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", iWRPanel, "TOPRIGHT", -5, -5)
closeButton:SetText("X")
closeButton:SetScript("OnClick", function()
    iWR:MenuClose()
end)

-- Add title for Player Name input field
local playerNameTitle = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playerNameTitle:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
playerNameTitle:SetText("Player Name")
playerNameTitle:SetTextColor(1, 1, 1, 1)

-- Create the Player Name input field
iWRNameInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNameInput:SetSize(150, 30)
iWRNameInput:SetPoint("TOP", playerNameTitle, "BOTTOM", 0, -1)
iWRNameInput:SetMaxLetters(20)
iWRNameInput:SetAutoFocus(false)
iWRNameInput:SetTextColor(1, 1, 1, 1)
iWRNameInput:SetText(L["DefaultNameInput"])

-- Add title for Note input field
local noteTitle = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
noteTitle:SetPoint("TOP", iWRNameInput, "BOTTOM", 0, -10)
noteTitle:SetText("Personalized note about chosen player")
noteTitle:SetTextColor(1, 1, 1, 1) -- White text

-- Create the Note input field
iWRNoteInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNoteInput:SetSize(250, 30)
iWRNoteInput:SetPoint("TOP", noteTitle, "BOTTOM", 0, -3)
iWRNoteInput:SetMultiLine(false)
iWRNoteInput:SetMaxLetters(40)
iWRNoteInput:SetAutoFocus(false)
iWRNoteInput:SetTextColor(1, 1, 1, 1)
iWRNoteInput:SetText(L["DefaultNoteInput"])

-- Grab targets name Button
local playerNameButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
playerNameButton:SetSize(60, 30)
playerNameButton:SetPoint("LEFT", iWRNameInput, "RIGHT", 5, 0)
playerNameButton:SetText("Target")
playerNameButton:SetScript("OnClick", function()
    if UnitExists("target") and UnitIsPlayer("target") then
        iWRNameInput:SetText(UnitName("target"))
    else
        print(L["InvalidTarget"])
    end
end)

-- Create buttons below the Note input field
local button1 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button1:SetSize(50, 30)
button1:SetPoint("TOP", iWRNoteInput, "BOTTOM", -120, -10)
button1:SetText("1")
button1:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(),iWRNoteInput:GetText(),iWRBase.Types["Hostile"])
    iWR:MenuClose()
end)

local button2 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button2:SetSize(50, 30)
button2:SetPoint("TOP", iWRNoteInput, "BOTTOM", -60, -10)
button2:SetText("2")
button2:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(),iWRNoteInput:GetText(),iWRBase.Types["Unfriendly"])
    iWR:MenuClose()
end)

local button3 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button3:SetSize(50, 30)
button3:SetPoint("TOP", iWRNoteInput, "BOTTOM", 0, -10)
button3:SetText("3")
button3:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(),iWRNoteInput:GetText(),iWRBase.Types["Friend"])
    iWR:MenuClose()
end)

local button4 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button4:SetSize(50, 30)
button4:SetPoint("TOP", iWRNoteInput, "BOTTOM", 60, -10)
button4:SetText("4")
button4:SetScript("OnClick", function()
    iWR:AddNewNote(iWRNameInput:GetText(),iWRNoteInput:GetText(),iWRBase.Types["BestFriend"])
    iWR:MenuClose()
end)

local button5 = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
button5:SetSize(50, 30)
button5:SetPoint("TOP", iWRNoteInput, "BOTTOM", 120, -10)
button5:SetText("5")
button5:SetScript("OnClick", function()
    iWR:ClearNote(iWRNameInput:GetText())
    iWR:MenuClose()
end)

-- Create a new frame to display the database
local iWRDatabaseFrame = CreateFrame("Frame", "DatabaseFrame", UIParent, "BackdropTemplate")

-- Set panel size
iWRDatabaseFrame:SetSize(350, 300)

-- Initially hide the frame
iWRDatabaseFrame:Hide()

-- Position the frame at the center of the screen
iWRDatabaseFrame:SetPoint("CENTER", UIParent, "CENTER")

-- Enable mouse interaction and make it movable
iWRDatabaseFrame:EnableMouse()
iWRDatabaseFrame:SetMovable(true)

-- Set the frame strata
iWRDatabaseFrame:SetFrameStrata("MEDIUM")

-- Set up drag functionality
iWRDatabaseFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)

-- Allow the frame to be dragged with both mouse buttons
iWRDatabaseFrame:RegisterForDrag("LeftButton", "RightButton")

-- Keep the frame clamped to the screen
iWRDatabaseFrame:SetClampedToScreen(true)

-- Set the frame's backdrop (background and border)
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
dbTitleText:SetText("iWR Database")
dbTitleText:SetTextColor(1, 1, 1, 1) -- White text

-- Create a scrollable frame to list database entries
local dbScrollFrame = CreateFrame("ScrollFrame", nil, iWRDatabaseFrame, "UIPanelScrollFrameTemplate")
dbScrollFrame:SetPoint("TOP", dbTitleBar, "BOTTOM", 0, -5)
dbScrollFrame:SetSize(320, 200)

-- Create a container for the database entries (this will be scrollable)
local dbContainer = CreateFrame("Frame", nil, dbScrollFrame)
dbContainer:SetSize(300, 400) -- Make sure it's larger than the scroll area
dbScrollFrame:SetScrollChild(dbContainer)

-- Create a button to open the database frame
local openDatabaseButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
openDatabaseButton:SetSize(100, 30)
openDatabaseButton:SetPoint("TOP", button5, "BOTTOM", 0, -10)
openDatabaseButton:SetText("Open DB")
openDatabaseButton:SetScript("OnClick", function()
    iWRDatabaseFrame:Show()  -- Show the database frame
    iWR:PopulateDatabase()    -- Populate the database list
end)

-- Create a close button for the database frame
local dbCloseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelButtonTemplate")
dbCloseButton:SetSize(20, 20)
dbCloseButton:SetPoint("TOPRIGHT", iWRDatabaseFrame, "TOPRIGHT", -5, -5)
dbCloseButton:SetText("X")
dbCloseButton:SetScript("OnClick", function()
    iWRDatabaseFrame:Hide()  -- Close the database frame
end)

-- Function to populate the database list
function iWR:PopulateDatabase()
    -- Clear the container first
    -- Gather all child frames and hide them
    for _, child in ipairs({dbContainer:GetChildren()}) do
        child:Hide()
    end

    -- Iterate over the iWRDatabase and create buttons for each entry
    local yOffset = -5
    for playerName, data in pairs(iWRDatabase) do
        -- Create a new button for each entry in the database
        local entryButton = CreateFrame("Button", nil, dbContainer, "UIPanelButtonTemplate")
        entryButton:SetSize(280, 30)
        entryButton:SetPoint("TOP", dbContainer, "TOP", 0, yOffset)
        entryButton:SetText(playerName .. ": " .. data[1]) -- Display player name and note
        entryButton:SetScript("OnClick", function()
            print("Selected " .. playerName) -- You can add functionality here for what happens when the entry is clicked
        end)

        yOffset = yOffset - 35 -- Adjust for next button's position
    end
end

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

    if playerName == "Baldvin" or "Crasling" or "Enöl" then
        DebugMsg = true
        print(L["DevLoad"])
    else
        DebugMsg = false
    end

    -- Print a message to the chat frame when the addon is loaded
    print(L["iWRLoaded"] .. L["VersionNumber"])

    -- Create the main launcher button
    LDBroker:NewDataObject("iWillRemember_DataObject", {
        type = "launcher",
        text = "iWillRemember",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(clickedframe, button)

        end,
    })

    -- Create the minimap button (DataObject for the minimap button)
    local minimapButton = LDBroker:NewDataObject("iWillRemember_MinimapButton", {
        type = "data source",
        text = "iWillRemember",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(self, button)
            iWR:MenuToggle()
        end,

    -- Tooltip handling
    OnTooltipShow = function(tooltip)
        -- Name
        tooltip:SetText("|cffff9716iWillRemember|r", 1, 1, 1)

        -- Desc
        tooltip:AddLine(" ", 1, 1, 1) 
        tooltip:AddLine("Open iWillRemember interface", 1, 1, 1) 
        tooltip:AddLine(L["VersionNumber"]) 

        -- Make visible
        tooltip:Show()  -- Make sure the tooltip is displayed
    end,
    })

    -- Register the minimap button with LibDBIcon
    LDBIcon:Register("iWillRemember_MinimapButton", minimapButton, {
        minimapPos = 45,
        radius = 80,
    })

    -- Function to modify the right-click menu for a given context
    local function ModifyMenuForContext(menuType)
        Menu.ModifyMenu(menuType, function(ownerRegion, rootDescription, contextData)
            -- Retrieve the name of the player for whom the menu is opened
            local playerName = contextData.name

            -- Check if playerName is available
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

    -- Modify the right-click menu for players, party members, and raid members
    ModifyMenuForContext("MENU_UNIT_PLAYER")
    ModifyMenuForContext("MENU_UNIT_PARTY")
    ModifyMenuForContext("MENU_UNIT_RAID")

end
