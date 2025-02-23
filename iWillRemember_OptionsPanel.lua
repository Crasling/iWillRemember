-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔ 
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                                  Options Panel                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯
function iWR:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "iWROptionsPanel", UIParent)
    panel:SetSize(650, 570)
    panel:SetPoint("CENTER", nil, "CENTER")
    panel:Hide()

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", panel, "TOP", 0, -2)
    title:SetText(Title .. L["SettingsTitle"])

    -- Content Frames
    local optionsPanel = {
        General = CreateFrame("Frame", "$parentGeneralTabContent", panel, "BackdropTemplate"),
        Sync = CreateFrame("Frame", "$parentSyncTabContent", panel, "BackdropTemplate"),
        Backup = CreateFrame("Frame", "$parentBackupTabContent", panel, "BackdropTemplate"),
        About = CreateFrame("Frame", "$parentAboutTabContent", panel, "BackdropTemplate"),
    }

    -- Initialize Content Frames
    for name, frame in pairs(optionsPanel) do
        frame:SetSize(panel:GetWidth() - 20, panel:GetHeight() - 50)
        frame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -55)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        frame:SetBackdropBorderColor(0.7, 0.7, 0.8, 1)
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        if name ~= L["Tab1General"] then
            frame:Hide()
        end
    end

    -- ╭───────────────────────╮
    -- │      General Tab      │
    -- ╰───────────────────────╯
    -- Target Frame and Chat Icons Category Title
    local targetChatCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetChatCategoryTitle:SetPoint("TOPLEFT", optionsPanel.General, "TOPLEFT", 20, -20)
    targetChatCategoryTitle:SetText(L["DisplaySettings"])

    -- Target Frames Visibility Checkbox
    local targetFrameCheckbox = CreateFrame("CheckButton", "iWRTargetFrameCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    targetFrameCheckbox:SetPoint("TOPLEFT", targetChatCategoryTitle, "BOTTOMLEFT", 0, -5)
    targetFrameCheckbox.Text:SetText(L["EnhancedFrame"])
    targetFrameCheckbox:SetChecked(iWRSettings.UpdateTargetFrame)
    targetFrameCheckbox:SetScript("OnClick", function(self)
        iWRSettings.UpdateTargetFrame = self:GetChecked()
        iWR:DebugMsg("TargetFrame Update: " .. tostring(iWRSettings.UpdateTargetFrame),3)
    end)

    -- Chat Icon Visibility Checkbox
    local chatIconCheckbox = CreateFrame("CheckButton", "iWRChatIconCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    chatIconCheckbox:SetPoint("TOPLEFT", targetFrameCheckbox, "BOTTOMLEFT", 0, -10)
    chatIconCheckbox.Text:SetText(L["ShowChatIcons"])
    chatIconCheckbox:SetChecked(iWRSettings.ShowChatIcons)
    chatIconCheckbox:SetScript("OnClick", function(self)
        iWRSettings.ShowChatIcons = self:GetChecked()
        iWR:DebugMsg("Chat Icons: " .. tostring(iWRSettings.ShowChatIcons),3)
    end)

    -- Group Warnings Category Title
    local groupWarningCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    groupWarningCategoryTitle:SetPoint("TOPLEFT", chatIconCheckbox, "BOTTOMLEFT", 0, -15)
    groupWarningCategoryTitle:SetText(L["WarningSettings"])

    -- Group Warning Checkbox
    local groupWarningCheckbox = CreateFrame("CheckButton", "iWRGroupWarningCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    groupWarningCheckbox:SetPoint("TOPLEFT", groupWarningCategoryTitle, "BOTTOMLEFT", 0, -5)
    groupWarningCheckbox.Text:SetText(L["EnableGroupWarning"])
    groupWarningCheckbox:SetChecked(iWRSettings.GroupWarnings)
    groupWarningCheckbox:SetScript("OnClick", function(self)
        local isEnabled = self:GetChecked()
        iWRSettings.GroupWarnings = isEnabled
        soundWarningCheckbox:SetEnabled(isEnabled)
        if iWRSettings.GroupWarnings ~= true then
            iWRMemory.SoundWarnings = iWRSettings.SoundWarnings
            iWRSettings.SoundWarnings = false
        else
            iWRSettings.SoundWarnings = iWRMemory.SoundWarnings
            soundWarningCheckbox:SetChecked(iWRSettings.SoundWarnings)
        end
        iWR:DebugMsg("GroupWarnings: " .. tostring(iWRSettings.GroupWarnings),3)
        iWR:DebugMsg("SoundWarnings: " .. tostring(iWRSettings.SoundWarnings),3)
    end)

    -- Sound Warning Checkbox
    soundWarningCheckbox = CreateFrame("CheckButton", "iWRSoundWarningCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    soundWarningCheckbox:SetPoint("TOPLEFT", groupWarningCheckbox, "BOTTOMLEFT", 30, -3)
    soundWarningCheckbox.Text:SetText(L["EnableSoundWarning"])
    soundWarningCheckbox:SetChecked(iWRSettings.SoundWarnings)
    soundWarningCheckbox:SetScript("OnClick", function(self)
        iWRSettings.SoundWarnings = self:GetChecked()
        iWR:DebugMsg("SoundWarnings: " .. tostring(iWRSettings.SoundWarnings),3)
    end)

    -- Tooltip Category Title
    local tooltipCategoryTitle = optionsPanel.General:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tooltipCategoryTitle:SetPoint("TOPLEFT", soundWarningCheckbox, "BOTTOMLEFT", -30, -15)
    tooltipCategoryTitle:SetText(L["ToolTipSettings"])

    -- Tooltip Author Checkbox
    local tooltipAuthorCheckbox = CreateFrame("CheckButton", "iWRTooltipAuthorCheckbox", optionsPanel.General, "InterfaceOptionsCheckButtonTemplate")
    tooltipAuthorCheckbox:SetPoint("TOPLEFT", tooltipCategoryTitle, "BOTTOMLEFT", 0, -5)
    tooltipAuthorCheckbox.Text:SetText(L["ShowAuthor"])
    tooltipAuthorCheckbox:SetChecked(iWRSettings.TooltipShowAuthor)
    tooltipAuthorCheckbox:SetScript("OnClick", function(self)
        local isEnabled = self:GetChecked()
        iWRSettings.TooltipShowAuthor = isEnabled
        iWR:DebugMsg("TooltipShowAuthor: " .. tostring(iWRSettings.TooltipShowAuthor), 3)
    end)

    -- ╭────────────────────╮
    -- │      Sync Tab      │
    -- ╰────────────────────╯
    -- Data Sharing Category Title
    local dataSharingCategoryTitle = optionsPanel.Sync:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dataSharingCategoryTitle:SetPoint("TOPLEFT", optionsPanel.Sync, "TOPLEFT", 20, -20)
    dataSharingCategoryTitle:SetText(L["SyncSettings"])

    -- Data Sharing Checkbox
    local dataSharingCheckbox = CreateFrame("CheckButton", "iWRDataSharingCheckbox", optionsPanel.Sync, "InterfaceOptionsCheckButtonTemplate")
    dataSharingCheckbox:SetPoint("TOPLEFT", dataSharingCategoryTitle, "BOTTOMLEFT", 0, -10)
    dataSharingCheckbox.Text:SetText(L["EnableSync"])
    dataSharingCheckbox:SetChecked(iWRSettings.DataSharing)
    dataSharingCheckbox:SetScript("OnClick", function(self)
        iWRSettings.DataSharing = self:GetChecked()
        iWR:DebugMsg("Sync with Friends: " .. tostring(iWRSettings.DataSharing), 3)
    end)

    -- Sync Type Dropdown Menu
    local syncTypeDropdown = CreateFrame("Frame", "iWRSyncTypeDropdown", optionsPanel.Sync, "UIDropDownMenuTemplate")
    syncTypeDropdown:SetPoint("TOPLEFT", dataSharingCheckbox, "BOTTOMLEFT", -16, -10)
    UIDropDownMenu_SetWidth(syncTypeDropdown, 100)
    UIDropDownMenu_SetText(syncTypeDropdown, iWRSettings.SyncType or L["Friends"])

    -- Dropdown Initialization
    local function InitializeDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self)
            iWRSettings.SyncType = self.value
            UIDropDownMenu_SetText(syncTypeDropdown, self.value)
            iWR:DebugMsg("Sync Type set to: " .. self.value, 3)
        end
        info.text, info.value = L["AllFriends"], L["Friends"]
        UIDropDownMenu_AddButton(info, level)
        info.text, info.value = L["OnlyWhitelist"], L["Whitelist"]
        UIDropDownMenu_AddButton(info, level)
    end
    UIDropDownMenu_Initialize(syncTypeDropdown, InitializeDropdown)

    -- Friend List Title
    local friendListTitle = optionsPanel.Sync:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    friendListTitle:SetPoint("TOPLEFT", syncTypeDropdown, "BOTTOMLEFT", 16, -20)
    friendListTitle:SetText(L["AddtoWhitelist"])

    -- Scrollable Dropdown Menu for Adding Friends
    local friendDropdownMenu = CreateFrame("Frame", "iWRFriendDropdownMenu", optionsPanel.Sync, "BackdropTemplate")
    friendDropdownMenu:SetPoint("TOPLEFT", friendListTitle, "BOTTOMLEFT", -10, -20)
    friendDropdownMenu:SetSize(250, 300)
    friendDropdownMenu:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 12,
    })

    local friendScrollFrame = CreateFrame("ScrollFrame", "iWRFriendScrollFrame", friendDropdownMenu, "UIPanelScrollFrameTemplate")
    friendScrollFrame:SetPoint("TOPLEFT", 5, -5)
    friendScrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    local friendScrollChild = CreateFrame("Frame", nil, friendScrollFrame)
    friendScrollChild:SetSize(200, 400)
    friendScrollFrame:SetScrollChild(friendScrollChild)

    -- Populate Scrollable Friend List with Icons and Add Button
    local function PopulateScrollableFriendList()
        -- Clear existing children
        for _, child in ipairs({friendScrollChild:GetChildren()}) do
            ---@diagnostic disable-next-line: undefined-field
            child:Hide()
        end

        local yOffset = -5
        local friendsList = {}
        local numFriends = C_FriendList.GetNumFriends()
        local currentRealm = GetRealmName()

        -- Ensure the friend list is fully loaded
        C_FriendList.ShowFriends()

        -- WoW Friends (Filter by whitelist and realm)
        for i = 1, numFriends do
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            if friendInfo and friendInfo.name then
                -- Check if this friend is already in the whitelist for the same realm
                local isInWhitelist = false
                for _, entry in ipairs(iWRSettings.SyncList or {}) do
                    if entry.name == friendInfo.name and entry.realm == currentRealm then
                        isInWhitelist = true
                        break
                    end
                end

                if not isInWhitelist then
                    table.insert(friendsList, { name = friendInfo.name, realm = currentRealm, type = "wow" })
                end
            end
        end

        -- Display friends in the scrollable UI
        for _, friend in ipairs(friendsList) do
            -- Create a frame for each entry
            local entryFrame = CreateFrame("Frame", nil, friendScrollChild)
            entryFrame:SetSize(200, 20)
            entryFrame:SetPoint("TOPLEFT", friendScrollChild, "TOPLEFT", 10, yOffset)

            -- Display the icon
            local icon = entryFrame:CreateTexture(nil, "OVERLAY")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", entryFrame, "LEFT", 0, 0)
            icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")

            -- Display the name
            local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
            nameText:SetText(friend.name)
            nameText:Show() -- Force UI update

            -- Add button
            local addButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
            addButton:SetSize(50, 20)
            addButton:SetPoint("RIGHT", entryFrame, "RIGHT", 0, 0)
            addButton:SetText("Add")
            addButton:SetScript("OnClick", function()
                if not iWRSettings.SyncList then iWRSettings.SyncList = {} end
                -- Save the friend with realm information
                table.insert(iWRSettings.SyncList, { name = friend.name, realm = friend.realm, type = friend.type })
                iWR:UpdateSyncListDisplay()
                PopulateScrollableFriendList() -- Refresh the friend list to remove the added friend
            end)

            yOffset = yOffset - 25
        end
        friendScrollChild:SetHeight(math.abs(yOffset))

        -- Slight delay to ensure UI updates properly
        C_Timer.After(0.1, function()
            friendScrollChild:Show()
        end)
    end

    -- Call the function to populate the friend list
    PopulateScrollableFriendList()

    -- Sync List Container
    local syncListContainer = CreateFrame("Frame", nil, optionsPanel.Sync, "BackdropTemplate")
    syncListContainer:SetSize(300, 200)
    syncListContainer:SetPoint("TOPRIGHT", optionsPanel.Sync, "TOPRIGHT", -20, -50)
    syncListContainer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 12,
    })

    -- Whitelist Title
    local whitelistTitle = syncListContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    whitelistTitle:SetPoint("BOTTOM", syncListContainer, "TOP", 0, 5)
    whitelistTitle:SetText(L["WhiteListTitle"] .. " (" .. iWRCurrentRealm .. ")")

    -- Update Sync List Display with Icons
    function iWR:UpdateSyncListDisplay()
        -- Ensure all whitelist entries have a realm assigned
        iWR:EnsureWhitelistHasRealm()

        -- Get the current realm name
        local currentRealm = GetRealmName()

        -- Clear Existing Children
        for _, child in ipairs({syncListContainer:GetChildren()}) do
            ---@diagnostic disable-next-line: undefined-field
            child:Hide()
        end

        local yOffset = -5
        for index, syncEntry in ipairs(iWRSettings.SyncList or {}) do
            local entryName, entryType, entryRealm = syncEntry.name, syncEntry.type, syncEntry.realm

            -- Only display players from the current realm
            if entryRealm == currentRealm then
                -- Create a frame to hold the name, icon, and button
                local entryFrame = CreateFrame("Frame", nil, syncListContainer)
                entryFrame:SetSize(syncListContainer:GetWidth() - 20, 20)
                entryFrame:SetPoint("TOPLEFT", syncListContainer, "TOPLEFT", 10, yOffset)

                -- Display the icon
                local icon = entryFrame:CreateTexture(nil, "OVERLAY")
                icon:SetSize(16, 16)
                icon:SetPoint("LEFT", entryFrame, "LEFT", 0, 0)
                icon:SetTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")

                -- Display the name
                local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
                nameText:SetText(entryName)

                -- Create the "Remove" button
                local removeButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
                removeButton:SetSize(60, 20)
                removeButton:SetPoint("RIGHT", entryFrame, "RIGHT", 0, 0)
                removeButton:SetText("Remove")
                removeButton:SetScript("OnClick", function()
                    -- Remove the entry from the sync list
                    table.remove(iWRSettings.SyncList, index)
                    -- Update the display
                    iWR:UpdateSyncListDisplay()
                    PopulateScrollableFriendList() -- Refresh the friend list to re-add the removed friend
                end)

                yOffset = yOffset - 25
            end
        end
    end
    iWR:UpdateSyncListDisplay()

    -- ╭──────────────────────╮
    -- │      Backup Tab      │
    -- ╰──────────────────────╯
    local backupCategoryTitle = optionsPanel.Backup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    backupCategoryTitle:SetPoint("TOPLEFT", optionsPanel.Backup, "TOPLEFT", 20, -20)
    backupCategoryTitle:SetText(iWRBase.Colors.iWR .. "Backup Settings|r")

    -- Backup Checkbox
    local backupCheckbox = CreateFrame("CheckButton", nil, optionsPanel.Backup, "InterfaceOptionsCheckButtonTemplate")
    backupCheckbox:SetPoint("TOPLEFT", backupCategoryTitle, "BOTTOMLEFT", 0, -5)
    backupCheckbox.Text:SetText(L["EnableBackup"])
    backupCheckbox:SetChecked(iWRSettings.HourlyBackup)
    backupCheckbox:SetScript("OnClick", function(self)
        local isEnabled = self:GetChecked()
        iWRSettings.HourlyBackup = isEnabled
        iWR:ToggleHourlyBackup(isEnabled)
        iWR:DebugMsg("Automatic Backup: " .. tostring(iWRSettings.HourlyBackup),3)
    end)

    local restoreButton = CreateFrame("Button", nil, optionsPanel.Backup, "UIPanelButtonTemplate")
    restoreButton:SetSize(150, 30)
    restoreButton:SetPoint("TOPLEFT", backupCheckbox, "BOTTOMLEFT", 0, -10)
    restoreButton:SetText(L["RestoreDatabase"])
    restoreButton:SetScript("OnClick", function()
        if iWRDatabaseBackup then
            StaticPopupDialogs["CONFIRM_RESTORE_DATABASE"] = {
                text = L["RestoreConfirm"]
                    .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupDate or L["UnknownDate"]))
                    .. L["at"]
                    .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupTime or L["UnknownTime"])) .. ".",
                button1 = L["Yes"],
                button2 = L["No"],
                OnAccept = function()
                    iWRDatabase = CopyTable(iWRDatabaseBackup)
                    print(L["BackupRestore"]
                        .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupDate or L["UnknownDate"]))
                        .. L["at"]
                        .. (iWRSettings.iWRDatabaseBackupInfo and (iWRSettings.iWRDatabaseBackupInfo.backupTime or L["UnknownTime"]))
                        .. ".")
                    iWR:PopulateDatabase()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("CONFIRM_RESTORE_DATABASE")
        else
            print(L["BackupRestoreError"])
        end
    end)

    -- Backup Info Display
    local backupInfoDisplay = optionsPanel.Backup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    backupInfoDisplay:SetPoint("LEFT", restoreButton, "RIGHT", 10, 0)

    -- Function to Update Restore Button and Backup Info Display
    local function UpdateBackupInfoDisplay()
        if iWRDatabaseBackup and iWRSettings.iWRDatabaseBackupInfo and iWRSettings.iWRDatabaseBackupInfo.backupDate ~= "" and iWRSettings.iWRDatabaseBackupInfo.backupTime ~= "" then
            backupInfoDisplay:SetText(L["LastBackup1"] .. iWRSettings.iWRDatabaseBackupInfo.backupDate .. L["at"] .. iWRSettings.iWRDatabaseBackupInfo.backupTime)
            restoreButton:Enable()
            restoreButton:SetAlpha(1.0)
        else
            backupInfoDisplay:SetText(L["NoBackup"])
            restoreButton:Disable()
            restoreButton:SetAlpha(0.5)
        end
    end

    -- Update the display when a new backup is made
    hooksecurefunc(iWR, "BackupDatabase", UpdateBackupInfoDisplay)

    -- Initial Update
    UpdateBackupInfoDisplay()

    -- ╭─────────────────────╮
    -- │      About Tab      │
    -- ╰─────────────────────╯
    -- Debug Mode Category Title
    local debugCategoryTitle = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugCategoryTitle:SetPoint("TOPLEFT", optionsPanel.About, "TOPLEFT", 20, -20)
    debugCategoryTitle:SetText(iWRBase.Colors.iWR .. "Developer Settings")

    -- Debug Mode Checkbox
    local debugCheckbox = CreateFrame("CheckButton", "iWRDebugCheckbox", optionsPanel.About, "InterfaceOptionsCheckButtonTemplate")
    debugCheckbox:SetPoint("TOPLEFT", debugCategoryTitle, "BOTTOMLEFT", 0, -5)
    debugCheckbox.Text:SetText("Enable Debug Mode")
    debugCheckbox:SetChecked(iWRSettings.DebugMode)
    debugCheckbox:SetScript("OnClick", function(self)
        local isDebugEnabled = self:GetChecked()
        iWRSettings.DebugMode = isDebugEnabled
        iWR:DebugMsg("Debug Mode is activated." .. iWRBase.Colors.Red .. " This is not recommended for common use and will cause a lot of message spam in chat",3)
    end)

    -- About Category Title
    local aboutCategoryTitle = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aboutCategoryTitle:SetPoint("TOP", optionsPanel.About, "TOP", 0, -30)
    aboutCategoryTitle:SetText(iWRBase.Colors.iWR .. "About|r")

    -- Addon Name and Version
    local aboutAddonName = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAddonName:SetPoint("TOP", aboutCategoryTitle, "BOTTOM", 0, -10)
    aboutAddonName:SetText(iWRBase.Colors.iWR .. Title)

    -- Author Information
    local aboutAuthor = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAuthor:SetPoint("TOP", aboutAddonName, "BOTTOM", 0, -10)
    aboutAuthor:SetText(L["CreatedBy"] .. iWRBase.Colors.Cyan .. Author .. iWRBase.Colors.Reset)

    -- Description
    local aboutDescription = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutDescription:SetPoint("TOP", aboutAuthor, "BOTTOM", 0, -30)
    aboutDescription:SetText(L["AboutMessageInfo"])

    -- Support Information
    local aboutSupport = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutSupport:SetPoint("TOP", aboutDescription, "BOTTOM", 0, -10)
    aboutSupport:SetText(L["AboutMessageEarlyDev"])

    -- Discord Link
    local aboutDiscord = CreateFrame("EditBox", nil, optionsPanel.About, "InputBoxTemplate")
    aboutDiscord:SetSize(200, 30)
    aboutDiscord:SetText(L["DiscordLink"])
    aboutDiscord:SetPoint("TOP", aboutSupport, "BOTTOM", 0, -20)
    aboutDiscord:SetAutoFocus(false)
    aboutDiscord:SetTextColor(1, 1, 1, 1)
    aboutDiscord:SetFontObject(GameFontHighlight)
    aboutDiscord:SetJustifyH("CENTER")
    aboutDiscord:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self:GetText() ~= L["DiscordLink"] then
            self:SetText(L["DiscordLink"])
        end
    end)
    aboutDiscord:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["DiscordLinkMessage"], 1, 1, 1)
        GameTooltip:Show()
    end)
    aboutDiscord:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Create a container for the credits section
    local creditsContainer = CreateFrame("Frame", nil, optionsPanel.About, "BackdropTemplate")
    creditsContainer:SetSize(400, 100)
    creditsContainer:SetPoint("BOTTOM", optionsPanel.About, "BOTTOM", 0, 20)
    creditsContainer:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 12,
    })
    creditsContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

    -- Title for the credits section
    local creditsTitle = creditsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    creditsTitle:SetPoint("TOP", creditsContainer, "TOP", 0, 20)
    creditsTitle:SetText(iWRBase.Colors.iWR .. L["Translations"])

    -- List of translators 
    local translatorList = {
        { name = "ZamestoTV", language = "Russian", flag = "Interface\\AddOns\\iWillRemember\\Images\\Locale\\ruRU.blp" },
    }

    -- Populate the credits list dynamically
    local yOffset = -5
    for _, translator in ipairs(translatorList) do
        -- Create a frame to hold the flag and text
        local entryFrame = CreateFrame("Frame", nil, creditsContainer)
        entryFrame:SetSize(350, 20)
        entryFrame:SetPoint("TOPLEFT", creditsContainer, "TOPLEFT", 20, yOffset)

        -- Create the flag icon
        local flagIcon = entryFrame:CreateTexture(nil, "OVERLAY")
        flagIcon:SetSize(16, 16)
        flagIcon:SetPoint("LEFT", entryFrame, "LEFT", 0, 0)
        flagIcon:SetTexture(translator.flag)

        -- Display the name and language
        local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("LEFT", flagIcon, "RIGHT", 5, 0)
        nameText:SetText(iWRBase.Colors.Yellow .. translator.name .. iWRBase.Colors.Reset .. " - " .. translator.language)

        yOffset = yOffset - 20
    end

    if iWRSettings.DebugMode then
        -- Game Version Label
        local aboutGameVersion = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutGameVersion:SetPoint("TOP", aboutDiscord, "BOTTOM", 0, -20)
        aboutGameVersion:SetText(iWRBase.Colors.iWR .. "Game Version: " .. iWRBase.Colors.Reset .. iWRGameVersion)

        -- TOC Version Label
        local aboutTocVersion = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutTocVersion:SetPoint("TOP", aboutGameVersion, "BOTTOM", 0, -10)
        aboutTocVersion:SetText(iWRBase.Colors.iWR .. "TOC Version: " .. iWRBase.Colors.Reset .. iWRGameTocVersion)

        -- TOC Version Label
        local aboutBuildVersion = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutBuildVersion:SetPoint("TOP", aboutTocVersion, "BOTTOM", 0, -10)
        aboutBuildVersion:SetText(iWRBase.Colors.iWR .. "Build Version: " .. iWRBase.Colors.Reset .. iWRGameBuild)

        -- TOC Version Label
        local aboutBuildDate = optionsPanel.About:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        aboutBuildDate:SetPoint("TOP", aboutBuildVersion, "BOTTOM", 0, -10)
        aboutBuildDate:SetText(iWRBase.Colors.iWR .. "Build Date: " .. iWRBase.Colors.Reset .. iWRGameBuildDate)
    end

    -- Tabs
    local tabs = {
        General = iWR:CreateTab(panel, 1, "General", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == L["Tab1General"])
            end
        end),
        Sync = iWR:CreateTab(panel, 2, "Sync", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == L["Tab2Sync"])
                PopulateScrollableFriendList()
            end
        end),
        Backup = iWR:CreateTab(panel, 3, "Backup", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == L["Tab3Backup"])
            end
        end),
        About = iWR:CreateTab(panel, 4, "About", function()
            for name, frame in pairs(optionsPanel) do
                frame:SetShown(name == L["Tab4About"])
            end
        end),
    }

    -- Tab Switching Logic
    PanelTemplates_SetNumTabs(panel, 4)
    PanelTemplates_SetTab(panel, 1)

    -- Register the options panel
    optionsCategory = Settings.RegisterCanvasLayoutCategory(panel, "iWillRemember")
    Settings.RegisterAddOnCategory(optionsCategory)

    -- Return Panel
    return panel
end