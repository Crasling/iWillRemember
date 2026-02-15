-- ═══════════════════════════════════════════════════════════════════════
-- ██╗ ██╗    ██╗ ██████╗     ███████╗ ██████╗   █████╗  ███╗   ███╗ ███████╗ ███████╗
-- ╚═╝ ██║    ██║ ██╔══██╗    ██╔════╝ ██╔══██╗ ██╔══██╗ ████╗ ████║ ██╔════╝ ██╔════╝
-- ██║ ██║ █╗ ██║ ██████╔╝    █████╗   ██████╔╝ ███████║ ██╔████╔██║ █████╗   ███████╗
-- ██║ ██║███╗██║ ██  ██╔     ██╔══╝   ██  ██╔  ██╔══██║ ██║╚██╔╝██║ ██╔══╝   ╚════██║
-- ██║ ╚███╔███╔╝ ██   ██╗    ██║      ██   ██  ██║  ██║ ██║ ╚═╝ ██║ ███████╗ ███████║
-- ╚═╝  ╚══╝╚══╝  ╚══════╝    ╚═╝      ╚═════╝  ╚═╝  ╚═╝ ╚═╝     ╚═╝ ╚══════╝ ╚══════╝
-- ═══════════════════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                      Frames                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Main Panel
iWRPanel = iWR:CreateiWRStyleFrame(UIParent, 350, 250, {"CENTER", UIParent, "CENTER"})
iWRPanel:Hide()
iWRPanel:EnableMouse(true)
iWRPanel:SetMovable(true)
iWRPanel:SetFrameStrata("MEDIUM")
iWRPanel:SetClampedToScreen(true)

-- Add a shadow effect
local shadow = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
shadow:SetPoint("TOPLEFT", iWRPanel, -1, 1)
shadow:SetPoint("BOTTOMRIGHT", iWRPanel, 1, -1)
shadow:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 5,
})
shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

-- Drag and Drop functionality
iWRPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRPanel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
iWRPanel:RegisterForDrag("LeftButton", "RightButton")

-- ╭──────────────────────────────────╮
-- │      Create Main Panel title     │
-- ╰──────────────────────────────────╯
local titleBar = CreateFrame("Frame", nil, iWRPanel, "BackdropTemplate")
titleBar:SetSize(iWRPanel:GetWidth(), 31)
titleBar:SetPoint("TOP", iWRPanel, "TOP", 0, 0)
titleBar:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = {left = 5, right = 5, top = 5, bottom = 5},
})
titleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

-- Add title text
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
titleText:SetText(iWR.Colors.iWR .. "iWillRemember Menu" .. iWR.Colors.Green .. " v" .. iWR.Version)
titleText:SetTextColor(0.9, 0.9, 1, 1)


-- ╭───────────────────────────────────╮
-- │      Main Panel close button      │
-- ╰───────────────────────────────────╯
local closeButton = CreateFrame("Button", nil, iWRPanel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", iWRPanel, "TOPRIGHT", 0, 0)
closeButton:SetScript("OnClick", function()
    iWR:MenuClose()
end)

-- ╭───────────────────────────────────────────╮
-- │      Main Panel Name And Note Inputs      │
-- ╰───────────────────────────────────────────╯
local playerNameTitle = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
playerNameTitle:SetPoint("TOP", titleBar, "BOTTOM", 0, -10)
playerNameTitle:SetText("Player Name")
playerNameTitle:SetTextColor(0.9, 0.9, 1, 1)

iWRNameInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNameInput:SetSize(155, 30)
iWRNameInput:SetPoint("TOP", playerNameTitle, "BOTTOM", 0, -1)
iWRNameInput:SetMaxLetters(40)
iWRNameInput:SetAutoFocus(false)
iWRNameInput:SetTextColor(1, 1, 1, 1)
iWRNameInput:SetText(L["DefaultNameInput"])
iWRNameInput:SetFontObject(GameFontHighlight)
iWRNameInput:SetJustifyH("CENTER")

-- Clear the text when focused and it matches the default text
iWRNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNameInput"] then
        self:SetText("")
    end
end)

-- Reset to default text if left empty
iWRNameInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetText(L["DefaultNameInput"]) -- Reset to default text
    end
end)

-- Remove color codes when the text changes
iWRNameInput:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        local text = self:GetText()
        local cleanedText = StripColorCodes(text)
        if text ~= cleanedText then
            self:SetText(cleanedText)
        end
    end
end)

local noteTitle = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noteTitle:SetPoint("TOP", iWRNameInput, "BOTTOM", 0, -5)
noteTitle:SetText("Personalized note about chosen player")
noteTitle:SetTextColor(0.9, 0.9, 1, 1)

iWRNoteInput = CreateFrame("EditBox", nil, iWRPanel, "InputBoxTemplate")
iWRNoteInput:SetSize(250, 30)
iWRNoteInput:SetPoint("TOP", noteTitle, "BOTTOM", 0, -1)
iWRNoteInput:SetMultiLine(false)
iWRNoteInput:SetMaxLetters(99)
iWRNoteInput:SetAutoFocus(false)
iWRNoteInput:SetTextColor(1, 1, 1, 1)
iWRNoteInput:SetText(L["DefaultNoteInput"])
iWRNoteInput:SetFontObject(GameFontHighlight)

-- Clear the text when focused and it matches the default text
iWRNoteInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNoteInput"] then
        self:SetText("") -- Clear the default text
    end
end)

-- Reset to default text if left empty
iWRNoteInput:SetScript("OnEditFocusLost", function(self)
    if self:GetText() == "" then
        self:SetText(L["DefaultNoteInput"]) -- Reset to default text
    end
end)

-- ╭────────────────────╮
-- │      Help Icon     │
-- ╰────────────────────╯
local helpIcon = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
helpIcon:SetSize(24, 24)
helpIcon:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -10, -5)
helpIcon:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")

-- Create a tooltip for the help icon
helpIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("How do I use iWillRemember", 1, 0.85, 0.1)
    GameTooltip:AddLine(L["HelpUse"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpSync"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpClear"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpSettings"], 1, 0.82, 0, true)
    GameTooltip:AddLine(L["HelpDiscord"], 1, 0.82, 0, true)
    GameTooltip:Show()
end)

helpIcon:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

helpIcon:SetScript("OnClick", function()
    if not iWR:VerifyInputName(iWRNameInput:GetText()) then
    iWRNoteInput:SetText("https://discord.gg/8nnt25aw8B")
    print(L["DiscordCopiedToNote"])
    end
end)

-- ╭─────────────────────────╮
-- │      Focus Handling     │
-- ╰─────────────────────────╯
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
function iWR:OnFocusGained()
    clickAwayFrame:Show()
end

-- Hook focus gained for both edit boxes
iWRNameInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNameInput"] then
        self:SetText("") -- Clear default text
    end
    iWR:OnFocusGained()
end)

iWRNoteInput:SetScript("OnEditFocusGained", function(self)
    if self:GetText() == L["DefaultNoteInput"] then
        self:SetText("") -- Clear default text
    end
    iWR:OnFocusGained()
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
local button1, button1Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", 120, -15},
    iWR:GetIcon(-5),
    iWR:GetTypeName(-5),
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWR.Types["Hated"])
    end
)

-- ╭────────────────────────────────────────╮
-- │      Main Panel Set Type Disliked      │
-- ╰────────────────────────────────────────╯
local button2, button2Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", 60, -15},
    iWR:GetIcon(-3),
    iWR:GetTypeName(-3),
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWR.Types["Disliked"])
    end
)

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Liked      │
-- ╰─────────────────────────────────────╯
local button3, button3Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", 0, -15},
    iWR:GetIcon(3),
    iWR:GetTypeName(3),
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWR.Types["Liked"])
    end
)

-- ╭─────────────────────────────────────────╮
-- │      Main Panel Set Type Respected      │
-- ╰─────────────────────────────────────────╯
local button4, button4Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", -60, -15},
    iWR:GetIcon(5),
    iWR:GetTypeName(5),
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWR.Types["Respected"])
    end
)

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Clear      │
-- ╰─────────────────────────────────────╯
local button5, button5Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", -120, -15},
    iWR.Icons[iWR.Types["Clear"]],
    "Clear",
    function()
        iWR:ClearNote(iWRNameInput:GetText())
    end
)

-- ╭────────────────────────────────────────╮
-- │   Refresh buttons on panel show        │
-- ╰────────────────────────────────────────╯
local ratingButtons = {
    {button = button1, label = button1Label, key = -5},
    {button = button2, label = button2Label, key = -3},
    {button = button3, label = button3Label, key = 3},
    {button = button4, label = button4Label, key = 5},
}

iWRPanel:HookScript("OnShow", function()
    for _, rb in ipairs(ratingButtons) do
        rb.label:SetText(iWR:GetTypeName(rb.key))
        if rb.button.iconTexture then
            rb.button.iconTexture:SetTexture(iWR:GetIcon(rb.key))
        end
    end
end)

-- ╭────────────────────────────────────────╮
-- │      Button to Open the Database       │
-- ╰────────────────────────────────────────╯
local openDatabaseButton = CreateFrame("Button", nil, iWRPanel, "UIPanelButtonTemplate")
openDatabaseButton:SetSize(34, 34)
openDatabaseButton:SetPoint("TOP", iWRNameInput, "BOTTOM", -140, 45)
openDatabaseButton:SetScript("OnClick", function()
    iWR:DatabaseToggle()
    iWR:PopulateDatabase()
    iWR:MenuClose()
end)

-- Add an icon to the openDatabaseButton
local iconTextureDB = openDatabaseButton:CreateTexture(nil, "ARTWORK")
iconTextureDB:SetSize(25, 25)
iconTextureDB:SetPoint("CENTER", openDatabaseButton, "CENTER", 0, 0)
iconTextureDB:SetTexture(iWR.Icons.Database)

-- Add a label below the button
local openDatabaseButtonLabel = iWRPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
openDatabaseButtonLabel:SetPoint("TOP", openDatabaseButton, "BOTTOM", 0, -5)
openDatabaseButtonLabel:SetText("Open DB")

-- Create Tab
function iWR:CreateTab(panel, index, name, onClick)
    -- Create the tab
    local tab = CreateFrame("Button", "$parentTab" .. index, panel, "OptionsFrameTabButtonTemplate")
    tab:SetText(name)
    tab:SetID(index)

    -- Adjust the positioning of the tabs to the top of the panel
    if index == 1 then
        tab:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -20)
    else
        tab:SetPoint("LEFT", "$parentTab" .. (index - 1), "RIGHT", -5, 0)
    end

    -- Adjust the tab size
    tab:SetScale(1.3)
    tab:SetHeight(25)

    -- Ensure the font string (text) follows the tab movement
    local fontString = tab:GetFontString()
    if fontString then
        fontString:ClearAllPoints()
        fontString:SetPoint("CENTER", tab, "CENTER")
    end
    tab:SetScript("OnClick", function()
        PanelTemplates_SetTab(panel, index)
        if onClick then
        onClick()
        fontString:SetPoint("CENTER", tab, "CENTER", 0, -2)
        end
    end)
        PanelTemplates_TabResize(tab, 0)
    return tab
end

-- Create a new frame to display the database
iWRDatabaseFrame = iWR:CreateiWRStyleFrame(UIParent, 700, 450, {"CENTER", UIParent, "CENTER"})
iWRDatabaseFrame:Hide()
iWRDatabaseFrame:EnableMouse(true)
iWRDatabaseFrame:SetMovable(true)
iWRDatabaseFrame:SetFrameStrata("MEDIUM")
iWRDatabaseFrame:SetClampedToScreen(true)
iWRDatabaseFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
iWRDatabaseFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)

-- Add a shadow effect
local dbShadow = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbShadow:SetPoint("TOPLEFT", iWRDatabaseFrame, -1, 1)
dbShadow:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, 1, -1)
dbShadow:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 5,
})
dbShadow:SetBackdropBorderColor(0, 0, 0, 0.8)

-- Drag and Drop functionality
iWRDatabaseFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
iWRDatabaseFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
iWRDatabaseFrame:RegisterForDrag("LeftButton", "RightButton")

-- Create the title bar for the database frame
local dbTitleBar = CreateFrame("Frame", nil, iWRDatabaseFrame, "BackdropTemplate")
dbTitleBar:SetSize(iWRDatabaseFrame:GetWidth(), 31)
dbTitleBar:SetPoint("TOP", iWRDatabaseFrame, "TOP", 0, 0)
dbTitleBar:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = {left = 5, right = 5, top = 5, bottom = 5},
})
dbTitleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

-- Add title text
local dbTitleText = dbTitleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
dbTitleText:SetPoint("CENTER", dbTitleBar, "CENTER", 0, 0)
dbTitleText:SetText(iWR.Colors.iWR .. "iWillRemember Personal Database")
dbTitleText:SetTextColor(0.9, 0.9, 1, 1)

-- Create a close button for the database frame
local dbCloseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelCloseButton")
dbCloseButton:SetPoint("TOPRIGHT", iWRDatabaseFrame, "TOPRIGHT", 0, 0)
dbCloseButton:SetScript("OnClick", function()
    iWR:DatabaseClose()
end)

-- ╭──────────────────────────────────────────╮
-- │      Database Frame Tab System           │
-- ╰──────────────────────────────────────────╯
local dbActiveTab = 1

-- Notes container (holds the existing database view)
local notesContainer = CreateFrame("Frame", nil, iWRDatabaseFrame)
notesContainer:SetPoint("TOPLEFT", dbTitleBar, "BOTTOMLEFT", 0, -35)
notesContainer:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, "BOTTOMRIGHT", 0, 0)
notesContainer:Show()

-- Group Log container
local groupLogContainer = CreateFrame("Frame", nil, iWRDatabaseFrame)
groupLogContainer:SetPoint("TOPLEFT", dbTitleBar, "BOTTOMLEFT", 0, -35)
groupLogContainer:SetPoint("BOTTOMRIGHT", iWRDatabaseFrame, "BOTTOMRIGHT", 0, 0)
groupLogContainer:Hide()

local function ShowDatabaseTab(tabIndex)
    dbActiveTab = tabIndex
    if tabIndex == 1 then
        notesContainer:Show()
        groupLogContainer:Hide()
    else
        notesContainer:Hide()
        groupLogContainer:Show()
        iWR:PopulateGroupLog()
    end
end

-- Tab names must match frame:GetName() .. "Tab" .. index for PanelTemplates to work
local dbFrameName = iWRDatabaseFrame:GetName()

-- Tab 1: Notes
local dbTab1 = CreateFrame("Button", dbFrameName .. "Tab1", iWRDatabaseFrame, "OptionsFrameTabButtonTemplate")
dbTab1:SetText(L["NotesTab"] or "Notes")
dbTab1:SetID(1)
dbTab1:SetPoint("TOPLEFT", dbTitleBar, "BOTTOMLEFT", 10, 5)
dbTab1:SetScale(1.0)
dbTab1:SetHeight(25)
PanelTemplates_TabResize(dbTab1, 0)
dbTab1:SetScript("OnClick", function()
    PanelTemplates_SetTab(iWRDatabaseFrame, 1)
    ShowDatabaseTab(1)
end)

-- Tab 2: Group Log
local dbTab2 = CreateFrame("Button", dbFrameName .. "Tab2", iWRDatabaseFrame, "OptionsFrameTabButtonTemplate")
dbTab2:SetText(L["GroupLogTab"] or "Group Log")
dbTab2:SetID(2)
dbTab2:SetPoint("LEFT", dbTab1, "RIGHT", -5, 0)
dbTab2:SetScale(1.0)
dbTab2:SetHeight(25)
PanelTemplates_TabResize(dbTab2, 0)
dbTab2:SetScript("OnClick", function()
    PanelTemplates_SetTab(iWRDatabaseFrame, 2)
    ShowDatabaseTab(2)
end)

PanelTemplates_SetNumTabs(iWRDatabaseFrame, 2)
PanelTemplates_SetTab(iWRDatabaseFrame, 1)

-- Reset to Notes tab (called from DatabaseOpen to always start on Notes)
function iWR:ResetDatabaseTab()
    PanelTemplates_SetTab(iWRDatabaseFrame, 1)
    ShowDatabaseTab(1)
end

-- Notes tab: scrollable frame for database entries
local dbScrollFrame = CreateFrame("ScrollFrame", nil, notesContainer, "UIPanelScrollFrameTemplate")
dbScrollFrame:SetPoint("TOPLEFT", notesContainer, "TOPLEFT", 0, 0)
dbScrollFrame:SetPoint("BOTTOMRIGHT", notesContainer, "BOTTOMRIGHT", -22, 45)

-- Create a container for the database entries (this will be scrollable)
local dbContainer = CreateFrame("Frame", nil, dbScrollFrame)
dbContainer:SetSize(dbScrollFrame:GetWidth()+10, dbScrollFrame:GetHeight()+10)
dbScrollFrame:SetScrollChild(dbContainer)

-- ╭──────────────────────────────────────────────────╮
-- │      Create the "Clear All" Database Button      │
-- ╰──────────────────────────────────────────────────╯
local clearDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
clearDatabaseButton:SetSize(100, 30)
clearDatabaseButton:SetPoint("BOTTOM", notesContainer, "BOTTOM", -60, 10)
clearDatabaseButton:SetText("Clear All")
clearDatabaseButton:SetScript("OnClick", function()
    -- Confirm before clearing the database
    StaticPopupDialogs["CLEAR_DATABASE_CONFIRM"] = {
        text = iWR.Colors.Red .. "Are you sure you want to clear the current iWR Database?|nThis is non-reversible.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            iWRDatabase = {}
            print(iWR.Colors.iWR .. "[iWR]: Database cleared.")
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
local shareDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
shareDatabaseButton:SetSize(100, 30)
shareDatabaseButton:SetPoint("BOTTOM", notesContainer, "BOTTOM", 60, 10)
shareDatabaseButton:SetText("Share Full DB")
shareDatabaseButton:SetScript("OnClick", function()
    -- Check if the database is empty
    if not next(iWRDatabase) then
        print(iWR.Colors.iWR .. "[iWR]: The database is empty. Nothing to share.")
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
            print(iWR.Colors.iWR .. "[iWR]: Full database sync process initiated. This can take up to a few minutes.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SHARE_DATABASE_CONFIRM")
end)

-- ╭───────────────────────────────────────────────╮
-- │      Create the "Search Database" Button      │
-- ╰───────────────────────────────────────────────╯
local searchDatabaseButton = CreateFrame("Button", nil, notesContainer, "UIPanelButtonTemplate")
searchDatabaseButton:SetSize(30, 30)
searchDatabaseButton:SetPoint("BOTTOMLEFT", notesContainer, "BOTTOMLEFT", 10, 10)

local searchTexture = searchDatabaseButton:CreateTexture(nil, "ARTWORK")
searchTexture:SetAllPoints()
searchTexture:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03") -- Magnifying glass texture
searchDatabaseButton:SetNormalTexture(searchTexture)

searchDatabaseButton:SetScript("OnClick", function()
    -- Check if the SearchResultsFrame already exists and is visible
    if SearchResultsFrame and SearchResultsFrame:IsVisible() then
        SearchResultsFrame:Hide()
        -- Clear all child frames from the SearchResultsFrame
        for _, child in ipairs({SearchResultsFrame:GetChildren()}) do
            ---@diagnostic disable-next-line: undefined-field
            child:Hide()
            ---@diagnostic disable-next-line: undefined-field
            child:SetParent(nil)
        end
        if NoResultsText then
            NoResultsText:Hide()
            NoResultsText:SetParent(nil)
            NoResultsText = nil
        end
        if TooManyText then
            TooManyText:Hide()
            TooManyText:SetParent(nil)
            TooManyText = nil
        end
        if SearchTitle then
            SearchTitle:Hide()
            SearchTitle:SetParent(nil)
            SearchTitle = nil
        end
    end

    -- Prompt for search input
    StaticPopupDialogs["SEARCH_DATABASE"] = {
        text = "Enter the name of the player to search:",
        button1 = "Search",
        button2 = "Cancel",
        hasEditBox = true,
        OnAccept = function(self)
            local searchQuery = self.editBox:GetText()
            if searchQuery and searchQuery ~= "" then
                local foundEntries = {}
                for playerName, data in pairs(iWRDatabase) do
                    if string.find(string.lower(playerName), string.lower(searchQuery)) then
                        table.insert(foundEntries, {name = playerName, data = data})
                    end
                end

                -- Create the SearchResultsFrame if it doesn't already exist
                if not SearchResultsFrame then
                    SearchResultsFrame = iWR:CreateiWRStyleFrame(iWRDatabaseFrame, 280, 400, {"RIGHT", iWRDatabaseFrame, "RIGHT", 280, 0})
                    SearchResultsFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.9)
                    SearchResultsFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
                end

                -- Clear previous content
                for _, child in ipairs({SearchResultsFrame:GetChildren()}) do
                    ---@diagnostic disable-next-line: undefined-field
                    child:Hide()
                    ---@diagnostic disable-next-line: undefined-field
                    child:SetParent(nil)
                    if NoResultsText then
                        NoResultsText:Hide()
                        NoResultsText:SetParent(nil)
                        NoResultsText = nil
                    end
                    if TooManyText then
                        TooManyText:Hide()
                        TooManyText:SetParent(nil)
                        TooManyText = nil
                    end
                    if SearchTitle then
                        SearchTitle:Hide()
                        SearchTitle:SetParent(nil)
                        SearchTitle = nil
                    end
                end
                SearchResultsFrame:Show()

                -- Add title to the search results
                SearchTitle = SearchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                SearchTitle:SetPoint("TOP", SearchResultsFrame, "TOP", 0, -10)
                SearchTitle:SetText("Search Results for: " .. searchQuery)

                if #foundEntries > 0 then
                    local maxEntries = 7
                    for index, entry in ipairs(foundEntries) do
                        if index > maxEntries then
                            TooManyText = SearchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                            TooManyText:SetPoint("TOP", SearchResultsFrame, "TOP", 0, -40 * (maxEntries + 1))
                            TooManyText:SetText("Too many results, refine your search.")
                            break
                        end

                        local playerName, data = entry.name, entry.data

                        -- Create a frame for each entry
                        local entryFrame = CreateFrame("Frame", nil, SearchResultsFrame, "BackdropTemplate")
                        entryFrame:SetSize(230, 30)
                        entryFrame:SetPoint("TOP", SearchResultsFrame, "TOP", 0, -40 * index)

                        -- Add the icon for the type
                        local iconTexture = entryFrame:CreateTexture(nil, "ARTWORK")
                        iconTexture:SetSize(20, 20)
                        iconTexture:SetPoint("LEFT", entryFrame, "LEFT", -5, 0)

                        -- Set the icon texture
                        local typeIcon = iWR:GetIcon(data[2])
                        if typeIcon then
                            iconTexture:SetTexture(typeIcon)
                        else
                            iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback icon
                        end

                        -- Add player name and note
                        local entryText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        entryText:SetPoint("LEFT", iconTexture, "RIGHT", 5, 0)
                        if data[7] ~= iWR.CurrentRealm then
                            entryText:SetText(data[4]..iWR.Colors.Reset.."-"..data[7])
                        else
                            entryText:SetText(data[4])
                        end

                        -- Tooltip functionality
                        entryFrame:SetScript("OnEnter", function()
                            ---@diagnostic disable-next-line: param-type-mismatch
                            GameTooltip:SetOwner(entryFrame, "ANCHOR_RIGHT")
                            if data[7] ~= iWR.CurrentRealm then
                                GameTooltip:AddLine(data[4]..iWR.Colors.Reset.."-"..data[7], 1, 1, 1) -- Title (Player Name)
                            else
                                GameTooltip:AddLine(data[4], 1, 1, 1) -- Title (Player Name)
                            end
                            if #data[1] <= 30 then
                                GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0) -- Add note in tooltip
                            else
                                local firstLine, secondLine = iWR:splitOnSpace(data[1], 30) -- Split text on the nearest space
                                GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. firstLine, 1, 0.82, 0) -- Add first line
                                GameTooltip:AddLine(iWR.Colors[data[2]] .. secondLine, 1, 0.82, 0) -- Add second line
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

                        -- Add Edit button
                        local editButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
                        editButton:SetSize(50, 30)
                        editButton:SetPoint("RIGHT", entryFrame, "RIGHT", -50, 0)
                        editButton:SetText("Edit")
                        editButton.playerName = data[4] or playerName
                        editButton.note = data[1]
                        editButton:SetScript("OnClick", function(self)
                            iWR:MenuOpen(self.playerName)
                            iWRNameInput:SetText(self.playerName)
                            iWRNoteInput:SetText(self.note or "")
                        end)

                        -- Add Remove button
                        local removeButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
                        removeButton:SetSize(60, 30)
                        removeButton:SetPoint("RIGHT", editButton, "RIGHT", 60, 0)
                        removeButton:SetText("Remove")
                        removeButton:SetScript("OnClick", function()
                            local removeText
                            if iWRDatabase[playerName][7] ~= iWR.CurrentRealm then
                                removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. "-" .. iWRDatabase[playerName][7] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                            else
                                removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                            end
                            StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                                text = removeText,
                                button1 = "Yes",
                                button2 = "No",
                                OnAccept = function()
                                    print(L["CharNoteStart"] .. iWRDatabase[playerName][4]  .. L["CharNoteRemoved"])
                                    iWRDatabase[playerName] = nil
                                    if SearchResultsFrame then
                                        SearchResultsFrame:Hide()
                                    end
                                    iWR:PopulateDatabase()
                                    iWR:SendRemoveRequestToFriends(playerName)
                                end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            StaticPopup_Show("REMOVE_PLAYER_CONFIRM")
                        end)
                    end
                else
                    NoResultsText = SearchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    NoResultsText:SetPoint("CENTER", SearchResultsFrame, "CENTER", 0, 0)
                    NoResultsText:SetText("No players found for: " .. searchQuery)
                end

                local closeResultsButton = CreateFrame("Button", nil, SearchResultsFrame, "UIPanelButtonTemplate")
                closeResultsButton:SetSize(80, 24)
                closeResultsButton:SetPoint("BOTTOM", SearchResultsFrame, "BOTTOM", 0, 20)
                closeResultsButton:SetText("Close")
                closeResultsButton:SetScript("OnClick", function()
                    SearchResultsFrame:Hide()
                    for _, child in ipairs({SearchResultsFrame:GetChildren()}) do
                        ---@diagnostic disable-next-line: undefined-field
                        child:Hide()
                        ---@diagnostic disable-next-line: undefined-field
                        child:SetParent(nil)
                        if NoResultsText then
                            NoResultsText:Hide()
                            NoResultsText:SetParent(nil)
                            NoResultsText = nil
                        end
                        if TooManyText then
                            TooManyText:Hide()
                            TooManyText:SetParent(nil)
                            TooManyText = nil
                        end
                        if SearchTitle then
                            SearchTitle:Hide()
                            SearchTitle:SetParent(nil)
                            SearchTitle = nil
                        end
                    end
                end)
            end
        end,
        OnShow = function(self)
            self.editBox:SetMaxLetters(15) -- Set maximum character limit
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("SEARCH_DATABASE")
end)

-- ╭─────────────────────────────────────────╮
-- │      Function to Populate Database      │
-- ╰─────────────────────────────────────────╯
function iWR:PopulateDatabase()
    -- Create sub-containers for columns if they don't already exist
    if not dbContainer.col1 then
        dbContainer.col1 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col1:SetSize(dbContainer:GetWidth() * 0.3, dbContainer:GetHeight())
        dbContainer.col1:SetPoint("TOPLEFT", dbContainer, "TOPLEFT", 0, 0)
    end

    if not dbContainer.col2 then
        dbContainer.col2 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col2:SetSize(dbContainer:GetWidth() * 0.45, dbContainer:GetHeight())
        dbContainer.col2:SetPoint("TOPLEFT", dbContainer.col1, "TOPRIGHT", 0, 0)
    end

    if not dbContainer.col3 then
        dbContainer.col3 = CreateFrame("Frame", nil, dbContainer)
        dbContainer.col3:SetSize(dbContainer:GetWidth() * 0.25, dbContainer:GetHeight())
        dbContainer.col3:SetPoint("TOPLEFT", dbContainer.col2, "TOPRIGHT", 0, 0)
    end

    -- Reuse or hide existing frames in columns
    local function resetColumn(column)
        for _, child in ipairs({column:GetChildren()}) do
            child:Hide()
        end
    end

    resetColumn(dbContainer.col1)
    resetColumn(dbContainer.col2)
    resetColumn(dbContainer.col3)

    -- Categorize entries
    local categorizedData = {}
    for playerName, data in pairs(iWRDatabase) do
        local category = data[2] or "Uncategorized"
        categorizedData[category] = categorizedData[category] or {}
        table.insert(categorizedData[category], { name = playerName, data = data })
    end

    -- Sort categories in the correct order
    local sortedCategories = {}
    for category in pairs(categorizedData) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories, function(a, b) return a > b end)

    for _, category in ipairs(sortedCategories) do
        table.sort(categorizedData[category], function(a, b)
            return a.name < b.name
        end)
    end

    -- Iterate over categorized data and create or reuse frames
    local yOffset = -5
    local reusedFrames = { col1 = {}, col2 = {}, col3 = {} }

    for _, category in ipairs(sortedCategories) do
        if #categorizedData[category] > 0 then
            for _, entry in ipairs(categorizedData[category]) do
                local playerName, data = entry.name, entry.data

                -- Reuse or create frame in Col1 (Type Icon and Player Name)
                local col1Frame = reusedFrames.col1[#reusedFrames.col1 + 1] or CreateFrame("Frame", nil, dbContainer.col1)
                col1Frame:SetSize(dbContainer.col1:GetWidth(), 30)
                col1Frame:SetPoint("TOPLEFT", dbContainer.col1, "TOPLEFT", 0, yOffset)
                col1Frame:Show()
                table.insert(reusedFrames.col1, col1Frame)

                local iconTexture = col1Frame.iconTexture or col1Frame:CreateTexture(nil, "ARTWORK")
                iconTexture:SetSize(20, 20)
                iconTexture:SetPoint("LEFT", col1Frame, "LEFT", 10, 0)
                iconTexture:SetTexture(iWR:GetIcon(data[2]) or "Interface\\Icons\\INV_Misc_QuestionMark")
                col1Frame.iconTexture = iconTexture

                local playerNameText = col1Frame.playerNameText or col1Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                playerNameText:SetPoint("LEFT", iconTexture, "RIGHT", 10, 0)
                local displayName = data[4]
                local listdisplayName = displayName
                if data[7] and data[7] ~= iWR.CurrentRealm then
                    listdisplayName = displayName .. " (*)"
                    displayName = displayName .. "-" .. data[7]
                end
                local databasekey = StripColorCodes(data[4]) .. "-" .. data[7]
                playerNameText:SetText(iWR.Colors.iWR .. string.format("%-16s", listdisplayName))
                playerNameText:SetTextColor(1, 1, 1, 1)
                col1Frame.playerNameText = playerNameText

                -- Tooltip and Click for Name column
                col1Frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(col1Frame, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(listdisplayName, 1, 1, 1)
                    if data[7] then
                        GameTooltip:AddLine("Server: " .. iWR.Colors.Reset .. data[7], 1, 0.82, 0)
                    end
                    if data[1] then
                        GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0)
                    end
                    if data[6] then
                        GameTooltip:AddLine("Author: " .. data[6], 1, 0.82, 0)
                    end
                    if data[5] then
                        GameTooltip:AddLine("Date: " .. data[5], 1, 0.82, 0)
                    end
                    GameTooltip:Show()
                end)
                col1Frame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                col1Frame:SetScript("OnMouseDown", function()
                    iWR:ShowDetailWindow(databasekey)
                end)

                -- Reuse or create frame in Col2 (Notes)
                local col2Frame = reusedFrames.col2[#reusedFrames.col2 + 1] or CreateFrame("Frame", nil, dbContainer.col2)
                col2Frame:SetSize(dbContainer.col2:GetWidth(), 30)
                col2Frame:SetPoint("TOPLEFT", dbContainer.col2, "TOPLEFT", 0, yOffset)
                col2Frame:Show()
                table.insert(reusedFrames.col2, col2Frame)

                local noteText = col2Frame.noteText or col2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                noteText:SetPoint("LEFT", col2Frame, "LEFT", 10, 0)
                local noteColor = iWR.Colors[data[2]] or iWR.Colors.Default
                local truncatedNote = data[1] and #data[1] > 30 and data[1]:sub(1, 27) .. "..." or data[1] or ""
                noteText:SetText(noteColor .. truncatedNote)
                col2Frame.noteText = noteText

                -- Tooltip and Click for Notes column
                col2Frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(col2Frame, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(listdisplayName, 1, 1, 1)
                    if data[7] then
                        GameTooltip:AddLine("Server: " .. iWR.Colors.Reset .. data[7], 1, 0.82, 0)
                    end
                    if data[1] then
                        GameTooltip:AddLine("Note: " .. iWR.Colors[data[2]] .. data[1], 1, 0.82, 0)
                    end
                    if data[6] then
                        GameTooltip:AddLine("Author: " .. data[6], 1, 0.82, 0)
                    end
                    if data[5] then
                        GameTooltip:AddLine("Date: " .. data[5], 1, 0.82, 0)
                    end
                    GameTooltip:Show()
                end)
                col2Frame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                col2Frame:SetScript("OnMouseDown", function()
                    iWR:ShowDetailWindow(databasekey)
                end)

                -- Reuse or create frame in Col3 (Buttons)
                local col3Frame = reusedFrames.col3[#reusedFrames.col3 + 1] or CreateFrame("Frame", nil, dbContainer.col3)
                col3Frame:SetSize(dbContainer.col3:GetWidth(), 30)
                col3Frame:SetPoint("TOPLEFT", dbContainer.col3, "TOPLEFT", 0, yOffset)
                col3Frame:Show()
                table.insert(reusedFrames.col3, col3Frame)

                local editButton = col3Frame.editButton or CreateFrame("Button", nil, col3Frame, "UIPanelButtonTemplate")
                editButton:SetSize(50, 24)
                editButton:SetPoint("LEFT", col3Frame, "LEFT", 10, 0)
                editButton:SetText("Edit")
                editButton:SetScript("OnClick", function()
                    -- Check if databaseKey[7] matches the current realm
                    if data[7] == iWR.CurrentRealm then
                        -- Open with data[4]
                        iWR:MenuOpen(data[4])
                        if data[1] ~= "" or data[1] ~= nil then
                            iWRNoteInput:SetText(data[1])
                        end
                    else
                        -- Open with data[4] concatenated with "-" and data[7]
                        iWR:MenuOpen(data[4] .. "-" .. data[7])
                        if data[1] ~= "" or data[1] ~= nil then
                            iWRNoteInput:SetText(data[1])
                        end
                    end
                    -- Close the database menu
                    iWR:DatabaseClose()
                end)
                col3Frame.editButton = editButton

                local removeButton = col3Frame.removeButton or CreateFrame("Button", nil, col3Frame, "UIPanelButtonTemplate")
                removeButton:SetSize(60, 24)
                removeButton:SetPoint("LEFT", editButton, "RIGHT", 10, 0)
                removeButton:SetText("Remove")
                removeButton:SetScript("OnClick", function()
                    local removeText
                    if iWRDatabase[databasekey][7] ~= iWR.CurrentRealm then
                        removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[databasekey][4] .. "-" .. iWRDatabase[databasekey][7] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                    else
                        removeText = iWR.Colors.iWR .. "Are you sure you want to remove" .. iWR.Colors.iWR .. " |n|n[" .. iWRDatabase[databasekey][4] .. iWR.Colors.iWR .. "]|n|n from the iWR database?"
                    end
                    StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                        text = removeText,
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            print(L["CharNoteStart"] .. iWRDatabase[databasekey][4]  .. L["CharNoteRemoved"])
                            iWRDatabase[databasekey] = nil
                            if SearchResultsFrame then
                                SearchResultsFrame:Hide()
                            end
                            iWR:PopulateDatabase()
                            iWR:SendRemoveRequestToFriends(databasekey)
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3,
                    }
                    StaticPopup_Show("REMOVE_PLAYER_CONFIRM")
                end)
                col3Frame.removeButton = removeButton

                yOffset = yOffset - 30
            end
        end
    end
    dbContainer:SetHeight(math.abs(yOffset))
end

-- ╭─────────────────────────────────────────────────╮
-- │      Group Log Tab: UI & PopulateGroupLog       │
-- ╰─────────────────────────────────────────────────╯

-- Scroll frame for group log entries
local glScrollFrame = CreateFrame("ScrollFrame", nil, groupLogContainer, "UIPanelScrollFrameTemplate")
glScrollFrame:SetPoint("TOPLEFT", groupLogContainer, "TOPLEFT", 0, 0)
glScrollFrame:SetPoint("BOTTOMRIGHT", groupLogContainer, "BOTTOMRIGHT", -22, 45)

local glContainer = CreateFrame("Frame", nil, glScrollFrame)
glContainer:SetSize(glScrollFrame:GetWidth() + 10, glScrollFrame:GetHeight() + 10)
glScrollFrame:SetScrollChild(glContainer)

-- Empty state text
local glEmptyText = groupLogContainer:CreateFontString(nil, "OVERLAY", "GameFontDisable")
glEmptyText:SetPoint("CENTER", groupLogContainer, "CENTER", 0, 20)
glEmptyText:SetText(L["GroupLogEmpty"] or "No players logged yet. Group up and they'll appear here!")
glEmptyText:SetWidth(400)
glEmptyText:Hide()

-- Clear Log button
local clearLogButton = CreateFrame("Button", nil, groupLogContainer, "UIPanelButtonTemplate")
clearLogButton:SetSize(100, 30)
clearLogButton:SetPoint("BOTTOM", groupLogContainer, "BOTTOM", 0, 10)
clearLogButton:SetText(L["GroupLogClearAll"] or "Clear Log")
clearLogButton:SetScript("OnClick", function()
    StaticPopupDialogs["IWR_CLEAR_GROUP_LOG"] = {
        text = L["GroupLogClearConfirm"] or "Are you sure you want to clear the entire group log?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            iWR:ClearGroupLog()
            iWR:PopulateGroupLog()
            print(iWR.Colors.iWR .. (L["GroupLogCleared"] or "[iWR]: Group log cleared."))
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("IWR_CLEAR_GROUP_LOG")
end)

-- Reusable row frames for group log
local glRowCache = {}

function iWR:PopulateGroupLog()
    if not iWRMemory or not iWRMemory.GroupLog then return end

    -- Hide all cached rows first
    for _, row in ipairs(glRowCache) do
        row:Hide()
    end

    local entries = iWRMemory.GroupLog
    local totalEntries = #entries

    -- Hide empty text initially (may show later if all entries are filtered)
    glEmptyText:Hide()

    local yOffset = -5
    local ROW_HEIGHT = 30
    local displayIndex = 0

    -- Display in reverse order (newest first), skip players already in database
    for i = totalEntries, 1, -1 do
        local entry = entries[i]
        if not entry then break end

        -- Skip players that already have a note in the database
        local databaseKey = entry.name .. "-" .. entry.realm
        if iWRDatabase[databaseKey] then
            -- Player already has a note, don't show in Group Log
        else

        displayIndex = displayIndex + 1

        -- Reuse or create row frame
        local row = glRowCache[displayIndex]
        if not row then
            row = CreateFrame("Frame", nil, glContainer)
            row:SetHeight(ROW_HEIGHT)
            row:SetPoint("TOPLEFT", glContainer, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", glContainer, "TOPRIGHT", 0, 0)
            row:EnableMouse(true)

            -- Highlight on hover
            local highlight = row:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 0.59, 0.09, 0.08)

            -- Class icon
            local classIcon = row:CreateTexture(nil, "ARTWORK")
            classIcon:SetSize(20, 20)
            classIcon:SetPoint("LEFT", row, "LEFT", 10, 0)
            classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
            row.classIcon = classIcon

            -- Has-note indicator (small icon)
            local noteIndicator = row:CreateTexture(nil, "ARTWORK")
            noteIndicator:SetSize(14, 14)
            noteIndicator:SetPoint("LEFT", classIcon, "RIGHT", 2, 0)
            noteIndicator:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
            noteIndicator:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            noteIndicator:Hide()
            row.noteIndicator = noteIndicator

            -- Player name
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", classIcon, "RIGHT", 20, 0)
            nameText:SetWidth(140)
            nameText:SetJustifyH("LEFT")
            row.nameText = nameText

            -- Zone name
            local zoneText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            zoneText:SetPoint("LEFT", nameText, "RIGHT", 5, 0)
            zoneText:SetWidth(160)
            zoneText:SetJustifyH("LEFT")
            row.zoneText = zoneText

            -- Date
            local dateText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            dateText:SetPoint("LEFT", zoneText, "RIGHT", 5, 0)
            dateText:SetWidth(80)
            dateText:SetJustifyH("LEFT")
            row.dateText = dateText

            -- Add Note button
            local editBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            editBtn:SetSize(75, 22)
            editBtn:SetPoint("RIGHT", row, "RIGHT", -70, 0)
            editBtn:SetText(L["GroupLogAddNote"] or "Add Note")
            row.editBtn = editBtn

            -- Dismiss button
            local dismissBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            dismissBtn:SetSize(55, 22)
            dismissBtn:SetPoint("RIGHT", row, "RIGHT", -10, 0)
            dismissBtn:SetText(L["GroupLogDismiss"] or "Dismiss")
            row.dismissBtn = dismissBtn

            glRowCache[displayIndex] = row
        end

        -- Position the row
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", glContainer, "TOPLEFT", 0, yOffset)
        row:SetPoint("TOPRIGHT", glContainer, "TOPRIGHT", 0, yOffset)
        row:Show()

        -- Set class icon using CLASS_ICON_TCOORDS
        local classToken = entry.class or "UNKNOWN"
        local tcoords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
        if tcoords then
            row.classIcon:SetTexCoord(unpack(tcoords))
            row.classIcon:Show()
        else
            row.classIcon:Hide()
        end

        -- Player name with class color
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
        local nameColor = classColor and ("|c" .. classColor.colorStr) or iWR.Colors.Default
        row.nameText:SetText(nameColor .. entry.name)

        -- Zone with instance indicator
        local zoneStr = entry.zone or ""
        if entry.isInstance then
            local instanceLabel = ""
            if entry.instanceType == "party" then
                instanceLabel = " |cFF00CCFF(Dungeon)|r"
            elseif entry.instanceType == "raid" then
                instanceLabel = " |cFFFF8800(Raid)|r"
            elseif entry.instanceType == "pvp" then
                instanceLabel = " |cFFFF0000(BG)|r"
            elseif entry.instanceType == "arena" then
                instanceLabel = " |cFFFF0000(Arena)|r"
            else
                instanceLabel = " |cFF808080(Instance)|r"
            end
            zoneStr = zoneStr .. instanceLabel
        end
        row.zoneText:SetText(zoneStr)

        -- Date
        row.dateText:SetText(entry.date or "")

        -- Note indicator no longer needed (players with notes are filtered out)
        row.noteIndicator:Hide()

        -- Tooltip on hover
        local capturedEntry = entry
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(nameColor .. capturedEntry.name .. "-" .. capturedEntry.realm, 1, 1, 1)
            GameTooltip:AddLine("Zone: " .. (capturedEntry.zone or "Unknown"), 1, 0.82, 0)
            if capturedEntry.isInstance then
                GameTooltip:AddLine("Instance Type: " .. (capturedEntry.instanceType or "none"), 1, 0.82, 0)
            end
            GameTooltip:AddLine("Date: " .. (capturedEntry.date or ""), 1, 0.82, 0)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Add Note button: open iWR Menu with player name and class pre-filled
        local capturedName = entry.name
        local capturedRealm = entry.realm
        local capturedClass = entry.class
        row.editBtn:SetScript("OnClick", function()
            local menuName
            if capturedRealm == iWR.CurrentRealm then
                menuName = capturedName
            else
                menuName = capturedName .. "-" .. capturedRealm
            end
            iWR:MenuOpen(menuName, capturedClass)
            iWR:DatabaseClose()
        end)

        -- Dismiss button: remove this entry from the log
        local capturedEntryIndex = i
        row.dismissBtn:SetScript("OnClick", function()
            table.remove(iWRMemory.GroupLog, capturedEntryIndex)
            iWR:PopulateGroupLog()
        end)

        yOffset = yOffset - ROW_HEIGHT
        end -- end of else (skip players already in DB)
    end

    -- Show empty text if all entries were filtered out (or no entries exist)
    if displayIndex == 0 then
        glEmptyText:Show()
        glContainer:SetHeight(1)
        return
    end

    glContainer:SetHeight(math.max(math.abs(yOffset), 1))
end
