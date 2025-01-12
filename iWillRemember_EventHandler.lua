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
local groupFrame = CreateFrame("Frame")
groupFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupFrame:RegisterEvent("RAID_ROSTER_UPDATE")
-- Track if the player was in a group previously
local wasInGroup = false
groupFrame:SetScript("OnEvent", function(_, event)
    if event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_UPDATE" then
        iWR:HandleGroupRosterUpdate(wasInGroup)
        wasInGroup = IsInGroup()
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
    -- Print a messages to the chat frame when the addon is loaded
    iWR:DebugMsg("Debug Mode is activated." .. Colors.Red .. " This is not recommended for common use and will cause a lot of message spam in chat",3)
    print(L["iWRLoaded"] .. " " .. iWRGameVersionName .. Colors.Green .. " v" .. Version .. Colors.iWR .. " Loaded.")
    -- Secure hooks to add custom behavior
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update", "SetTargetingFrame")
    hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
        local linkType, playerName = string.split(":", link)
        if linkType == "iWRPlayer" and playerName then
            iWR:HandleHyperlink(link, text, button, chatFrame)
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
    if iWRSettings.WelcomeMessage ~= Version then
        local playerName = UnitName("player")
        local _, class = UnitClass("player")
        print(L["iWRWelcomeStart"] .. Colors.Classes[class] .. playerName .. L["iWRWelcomeEnd"])
        iWRSettings.WelcomeMessage = Version
    end
end