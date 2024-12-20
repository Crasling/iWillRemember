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

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Localization                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
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

L["iWRLoaded"] = Msg("iWillRemember Version")
L["DevLoad"] = Msg("iWillRemember Debug messages are now active. Welcome Developer")
L["InvalidTarget"] = Msg("Target must be a player")
