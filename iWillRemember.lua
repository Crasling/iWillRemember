-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════


-- ──────────────────────────────────────────────────────────────
-- [[                       Namespace                          ]]
-- ──────────────────────────────────────────────────────────────

local Name, AddOn = ...
local Title = select(2, C_AddOns.GetAddOnInfo(Name)):gsub("%s*v?[%d%.]+$", "")
local Version = C_AddOns.GetAddOnMetadata(Name, "Version")
local Author = C_AddOns.GetAddOnMetadata(Name, "Author")

-- ──────────────────────────────────────────────────────────────
-- [[                         Libs                             ]]
-- ──────────────────────────────────────────────────────────────

iWR = LibStub("AceAddon-3.0"):NewAddon("iWR", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("iWR")
local LDBroker = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- ──────────────────────────────────────────────────────────────
-- [[                       Variables                          ]]
-- ──────────────────────────────────────────────────────────────

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

-- ──────────────────────────────────────────────────────────────
-- [[                           Init                           ]]
-- ──────────────────────────────────────────────────────────────

if not isInitialized then
    -- Check if a different UI Frame is used
    local addonpath = "Classic"     -- default path

    if C_AddOns.IsAddOnLoaded("EasyFrames") then
        addonpath = "EasyFrames"    -- EasyFrames path
    end

    -- Set Targetframes
    iWRBase.TargetFrames = {
        "PlaceHolder", -- 1
        "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Hostile.blp",       -- 2
        "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Unpleasant.blp",    -- 3
        "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Friend.blp",        -- 4
        "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\BestFriend.blp",    -- 5
        "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Superior.blp",      -- 6
        "Interface\\AddOns\\iWillRemember\\Images\\TargetFrames\\" .. addonpath .. "\\Neutral.blp",       -- 7
    }

    -- Set Icons
    iWRBase.Icons = {
        "PlaceHolder", -- 1
        "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Hostile.blp",       -- 2
        "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Unpleasant.blp",    -- 3
        "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Friend.blp",        -- 4
        "Interface\\AddOns\\iWillRemember\\Images\\Icons\\BestFriends.blp",   -- 5
        "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Superior.blp",      -- 6
        "Interface\\AddOns\\iWillRemember\\Images\\Icons\\Neutral.blp",       -- 7
    }

    -- Set PanelIcons
    iWRBase.PanelIcons = {
        "PlaceHolder", -- 1
        "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Hostile.blp",       -- 2
        "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Unpleasant.blp",    -- 3
        "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Friend.blp",        -- 4
        "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\BestFriends.blp",   -- 5
        "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Superior.blp",      -- 6
        "Interface\\AddOns\\iWillRemember\\Images\\PanelIcons\\Neutral.blp",       -- 7
    }

    -- Set Colours
    iWRBase.Colour = {
        "", -- 1
        "|cffff2121", -- 2 (Hostile Colour)
        "|cfffb9038", -- 3 (Unpleasant Colour)
        "|cff80f451", -- 4 (Friend Colour)
        "|cff80f451", -- 5 (BestFriend Colour)
        "|cff80f451", -- 6 (Superior Colour)
        "|cff80f451", -- 7 (Neutral Colour)
    }

    iWRBase.Type = {
        [1] = "",
        [2] = "Hostile",
        [3] = "Unpleasant",
        [4] = "Friend",
        [5] = "BestFriend",
        [6] = "Superior",
        [7] = "Neutral"
    }
end

-- ──────────────────────────────────────────────────────────────
-- [[                         Functions                        ]]
-- ──────────────────────────────────────────────────────────────

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
                if tonumber(iWRDatabase[tostring(name)][1]) > 1 and tonumber(iWRDatabase[tostring(name)][1]) <= getn(L["RememberYouDefaultNotes"]) then
                    GameTooltip:AddLine(L["RememberYouDefaultNotes"][tonumber(iWRDatabase[tostring(name)][1])])
                end
            else
                GameTooltip:AddLine(L["RYStartNote"]..RememberYouColour[tonumber(iWRDatabase[tostring(name)][2])] .. tostring(iWRDatabase[tostring(name)][1]).."|r")
            end
        end
    end
end

function iWR:SetTargetingFrame()
    if not iWRDatabase[GetUnitName("target", false)] then 
        return
    end

    if iWRDatabase[tostring(GetUnitName("target", false))][2] > 1 then
        TargetFrameTextureFrameTexture:SetTexture(RememberYouTargetFrames[iWRDatabase[tostring(GetUnitName("target", false))][2]]);
    end
end

local JoiningGroup = CreateFrame("Frame")
    JoiningGroup:RegisterEvent("GROUP_JOINED")
    JoiningGroup:RegisterEvent("GROUP_LEFT")

JoiningGroup:SetScript("OnEvent", function(self, event)
    if event == "GROUP_JOINED" then
        InGroup = true
        iWR:SendFullDBUpdateToFriends()
    elseif event == "GROUP_LEFT" then
        InGroup = false
    end
end)

-- ──────────────────────────────────────────────────────────────
-- [[                         Frames                           ]]
-- ──────────────────────────────────────────────────────────────

-- Create the main panel
local iWRPanel = CreateFrame("Frame", "SettingsMenu", UIParent, "BackdropTemplate")

-- Set panel size
iWRPanel:SetWidth(350)
iWRPanel:SetHeight(250)

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
iWRPanel:SetBackdropColor(0, 0, 0, 1)  -- Background color
iWRPanel:SetBackdropBorderColor(1, 1, 1, 1)  -- Border color

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
titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1)  -- Dark gray background

-- Add title text to the title bar
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
titleText:SetText("iWillRemember Menu")
titleText:SetTextColor(1, 1, 1, 1)  -- White text

-- Create the close button (X)
local closeButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", iWRPanel, "TOPRIGHT", -5, -5)
closeButton:SetText("X")

-- Close panel when button is clicked
closeButton:SetScript("OnClick", function()
    iWRPanel:Hide()
    iWRNameInput:SetText("Enter Player Name")
end)

-- Create the Player Name input field
iWRNameInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNameInput:SetSize(300, 30)
iWRNameInput:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
iWRNameInput:SetMaxLetters(50)
iWRNameInput:SetAutoFocus(false)
iWRNameInput:SetTextColor(1, 1, 1, 1)
iWRNameInput:SetText("Enter Player Name")

-- Create the Note input field
iWRNoteInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNoteInput:SetSize(300, 80)
iWRNoteInput:SetPoint("TOP", iWRNameInput, "BOTTOM", 0, -10)
iWRNoteInput:SetMaxLetters(255)
iWRNoteInput:SetAutoFocus(false)
iWRNoteInput:SetTextColor(1, 1, 1, 1)
iWRNoteInput:SetText("Enter a note...")


-- ──────────────────────────────────────────────────────────────
-- [[                      Events Handler                      ]]
-- ──────────────────────────────────────────────────────────────

function iWR:OnEnable()
    -- Secure hooks to add custom behavior
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update", "SetTargetingFrame")

    -- Print a message to the chat frame when the addon is loaded
    print(L["iWRLoaded"] .. L["VersionNumber"])

    -- Create the main launcher button
    LDBroker:NewDataObject("iWillRemember_DataObject", {
        type = "launcher",
        text = "iWillRemember",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(clickedframe, button)
            if iWRPanel:IsVisible() then
                iWRPanel:Hide()
                iWRNameInput:SetText("Enter Player Name")
            else
                iWRPanel:Show()
                if UnitExists("target") then
                    iWRNameInput:SetText(UnitName("target"))
                end
            end
        end,
    })

    -- Create the minimap button (DataObject for the minimap button)
    local minimapButton = LDBroker:NewDataObject("iWillRemember_MinimapButton", {
        type = "data source",
        text = "iWillRemember",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(self, button)
            if iWRPanel:IsVisible() then
                iWRPanel:Hide()
                iWRNameInput:SetText("Enter Player Name")
            else
                iWRPanel:Show()
                if UnitExists("target") then
                    iWRNameInput:SetText(UnitName("target"))
                end
            end
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
        minimapPos = 45,  -- Set the position on the minimap (in degrees)
        radius = 80,     -- Set the radius from the center of the minimap
    })

    -- Share DB on Login
    if iWRSettings.Import ~= false then
        --iWR:RegisterComm("RYFullUpdate", "OnFullNotesCommReceived")       TODO
        --iWR:RegisterComm("RYOneUpdate", "OnNewNoteCommReceived")          TODO
        --iWR:SendFullDBUpdateToFriends()                                   TODO
    end

    -- Modify the right-click menu for a player unit (when you right-click on a player's portrait)
    Menu.ModifyMenu("MENU_UNIT_PLAYER", function(ownerRegion, rootDescription, contextData)

    -- Create a divider to visually separate this custom section from other menu items
    rootDescription:CreateDivider()

    -- Create a title for the custom section of the menu, labeled "iWillRemember"
    rootDescription:CreateTitle("iWillRemember")

    -- Add a new button to the menu with the text "Open Menu"
    rootDescription:CreateButton("Open Menu", function()
        -- Show the iWRPanel
        iWRPanel:Show()
        iWRNameInput:SetText(UnitName("target"))
    end)end)

end

