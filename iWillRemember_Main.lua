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

    -- Group Log
    MAX_GROUP_LOG_ENTRIES = 200,
    GROUP_LOG_ZONE_UPDATE_WINDOW = 600, -- 10 minutes: update zone on recent entries when zone changes
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

-- Group Log session tracking (runtime only, not saved)
iWR.LoggedThisSession = {}

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
    },
    ButtonLabels = {
        [10]  = "Superior",
        [6]   = "Respected",
        [1]   = "Liked",
        [-1]  = "Disliked",
        [-6]  = "Hated",
    },
    CustomIcons = {},
    GroupLogEnabled = true,
    SimpleMenu = false,
    GoodLevels = 3,
    BadLevels = 2,
    GuildWatchlist = {},
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
    "",  -- [8] Faction ("Horde"/"Alliance"/"")
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
if not iWRSettings.GuildWatchlist then
    iWRSettings.GuildWatchlist = {}
end
-- Migrate old integer-only GuildWatchlist entries to table format {type, author}
for guildName, val in pairs(iWRSettings.GuildWatchlist) do
    if type(val) ~= "table" then
        iWRSettings.GuildWatchlist[guildName] = { type = val, author = "" }
    end
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

    -- Relationship Colors (full -10 to +10 range)
    -- Hated: -10 to -6
    [-10]   = "|cffff2121",
    [-9]    = "|cffff2121",
    [-8]    = "|cffff2121",
    [-7]    = "|cffff2121",
    [-6]    = "|cffff2121",
    -- Disliked: -5 to -1
    [-5]    = "|cfffd7030",
    [-4]    = "|cfffd7030",
    [-3]    = "|cfffd7030",
    [-2]    = "|cfffd7030",
    [-1]    = "|cfffd7030",
    -- Liked: +1 to +5
    [1]     = "|cff80f451",
    [2]     = "|cff80f451",
    [3]     = "|cff80f451",
    [4]     = "|cff80f451",
    [5]     = "|cff80f451",
    -- Respected: +6 to +9
    [6]     = "|cff80f451",
    [7]     = "|cff80f451",
    [8]     = "|cff80f451",
    [9]     = "|cff80f451",
    -- Superior: 10
    [10]    = "|cff4da6ff",

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
    -- Number to name (full -10 to +10 range)
    -- Hated: -10 to -6
    [-10] = "Hated", [-9] = "Hated", [-8] = "Hated", [-7] = "Hated", [-6] = "Hated",
    -- Disliked: -5 to -1
    [-5] = "Disliked", [-4] = "Disliked", [-3] = "Disliked", [-2] = "Disliked", [-1] = "Disliked",
    -- Clear: 0
    [0] = "Clear",
    -- Liked: +1 to +5
    [1] = "Liked", [2] = "Liked", [3] = "Liked", [4] = "Liked", [5] = "Liked",
    -- Respected: +6 to +9
    [6] = "Respected", [7] = "Respected", [8] = "Respected", [9] = "Respected",
    -- Superior: 10
    [10] = "Superior",

    -- Name to number (representative value per group)
    Hated = -10,
    Disliked = -5,
    Clear = 0,
    Liked = 1,
    Respected = 6,
    Superior = 10,
}

-- ╭──────────────────────────────────────╮
-- │      Relation Level Key Maps         │
-- ╰──────────────────────────────────────╯
-- Maps level count → ordered keys (high to low for positive, mild to harsh for negative)
-- Base keys (+10, +1, -1, -10) are always present at minimum counts (3 pos, 2 neg)
iWR.PositiveKeyMap = {
    [3]  = {10, 6, 1},
    [4]  = {10, 6, 3, 1},
    [5]  = {10, 8, 6, 3, 1},
    [6]  = {10, 8, 6, 4, 2, 1},
    [7]  = {10, 9, 7, 6, 4, 2, 1},
    [8]  = {10, 9, 8, 6, 5, 3, 2, 1},
    [9]  = {10, 9, 8, 7, 6, 4, 3, 2, 1},
    [10] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1},
}

iWR.NegativeKeyMap = {
    [2]  = {-1, -10},
    [3]  = {-1, -6, -10},
    [4]  = {-1, -3, -6, -10},
    [5]  = {-1, -3, -6, -8, -10},
    [6]  = {-1, -2, -4, -6, -8, -10},
    [7]  = {-1, -2, -4, -6, -7, -9, -10},
    [8]  = {-1, -2, -3, -5, -6, -8, -9, -10},
    [9]  = {-1, -2, -3, -4, -6, -7, -8, -9, -10},
    [10] = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10},
}

function iWR.GetLevelKeys(goodCount, badCount)
    goodCount = math.max(3, math.min(10, goodCount or 3))
    badCount  = math.max(2, math.min(10, badCount or 2))
    return iWR.PositiveKeyMap[goodCount], iWR.NegativeKeyMap[badCount]
end

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
    -- Hated: -10 to -6
    [-10] = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Hated.blp",
    [-9]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Hated.blp",
    [-8]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Hated.blp",
    [-7]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Hated.blp",
    [-6]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Hated.blp",
    -- Disliked: -5 to -1
    [-5]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Disliked.blp",
    [-4]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Disliked.blp",
    [-3]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Disliked.blp",
    [-2]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Disliked.blp",
    [-1]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Disliked.blp",
    -- Clear: 0 (no target frame)
    -- Liked: +1 to +5
    [1]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Liked.blp",
    [2]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Liked.blp",
    [3]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Liked.blp",
    [4]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Liked.blp",
    [5]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Liked.blp",
    -- Respected: +6 to +9
    [6]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Respected.blp",
    [7]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Respected.blp",
    [8]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Respected.blp",
    [9]   = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Respected.blp",
    -- Superior: 10
    [10]  = iWR.AddonPath .. "Images\\TargetFrames\\" .. iWR.ImagePath .. "\\Superior.blp",
}

-- ╭────────────────────────╮
-- │      List of Icons     │
-- ╰────────────────────────╯
iWR.Icons = {
    iWRIcon     = iWR.AddonPath .. "Images\\Logo_iWR.blp",
    Database    = iWR.AddonPath .. "Images\\Icons\\Database.blp",
    -- Hated: -10 to -6
    [-10]       = iWR.AddonPath .. "Images\\Icons\\Hated.blp",
    [-9]        = iWR.AddonPath .. "Images\\Icons\\Hated.blp",
    [-8]        = iWR.AddonPath .. "Images\\Icons\\Hated.blp",
    [-7]        = iWR.AddonPath .. "Images\\Icons\\Hated.blp",
    [-6]        = iWR.AddonPath .. "Images\\Icons\\Hated.blp",
    -- Disliked: -5 to -1
    [-5]        = iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    [-4]        = iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    [-3]        = iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    [-2]        = iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    [-1]        = iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    -- Clear: 0
    [0]         = iWR.AddonPath .. "Images\\Icons\\Clear.blp",
    -- Liked: +1 to +5
    [1]         = iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    [2]         = iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    [3]         = iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    [4]         = iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    [5]         = iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    -- Respected: +6 to +9
    [6]         = iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    [7]         = iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    [8]         = iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    [9]         = iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    -- Superior: 10
    [10]        = "Interface\\Icons\\Spell_ChargePositive",
}

iWR.ChatIcons = {
    -- Hated: -10 to -6
    [-10] = iWR.AddonPath .. "Images\\ChatIcons\\Hated.blp",
    [-9]  = iWR.AddonPath .. "Images\\ChatIcons\\Hated.blp",
    [-8]  = iWR.AddonPath .. "Images\\ChatIcons\\Hated.blp",
    [-7]  = iWR.AddonPath .. "Images\\ChatIcons\\Hated.blp",
    [-6]  = iWR.AddonPath .. "Images\\ChatIcons\\Hated.blp",
    -- Disliked: -5 to -1
    [-5]  = iWR.AddonPath .. "Images\\ChatIcons\\Disliked.blp",
    [-4]  = iWR.AddonPath .. "Images\\ChatIcons\\Disliked.blp",
    [-3]  = iWR.AddonPath .. "Images\\ChatIcons\\Disliked.blp",
    [-2]  = iWR.AddonPath .. "Images\\ChatIcons\\Disliked.blp",
    [-1]  = iWR.AddonPath .. "Images\\ChatIcons\\Disliked.blp",
    -- Liked: +1 to +5
    [1]   = iWR.AddonPath .. "Images\\ChatIcons\\Liked.blp",
    [2]   = iWR.AddonPath .. "Images\\ChatIcons\\Liked.blp",
    [3]   = iWR.AddonPath .. "Images\\ChatIcons\\Liked.blp",
    [4]   = iWR.AddonPath .. "Images\\ChatIcons\\Liked.blp",
    [5]   = iWR.AddonPath .. "Images\\ChatIcons\\Liked.blp",
    -- Respected: +6 to +9
    [6]   = iWR.AddonPath .. "Images\\ChatIcons\\Respected.blp",
    [7]   = iWR.AddonPath .. "Images\\ChatIcons\\Respected.blp",
    [8]   = iWR.AddonPath .. "Images\\ChatIcons\\Respected.blp",
    [9]   = iWR.AddonPath .. "Images\\ChatIcons\\Respected.blp",
    -- Superior: 10 (fallback to Respected icon)
    [10]  = iWR.AddonPath .. "Images\\ChatIcons\\Respected.blp",
}

-- ╭──────────────────────────────╮
-- │      Icon Picker List        │
-- ╰──────────────────────────────╯
iWR.IconPickerList = {
    -- Addon default icons
    iWR.AddonPath .. "Images\\Icons\\Respected.blp",
    iWR.AddonPath .. "Images\\Icons\\Liked.blp",
    iWR.AddonPath .. "Images\\Icons\\Disliked.blp",
    iWR.AddonPath .. "Images\\Icons\\Hated.blp",
    -- Positive (love, heal, bless, gifts)
    "Interface\\Icons\\INV_ValentinesCandy",
    "Interface\\Icons\\INV_Valentinescard01",
    "Interface\\Icons\\INV_Misc_Gift_01",
    "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
    "Interface\\Icons\\Spell_ChargePositive",
    "Interface\\Icons\\Spell_Holy_LayOnHands",
    "Interface\\Icons\\Spell_Holy_BlessingOfProtection",
    "Interface\\Icons\\INV_Crown_01",
    "Interface\\Icons\\Spell_Holy_DivinePurpose",
    -- Negative (skulls, anger, shadow, fire)
    "Interface\\Icons\\Ability_Creature_Cursed_02",
    "Interface\\Icons\\Spell_Shadow_DeathScream",
    "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
    "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    "Interface\\Icons\\Spell_Fire_Fire",
    "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    "Interface\\Icons\\Ability_Rogue_MasterOfSubtlety",
    "Interface\\Icons\\Spell_Shadow_AuraOfDarkness",
    "Interface\\Icons\\Spell_Shadow_DeathPact",
}

-- ╭───────────────────────╮
-- │      Game Version     │
-- ╰───────────────────────╯
local gameTocNumber = tonumber(iWR.GameTocVersion) or 0
if gameTocNumber >= 120000 then
    iWR.GameVersionName = "Retail WoW"
elseif gameTocNumber > 50000 and gameTocNumber < 59999 then
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

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Backward Compatibility                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- These global variables are kept for backward compatibility with existing code