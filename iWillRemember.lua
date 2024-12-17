-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════


-- ──────────────────────────────────────────────────────────────
-- [[                       Namespace                          ]]
-- ──────────────────────────────────────────────────────────────

local Name,AddOn=...;
local Title=select(2,C_AddOns.GetAddOnInfo(Name)):gsub("%s*v?[%d%.]+$","");
local Version=C_AddOns.GetAddOnMetadata(Name,"Version");
local Author=C_AddOns.GetAddOnMetadata(Name,"Author");

-- ──────────────────────────────────────────────────────────────
-- [[                         Libs                             ]]
-- ──────────────────────────────────────────────────────────────

iWR = LibStub("AceAddon-3.0"):NewAddon("iWR", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("iWR")
local LDBroker = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

-- ──────────────────────────────────────────────────────────────
-- [[                       Variables                          ]]
-- ──────────────────────────────────────────────────────────────

local CurrDataTime
local CompDataTime
local Success
local DataCache

local TempTable = {}
local DataCacheTable = {}
local DataTimeTable = {}

iWRDatabase = {}
iWRSettings = {}

-- ──────────────────────────────────────────────────────────────
-- [[                     Settings Panel                       ]]
-- ──────────────────────────────────────────────────────────────


-- ──────────────────────────────────────────────────────────────
-- [[                      Event Handler                       ]]
-- ──────────────────────────────────────────────────────────────
function iWR:OnEnable()
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update",  "SetTargetingFrame")

    print(L["iWRLoaded"] .. L["VersionNumber"])

    if iWRSettings.Import ~= false then
        iWillRemember:RegisterComm("RYFullUpdate", "OnFullNotesCommReceived")
        iWillRemember:RegisterComm("RYOneUpdate", "OnNewNoteCommReceived")
        iWillRemember:SendFullDBUpdateToFriends()
    end
end