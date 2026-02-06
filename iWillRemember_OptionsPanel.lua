-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                              Options Panel (AceConfig)                        │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

iWR.Options = {
    type = "group",
    name = "iWillRemember",
    childGroups = "tab",
    get = function(info)
        return iWRSettings[info[#info]]
    end,
    set = function(info, value)
        iWRSettings[info[#info]] = value
    end,
    args = {

        ----------------------------------------------------------------
        -- GENERAL / DISPLAY
        ----------------------------------------------------------------
        General = {
            type = "group",
            name = L["Tab1General"],
            order = 1,
            args = {

                DisplayHeader = {
                    type = "header",
                    name = L["DisplaySettings"],
                    order = 1,
                },

                UpdateTargetFrame = {
                    type = "toggle",
                    name = L["EnhancedFrame"],
                    desc = "Display the iWR relationship frame on the target frame.",
                    width = "full",
                    order = 2,
                },

                ShowChatIcons = {
                    type = "toggle",
                    name = L["ShowChatIcons"],
                    desc = "Show iWR relationship icons next to player names in chat.",
                    width = "full",
                    order = 3,
                },

                WarningHeader = {
                    type = "header",
                    name = L["WarningSettings"],
                    order = 10,
                },

                GroupWarnings = {
                    type = "toggle",
                    name = L["EnableGroupWarning"],
                    desc = "Show a warning in chat when a player from your database joins your group or raid.",
                    width = "full",
                    order = 11,
                    set = function(info, value)
                        iWRSettings.GroupWarnings = value
                        if not value then
                            iWRMemory.SoundWarnings = iWRSettings.SoundWarnings
                            iWRSettings.SoundWarnings = false
                        else
                            iWRSettings.SoundWarnings = iWRMemory.SoundWarnings
                        end
                    end,
                },

                SoundWarnings = {
                    type = "toggle",
                    name = "    " .. L["EnableSoundWarning"],
                    desc = "Play a sound when a group warning is triggered.",
                    width = "full",
                    order = 12,
                    disabled = function()
                        return not iWRSettings.GroupWarnings
                    end,
                },

                TooltipHeader = {
                    type = "header",
                    name = L["ToolTipSettings"],
                    order = 20,
                },

                TooltipShowAuthor = {
                    type = "toggle",
                    name = L["ShowAuthor"],
                    desc = "Display who created the note when hovering over a player.",
                    width = "full",
                    order = 21,
                },
            },
        },

        ----------------------------------------------------------------
        -- SYNC
        ----------------------------------------------------------------
        Sync = {
            type = "group",
            name = L["Tab2Sync"],
            order = 2,
            args = {

                SyncHeader = {
                    type = "header",
                    name = L["SyncSettings"],
                    order = 1,
                },

                DataSharing = {
                    type = "toggle",
                    name = L["EnableSync"],
                    desc = "Allow sharing your player notes with friends who also use iWillRemember.",
                    width = "full",
                    order = 2,
                },

                SyncType = {
                    type = "select",
                    name = "Sync Mode",
                    desc = "Choose who to share your database with.",
                    order = 3,
                    values = {
                        Friends   = L["AllFriends"],
                        Whitelist = L["OnlyWhitelist"],
                    },
                },

                WhitelistHeader = {
                    type = "header",
                    name = L["WhiteListTitle"] .. " (" .. iWR.CurrentRealm .. ")",
                    order = 10,
                },

                WhitelistInfo = {
                    type = "description",
                    name = function()
                        local t = {}
                        for _, v in ipairs(iWRSettings.SyncList or {}) do
                            if v.realm == iWR.CurrentRealm then
                                table.insert(t, "|cFF00FF00\226\128\162|r " .. v.name)
                            end
                        end
                        if #t == 0 then
                            return "|cFF808080No friends on the whitelist for this realm.|r"
                        end
                        return table.concat(t, "\n")
                    end,
                    fontSize = "medium",
                    order = 11,
                },

                AddFriend = {
                    type = "select",
                    name = "Add Friend to Whitelist",
                    desc = "Select a friend from your in-game friends list to add to the whitelist.",
                    order = 12,
                    values = function()
                        C_FriendList.ShowFriends()
                        local friends = {}
                        local currentRealm = GetRealmName()
                        local numFriends = C_FriendList.GetNumFriends()
                        for i = 1, numFriends do
                            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
                            if friendInfo and friendInfo.name then
                                -- Skip friends already on the whitelist
                                local isInWhitelist = false
                                for _, entry in ipairs(iWRSettings.SyncList or {}) do
                                    if entry.name == friendInfo.name and entry.realm == currentRealm then
                                        isInWhitelist = true
                                        break
                                    end
                                end
                                if not isInWhitelist then
                                    friends[friendInfo.name] = friendInfo.name
                                end
                            end
                        end
                        return friends
                    end,
                    set = function(info, value)
                        if value and value ~= "" then
                            if not iWRSettings.SyncList then iWRSettings.SyncList = {} end
                            table.insert(iWRSettings.SyncList, {
                                name = value,
                                realm = GetRealmName(),
                                type = "wow",
                            })
                        end
                    end,
                    get = function() return "" end,
                },

                RemoveFriend = {
                    type = "select",
                    name = "Remove from Whitelist",
                    desc = "Select a friend to remove from the whitelist.",
                    order = 13,
                    values = function()
                        local names = {}
                        local currentRealm = GetRealmName()
                        for _, entry in ipairs(iWRSettings.SyncList or {}) do
                            if entry.realm == currentRealm then
                                names[entry.name] = entry.name
                            end
                        end
                        return names
                    end,
                    set = function(info, value)
                        if value and value ~= "" then
                            for i, entry in ipairs(iWRSettings.SyncList or {}) do
                                if entry.name == value and entry.realm == GetRealmName() then
                                    table.remove(iWRSettings.SyncList, i)
                                    return
                                end
                            end
                        end
                    end,
                    get = function() return "" end,
                },
            },
        },

        ----------------------------------------------------------------
        -- BACKUP
        ----------------------------------------------------------------
        Backup = {
            type = "group",
            name = L["Tab3Backup"],
            order = 3,
            args = {

                BackupHeader = {
                    type = "header",
                    name = "|cffff9716Backup Settings|r",
                    order = 1,
                },

                HourlyBackup = {
                    type = "toggle",
                    name = L["EnableBackup"],
                    desc = "Automatically create a backup of your database every hour.",
                    width = "full",
                    order = 2,
                    set = function(info, value)
                        iWRSettings.HourlyBackup = value
                        iWR:ToggleHourlyBackup(value)
                    end,
                },

                BackupInfo = {
                    type = "description",
                    name = function()
                        local info = iWRSettings.iWRDatabaseBackupInfo
                        if info and info.backupDate and info.backupDate ~= "" and info.backupTime and info.backupTime ~= "" then
                            return "\n" .. L["LastBackup1"] .. info.backupDate .. L["at"] .. info.backupTime
                        else
                            return "\n|cFF808080" .. L["NoBackup"] .. "|r"
                        end
                    end,
                    fontSize = "medium",
                    order = 3,
                },

                RestoreDatabase = {
                    type = "execute",
                    name = L["RestoreDatabase"],
                    desc = "Restore your database from the last backup. This will overwrite the current database.",
                    order = 4,
                    confirm = function()
                        local info = iWRSettings.iWRDatabaseBackupInfo
                        local date = info and info.backupDate or L["UnknownDate"]
                        local time = info and info.backupTime or L["UnknownTime"]
                        return "Are you sure you want to overwrite the current iWR Database with the backup data?\nThis is non-reversible.\n\nBackup made on " .. date .. " at " .. time .. "."
                    end,
                    disabled = function()
                        return not iWRDatabaseBackup or not next(iWRDatabaseBackup)
                    end,
                    func = function()
                        if iWRDatabaseBackup then
                            iWRDatabase = CopyTable(iWRDatabaseBackup)
                            local info = iWRSettings.iWRDatabaseBackupInfo
                            local date = info and info.backupDate or L["UnknownDate"]
                            local time = info and info.backupTime or L["UnknownTime"]
                            print(L["BackupRestore"] .. date .. L["at"] .. time .. ".")
                            iWR:PopulateDatabase()
                        else
                            print(L["BackupRestoreError"])
                        end
                    end,
                },
            },
        },

        ----------------------------------------------------------------
        -- ABOUT / DEBUG
        ----------------------------------------------------------------
        About = {
            type = "group",
            name = L["Tab4About"],
            order = 4,
            args = {

                DebugHeader = {
                    type = "header",
                    name = "|cffff9716Developer Settings|r",
                    order = 1,
                },

                DebugMode = {
                    type = "toggle",
                    name = "Enable Debug Mode",
                    desc = "Enables verbose debug messages in chat. Not recommended for normal use.",
                    width = "full",
                    order = 2,
                },

                AboutHeader = {
                    type = "header",
                    name = "|cffff9716About|r",
                    order = 10,
                },

                AddonInfo = {
                    type = "description",
                    name = function()
                        return "|cffff9716" .. iWR.Title .. "|r |cFF00FF00v" .. iWR.Version .. "|r\n" ..
                            L["CreatedBy"] .. "|cFF00FFFF" .. iWR.Author .. "|r\n\n" ..
                            L["AboutMessageInfo"] .. "\n\n" ..
                            L["AboutMessageEarlyDev"]
                    end,
                    fontSize = "medium",
                    order = 11,
                },

                DiscordHeader = {
                    type = "header",
                    name = "Discord",
                    order = 20,
                },

                DiscordLink = {
                    type = "input",
                    name = "Discord Invite Link",
                    desc = L["DiscordLinkMessage"],
                    width = "full",
                    order = 21,
                    get = function() return L["DiscordLink"] end,
                    set = function() end,
                },

                CreditsHeader = {
                    type = "header",
                    name = "|cffff9716" .. L["Translations"] .. "|r",
                    order = 30,
                },

                CreditsList = {
                    type = "description",
                    name = function()
                        return "|cFFFFFF00ZamestoTV|r - " .. L["Russian"]
                    end,
                    fontSize = "medium",
                    order = 31,
                },

                VersionHeader = {
                    type = "header",
                    name = "|cffff9716Version Info|r",
                    order = 40,
                    hidden = function() return not iWRSettings.DebugMode end,
                },

                VersionInfo = {
                    type = "description",
                    name = function()
                        return "|cffff9716Game Version:|r " .. (iWR.GameVersion or "N/A") .. "\n" ..
                            "|cffff9716TOC Version:|r " .. (iWR.GameTocVersion or "N/A") .. "\n" ..
                            "|cffff9716Build Version:|r " .. (iWR.GameBuild or "N/A") .. "\n" ..
                            "|cffff9716Build Date:|r " .. (iWR.GameBuildDate or "N/A")
                    end,
                    fontSize = "medium",
                    order = 41,
                    hidden = function() return not iWRSettings.DebugMode end,
                },
            },
        },
    },
}
