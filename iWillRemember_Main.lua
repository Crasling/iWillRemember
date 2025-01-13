-- ═══════════════════════════════════════════════════════════
-- ██╗ ██╗    ██╗ ██████╗     ███╗   ███╗ █████╗ ██╗███╗   ██╗
-- ╚═╝ ██║    ██║ ██╔══██╗    ████╗ ████║██╔══██╗██║████╗  ██║
-- ██║ ██║ █╗ ██║ ██████╔╝    ██╔████╔██║███████║██║██╔██╗ ██║
-- ██║ ██║███╗██║ ██  ██╔     ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
-- ██║ ╚███╔███╔╝ ██   ██╗    ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
-- ╚═╝  ╚══╝╚══╝  ╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ 
-- ═══════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Namespace                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local addonName, AddOn = ...
Title = select(2, C_AddOns.GetAddOnInfo(addonName)):gsub("%s*v?[%d%.]+$", "")
Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
Author = C_AddOns.GetAddOnMetadata(addonName, "Author")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                        Libs                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iWR = LibStub("AceAddon-3.0"):NewAddon("iWR", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
L = LibStub("AceLocale-3.0"):GetLocale("iWR")
LDBroker = LibStub("LibDataBroker-1.1")
LDBIcon = LibStub("LibDBIcon-1.0")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Variables                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iWRCurrentRealm = GetRealmName()
iWRaddonPath = "Interface\\AddOns\\iWillRemember\\"
iWRimagePath = "Classic"
iWRBase = {}
iWRGameVersionName = ""
iWRGameVersion, iWRGameBuild, iWRGameBuildDate, iWRGameTocVersion = GetBuildInfo()
iWRSuccess = false
iWRVersionMessaged = false
iWRDataCache = ""
iWRTempTable = {}
iWRDataCacheTable = {}
iWRFullTableToSend = {}
iWRInCombat = false
iWRRemoveRequestQueue = {}
iWRisPopupActive = false
iWRWarnedPlayers = {}
iWRActiveTimers = {}
iWRSettingsDefault = {
    DataSharing = true,
    DebugMode = false,
    GroupWarnings = true,
    HourlyBackup = true,
    MinimapButton = {
        hide = false,
        minimapPos = -30 },
    ShowChatIcons = true,
    SoundWarnings = true,
    UpdateTargetFrame = true,
    WelcomeMessage = "0",
    iWRDatabaseBackupInfo = {
        backupDate = "",
        backupTime = "",
    }
}
iWRDatabaseDefault = {
    "",
    0,
    0,
    "",
    "",
    "",
    "",
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Saved Variables                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
if not iWRSettings then
    iWRSettings = {}
end
if not iWRDatabase then
    iWRDatabase = {}
end
if not iWRDatabaseBackup then
    iWRDatabaseBackup = {}
end
if not iWRMemory then
    iWRMemory = {}
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
Colors = {
    -- Standard Colors
    iWR = "|cffff9716",
    Default = "|cffffd200",
    White = "|cFFFFFFFF",
    Black = "|cFF000000",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Blue = "|cFF0000FF",
    Yellow = "|cFFFFFF00",
    Cyan = "|cFF00FFFF",
    Magenta = "|cFFFF00FF",
    Orange = "|cFFFFA500",
    Gray = "|cFFC0C0C0",

    [10]    = "|cff80f451", -- Superior Colour
    [5]     = "|cff80f451", -- Respected Colour
    [3]     = "|cff80f451", -- Liked Colour
    [1]     = "|cff80f451", -- Neutral Colour
    [-3]    = "|cfffd7030", -- Disliked Colour
    [-5]    = "|cffff2121", -- Hated Colour

    -- WoW Class Colors
    Classes = {
        WARRIOR = "|cFFC79C6E",
        PALADIN = "|cFFF58CBA",
        HUNTER = "|cFFABD473",
        ROGUE = "|cFFFFF569",
        PRIEST = "|cFFFFFFFF",
        SHAMAN = "|cFF0070DE",
        MAGE = "|cFF40C7EB",
        WARLOCK = "|cFF8788EE",
        DRUID = "|cFFFF7D0A",
        DEATHKNIGHT = "|cFFC41F3B"
    },

    -- Reset Color
    Reset = "|r"
}

-- ╭────────────────────────╮
-- │      List of Types     │
-- ╰────────────────────────╯
iWRBase.Types = {
    [10]    = "Superior",
    [5]     = "Respected",
    [3]     = "Liked",
    [1]     = "Neutral",
    [0]     = "Clear",
    [-3]    = "Disliked",
    [-5]    = "Hated",
    Superior = 10,
    Respected = 5,
    Liked = 3,
    Neutral = 1,
    Clear = 0,
    Disliked = -3,
    Hated = -5,
}



-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                    Set Paths                                   │
-- ├──────────────────────────┬─────────────────────────────────────────────────────╯
-- │      Check what UI       │
-- ╰──────────────────────────╯
if C_AddOns.IsAddOnLoaded("EasyFrames") or C_AddOns.IsAddOnLoaded("Easy Frames") then
    iWRimagePath = "EasyFrames"
elseif C_AddOns.IsAddOnLoaded("DragonFlightUI") then
    iWRimagePath = "DragonFlightUI"
end

-- ╭───────────────────────────────────╮
-- │      List of Targeting Frames     │
-- ╰───────────────────────────────────╯
iWRBase.TargetFrames = {
    [10]    = iWRaddonPath .. "Images\\TargetFrames\\" .. iWRimagePath .. "\\Superior.blp",
    [5]     = iWRaddonPath .. "Images\\TargetFrames\\" .. iWRimagePath .. "\\Respected.blp",
    [3]     = iWRaddonPath .. "Images\\TargetFrames\\" .. iWRimagePath .. "\\Liked.blp",
    [-3]    = iWRaddonPath .. "Images\\TargetFrames\\" .. iWRimagePath .. "\\Disliked.blp",
    [-5]    = iWRaddonPath .. "Images\\TargetFrames\\" .. iWRimagePath .. "\\Hated.blp",
}

-- ╭────────────────────────╮
-- │      List of Icons     │
-- ╰────────────────────────╯
iWRBase.Icons = {
    iWRIcon     = iWRaddonPath .. "Images\\Icons\\iWRIcon.blp",
    Database    = iWRaddonPath .. "Images\\Icons\\Database.blp",
    [10]        = iWRaddonPath .. "Images\\Icons\\Respected.blp",
    [5]         = iWRaddonPath .. "Images\\Icons\\Respected.blp",
    [3]         = iWRaddonPath .. "Images\\Icons\\Liked.blp",
    [1]         = iWRaddonPath .. "Images\\Icons\\Neutral.blp",
    [0]         = iWRaddonPath .. "Images\\Icons\\Clear.blp",
    [-3]        = iWRaddonPath .. "Images\\Icons\\Disliked.blp",
    [-5]        = iWRaddonPath .. "Images\\Icons\\Hated.blp",
}

iWRBase.ChatIcons = {
    [5]     = iWRaddonPath .. "Images\\ChatIcons\\Respected.blp",
    [3]     = iWRaddonPath .. "Images\\ChatIcons\\Liked.blp",
    [-3]    = iWRaddonPath .. "Images\\ChatIcons\\Disliked.blp",
    [-5]    = iWRaddonPath .. "Images\\ChatIcons\\Hated.blp",
}

-- ╭───────────────────────╮
-- │      Game Version     │
-- ╰───────────────────────╯
local major, minor, patch = string.match(iWRGameTocVersion, "(%d)(%d%d)(%d%d)")
if major and minor and patch then
    local gameTocNumber = tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
    if gameTocNumber >40000 and gameTocNumber <49999 then
        iWRGameVersionName = "Classic Cata"
    elseif gameTocNumber >50000 then
        iWRGameVersionName =   "Retail"
    elseif gameTocNumber >10000 and gameTocNumber <19999 then
        iWRGameVersionName = "Classic Era"
    else
        iWRGameVersionName = "Unknown Game Version"
    end
end

