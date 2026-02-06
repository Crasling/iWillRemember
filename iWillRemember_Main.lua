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
local Title = select(2, C_AddOns.GetAddOnInfo(addonName)):gsub("%s*v?[%d%.]+$", "")
local Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
local Author = C_AddOns.GetAddOnMetadata(addonName, "Author")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                        Libs                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iWR = LibStub("AceAddon-3.0"):NewAddon(
    "iWR",
    "AceEvent-3.0",
    "AceSerializer-3.0",
    "AceComm-3.0",
    "AceTimer-3.0",
    "AceHook-3.0"
)
L = LibStub("AceLocale-3.0"):GetLocale("iWR")
LDBroker = LibStub("LibDataBroker-1.1")
LDBIcon = LibStub("LibDBIcon-1.0")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Constants                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iWR.CONSTANTS = {
    -- Timing
    LOGIN_SYNC_DELAY = 5,
    SYNC_INTERVAL_HOURS = 3600,
    BACKUP_INTERVAL_HOURS = 3600,
    MIN_SYNC_INTERVAL = 2,
    
    -- Limits
    MAX_NOTE_LENGTH = 99,
    MAX_NAME_LENGTH = 40,
    MIN_NAME_LENGTH = 3,
    MAX_SEARCH_RESULTS = 7,
    CHUNK_SIZE = 240,
    
    -- UI
    TOOLTIP_MAX_LINE_LENGTH = 30,
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Variables                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Store all addon data in the iWR namespace
iWR.CurrentRealm = GetRealmName()
iWR.AddonPath = "Interface\\AddOns\\iWillRemember\\"
iWR.ImagePath = "Classic"

-- Addon metadata (exposed for UI display)
iWR.Title = Title
iWR.Version = Version
iWR.Author = Author

-- Game version info
iWR.GameVersion, iWR.GameBuild, iWR.GameBuildDate, iWR.GameTocVersion = GetBuildInfo()
iWR.GameVersionName = ""

-- Runtime state
iWR.State = {
    InCombat = false,
    VersionMessaged = false,
    PopupActive = false,
}

-- Temporary data structures
iWR.Cache = {
    Data = "",
    DataTable = {},
    FullTableToSend = {},
    TempTable = {},
}

-- Queue management
iWR.Queues = {
    RemoveRequests = {},
    SyncUpdates = {},
}

-- Warning tracking
iWR.WarnedPlayers = {}

-- Active timer tracking
iWR.ActiveTimers = {}

-- Settings with defaults
iWR.SettingsDefault = {
    TooltipShowAuthor = true,
    DataSharing = true,
    DebugMode = false,
    GroupWarnings = true,
    HourlyBackup = true,
    MinimapButton = {
        hide = false,
        minimapPos = -30
    },
    ShowChatIcons = true,
    SoundWarnings = true,
    UpdateTargetFrame = true,
    WelcomeMessage = "0",
    iWRDatabaseBackupInfo = {
        backupDate = "",
        backupTime = "",
    }
}

-- Database entry template
iWR.DatabaseDefault = {
    "",  -- [1] Note
    0,   -- [2] Type
    0,   -- [3] Timestamp
    "",  -- [4] Name (colored)
    "",  -- [5] Date
    "",  -- [6] Author
    "",  -- [7] Realm
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Saved Variables                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- These remain global as they need to be saved by WoW
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
if not iWRSettings.SyncList then
    iWRSettings.SyncList = {}
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iWR.Colors = {
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

    -- Relationship Colors
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
        DEATHKNIGHT = "|cFFC41F3B",
        MONK = "|cFF00FF98",
        DEMONHUNTER = "|cFFA330C9",
        EVOKER = "|cFF33937F"
    },

    -- Reset Color
    Reset = "|r"
}

-- ╭────────────────────────╮
-- │      List of Types     │
-- ╰────────────────────────╯
iWR.Types = {
    -- Number to name
    [10]    = "Superior",
    [5]     = "Respected",
    [3]     = "Liked",
    [1]     = "Neutral",
    [0]     = "Clear",
    [-3]    = "Disliked",
    [-5]    = "Hated",
    
    -- Name to number
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
C_Timer.After(2, function()
    if C_AddOns.IsAddOnLoaded("EasyFrames") or C_AddOns.IsAddOnLoaded("Easy Frames") then
        iWR.ImagePath = "EasyFrames"
    elseif C_AddOns.IsAddOnLoaded("DragonFlightUI") then
        iWR.ImagePath = "DragonFlightUI"
    elseif C_AddOns.IsAddOnLoaded("Shadowed Unit Frames") or C_AddOns.IsAddOnLoaded("ShadowedUnitFrames") then
        iWR.ImagePath = "ShadowedUnitFrames"
    end
end)

-- ╭───────────────────────────────────╮
-- │      List of Targeting Frames     │
-- ╰───────────────────────────────────╯
iWR.TargetFrames = {
    [10]    = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Superior.blp",
    [5]     = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Respected.blp",
    [3]     = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Liked.blp",
    [-3]    = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Disliked.blp",
    [-5]    = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Hated.blp",
}

-- ╭────────────────────────╮
-- │      List of Icons     │
-- ╰────────────────────────╯
iWR.Icons = {
    iWRIcon     = iWR.AddonPath .. "Images\\Icons\\iWRIcon.blp",
    Database    = iWR.AddonPath .. "Images\\Icons\\Database.blp",
    [10]        = iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    [5]         = iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    [3]         = iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    [1]         = iWR.AddonPath .. "Images\\Icons\\Neutral.blp",
    [0]         = iWR.AddonPath .. "Images\\Icons\\Clear.blp",
    [-3]        = iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    [-5]        = iWR.AddonPath .. "Images\\Icons\\Hated.blp",
}

iWR.ChatIcons = {
    [5]     = iWR.AddonPath .. "Images\\ChatIcons\\Respected.blp",
    [3]     = iWR.AddonPath .. "Images\\ChatIcons\\Liked.blp",
    [-3]    = iWR.AddonPath .. "Images\\ChatIcons\\Disliked.blp",
    [-5]    = iWR.AddonPath .. "Images\\ChatIcons\\Hated.blp",
}

-- ╭───────────────────────╮
-- │      Game Version     │
-- ╰───────────────────────╯
local major, minor, patch = string.match(iWR.GameTocVersion, "(%d)(%d%d)(%d%d)")
if major and minor and patch then
    local gameTocNumber = tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
    if gameTocNumber > 50000 and gameTocNumber < 59999 then
        iWR.GameVersionName = "Classic MoP"
    elseif gameTocNumber > 40000 and gameTocNumber < 49999 then
        iWR.GameVersionName = "Classic Cata"
    elseif gameTocNumber > 30000 and gameTocNumber < 39999 then
        iWR.GameVersionName = "Classic WotLK"
    elseif gameTocNumber > 20000 and gameTocNumber < 29999 then
        iWR.GameVersionName = "Classic TBC"
    elseif gameTocNumber > 10000 and gameTocNumber < 19999 then
        iWR.GameVersionName = "Classic Era"
    else
        iWR.GameVersionName = "Unknown Version"
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Backward Compatibility                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- These global variables are kept for backward compatibility with existing code