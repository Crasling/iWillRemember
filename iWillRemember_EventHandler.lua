-- ════════════════════════════════════════════════════════════════════════════════════
-- ██╗ ██╗    ██╗ ██████╗     ███████╗ ██╗   ██╗ ███████╗ ███╗   ██╗ ████████╗ ███████╗
-- ╚═╝ ██║    ██║ ██╔══██╗    ██╔════╝ ██║   ██║ ██╔════╝ ████╗  ██║ ╚══██╔══╝ ██╔════╝
-- ██║ ██║ █╗ ██║ ██████╔╝    █████╗   ██║   ██║ █████╗   ██╔██╗ ██║    ██║    ███████╗
-- ██║ ██║███╗██║ ██  ██╔     ██╔══╝   ╚██╗ ██╔╝ ██╔══╝   ██╔██╗ ██║    ██║    ╚════██║
-- ██║ ╚███╔███╔╝ ██   ██╗    ███████╗  ╚████╔╝  ███████╗ ██║ ╚████║    ██║    ███████║
-- ╚═╝  ╚══╝╚══╝  ╚══════╝    ╚══════╝   ╚═══╝   ╚══════╝ ╚═╝  ╚═══╝    ╚═╝    ╚══════╝
-- ════════════════════════════════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Event Handlers                                 │
-- ╭────────────────────────────────────────────────────────────────────────────────╯
-- │      Event Handler for Combat Events      │
-- ╰───────────────────────────────────────────╯
local combatEventFrame = CreateFrame("Frame")
iWR.State.InCombat = false
combatEventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        iWR.State.InCombat = true
        iWRPanel:Hide()
        iWRDatabaseFrame:Hide()
        iWR:DebugMsg("Entered combat, UI interaction disabled.",3)
    elseif event == "PLAYER_REGEN_ENABLED" then
        iWR.State.InCombat = false
        iWR:DebugMsg("Left combat, UI interaction enabled.",3)
    end
end)
combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- ╭──────────────────────────────────╮
-- │      Event Handler for Login     │
-- ╰──────────────────────────────────╯
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(5, function()
            iWR:SendFullDBUpdateToFriends()
            iWR:EnsureWhitelistedPlayersInFriends()
        end)
    end
end)

-- ╭──────────────────────────────────────────────────╮
-- │      Event Handler for Party or Raid Changes     │
-- ╰──────────────────────────────────────────────────╯
local groupFrame = CreateFrame("Frame")
groupFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupFrame:RegisterEvent("RAID_ROSTER_UPDATE")
local wasInGroup = false
groupFrame:SetScript("OnEvent", function(_, event)
    if event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
        iWR:HandleGroupRosterUpdate(wasInGroup)
        wasInGroup = IsInGroup()
    end
end)

-- ╭──────────────────────╮
-- │      On Startup      │
-- ╰──────────────────────╯
function iWR:OnEnable()
    -- Print a messages to the chat frame when the addon is loaded
    iWR:DebugMsg("Debug Mode is activated." .. iWR.Colors.Red .. " This is not recommended for common use and will cause a lot of message spam in chat",3)
    print(L["iWRLoaded"] .. " " .. iWR.GameVersionName .. iWR.Colors.Green .. " v" .. iWR.Version .. iWR.Colors.iWR .. " Loaded.")
    -- Secure hooks to add custom behavior
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update", "SetTargetingFrame")
    
    -- Register callback for handling custom addon links
    EventRegistry:RegisterCallback("SetItemRef", function(_, link, text, button, chatFrame)
        local linkType, addonName, linkData = string.split(":", link, 3)

        -- Handle only your specific addon link type
        if linkType == "addon" and addonName == "iWR" then
            iWR:DebugMsg("Addon link clicked: " .. tostring(linkData), 3)

            -- Extract the player name and realm from linkData
            local authorName, authorRealm = string.match(linkData, "^([^-]+)-?(.*)$")
            authorRealm = authorRealm ~= "" and authorRealm or iWR.CurrentRealm -- Default to current realm

            -- Show detail window or log a message if not found
            if iWRDatabase[linkData] then
                iWR:ShowDetailWindow(linkData)
            else
                iWR:DebugMsg("No data found for: " .. linkData, 1)
            end
        end
    end)

    -- Hook into LibDBIcon updates
    LDBIcon.RegisterCallback(iWR, "LibDBIcon_Changed", "SaveMinimapPosition")
    -- Initialize
    iWR:InitializeSettings()
    iWR:InitializeDatabase()
    -- Create Options Panel
    iWR:CreateOptionsPanel()
     -- Initialize hourly backup based on saved settings
     if iWRSettings.HourlyBackup then
        iWR:StartHourlyBackup()
    end
    -- Check versioning
    iWR:CheckLatestVersion()
    -- Register DataSharing
    iWR:RegisterComm("iWRFullDBUpdate", "OnFullDBUpdate")
    iWR:RegisterComm("iWRNewDBUpdate", "OnNewDBUpdate")
    iWR:RegisterComm("iWRRemDBUpdate", "OnRemDBUpdate")
    iWR:RegisterComm("iWRVersionCheck", "OnVersionCheck")

    -- Restore minimap position if moved
    iWR:RestoreMinimapPosition()

    -- Done Messages
    iWR:DebugMsg("All initialization hooks added.",3)
    if iWRSettings.WelcomeMessage ~= iWR.Version then
        local playerName = UnitName("player")
        local _, class = UnitClass("player")
        print(L["iWRWelcomeStart"] .. iWR.Colors.Classes[class] .. playerName .. L["iWRWelcomeEnd"])
        iWRSettings.WelcomeMessage = iWR.Version
    end
end

-- ╭────────────────────────────╮
-- │      On Target change      │
-- ╰────────────────────────────╯
local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_TARGET")
frame:SetScript("OnEvent", function(_, event, unit)
    if iWR.ImagePath == 'ShadowedUnitFrames' then
        if unit == "player" or unit == "target" then
            iWR:SetTargetingFrame()
        end
    end
end)
