-- ════════════════════════════════════════════════════════════════════════════════════
-- iWillRemember – Event Handlers
-- ════════════════════════════════════════════════════════════════════════════════════

----------------------------------------------------------------
-- COMBAT STATE HANDLING
----------------------------------------------------------------
local combatEventFrame = CreateFrame("Frame")
iWR.State.InCombat = false

combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

combatEventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        iWR.State.InCombat = true

        if iWRPanel then iWRPanel:Hide() end
        if iWRDatabaseFrame then iWRDatabaseFrame:Hide() end
        if iWR.SettingsFrame then iWR.SettingsFrame:Hide() end

        if StaticPopup_Visible("REMOVE_PLAYER_CONFIRM") then
            StaticPopup_Hide("REMOVE_PLAYER_CONFIRM")
        end

        iWR:DebugMsg("Entered combat, UI interaction disabled.", 3)

    elseif event == "PLAYER_REGEN_ENABLED" then
        iWR.State.InCombat = false
        iWR:DebugMsg("Left combat, UI interaction enabled.", 3)
    end
end)

----------------------------------------------------------------
-- PLAYER LOGIN (DELAYED LOGIC)
----------------------------------------------------------------
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")

loginFrame:SetScript("OnEvent", function()
    C_Timer.After(5, function()
        if iWR.SendFullDBUpdateToFriends then
            iWR:SendFullDBUpdateToFriends()
        end
        if iWR.EnsureWhitelistedPlayersInFriends then
            iWR:EnsureWhitelistedPlayersInFriends()
        end
    end)
end)

----------------------------------------------------------------
-- GROUP / RAID ROSTER HANDLING
----------------------------------------------------------------
local groupFrame = CreateFrame("Frame")
groupFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
groupFrame:RegisterEvent("RAID_ROSTER_UPDATE")

local wasInGroup = false

groupFrame:SetScript("OnEvent", function()
    if iWR.HandleGroupRosterUpdate then
        iWR:HandleGroupRosterUpdate(wasInGroup)
    end
    wasInGroup = IsInGroup()
end)

----------------------------------------------------------------
-- ADDON ENABLE (SAFE PHASE ONLY)
----------------------------------------------------------------
function iWR:OnEnable()
    ----------------------------------------------------------------
    -- INFO OUTPUT
    ----------------------------------------------------------------
    iWR:DebugMsg(
        "Debug Mode is activated." .. iWR.Colors.Red ..
        " This is not recommended for common use and will cause message spam.",
        3
    )

    print(
        L["iWRLoaded"] .. " " ..
        iWR.GameVersionName ..
        iWR.Colors.Green .. " v" .. iWR.Version ..
        iWR.Colors.iWR .. " Loaded."
    )

    ----------------------------------------------------------------
    -- TOOLTIP HOOK (SAFE AT ENABLE)
    ----------------------------------------------------------------
    local ok = pcall(function()
        self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    end)

    if not ok then
        GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip, ...)
            iWR:AddNoteToGameTooltip(tooltip, ...)
        end)
        iWR:DebugMsg("Fallback tooltip hook used.", 3)
    end

    ----------------------------------------------------------------
    -- DELAYED UI HOOKS
    ----------------------------------------------------------------
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")

    ----------------------------------------------------------------
    -- CORE INITIALIZATION
    ----------------------------------------------------------------
    iWR:InitializeSettings()
    iWR:InitializeDatabase()
    iWR:CreateOptionsPanel()

    if iWRSettings.HourlyBackup then
        iWR:StartHourlyBackup()
    end

    iWR:CheckLatestVersion()

    ----------------------------------------------------------------
    -- COMM CHANNELS
    ----------------------------------------------------------------
    iWR:RegisterComm("iWRFullDBUpdate", "OnFullDBUpdate")
    iWR:RegisterComm("iWRNewDBUpdate", "OnNewDBUpdate")
    iWR:RegisterComm("iWRRemDBUpdate", "OnRemDBUpdate")
    iWR:RegisterComm("iWRVersionCheck", "OnVersionCheck")

    ----------------------------------------------------------------
    -- MINIMAP ICON
    ----------------------------------------------------------------
    if LDBIcon then
        LDBIcon.RegisterCallback(iWR, "LibDBIcon_Changed", "SaveMinimapPosition")
        iWR:RestoreMinimapPosition()
    end

    ----------------------------------------------------------------
    -- WELCOME MESSAGE
    ----------------------------------------------------------------
    if iWRSettings.WelcomeMessage ~= iWR.Version then
        local playerName = UnitName("player")
        local _, class = UnitClass("player")

        print(
            L["iWRWelcomeStart"] ..
            iWR.Colors.Classes[class] ..
            playerName ..
            L["iWRWelcomeEnd"]
        )

        iWRSettings.WelcomeMessage = iWR.Version
    end

    ----------------------------------------------------------------
    -- SLASH COMMANDS
    ----------------------------------------------------------------
    SLASH_IWR1 = "/iwr"
    SlashCmdList["IWR"] = function(msg)
        msg = strtrim(msg):lower()
        if msg == "settings" or msg == "options" or msg == "config" then
            iWR:SettingsToggle()
        elseif msg == "db" or msg == "database" then
            iWR:DatabaseToggle()
            iWR:PopulateDatabase()
        else
            iWR:MenuToggle()
        end
    end
end

----------------------------------------------------------------
-- PLAYER_LOGIN (SAFE UI HOOKS)
----------------------------------------------------------------

-- Check if TargetFrame_Update is reliable for this client
-- Classic Era, Anniversary (TBC) and MoP have the function but it never fires
local tocNumber = tonumber(iWR.GameTocVersion) or 0
local isClassicEra = (tocNumber >= 11500 and tocNumber < 20000)
local isAnniversary = (tocNumber >= 20500 and tocNumber < 30000)
local isMoP = (tocNumber >= 50500 and tocNumber < 60000)
iWR.UseTargetFrameHook = type(TargetFrame_Update) == "function" and not isClassicEra and not isAnniversary and not isMoP

function iWR:OnPlayerLogin()
    ----------------------------------------------------------------
    -- TARGET FRAME HOOK (SAFE + GUARDED)
    ----------------------------------------------------------------
    if iWR.UseTargetFrameHook then
        self:SecureHook("TargetFrame_Update", "SetTargetingFrame")
    end
end

----------------------------------------------------------------
-- CHAT LINK HANDLING (VERSION SAFE)
----------------------------------------------------------------
hooksecurefunc("SetItemRef", function(link)
    local linkType, addonName, linkData = string.split(":", link, 3)

    if linkType == "addon" and addonName == "iWR" then
        if iWRDatabase[linkData] then
            iWR:ShowDetailWindow(linkData)
        end
    end
end)

----------------------------------------------------------------
-- TARGET CHANGES (ALL FRAMES)
----------------------------------------------------------------
local targetFrame = CreateFrame("Frame")
targetFrame:RegisterEvent("UNIT_TARGET")
targetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

targetFrame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_TARGET_CHANGED" then
        -- Fires on every target change — used when SecureHook is not reliable
        if not iWR.UseTargetFrameHook then
            if iWR.SetTargetingFrame then
                iWR:SetTargetingFrame()
            end
        end
    elseif event == "UNIT_TARGET" then
        -- ShadowedUnitFrames needs UNIT_TARGET for proper updates
        if (unit == "player" or unit == "target") and iWR.ImagePath == "ShadowedUnitFrames" then
            if iWR.SetTargetingFrame then
                iWR:SetTargetingFrame()
            end
        end
    end
end)
