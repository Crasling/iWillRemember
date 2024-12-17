-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════


-- ──────────────────────────────────────────────────────────────
--[[                          Libs                             ]]
-- ──────────────────────────────────────────────────────────────

iWillRemember = LibStub("AceAddon-3.0"):NewAddon("iWillRemember", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("iWillRemember")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

-- ──────────────────────────────────────────────────────────────
--[[                       Variables                           ]]
-- ──────────────────────────────────────────────────────────────

local CurrDataTime, CompDataTime
local InGroup, success, SerializedCash
local TempTable, CashTable, TimeTable = {}, {}, {}

iWillRememberDatabase = {}
iWillRememberSettings = {}

-- Base paths for cleaner file referencing
local BASE_IMG_PATH = "Interface\\AddOns\\iWillRemember\\Img\\"
local TARGET_FRAMES_PATH = BASE_IMG_PATH .. "TargetFrames\\"
local ICONS_PATH = BASE_IMG_PATH .. "Icons\\"
local PANEL_PATH = BASE_IMG_PATH .. "Panel\\"
local SKINS_PATH = BASE_IMG_PATH .. "Skins\\"

-- Target Frames
local function GetTargetFrames()
    if IsAddOnLoaded("EasyFrames") then
        return {
            TARGET_FRAMES_PATH .. "EFRedWings.blp",     -- 1 Worst  <->  Red with wings
            TARGET_FRAMES_PATH .. "EFRed.blp",          -- 2 Bad    <->  Red 
            TARGET_FRAMES_PATH .. "EFGreen.blp",        -- 3 Good   <-> Green
            TARGET_FRAMES_PATH .. "EFGreenWings.blp",   -- 4 Best   <-> Green with wings
        }
    else
        return {
            TARGET_FRAMES_PATH .. "RedWings.blp",       -- 1 Worst  <->  Red with wings
            TARGET_FRAMES_PATH .. "Red.blp",            -- 2 Bad    <->  Red 
            TARGET_FRAMES_PATH .. "Green.blp",          -- 3 Good   <-> Green
            TARGET_FRAMES_PATH .. "GreenWings.blp",     -- 4 Best   <-> Green with wings
        }
    end
end
local iWillRememberTargetFrames = GetTargetFrames()

-- Icons
local iWillRememberIcons = {
    ICONS_PATH .. "Custom.blp",
    ICONS_PATH .. "Skull.blp",
    ICONS_PATH .. "Dislike.blp",
    ICONS_PATH .. "Like.blp",
    ICONS_PATH .. "Friend.blp",
}

-- Panel Icons
local iWillRememberPanelIcons = {
    PANEL_PATH .. "Clear.blp",       -- 1
    PANEL_PATH .. "Skull.blp",        -- 2
    PANEL_PATH .. "Dislike.blp",      -- 3
    PANEL_PATH .. "Like.blp",         -- 4
    PANEL_PATH .. "Friend.blp",       -- 5
    PANEL_PATH .. "Note.blp",         -- 6
    PANEL_PATH .. "ImportOff.blp",    -- 7
    PANEL_PATH .. "ImportOn.blp",     -- 8
    PANEL_PATH .. "editicon.blp",     -- 9
}

-- Panel Skins
local iWillRememberPanelSkins = {
    SKINS_PATH .. "Skin1.blp",
    SKINS_PATH .. "Skin2.blp",
    SKINS_PATH .. "Skin3.blp",
    SKINS_PATH .. "Skin4.blp",
}

-- Colours
local iWillRememberColour = {
    "",              -- Custom Note
    "|cffff2121",    -- Hostile
    "|cfffb9038",    -- Unfriendly
    "|cff80f451",    -- Friendly
    "|cff80f451",    -- Exalted
}

-- ──────────────────────────────────────────────────────────────
--[[                       Functions                           ]]
-- ──────────────────────────────────────────────────────────────

-- Function to check if an update is needed based on current and comparison time
function IsNeedToUpdate(CurrDataTime, CompDataTime)
    if tonumber(CurrDataTime) < tonumber(CompDataTime) then
        return true
    end
end

-- Function to get the current time in hours (from a specific reference)
function GetCurrentTimeByHours()
    local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
    local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay) * 24 + tonumber(CurrMonth) * 720 + tonumber(CurrYear) * 8640
    return tonumber(CurrentTime)
end

-- Function to check if the name field in the Editbox has text
function iWillRemember:EditboxNameHasText()
    if iWillRememberNotes.EditBoxName:GetText() ~= L["EditboxName"] and 
       iWillRememberNotes.EditBoxName:GetText() ~= "" and 
       iWillRememberNotes.EditBoxName:GetText() ~= nil and 
       (not string.find(iWillRememberNotes.EditBoxName:GetText(), "^%s+$")) then
        return true
    end
end

-- Function to check if the note field in the Editbox has text
function iWillRemember:EditboxNoteHasText()
    if iWillRememberNotes.EditBoxNote:GetText() ~= L["EditboxNote"] and 
       iWillRememberNotes.EditBoxNote:GetText() ~= "" and 
       iWillRememberNotes.EditBoxNote:GetText() ~= nil and 
       (not string.find(iWillRememberNotes.EditBoxNote:GetText(), "^%s+$")) then
        return true
    end
end

-- Function to clear the Editbox fields and reset focus
function iWillRemember:ClearEditboxes()
    iWillRememberNotes.EditBoxName:ClearFocus()
    iWillRememberNotes.EditBoxNote:ClearFocus()
    iWillRememberNotes.EditBoxName:SetText(L["EditboxName"])
    iWillRememberNotes.EditBoxNote:SetText(L["EditboxNote"])
end

-- Function to sort notes by type and create a new note if needed
function iWillRemember:SortNotesByType(Notelevel)
    if iWillRemember:EditboxNameHasText() then
        if iWillRemember:EditboxNoteHasText() then
            iWillRemember:CreateNote(tostring(iWillRememberNotes.EditBoxName:GetText()), 
                                      tostring(iWillRememberNotes.EditBoxNote:GetText()), 
                                      Notelevel)
        else
            iWillRemember:CreateNote(tostring(iWillRememberNotes.EditBoxName:GetText()), Notelevel, Notelevel)
        end
    else
        if UnitIsPlayer("target") then
            if iWillRemember:EditboxNoteHasText() then
                iWillRemember:CreateNote(tostring(GetUnitName("target", false)), 
                                          tostring(iWillRememberNotes.EditBoxNote:GetText()), 
                                          Notelevel)
            else
                iWillRemember:CreateNote(tostring(GetUnitName("target", false)), Notelevel, Notelevel)
            end
        else
            print(L["NoTarget"])
        end
    end
    iWillRemember:ClearEditboxes()
end

-- Function to send the latest note only to friends list
function iWillRemember:SendNewDBUpdateToFriends()
    -- Loop through all friends in the friend list
    for i = 1, C_FriendList.GetNumFriends() do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        local friendName = friendInfo and friendInfo.name
        if friendName then
            iWillRemember:SendCommMessage("OneUpdate", SerializedCash, "WHISPER", friendName)
            print("DEBUG: Successfully shared new iWillRemember note to: " .. friendName)
        else
            print("No friend found at index " .. i)
        end
    end
end

-- Function to send the full database update to friends list
function iWillRemember:SendFullDBUpdateToFriends()
    if iWillRememberSettings.Import ~= false then
        for i = 1, C_FriendList.GetNumFriends() do
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            local friendName = friendInfo and friendInfo.name
            if friendName then
                wipe(TimeTable)
                local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
                local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay) * 24 + tonumber(CurrMonth) * 720 + tonumber(CurrYear) * 8640
                for k, v in pairs(iWillRememberDatabase) do
                    if (iWillRememberDatabase[k][3] - CurrentTime) > -800 then
                        TimeTable[k] = iWillRememberDatabase[k]
                    end
                end
                TimeTableToSend = iWillRemember:Serialize(TimeTable)
                iWillRemember:SendCommMessage("FullUpdate", TimeTableToSend, "WHISPER", friendName)
                print("DEBUG: Successfully shared all iWillRemember notes to: " .. friendName)
            else
                print("No friend found at index " .. i)
            end
        end
    end
end

-- Function to create a new note and add it to the database
function iWillRemember:CreateNote(name, note, frameicon)
    iWillRememberDatabase[tostring(name)] = {
        note,
        frameicon,
        GetCurrentTimeByHours(),
    }
    TargetFrame_Update(TargetFrame)

    if iWillRememberSettings.Import ~= false then
        wipe(CashTable)
        CashTable[tostring(name)] = {
            note,
            frameicon,
            GetCurrentTimeByHours(),
        }
        SerializedCash = iWillRemember:Serialize(CashTable)
        iWillRemember:SendNewDBUpdateToFriends()
    end
    print(L["NotifyBase"] .. tostring(name) .. L["NotifyEnd"])
end

-- Function to handle the reception of a full notes update from another player
function iWillRemember:OnFullNotesCommReceived(prefix, message, distribution, sender)
    if GetUnitName("player", false) == sender then return end
    success, FullNotesTable = iWillRemember:Deserialize(message)
    
    if not success then
        print("Error")
    else
        print(L["DataReceived"] .. sender)
        for k, v in pairs(FullNotesTable) do
            if iWillRememberDatabase[k] then
                if IsNeedToUpdate((iWillRememberDatabase[k][3]), v[3]) then
                    iWillRememberDatabase[k] = v
                end
            else
                iWillRememberDatabase[k] = v
            end
        end
    end
end

-- Function to handle the reception of a new note from another player
function iWillRemember:OnNewNoteCommReceived(prefix, message, distribution, sender)
    if GetUnitName("player", false) == sender then return end
    success, TempTable = iWillRemember:Deserialize(message)
    
    if not success then
        print("Error")
    else
        for k, v in pairs(TempTable) do
            iWillRememberDatabase[k] = v
        end
        print(L["DataReceived"] .. sender)
    end
    wipe(TempTable)
end

-- Function to handle the player entering combat and hide the notes window
local function OnCombatEnter(self, event)
    iWillRememberNotes:Hide()
end


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                                Hooks                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function iWillRemember:AddNoteToGameTooltip(self,...)
local name, unit = self:GetUnit();
if (not unit) then
local mFocus = GetMouseFocus();
    if (mFocus) and (mFocus.unit) then
        unit = mFocus.unit;
    end
end

    if (UnitIsPlayer(unit)) then    
        if iWillRememberDatabase[tostring(name)] then
            if tonumber(iWillRememberDatabase[tostring(name)][1]) then
                if tonumber(iWillRememberDatabase[tostring(name)][1]) > 1 and tonumber(iWillRememberDatabase[tostring(name)][1]) <= getn(L["iWillRememberDefaultNotes"]) then
                    GameTooltip:AddLine(L["iWillRememberDefaultNotes"][tonumber(iWillRememberDatabase[tostring(name)][1])])
                end
            else
                GameTooltip:AddLine(L["StartNote"]..iWillRememberColour[tonumber(iWillRememberDatabase[tostring(name)][2])] .. tostring(iWillRememberDatabase[tostring(name)][1]).."|r")
            end
        end
    end
end

function iWillRemember:SetTargetingFrame()
if not iWillRememberDatabase[GetUnitName("target", false)] then return end

    if iWillRememberDatabase[tostring(GetUnitName("target", false))][2] > 1 then
            TargetFrameTextureFrameTexture:SetTexture(iWillRememberTargetFrames[iWillRememberDatabase[tostring(GetUnitName("target", false))][2]]);
    end
end

local JoiningGroup = CreateFrame("Frame")
    JoiningGroup:RegisterEvent("GROUP_JOINED")
    JoiningGroup:RegisterEvent("GROUP_LEFT")

JoiningGroup:SetScript("OnEvent", function(self, event)
    if event == "GROUP_JOINED" then
        InGroup = true
        iWillRemember:SendFullDBUpdateToFriends()
    elseif event == "GROUP_LEFT" then
        InGroup = false
    end
end)

-- ──────────────────────────────────────────────────────────────
--[[                       Name Plates                         ]]
-- ──────────────────────────────────────────────────────────────

-- Create a frame to handle name plate events
local iWillRememberNamePlate = CreateFrame("frame")
iWillRememberNamePlate:RegisterEvent("NAME_PLATE_UNIT_ADDED")
iWillRememberNamePlate:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

-- Event handler for name plate events
iWillRememberNamePlate:SetScript("OnEvent", function(self, event, ...) 
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unitID = ...
        local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)

        -- Create an indicator texture if it doesn't exist
        if not nameplate.Indicator then
            nameplate.Indicator = nameplate:CreateTexture(nil, "OVERLAY")
            nameplate.Indicator:SetTexture(nil)
            nameplate.Indicator:SetSize(30, 30)
            nameplate.Indicator:SetPoint("RIGHT", 30, -5)
        end

        -- Set the texture for the indicator based on the unit's data
        if iWillRememberDatabase[GetUnitName(unitID, false)] then
            nameplate.Indicator:SetTexture(iWillRememberIcons[iWillRememberDatabase[GetUnitName(unitID, false)][2]])
            nameplate.Indicator:Show()
        else
            nameplate.Indicator:SetTexture(nil)
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
        local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)

        -- Hide the indicator when the name plate is removed
        if nameplate.Indicator then 
            nameplate.Indicator:SetTexture(nil)
            if iWillRememberDatabase[GetUnitName(unitID, false)] then
                nameplate.Indicator:SetTexture(iWillRememberIcons[iWillRememberDatabase[GetUnitName(unitID, false)][2]])
            end
            nameplate.Indicator:Hide()
        end
    end
end)


-- ──────────────────────────────────────────────────────────────
--[[                          On Load                           ]]
-- ──────────────────────────────────────────────────────────────

function iWillRemember:OnEnable()
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update",  "SetTargetingFrame")

    print(L["OnLoad"])

    -- Create the main launcher button
    LDB:NewDataObject("iWillRemember", {
        type = "launcher",
        text = "Remember You",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(clickedframe, button)
            if iWillRememberNotes:IsVisible() then
                iWillRememberNotes:Hide()
            else
                iWillRememberNotes:Show()
            end
        end,
    })

    -- Create the minimap button (DataObject for the minimap button)
    local minimapButton = LDB:NewDataObject("iWillRemember_MinimapButton", {
        type = "data source",
        text = "Remember You",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(self, button)
            if iWillRememberNotes:IsVisible() then
                iWillRememberNotes:Hide()
            else
                iWillRememberNotes:Show()
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

        tooltip:Show()  -- Make sure the tooltip is displayed
    end,

    })

    -- Register the minimap button with LibDBIcon
    LDBIcon:Register("iWillRemember_MinimapButton", minimapButton, {
        minimapPos = 45,  -- Set the position on the minimap (in degrees)
        radius = 80,     -- Set the radius from the center of the minimap
    })

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Frames                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local iWillRememberNotes = CreateFrame("Frame", "iWillRememberNotes", UIParent)
    iWillRememberNotes:SetWidth(350)
    iWillRememberNotes:SetHeight(250)
    iWillRememberNotes:Hide()
    iWillRememberNotes:SetPoint("CENTER", UIParent, "CENTER")
    iWillRememberNotes:EnableMouse()
    iWillRememberNotes:SetMovable(true)
    iWillRememberNotes:SetFrameStrata("MEDIUM")
    iWillRememberNotes:SetScript("OnDragStart", function(self) self:StartMoving() end)
    iWillRememberNotes:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    iWillRememberNotes:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
    iWillRememberNotes:RegisterForDrag("LeftButton", "RightButton")
    iWillRememberNotes:SetClampedToScreen(true)

local floatingText = iWillRememberNotes:CreateFontString(nil, "OVERLAY")
    floatingText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    floatingText:SetText(L["VersionNumber"])
    floatingText:SetPoint("CENTER", iWillRememberNotes, "CENTER", 120, 65)
    floatingText:SetTextColor(1, 1, 0)

local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:SetScript("OnEvent", OnCombatEnter)

--[[iWillRememberNotes:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
iWillRememberNotes:SetBackdropColor(0, 0, 0, 1)]]

iWillRememberNotes.ArtWork = iWillRememberNotes:CreateTexture()
iWillRememberNotes.ArtWork:SetTexture("Interface\\AddOns\\iWillRemember\\Img\\Skins\\Skin2.blp");
iWillRememberNotes.ArtWork:SetTexCoord(0, 0.551, 0, 0.801)
iWillRememberNotes.ArtWork:SetPoint("CENTER", 0, 0)
iWillRememberNotes.ArtWork:SetDrawLayer("ARTWORK", 1)
iWillRememberNotes.ArtWork:SetSize(338.4, 246)
iWillRememberNotes.ArtWork:SetAlpha(0.97)
--iWillRememberNotes.ArtWork:SetSize(282, 229)

iWillRememberNotes.FriendButton = CreateFrame("BUTTON", "iWillRememberNotes.FriendButton", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.FriendButton:SetSize(43, 43)
iWillRememberNotes.FriendButton:SetAlpha(0.8)
iWillRememberNotes.FriendButton:SetPoint("CENTER", iWillRememberNotes, "CENTER", -120, 28)
iWillRememberNotes.FriendButton:SetNormalTexture(iWillRememberPanelIcons[4])
iWillRememberNotes.FriendButton:SetHighlightTexture(iWillRememberPanelIcons[4])
iWillRememberNotes.FriendButton:RegisterForClicks("AnyUp")
iWillRememberNotes.FriendButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(4)
end)

iWillRememberNotes.LikeButton = CreateFrame("BUTTON", "iWillRememberNotes.LikeButton", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.LikeButton:SetSize(43, 43)
iWillRememberNotes.LikeButton:SetAlpha(0.8)
iWillRememberNotes.LikeButton:SetPoint("CENTER", iWillRememberNotes, "CENTER", -60, 28)
iWillRememberNotes.LikeButton:SetNormalTexture(iWillRememberPanelIcons[3])
iWillRememberNotes.LikeButton:SetHighlightTexture(iWillRememberPanelIcons[3])
iWillRememberNotes.LikeButton:RegisterForClicks("AnyUp")
iWillRememberNotes.LikeButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(3)
end)

iWillRememberNotes.CustomButton = CreateFrame("BUTTON", "iWillRememberNotes.CustomButton", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.CustomButton:SetSize(43, 43)
iWillRememberNotes.CustomButton:SetAlpha(0.8)
iWillRememberNotes.CustomButton:SetPoint("CENTER", iWillRememberNotes, "CENTER", 0, 28)
iWillRememberNotes.CustomButton:SetNormalTexture(iWillRememberPanelIcons[1])
iWillRememberNotes.CustomButton:SetHighlightTexture(iWillRememberPanelIcons[1])
iWillRememberNotes.CustomButton:RegisterForClicks("AnyUp")
iWillRememberNotes.CustomButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(0)
end)

iWillRememberNotes.DisLikeButton = CreateFrame("BUTTON", "iWillRememberNotes.DisLikeButton", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.DisLikeButton:SetSize(43, 43)
iWillRememberNotes.DisLikeButton:SetAlpha(0.8)
iWillRememberNotes.DisLikeButton:SetPoint("CENTER", iWillRememberNotes, "CENTER", 60, 28)
iWillRememberNotes.DisLikeButton:SetNormalTexture(iWillRememberPanelIcons[3])
iWillRememberNotes.DisLikeButton:SetHighlightTexture(iWillRememberPanelIcons[3])
iWillRememberNotes.DisLikeButton:RegisterForClicks("AnyUp")
iWillRememberNotes.DisLikeButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(3)
end)

iWillRememberNotes.SkullButton = CreateFrame("BUTTON", "iWillRememberNotes.SkullButton", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.SkullButton:SetSize(43, 43)
iWillRememberNotes.SkullButton:SetAlpha(0.8)
iWillRememberNotes.SkullButton:SetPoint("CENTER", iWillRememberNotes, "CENTER", 120, 28)
iWillRememberNotes.SkullButton:SetNormalTexture(iWillRememberPanelIcons[2])
iWillRememberNotes.SkullButton:SetHighlightTexture(iWillRememberPanelIcons[2])
iWillRememberNotes.SkullButton:RegisterForClicks("AnyUp")
iWillRememberNotes.SkullButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(2)
end)

iWillRememberNotes.ToggleSkin = CreateFrame("BUTTON", "iWillRememberNotes.ToggleSkin", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.ToggleSkin:SetSize(43, 43)
iWillRememberNotes.ToggleSkin:SetAlpha(0.8)
iWillRememberNotes.ToggleSkin:SetPoint("CENTER", iWillRememberNotes, "CENTER", -130, -70)
iWillRememberNotes.ToggleSkin:SetNormalTexture(iWillRememberPanelIcons[13])
iWillRememberNotes.ToggleSkin:SetHighlightTexture(iWillRememberPanelIcons[13])
iWillRememberNotes.ToggleSkin:RegisterForClicks("AnyUp")
iWillRememberNotes.ToggleSkin:SetScript("OnClick", function(self, button)
    iWillRememberSettings.Skin = iWillRememberSettings.Skin+1
    if iWillRememberSettings.Skin == 5 then
        iWillRememberSettings.Skin = 1
    end
    iWillRememberNotes.ArtWork:SetTexture(iWillRememberPanelSkins[tonumber(iWillRememberSettings.Skin)]);
    print(L["SetSkinToggle"])
end)

iWillRememberNotes.DataBaseWrite = CreateFrame("BUTTON", "iWillRememberNotes.DataBaseWrite", iWillRememberNotes, "SecureHandlerClickTemplate");
iWillRememberNotes.DataBaseWrite:SetSize(43, 43)
iWillRememberNotes.DataBaseWrite:SetAlpha(0.8)
iWillRememberNotes.DataBaseWrite:SetPoint("CENTER", iWillRememberNotes, "CENTER", 130, -70)
if iWillRememberSettings.Import == false then
    iWillRememberNotes.DataBaseWrite:SetNormalTexture(iWillRememberPanelIcons[11])
    iWillRememberNotes.DataBaseWrite:SetHighlightTexture(iWillRememberPanelIcons[11])
else
    iWillRememberNotes.DataBaseWrite:SetNormalTexture(iWillRememberPanelIcons[12])
    iWillRememberNotes.DataBaseWrite:SetHighlightTexture(iWillRememberPanelIcons[12])
end
iWillRememberNotes.DataBaseWrite:RegisterForClicks("AnyUp")
iWillRememberNotes.DataBaseWrite:SetScript("OnClick", function(self, button)
    if iWillRememberSettings.Import == false then
        iWillRememberSettings.Import = true
        print(L["DataImportOn"])
        iWillRememberNotes.DataBaseWrite:SetNormalTexture(iWillRememberPanelIcons[12])
        iWillRememberNotes.DataBaseWrite:SetHighlightTexture(iWillRememberPanelIcons[12])
    else
        iWillRememberSettings.Import = false
        print(L["DataImportOff"])
        iWillRememberNotes.DataBaseWrite:SetNormalTexture(iWillRememberPanelIcons[11])
        iWillRememberNotes.DataBaseWrite:SetHighlightTexture(iWillRememberPanelIcons[11])
    end
end)

iWillRememberNotes.EditBoxName = CreateFrame("EditBox", "iWillRememberNotes.EditBoxName", iWillRememberNotes)
iWillRememberNotes.EditBoxName:SetPoint("CENTER", iWillRememberNotes, "CENTER", 2, -29)
iWillRememberNotes.EditBoxName:SetSize(90, 16)
iWillRememberNotes.EditBoxName:SetAltArrowKeyMode(false)
iWillRememberNotes.EditBoxName:SetAutoFocus(false)
iWillRememberNotes.EditBoxName:SetFontObject(GameFontHighlightSmall)
iWillRememberNotes.EditBoxName:SetMaxLetters(14)
iWillRememberNotes.EditBoxName:SetText(L["EditboxName"])

iWillRememberNotes.EditBoxName:SetScript("OnEditFocusGained", function(self)
    if iWillRememberNotes.EditBoxName:GetText() == L["EditboxName"] then
        iWillRememberNotes.EditBoxName:SetText("")
    end
end)

iWillRememberNotes.EditBoxName:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["EditboxName"])
    end
end)

iWillRememberNotes.EditBoxName:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["EditboxName"])
    end
end)

iWillRememberNotes.EditBoxNote = CreateFrame("EditBox", "iWillRememberNotes.EditBoxNote", iWillRememberNotes)
iWillRememberNotes.EditBoxNote:SetPoint("CENTER", iWillRememberNotes, "CENTER", 0, -66)
iWillRememberNotes.EditBoxNote:SetSize(165, 16)
iWillRememberNotes.EditBoxNote:SetAltArrowKeyMode(false)
iWillRememberNotes.EditBoxNote:SetAutoFocus(false)
iWillRememberNotes.EditBoxNote:SetFontObject(GameFontHighlightSmall)
iWillRememberNotes.EditBoxNote:SetMaxLetters(35)
iWillRememberNotes.EditBoxNote:SetText(L["EditboxNote"])

iWillRememberNotes.EditBoxNote:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["EditboxNote"] then
        self:SetText("")
    end
end)

iWillRememberNotes.EditBoxNote:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["EditboxNote"])
    end
end)

iWillRememberNotes.EditBoxNote:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["EditboxNote"])
    end
end)