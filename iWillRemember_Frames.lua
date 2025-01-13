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
titleText:SetText(Colors.iWR .. "iWillRemember Menu" .. Colors.Green .. " v" .. Version)
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
    iWRBase.Icons[iWRBase.Types["Hated"]],
    "Hated",
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Hated"])
    end
)

-- ╭────────────────────────────────────────╮
-- │      Main Panel Set Type Disliked      │
-- ╰────────────────────────────────────────╯
local button2, button2Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", 60, -15},
    iWRBase.Icons[iWRBase.Types["Disliked"]],
    "Disliked",
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Disliked"])
    end
)

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Liked      │
-- ╰─────────────────────────────────────╯
local button3, button3Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", 0, -15},
    iWRBase.Icons[iWRBase.Types["Liked"]],
    "Liked",
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Liked"])
    end
)

-- ╭─────────────────────────────────────────╮
-- │      Main Panel Set Type Respected      │
-- ╰─────────────────────────────────────────╯
local button4, button4Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", -60, -15},
    iWRBase.Icons[iWRBase.Types["Respected"]],
    "Respected",
    function()
        iWR:AddNewNote(iWRNameInput:GetText(), iWRNoteInput:GetText(), iWRBase.Types["Respected"])
    end
)

-- ╭─────────────────────────────────────╮
-- │      Main Panel Set Type Clear      │
-- ╰─────────────────────────────────────╯
local button5, button5Label = iWR:CreateRelationButton(
    iWRPanel,
    {53, 53},
    {"TOP", iWRNoteInput, "BOTTOM", -120, -15},
    iWRBase.Icons[iWRBase.Types["Clear"]],
    "Clear",
    function()
        iWR:ClearNote(iWRNameInput:GetText())
    end
)

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

---------------------
-- Create a new frame to display the database
iWRDatabaseFrame = iWR:CreateiWRStyleFrame(UIParent, 400, 500, {"CENTER", UIParent, "CENTER"})
iWRDatabaseFrame:Hide()
iWRDatabaseFrame:EnableMouse(true)
iWRDatabaseFrame:SetMovable(true)
iWRDatabaseFrame:SetFrameStrata("MEDIUM")
iWRDatabaseFrame:SetClampedToScreen(true)
iWRDatabaseFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.9)
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
dbTitleText:SetText(Colors.iWR .. "iWillRemember Personal Database")
dbTitleText:SetTextColor(0.9, 0.9, 1, 1)

-- Create a scrollable frame to list database entries
local dbScrollFrame = CreateFrame("ScrollFrame", nil, iWRDatabaseFrame, "UIPanelScrollFrameTemplate")
dbScrollFrame:SetPoint("TOP", dbTitleBar, "BOTTOM", -10, -10)
dbScrollFrame:SetSize(350, 420)

-- Create a container for the database entries (this will be scrollable)
local dbContainer = CreateFrame("Frame", nil, dbScrollFrame)
dbContainer:SetSize(360, 500) -- Make sure it's larger than the scroll area
dbScrollFrame:SetScrollChild(dbContainer)

-- Create a close button for the database frame
local dbCloseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelCloseButton")
dbCloseButton:SetPoint("TOPRIGHT", iWRDatabaseFrame, "TOPRIGHT", 0, 0)
dbCloseButton:SetScript("OnClick", function()
    iWR:DatabaseClose()
end)

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
        text = Colors.iWR .. "Are you sure you want to" .. Colors.Red ..  "|n clear all data" .. Colors.iWR .. "|n in the database?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            iWRDatabase = {}
            print(Colors.iWR .. "[iWR]: Database cleared.")
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
        print(Colors.iWR .. "[iWR]: The database is empty. Nothing to share.")
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
            print(Colors.iWR .. "[iWR]: Full database synced to friends.")
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
local searchDatabaseButton = CreateFrame("Button", nil, iWRDatabaseFrame, "UIPanelButtonTemplate")
searchDatabaseButton:SetSize(30, 30)
searchDatabaseButton:SetPoint("BOTTOMLEFT", iWRDatabaseFrame, "BOTTOMLEFT", 10, 10)

local searchTexture = searchDatabaseButton:CreateTexture(nil, "ARTWORK")
searchTexture:SetAllPoints()
searchTexture:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03") -- Magnifying glass texture
searchDatabaseButton:SetNormalTexture(searchTexture)

searchDatabaseButton:SetScript("OnClick", function()
    -- Check if the searchResultsFrame already exists and is visible
    if searchResultsFrame and searchResultsFrame:IsVisible() then
        searchResultsFrame:Hide()
        -- Clear all child frames from the searchResultsFrame
        for _, child in ipairs({searchResultsFrame:GetChildren()}) do
            ---@diagnostic disable-next-line: undefined-field
            child:Hide()
            ---@diagnostic disable-next-line: undefined-field
            child:SetParent(nil)
        end
        if noResultsText then
            noResultsText:Hide()
            noResultsText:SetParent(nil)
            noResultsText = nil
        end
        if tooManyText then
            tooManyText:Hide()
            tooManyText:SetParent(nil)
            tooManyText = nil
        end
        if searchTitle then
            searchTitle:Hide()
            searchTitle:SetParent(nil)
            searchTitle = nil
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

                -- Create the searchResultsFrame if it doesn't already exist
                if not searchResultsFrame then
                    searchResultsFrame = iWR:CreateiWRStyleFrame(iWRDatabaseFrame, 280, 400, {"RIGHT", iWRDatabaseFrame, "RIGHT", 280, 0})
                    searchResultsFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.9)
                    searchResultsFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
                end

                -- Clear previous content
                for _, child in ipairs({searchResultsFrame:GetChildren()}) do
                    ---@diagnostic disable-next-line: undefined-field
                    child:Hide()
                    ---@diagnostic disable-next-line: undefined-field
                    child:SetParent(nil)
                    if noResultsText then
                        noResultsText:Hide()
                        noResultsText:SetParent(nil)
                        noResultsText = nil
                    end
                    if tooManyText then
                        tooManyText:Hide()
                        tooManyText:SetParent(nil)
                        tooManyText = nil
                    end
                    if searchTitle then
                        searchTitle:Hide()
                        searchTitle:SetParent(nil)
                        searchTitle = nil
                    end
                end
                searchResultsFrame:Show()

                -- Add title to the search results
                searchTitle = searchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                searchTitle:SetPoint("TOP", searchResultsFrame, "TOP", 0, -10)
                searchTitle:SetText("Search Results for: " .. searchQuery)

                if #foundEntries > 0 then
                    local maxEntries = 7
                    for index, entry in ipairs(foundEntries) do
                        if index > maxEntries then
                            tooManyText = searchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                            tooManyText:SetPoint("TOP", searchResultsFrame, "TOP", 0, -40 * (maxEntries + 1))
                            tooManyText:SetText("Too many results, refine your search.")
                            break
                        end

                        local playerName, data = entry.name, entry.data

                        -- Create a frame for each entry
                        local entryFrame = CreateFrame("Frame", nil, searchResultsFrame, "BackdropTemplate")
                        entryFrame:SetSize(230, 30)
                        entryFrame:SetPoint("TOP", searchResultsFrame, "TOP", 0, -40 * index)

                        -- Add the icon for the type
                        local iconTexture = entryFrame:CreateTexture(nil, "ARTWORK")
                        iconTexture:SetSize(20, 20)
                        iconTexture:SetPoint("LEFT", entryFrame, "LEFT", -5, 0)

                        -- Set the icon texture
                        local typeIcon = iWRBase.Icons[data[2]]
                        if typeIcon then
                            iconTexture:SetTexture(typeIcon)
                        else
                            iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback icon
                        end

                        -- Add player name and note
                        local entryText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        entryText:SetPoint("LEFT", iconTexture, "RIGHT", 5, 0)
                        if data[7] ~= iWRCurrentRealm then
                            entryText:SetText(data[4]..Colors.Reset.."-"..data[7])
                        else
                            entryText:SetText(data[4])
                        end

                        -- Tooltip functionality
                        entryFrame:SetScript("OnEnter", function()
                            ---@diagnostic disable-next-line: param-type-mismatch
                            GameTooltip:SetOwner(entryFrame, "ANCHOR_RIGHT")
                            print(data[7])
                            if data[7] ~= iWRCurrentRealm then
                                GameTooltip:AddLine(data[4]..Colors.Reset.."-"..data[7], 1, 1, 1) -- Title (Player Name)
                            else
                                GameTooltip:AddLine(data[4], 1, 1, 1) -- Title (Player Name)
                            end
                            if #data[1] <= 30 then
                                GameTooltip:AddLine("Note: " .. Colors[data[2]] .. data[1], 1, 0.82, 0) -- Add note in tooltip
                            else
                                local firstLine, secondLine = iWR:splitOnSpace(data[1], 30) -- Split text on the nearest space
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
                            if iWRDatabase[playerName][7] ~= iWRCurrentRealm then
                                removeText = Colors.iWR .. "Are you sure you want to remove" .. Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. "-" .. iWRDatabase[playerName][7] .. Colors.iWR .. "]|n|n from the iWR database?"
                            else
                                removeText = Colors.iWR .. "Are you sure you want to remove" .. Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. Colors.iWR .. "]|n|n from the iWR database?"
                            end
                            StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                                text = removeText,
                                button1 = "Yes",
                                button2 = "No",
                                OnAccept = function()
                                    print(L["CharNoteStart"] .. iWRDatabase[playerName][4]  .. L["CharNoteRemoved"])
                                    iWRDatabase[playerName] = nil
                                    if searchResultsFrame then
                                        searchResultsFrame:Hide()
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
                    noResultsText = searchResultsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    noResultsText:SetPoint("CENTER", searchResultsFrame, "CENTER", 0, 0)
                    noResultsText:SetText("No players found for: " .. searchQuery)
                end

                local closeResultsButton = CreateFrame("Button", nil, searchResultsFrame, "UIPanelButtonTemplate")
                closeResultsButton:SetSize(80, 24)
                closeResultsButton:SetPoint("BOTTOM", searchResultsFrame, "BOTTOM", 0, 20)
                closeResultsButton:SetText("Close")
                closeResultsButton:SetScript("OnClick", function()
                    searchResultsFrame:Hide()
                    for _, child in ipairs({searchResultsFrame:GetChildren()}) do
                        ---@diagnostic disable-next-line: undefined-field
                        child:Hide()
                        ---@diagnostic disable-next-line: undefined-field
                        child:SetParent(nil)
                        if noResultsText then
                            noResultsText:Hide()
                            noResultsText:SetParent(nil)
                            noResultsText = nil
                        end
                        if tooManyText then
                            tooManyText:Hide()
                            tooManyText:SetParent(nil)
                            tooManyText = nil
                        end
                        if searchTitle then
                            searchTitle:Hide()
                            searchTitle:SetParent(nil)
                            searchTitle = nil
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

-- ╭─────────────────────────────────────────╮
-- │      Function to Populate Database      │
-- ╰─────────────────────────────────────────╯
function iWR:PopulateDatabase()
    -- Clear the container first by hiding all existing child frames
    for _, child in ipairs({dbContainer:GetChildren()}) do
        ---@diagnostic disable-next-line: undefined-field
        child:Hide()
    end

    -- Categorize entries
    local categorizedData = {}
    for playerName, data in pairs(iWRDatabase) do
        local category = data[2] or "Uncategorized"
        categorizedData[category] = categorizedData[category] or {}
        table.insert(categorizedData[category], { name = playerName, data = data })
    end

    -- Sort categories
    local sortedCategories = {}
    for category in pairs(categorizedData) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories, function(a, b)
        return a > b
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
                if data[7] and data[7] ~= iWRCurrentRealm then
                    playerNameText:SetText(data[4]..Colors.Reset.."-"..data[7])
                else
                    playerNameText:SetText(data[4] .. Colors.iWR .. " (" .. Colors[data[2]] .. truncatedNote .. Colors.iWR .. ")")
                end
            else
                if data[7] and data[7] ~= iWRCurrentRealm then
                    playerNameText:SetText(data[4]..Colors.Reset.."-"..data[7])
                else
                    playerNameText:SetText(data[4])
                end
            end
            playerNameText:SetTextColor(1, 1, 1, 1) -- White text

            -- Tooltip functionality
            entryFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(entryFrame, "ANCHOR_RIGHT")
                if data[7] ~= iWRCurrentRealm then
                    GameTooltip:AddLine(data[4]..Colors.Reset.."-"..data[7], 1, 1, 1) -- Title (Player Name)
                else
                    GameTooltip:AddLine(data[4], 1, 1, 1) -- Title (Player Name)
                end
                if #data[1] <= 30 then
                    GameTooltip:AddLine("Note: " .. Colors[data[2]] .. data[1], 1, 0.82, 0) -- Add note in tooltip
                else
                    local firstLine, secondLine = iWR:splitOnSpace(data[1], 30) -- Split text on the nearest space
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

            -- Add OnClick event to open the detail window
            entryFrame:SetScript("OnMouseDown", function()
                iWR:ShowDetailWindow(playerName)
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
                local removeText
                if iWRDatabase[playerName][7] ~= iWRCurrentRealm then
                    removeText = Colors.iWR .. "Are you sure you want to remove" .. Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. "-" .. iWRDatabase[playerName][7] .. Colors.iWR .. "]|n|n from the iWR database?"
                else
                    removeText = Colors.iWR .. "Are you sure you want to remove" .. Colors.iWR .. " |n|n[" .. iWRDatabase[playerName][4] .. Colors.iWR .. "]|n|n from the iWR database?"
                end
                StaticPopupDialogs["REMOVE_PLAYER_CONFIRM"] = {
                    text = removeText,
                    button1 = "Yes",
                    button2 = "No",
                    OnAccept = function()
                        print(L["CharNoteStart"] .. iWRDatabase[playerName][4]  .. L["CharNoteRemoved"])
                        iWRDatabase[playerName] = nil
                        if searchResultsFrame then
                            searchResultsFrame:Hide()
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

            -- Add a divider below the current entry
            local divider = entryFrame:CreateTexture(nil, "BACKGROUND")
            divider:SetPoint("BOTTOMLEFT", entryFrame, "BOTTOMLEFT", 0, -6)
            divider:SetPoint("BOTTOMRIGHT", entryFrame, "BOTTOMRIGHT", 0, -6)
            divider:SetHeight(1)
            divider:SetColorTexture(0.3, 0.3, 0.3, 1)

            yOffset = yOffset - 40
        end
    end
end