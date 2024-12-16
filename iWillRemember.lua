iWillRemember = LibStub("AceAddon-3.0"):NewAddon("iWillRemember", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("iWillRemember")

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Variables                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local CurrDataTime
local CompDataTime

local InGroup
local success
local SerializedCash
local TempTable = {}
local CashTable = {}
local TimeTable = {}
 
RememberYouDatabase = {}
RememberYouSettings = {}

local RememberYouTargetFrames = {
"PlaceHolder", --// First index 1
"Interface\\AddOns\\iWillRemember\\Img\\TargetFrames\\RedWings.blp", --// Ненавистный 2
"Interface\\AddOns\\iWillRemember\\Img\\TargetFrames\\Red.blp", --// Неприятель 3
"Interface\\AddOns\\iWillRemember\\Img\\TargetFrames\\Green.blp", --// Дружественный 4
"Interface\\AddOns\\iWillRemember\\Img\\TargetFrames\\GreenWings.blp", --// Превозносимый 5
"Interface\\AddOns\\iWillRemember\\Img\\TargetFrames\\BlueWings.blp", --// 6
"Interface\\AddOns\\iWillRemember\\Img\\TargetFrames\\Neutral.blp", --// 7
}

local RememberYouIcons = {
"Interface\\AddOns\\iWillRemember\\Img\\Icons\\Custom.blp", --// Кастомная заметка 1
"Interface\\AddOns\\iWillRemember\\Img\\Icons\\Skull.blp", --// Ненавистный 2
"Interface\\AddOns\\iWillRemember\\Img\\Icons\\Dislike.blp", --// Неприятель 3
"Interface\\AddOns\\iWillRemember\\Img\\Icons\\Like.blp", --// Дружественный 4
"Interface\\AddOns\\iWillRemember\\Img\\Icons\\Friend.blp", --// Превозносимый 5
}

local RememberYouPanelIcons = {
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Custom.blp",      -- 1
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Skull.blp",       -- 2
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Dislike.blp",     -- 3
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Like.blp",        -- 4
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Friend.blp",      -- 5
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Note.blp",        -- 6
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Custom1.blp",     -- 7
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Custom2.blp",     -- 8
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Custom3.blp",     -- 9
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\Custom4.blp",     -- 10
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\ImportOff.blp",   -- 11
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\ImportOn.blp",    -- 12
"Interface\\AddOns\\iWillRemember\\Img\\Panel\\editicon.blp",    -- 13
}

local RememberYouPanelSkins = {
"Interface\\AddOns\\iWillRemember\\Img\\Skins\\Skin1.blp",
"Interface\\AddOns\\iWillRemember\\Img\\Skins\\Skin2.blp",
"Interface\\AddOns\\iWillRemember\\Img\\Skins\\Skin3.blp",
"Interface\\AddOns\\iWillRemember\\Img\\Skins\\Skin4.blp",
}

local RememberYouColour = {
"", --// Кастомная заметка 1
"|cffff2121", --// Ненавистный 2
"|cfffb9038", --// Неприятель 3
"|cff80f451", --// Дружественный 4
"|cff80f451", --// Превозносимый 5
}


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                                  Funcs                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local function IsNeedToUpdate(CurrDataTime, CompDataTime)
    if tonumber(CurrDataTime) < tonumber(CompDataTime) then
        return true
    end
end

local function GetCurrentTimeByHours()
local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay)*24 + tonumber(CurrMonth)*720 + tonumber(CurrYear)*8640
    return tonumber(CurrentTime)
end

function iWillRemember:EditboxNameHasText()
 if RememberYouNotes.EditBoxName:GetText() ~= L["RYEditboxName"] and RememberYouNotes.EditBoxName:GetText() ~= "" and RememberYouNotes.EditBoxName:GetText() ~= nil and (not string.find( RememberYouNotes.EditBoxName:GetText(), "^%s+$")) then
    return true
 end
end

function iWillRemember:EditboxNoteHasText()
 if RememberYouNotes.EditBoxNote:GetText() ~= L["RYEditboxNote"] and RememberYouNotes.EditBoxNote:GetText() ~= "" and RememberYouNotes.EditBoxNote:GetText() ~= nil and (not string.find( RememberYouNotes.EditBoxNote:GetText(), "^%s+$")) then
    return true
 end
end

function iWillRemember:ClearEditboxes()
    RememberYouNotes.EditBoxName:ClearFocus()
    RememberYouNotes.EditBoxNote:ClearFocus()
    RememberYouNotes.EditBoxName:SetText(L["RYEditboxName"])
    RememberYouNotes.EditBoxNote:SetText(L["RYEditboxNote"])
end


function iWillRemember:SortNotesByType(Notelevel)
    if iWillRemember:EditboxNameHasText() then
        if iWillRemember:EditboxNoteHasText() then
            iWillRemember:CreateNote(tostring(RememberYouNotes.EditBoxName:GetText()), tostring(RememberYouNotes.EditBoxNote:GetText()), Notelevel)
        else
            iWillRemember:CreateNote(tostring(RememberYouNotes.EditBoxName:GetText()), Notelevel, Notelevel)
        end
    else
        if UnitIsPlayer("target") then
            if iWillRemember:EditboxNoteHasText() then
                iWillRemember:CreateNote(tostring(GetUnitName("target", false)), tostring(RememberYouNotes.EditBoxNote:GetText()), Notelevel)
            else
                iWillRemember:CreateNote(tostring(GetUnitName("target", false)), Notelevel, Notelevel)
            end
        else
            print(L["RYNoTarget"])
        end
    end
iWillRemember:ClearEditboxes()
end

-- Sending Latest note only to friendslist
function iWillRemember:SendNewDBUpdateToFriends()
    -- Loop through all friends in the friend list
    for i = 1, C_FriendList.GetNumFriends() do
        -- Get friend's info (which includes friendName)
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        -- Extract the friend's name from the table
        local friendName = friendInfo and friendInfo.name
        -- Ensure friendName is valid before printing
        if friendName then
            iWillRemember:SendCommMessage("RYOneUpdate", SerializedCash, "WHISPER", friendName)
            print("DEBUG: Successfully shared new RememberYou note to: " .. friendName)
        else
            print("No friend found at index " .. i)
        end
    end
end

-- Sending new note only to friendslist
function iWillRemember:SendFullDBUpdateToFriends()
    if RememberYouSettings.Import ~= false then
        -- Loop through all friends in the friend list
        for i = 1, C_FriendList.GetNumFriends() do
            -- Get friend's info (which includes friendName)
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            -- Extract the friend's name from the table
            local friendName = friendInfo and friendInfo.name
            -- Ensure friendName is valid before printing
            if friendName then
                wipe(TimeTable)
                local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
                local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay)*24 + tonumber(CurrMonth)*720 + tonumber(CurrYear)*8640
                    for k,v in pairs(RememberYouDatabase) do
                        if (RememberYouDatabase[k][3] - CurrentTime) > -800 then --// Update only recent 33 days (800 h)
                            TimeTable[k] = RememberYouDatabase[k]
                        end
                    end       
                    TimeTableToSend = iWillRemember:Serialize(TimeTable)
                    iWillRemember:SendCommMessage("RYFullUpdate", TimeTableToSend, "WHISPER", friendName)
                    print("DEBUG: Successfully shared all RememberYou notes to: " .. friendName)
            else
                print("No friend found at index " .. i)
            end
        end
    end
end

-- Create new note
function iWillRemember:CreateNote(name, note, frameicon)
RememberYouDatabase[tostring(name)] = {
        note,
        frameicon,
        GetCurrentTimeByHours(),
    }
TargetFrame_Update(TargetFrame)

    if RememberYouSettings.Import ~= false then
        wipe(CashTable)
        CashTable[tostring(name)] = {
                note,
                frameicon,
                GetCurrentTimeByHours(),
            }
    SerializedCash = iWillRemember:Serialize(CashTable)
    iWillRemember:SendNewDBUpdateToFriends()
    end
print(L["RYNotifyBase"] .. tostring(name) .. L["RYNotifyEnd"])
end

-- Sending Latest note only
function iWillRemember:OnFullNotesCommReceived(prefix, message, distribution, sender)
if GetUnitName("player", false) == sender then return end
   success, FullNotesTable = iWillRemember:Deserialize(message)
    
    if not success then
      print("Error")
    else
        print(L["RYDataReceived"] .. sender)
        for k,v in pairs(FullNotesTable) do
            if RememberYouDatabase[k] then
                if IsNeedToUpdate((RememberYouDatabase[k][3]), v[3]) then
                    RememberYouDatabase[k] = v
                end
            else
                RememberYouDatabase[k] = v
            end
        end
    end
end

function iWillRemember:OnNewNoteCommReceived(prefix, message, distribution, sender)
if GetUnitName("player", false) == sender then return end
   success, TempTable = iWillRemember:Deserialize(message)
    
    if not success then
      print("Error")
    else
      for k,v in pairs(TempTable) do
            RememberYouDatabase[k] = v
      end
      print(L["RYDataReceived"]+sender)
    end
    wipe(TempTable)
end

-- function iWillRemember:SendRecentNotes()
-- wipe(TimeTable)

-- local CurrHour, CurrDay, CurrMonth, CurrYear = strsplit("/", date("%H/%d/%m/%y"), 4)
-- local CurrentTime = tonumber(CurrHour) + tonumber(CurrDay)*24 + tonumber(CurrMonth)*720 + tonumber(CurrYear)*8640
--     for k,v in pairs(RememberYouDatabase) do
--         if (RememberYouDatabase[k][3] - CurrentTime) > -800 then --// Update only recent 33 days (800 h)
--             TimeTable[k] = RememberYouDatabase[k]
--         end
--     end
    
--     TimeTableToSend = iWillRemember:Serialize(TimeTable)
--     iWillRemember:SendCommMessage("RYFullUpdate", TimeTableToSend, "PARTY")
--     print(L["RYDataSharedRecent"])
-- end

-- function iWillRemember:SendFullNotes()  
-- wipe(TimeTable) 
--     TimeTableToSend = iWillRemember:Serialize(RememberYouDatabase)
--     iWillRemember:SendCommMessage("RYFullUpdate", TimeTableToSend, "PARTY")
--     print(L["RYDataSharedFull"])
    
-- end

local function OnCombatEnter(self, event)
    RememberYouNotes:Hide()
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
        if RememberYouDatabase[tostring(name)] then
            if tonumber(RememberYouDatabase[tostring(name)][1]) then
                if tonumber(RememberYouDatabase[tostring(name)][1]) > 1 and tonumber(RememberYouDatabase[tostring(name)][1]) <= getn(L["RememberYouDefaultNotes"]) then
                    GameTooltip:AddLine(L["RememberYouDefaultNotes"][tonumber(RememberYouDatabase[tostring(name)][1])])
                end
            else
                GameTooltip:AddLine(L["RYStartNote"]..RememberYouColour[tonumber(RememberYouDatabase[tostring(name)][2])] .. tostring(RememberYouDatabase[tostring(name)][1]).."|r")
            end
        end
    end
end

function iWillRemember:SetTargetingFrame()
if not RememberYouDatabase[GetUnitName("target", false)] then return end

    if RememberYouDatabase[tostring(GetUnitName("target", false))][2] > 1 then
            TargetFrameTextureFrameTexture:SetTexture(RememberYouTargetFrames[RememberYouDatabase[tostring(GetUnitName("target", false))][2]]);
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

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                               Name Plates                               ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local RememberYouNamePlate = CreateFrame("frame")
RememberYouNamePlate:RegisterEvent("NAME_PLATE_UNIT_ADDED")
RememberYouNamePlate:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
RememberYouNamePlate:SetScript("OnEvent", function(self, event, ...) 
if event == "NAME_PLATE_UNIT_ADDED" then
    local unitID = ...
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    if not nameplate.RYIndicator then
            nameplate.RYIndicator = nameplate:CreateTexture(nil, "OVERLAY")
            nameplate.RYIndicator:SetTexture(nil)
            nameplate.RYIndicator:SetSize(30,30)
            nameplate.RYIndicator:SetPoint("RIGHT", 30, -5)
    end
    if RememberYouDatabase[GetUnitName(unitID, false)] then
        nameplate.RYIndicator:SetTexture(RememberYouIcons[RememberYouDatabase[GetUnitName(unitID, false)][2]])
        nameplate.RYIndicator:Show()
    else
        nameplate.RYIndicator:SetTexture(nil)
    end
 
elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    if nameplate.RYIndicator then 
        nameplate.RYIndicator:SetTexture(nil)
        if RememberYouDatabase[GetUnitName(unitID, false)] then
            nameplate.RYIndicator:SetTexture(RememberYouIcons[RememberYouDatabase[GetUnitName(unitID, false)][2]])
        end
        nameplate.RYIndicator:Hide()
    end
end
end)

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                                 ENABLE                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function iWillRemember:OnEnable()
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update",  "SetTargetingFrame")

    print(L["RYOnLoad"])

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                             Minimap Button                              ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    -- Create the main launcher button
    LDB:NewDataObject("RememberYou", {
        type = "launcher",
        text = "Remember You",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(clickedframe, button)
            if RememberYouNotes:IsVisible() then
                RememberYouNotes:Hide()
            else
                RememberYouNotes:Show()
            end
        end,
    })

    -- Create the minimap button (DataObject for the minimap button)
    local minimapButton = LDB:NewDataObject("iWillRemember_MinimapButton", {
        type = "data source",
        text = "Remember You",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        OnClick = function(self, button)
            if RememberYouNotes:IsVisible() then
                RememberYouNotes:Hide()
            else
                RememberYouNotes:Show()
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
--[[                           STARTING FUNCTIONS                            ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    

    if not RememberYouSettings.Skin then RememberYouSettings.Skin = 2 end
    RememberYouNotes.ArtWork:SetTexture(RememberYouPanelSkins[tonumber(RememberYouSettings.Skin)]);

    if RememberYouSettings.Import ~= false then
        iWillRemember:RegisterComm("RYFullUpdate", "OnFullNotesCommReceived")
        iWillRemember:RegisterComm("RYOneUpdate", "OnNewNoteCommReceived")
        iWillRemember:SendFullDBUpdateToFriends()
    end
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Frames                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local RememberYouNotes = CreateFrame("Frame", "RememberYouNotes", UIParent)
    RememberYouNotes:SetWidth(350)
    RememberYouNotes:SetHeight(250)
    RememberYouNotes:Hide()
    RememberYouNotes:SetPoint("CENTER", UIParent, "CENTER")
    RememberYouNotes:EnableMouse()
    RememberYouNotes:SetMovable(true)
    RememberYouNotes:SetFrameStrata("MEDIUM")
    RememberYouNotes:SetScript("OnDragStart", function(self) self:StartMoving() end)
    RememberYouNotes:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    RememberYouNotes:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
    RememberYouNotes:RegisterForDrag("LeftButton", "RightButton")
    RememberYouNotes:SetClampedToScreen(true)

local floatingText = RememberYouNotes:CreateFontString(nil, "OVERLAY")
    floatingText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    floatingText:SetText(L["VersionNumber"])
    floatingText:SetPoint("CENTER", RememberYouNotes, "CENTER", 120, 65)
    floatingText:SetTextColor(1, 1, 0)

local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:SetScript("OnEvent", OnCombatEnter)

--[[RememberYouNotes:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
RememberYouNotes:SetBackdropColor(0, 0, 0, 1)]]

RememberYouNotes.ArtWork = RememberYouNotes:CreateTexture()
RememberYouNotes.ArtWork:SetTexture("Interface\\AddOns\\iWillRemember\\Img\\Skins\\Skin2.blp");
RememberYouNotes.ArtWork:SetTexCoord(0, 0.551, 0, 0.801)
RememberYouNotes.ArtWork:SetPoint("CENTER", 0, 0)
RememberYouNotes.ArtWork:SetDrawLayer("ARTWORK", 1)
RememberYouNotes.ArtWork:SetSize(338.4, 246)
RememberYouNotes.ArtWork:SetAlpha(0.97)
--RememberYouNotes.ArtWork:SetSize(282, 229)

RememberYouNotes.FriendButton = CreateFrame("BUTTON", "RememberYouNotes.FriendButton", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.FriendButton:SetSize(43, 43)
RememberYouNotes.FriendButton:SetAlpha(0.8)
RememberYouNotes.FriendButton:SetPoint("CENTER", RememberYouNotes, "CENTER", -120, 28)
RememberYouNotes.FriendButton:SetNormalTexture(RememberYouPanelIcons[5])
RememberYouNotes.FriendButton:SetHighlightTexture(RememberYouPanelIcons[5])
RememberYouNotes.FriendButton:RegisterForClicks("AnyUp")
RememberYouNotes.FriendButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(5)
end)

RememberYouNotes.LikeButton = CreateFrame("BUTTON", "RememberYouNotes.LikeButton", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.LikeButton:SetSize(43, 43)
RememberYouNotes.LikeButton:SetAlpha(0.8)
RememberYouNotes.LikeButton:SetPoint("CENTER", RememberYouNotes, "CENTER", -60, 28)
RememberYouNotes.LikeButton:SetNormalTexture(RememberYouPanelIcons[4])
RememberYouNotes.LikeButton:SetHighlightTexture(RememberYouPanelIcons[4])
RememberYouNotes.LikeButton:RegisterForClicks("AnyUp")
RememberYouNotes.LikeButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(4)
end)

RememberYouNotes.CustomButton = CreateFrame("BUTTON", "RememberYouNotes.CustomButton", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.CustomButton:SetSize(43, 43)
RememberYouNotes.CustomButton:SetAlpha(0.8)
RememberYouNotes.CustomButton:SetPoint("CENTER", RememberYouNotes, "CENTER", 0, 28)
RememberYouNotes.CustomButton:SetNormalTexture(RememberYouPanelIcons[1])
RememberYouNotes.CustomButton:SetHighlightTexture(RememberYouPanelIcons[1])
RememberYouNotes.CustomButton:RegisterForClicks("AnyUp")
RememberYouNotes.CustomButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(0)
end)

RememberYouNotes.DisLikeButton = CreateFrame("BUTTON", "RememberYouNotes.DisLikeButton", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.DisLikeButton:SetSize(43, 43)
RememberYouNotes.DisLikeButton:SetAlpha(0.8)
RememberYouNotes.DisLikeButton:SetPoint("CENTER", RememberYouNotes, "CENTER", 60, 28)
RememberYouNotes.DisLikeButton:SetNormalTexture(RememberYouPanelIcons[3])
RememberYouNotes.DisLikeButton:SetHighlightTexture(RememberYouPanelIcons[3])
RememberYouNotes.DisLikeButton:RegisterForClicks("AnyUp")
RememberYouNotes.DisLikeButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(3)
end)

RememberYouNotes.SkullButton = CreateFrame("BUTTON", "RememberYouNotes.SkullButton", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.SkullButton:SetSize(43, 43)
RememberYouNotes.SkullButton:SetAlpha(0.8)
RememberYouNotes.SkullButton:SetPoint("CENTER", RememberYouNotes, "CENTER", 120, 28)
RememberYouNotes.SkullButton:SetNormalTexture(RememberYouPanelIcons[2])
RememberYouNotes.SkullButton:SetHighlightTexture(RememberYouPanelIcons[2])
RememberYouNotes.SkullButton:RegisterForClicks("AnyUp")
RememberYouNotes.SkullButton:SetScript("OnClick", function(self, button)
    iWillRemember:SortNotesByType(2)
end)

RememberYouNotes.ToggleSkin = CreateFrame("BUTTON", "RememberYouNotes.ToggleSkin", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.ToggleSkin:SetSize(43, 43)
RememberYouNotes.ToggleSkin:SetAlpha(0.8)
RememberYouNotes.ToggleSkin:SetPoint("CENTER", RememberYouNotes, "CENTER", -130, -70)
RememberYouNotes.ToggleSkin:SetNormalTexture(RememberYouPanelIcons[13])
RememberYouNotes.ToggleSkin:SetHighlightTexture(RememberYouPanelIcons[13])
RememberYouNotes.ToggleSkin:RegisterForClicks("AnyUp")
RememberYouNotes.ToggleSkin:SetScript("OnClick", function(self, button)
    RememberYouSettings.Skin = RememberYouSettings.Skin+1
    if RememberYouSettings.Skin == 5 then
        RememberYouSettings.Skin = 1
    end
    RememberYouNotes.ArtWork:SetTexture(RememberYouPanelSkins[tonumber(RememberYouSettings.Skin)]);
    print(L["RYSetSkinToggle"])
end)

RememberYouNotes.DataBaseWrite = CreateFrame("BUTTON", "RememberYouNotes.DataBaseWrite", RememberYouNotes, "SecureHandlerClickTemplate");
RememberYouNotes.DataBaseWrite:SetSize(43, 43)
RememberYouNotes.DataBaseWrite:SetAlpha(0.8)
RememberYouNotes.DataBaseWrite:SetPoint("CENTER", RememberYouNotes, "CENTER", 130, -70)
if RememberYouSettings.Import == false then
    RememberYouNotes.DataBaseWrite:SetNormalTexture(RememberYouPanelIcons[11])
    RememberYouNotes.DataBaseWrite:SetHighlightTexture(RememberYouPanelIcons[11])
else
    RememberYouNotes.DataBaseWrite:SetNormalTexture(RememberYouPanelIcons[12])
    RememberYouNotes.DataBaseWrite:SetHighlightTexture(RememberYouPanelIcons[12])
end
RememberYouNotes.DataBaseWrite:RegisterForClicks("AnyUp")
RememberYouNotes.DataBaseWrite:SetScript("OnClick", function(self, button)
    if RememberYouSettings.Import == false then
        RememberYouSettings.Import = true
        print(L["RYDataImportOn"])
        RememberYouNotes.DataBaseWrite:SetNormalTexture(RememberYouPanelIcons[12])
        RememberYouNotes.DataBaseWrite:SetHighlightTexture(RememberYouPanelIcons[12])
    else
        RememberYouSettings.Import = false
        print(L["RYDataImportOff"])
        RememberYouNotes.DataBaseWrite:SetNormalTexture(RememberYouPanelIcons[11])
        RememberYouNotes.DataBaseWrite:SetHighlightTexture(RememberYouPanelIcons[11])
    end
end)

RememberYouNotes.EditBoxName = CreateFrame("EditBox", "RememberYouNotes.EditBoxName", RememberYouNotes)
RememberYouNotes.EditBoxName:SetPoint("CENTER", RememberYouNotes, "CENTER", 2, -29)
RememberYouNotes.EditBoxName:SetSize(90, 16)
RememberYouNotes.EditBoxName:SetAltArrowKeyMode(false)
RememberYouNotes.EditBoxName:SetAutoFocus(false)
RememberYouNotes.EditBoxName:SetFontObject(GameFontHighlightSmall)
RememberYouNotes.EditBoxName:SetMaxLetters(14)
RememberYouNotes.EditBoxName:SetText(L["RYEditboxName"])

RememberYouNotes.EditBoxName:SetScript("OnEditFocusGained", function(self)
    if RememberYouNotes.EditBoxName:GetText() == L["RYEditboxName"] then
        RememberYouNotes.EditBoxName:SetText("")
    end
end)

RememberYouNotes.EditBoxName:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["RYEditboxName"])
    end
end)

RememberYouNotes.EditBoxName:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["RYEditboxName"])
    end
end)

RememberYouNotes.EditBoxNote = CreateFrame("EditBox", "RememberYouNotes.EditBoxNote", RememberYouNotes)
RememberYouNotes.EditBoxNote:SetPoint("CENTER", RememberYouNotes, "CENTER", 0, -66)
RememberYouNotes.EditBoxNote:SetSize(165, 16)
RememberYouNotes.EditBoxNote:SetAltArrowKeyMode(false)
RememberYouNotes.EditBoxNote:SetAutoFocus(false)
RememberYouNotes.EditBoxNote:SetFontObject(GameFontHighlightSmall)
RememberYouNotes.EditBoxNote:SetMaxLetters(35)
RememberYouNotes.EditBoxNote:SetText(L["RYEditboxNote"])

RememberYouNotes.EditBoxNote:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["RYEditboxNote"] then
        self:SetText("")
    end
end)

RememberYouNotes.EditBoxNote:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["RYEditboxNote"])
    end
end)

RememberYouNotes.EditBoxNote:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    if self:GetText() == "" or self:GetText() == nil then
        self:SetText(L["RYEditboxNote"])
    end
end)


--RememberYouOpenButton = CreateFrame("BUTTON", "RememberYouOpenButton", UIParent, "SecureHandlerClickTemplate");
--RememberYouOpenButton:SetSize(40, 40)
--RememberYouOpenButton:SetAlpha(0.95)
--RememberYouOpenButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
--RememberYouOpenButton:SetNormalTexture(RememberYouPanelIcons[6])
--RememberYouOpenButton:SetHighlightTexture(RememberYouPanelIcons[6])
--RememberYouOpenButton:RegisterForClicks("AnyUp")
--RememberYouOpenButton:SetScript("OnClick", function(self, button)
--    if RememberYouNotes:IsVisible() then
--        RememberYouNotes:Hide()
--    else
--        RememberYouNotes:Show()
--    end
--end)
--RememberYouOpenButton:EnableMouse()
--RememberYouOpenButton:SetMovable(true)
--RememberYouOpenButton:SetFrameStrata("MEDIUM")
--RememberYouOpenButton:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
--RememberYouOpenButton:SetScript("OnMouseDown", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
--RememberYouOpenButton:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
--RememberYouOpenButton:RegisterForDrag("LeftButton", "RightButton")
--RememberYouOpenButton:SetClampedToScreen(true)

--RememberYouNotes.CloseButton = CreateFrame("BUTTON", "RememberYouNotes.CloseButton", RememberYouNotes, "SecureHandlerClickTemplate");
--RememberYouNotes.CloseButton:SetSize(45, 45)
--RememberYouNotes.CloseButton:SetAlpha(0.95)
--RememberYouNotes.CloseButton:SetPoint("CENTER", RememberYouNotes, "CENTER", 2, 102)
--RememberYouNotes.CloseButton:SetNormalTexture(nil)
--RememberYouNotes.CloseButton:SetHighlightTexture(RememberYouPanelIcons[6])
--RememberYouNotes.CloseButton:RegisterForClicks("AnyUp")
--RememberYouNotes.CloseButton:SetScript("OnClick", function(self, button)
--    if RememberYouNotes:IsVisible() then
--        RememberYouNotes:Hide()
--    else
--        RememberYouNotes:Show()
--    end
--end)

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Slash-Commands                             ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- These dont seem to work.

SLASH_REMYOU1 = "/rememberyou"
SLASH_REMYOU2 = "/ry"
SlashCmdList["REMYOU"] = function(msg)
local msg, arg1, arg2, arg3 = strsplit(" ", msg, 4)
if strlower(msg) == "help" then
    print(L["RYHelp1"])
    print(L["RYHelp2"])
    print(L["RYHelp3"])
    print(L["RYHelp4"])
    print(L["RYHelp5"])
    print(L["RYHelp6"])
    print(L["RYHelp7"])
    print(L["RYHelp8"])
elseif strlower(msg) == "data" then
    if strlower(arg1) == "reset" then
        wipe(RememberYouDatabase)
        print(L["RYDataReset"])
    elseif strlower(arg1) == "send" and strlower(arg2) == "recent" then
        iWillRemember:SendRecentNotes()
        print(L["RYDataSendRecent"])
    elseif strlower(arg1) == "send" and strlower(arg2) == "full" then
        iWillRemember:SendFullNotes()
        print(L["RYDataSendFull"])
    end
elseif strlower(msg) == "import" then
    if strlower(arg1) == "on" then
        RememberYouSettings.Import = true
        print(L["RYDataImportOn"])
    elseif strlower(arg1) == "off" then
        RememberYouSettings.Import = false
        print(L["RYDataImportOff"])
    end
elseif strlower(msg) == "skin" then
    if tonumber(arg1) > 0 and tonumber(arg1) <= getn(RememberYouPanelSkins) then
        RememberYouSettings.Skin = tonumber(arg1)
        RememberYouNotes.ArtWork:SetTexture(RememberYouPanelSkins[tonumber(RememberYouSettings.Skin)]);
        print(L["RYSetSkin"])
    end
else
    print(L["RYHelp1"])
    print(L["RYHelp2"])
    print(L["RYHelp3"])
    print(L["RYHelp4"])
    print(L["RYHelp5"])
    print(L["RYHelp6"])
    print(L["RYHelp7"])
    print(L["RYHelp8"])
end
end
