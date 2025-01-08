-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Colors = {
    -- Standard Colors
    iWR = "|cffff9716",
    White = "|cFFFFFFFF",
    Black = "|cFF000000",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Blue = "|cFF0000FF",
    Yellow = "|cFFFFFF00",
    Cyan = "|cFF00FFFF",
    Magenta = "|cFFFF00FF",
    Orange = "|cFFFFA500",
    Gray = "|cFF808080",

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

local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "enUS", true)
local DefaultMessageStart = Colors.iWR .. "[iWR]: "
local function Msg(message)
    return DefaultMessageStart .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Text Templates                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NoteToolTip"] = Colors.iWR .. "[iWR]: "
L["DefaultNameInput"] = "Enter player name..."
L["DefaultNoteInput"] = "Enter note..."
L["MinimapButtonLeftClick"] = (Colors.Yellow .. "Left Click: " .. Colors.Orange .. "Open iWR Menu")
L["MinimapButtonShiftLeftClick"] = (Colors.Yellow .. "Shift-Left Click: " .. Colors.Orange .. "Open iWR Database")
L["MinimapButtonRightClick"] = (Colors.Yellow .. "Right Click: " .. Colors.Orange .. "Open Settings")
L["CharNoteCreated"] = Colors.iWR .."] added to the iWR Database.|r"
L["CharNoteUpdated"] = Colors.iWR .."] was updated in the iWR Database.|r"
L["CharNoteRemoved"] = Colors.iWR .."] was removed from the iWR Database.|r"
L["CharNoteColorUpdate"] = Colors.iWR .."] was found with missing class information in the iWR Database. Class color was added to the iWR Database."

L["HelpSync"] = Colors.Yellow .. "How to sync: " .. Colors.iWR .. "Add your friends in the social panel in-game, It will not share to Battle.Net friends(REAL ID), only the friends added to the World of Warcraft friendslist, and you both need to add each other for sync to go through."
L["HelpUse"] = Colors.Yellow .. "How to use: " .. Colors.iWR .. "Target a player or write their name manually, optionally add a note and then press Respected, Liked, Disliked or Hated to save the player in the database"
L["HelpClear"] = Colors.Yellow .. "How to clear: " .. Colors.iWR .. "When pressing the Clear button the name in the player name text box will be removed from the database, you can also remove them from the database using the remove button, or just edit it from the database."
L["HelpSettings"] = Colors.Yellow .. "Settings Menu: " .. Colors.iWR .. "Right clicking the minimap icon to open settings menu."
L["HelpDiscord"] = Colors.Yellow .."Help Discord: " .. Colors.iWR .. "Click the Question Mark Button without a player name to put code in the note field to be able to copy [https://discord.gg/8nnt25aw8B]"

L["iWRLoaded"] = Msg("iWillRemember Version")
L["iWRWelcomeStart"] = Msg("Thank you ")
L["iWRWelcomeEnd"] = Colors.iWR .. (" for being part of the development of iWillRemember, if you get into any issues please reach out on CurseForge in the comment section or Discord [https://discord.gg/8nnt25aw8B], can be copied from the Question Mark in the iWR menu.")
L["DiscordCopiedToNote"] = Msg("Discord link was copied to note field.")
L["DiscordLink"] = ("https://discord.gg/8nnt25aw8B")
L["InCombat"] = Msg("Cannot be used in combat.")
L["CharNoteStart"] = Msg("Character note [")
L["DebugError"] = Msg(Colors.Red .. "ERROR: " .. Colors.iWR)
L["DebugWarning"] = Msg(Colors.Yellow .. "WARNING: " .. Colors.iWR)
L["DebugInfo"] = Msg(Colors.White .. "INFO: " .. Colors.iWR)
L["NameInputError"] = Msg("Unable to add player: The name contains invalid characters or is empty. Please remove spaces, numbers, or special symbols and try again.")
L["ClearInputError"] = Msg("Unable to clear player: The name contains invalid characters or is empty. Please remove spaces, numbers, or special symbols and try again.")
L["GroupWarning"] = Msg((Colors.Red .. "Warning: Database Matches in group.|r"))
L["NewVersionAvailable"] = Msg("A new version is available on CurseForge.")