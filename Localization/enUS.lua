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
L["NoteToolTip"] = "[iWR]: "
L["DefaultNameInput"] = "Enter player name..."
L["DefaultNoteInput"] = "Enter note..."
L["MinimapButtonLeftClick"] = (Colors.Yellow .. "Left Click: " .. Colors.Orange .. "Open iWR Menu")
L["MinimapButtonShiftLeftClick"] = (Colors.Yellow .. "Shift-Left Click: " .. Colors.Orange .. "Open iWR Database")
L["MinimapButtonRightClick"] = (Colors.Yellow .. "Right Click: " .. Colors.Orange .. "Open iWR Settings")

L["HelpSync"] = Colors.Yellow .. "How to sync: " .. Colors.iWR .. "Add your friends in the social panel in-game, It will not share to Battle.Net friends(REAL ID), only the friends added to the World of Warcraft friendslist"
L["HelpUse"] = Colors.Yellow .. "How to use: " .. Colors.iWR .. "Target a player or write their name manually, optionally add a note and then press Respected, Liked, Disliked or Hated to save the player in the database"
L["HelpClear"] = Colors.Yellow .. "How to clear: " .. Colors.iWR .. "When pressing the Clear button the name in the player name text box will be removed from the database, you can also remove them from the database using the remove button, or just edit it from the database."
L["HelpSettings"] = Colors.Yellow .. "Settings Menu: " .. Colors.iWR .. "You will find the settings menu in ESC > Options > addOns > iWillRemember"

L["iWRLoaded"] = Msg("iWillRemember Version v")
L["DevLoad"] = Msg("iWillRemember Debug messages are now active. Welcome Developer")
L["InvalidTarget"] = Msg("Target must be a player")
L["InCombat"] = Msg("Cannot be used in combat")
L["CharNoteStart"] = Msg("Character note: [")
L["CharNoteEnd"] = "|cffff9716] created.|r"
