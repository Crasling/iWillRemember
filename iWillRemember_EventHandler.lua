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
iWRInCombat = false
combatEventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        iWRInCombat = true
        iWRPanel:Hide()
        iWRDatabaseFrame:Hide()
        iWR:DebugMsg("Entered combat, UI interaction disabled.",3)
    elseif event == "PLAYER_REGEN_ENABLED" then
        iWRInCombat = false
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

-- Event handler function
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        iWR:SendFullDBUpdateToFriends()
    end
end)

-- ╭──────────────────────────────────────────────────╮
-- │      Event Handler for Party or Raid Changes     │
-- ╰──────────────────────────────────────────────────╯
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
        iWR:CheckGroupMembersAgainstDatabase()
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, function()
            iWR:CheckGroupMembersAgainstDatabase()
        end)
    end
end)

-- ╭─────────────────────────────────────────────────────╮
-- │      Event and Function Handler for LFG Browser     │
-- ╰─────────────────────────────────────────────────────╯
if iWRGameVersionName == "Classic Era" then
    iWR:InitializeLFGHook()
else
    iWR:DebugMsg("LFG Browser integration is not functional in this version yet.")
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Event Handlers                                │
-- ├──────────────────────┬─────────────────────────────────────────────────────────╯
-- │      On Startup      │
-- ╰──────────────────────╯
function iWR:OnEnable()
    -- Print a message to the chat frame when the addon is loaded
    print(L["iWRLoaded"] .. " " .. iWRGameVersionName .. Colors.Green .. " v" .. Version .. Colors.iWR .. " Loaded.")
    
    -- Secure hooks to add custom behavior
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update", "SetTargetingFrame")
    hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
        -- Call your custom handler
        iWR:HandleHyperlink(link, text, button, chatFrame)
    
        -- Check if the link is a player link
        if link:match("^player:") then
            local _, playerName, playerRealm = strsplit(":", link)
    
            -- If the playerRealm is empty, it means the player is from the same realm
            if not playerRealm or playerRealm == "" then
                playerRealm = GetRealmName() -- Retrieve the current realm if not specified
            end
    
            -- Print or use the player and realm information
            print("Player Name: " .. playerName)
            print("Realm: " .. playerRealm)
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

    -- Messages
    iWR:DebugMsg("All initialization hooks added.",3)
    iWR:DebugMsg("Debug Mode is activated." .. Colors.Red .. " This is not recommended for common use and will cause a lot of message spam in chat",3)

    if iWRSettings.WelcomeMessage ~= Version then
        local playerName = UnitName("player")
        local _, class = UnitClass("player")
        print(L["iWRWelcomeStart"] .. Colors.Classes[class] .. playerName .. L["iWRWelcomeEnd"])
        iWRSettings.WelcomeMessage = Version
    end
end