-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════

-- ──────────────────────────────────────────────────────────────
-- [[                      Localization                        ]]
-- ──────────────────────────────────────────────────────────────

local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "enUS", true)

-- Default Message Start (color and prefix)
local DefaultMessageStart = "|cffff9716[iWR]:"

-- Create String
local function Msg(message)
    return DefaultMessageStart .. message
end

-- Using the helper function to set the localized strings
L["VersionNumber"] = ("v0.1.0")
L["NoteToolTip"] = "[iWR]: "

L["iWRLoaded"] = Msg("iWillRemember Version")
L["DefaultNameInput"] = Msg("Enter player name...")
L["DefaultNoteInput"] = Msg("Enter note...")
L["DevLoad"] = Msg("iWillRemember Debug messages are now active. Welcome Developer")
L["InvalidTarget"] = Msg("|cffff9716[iWR]: Target must be a player")
