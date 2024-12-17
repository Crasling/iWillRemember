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

local Name, AddOn = ...
local Title = select(2, C_AddOns.GetAddOnInfo(Name)):gsub("%s*v?[%d%.]+$", "")
local Version = C_AddOns.GetAddOnMetadata(Name, "Version")
local Author = C_AddOns.GetAddOnMetadata(Name, "Author")

-- ──────────────────────────────────────────────────────────────
-- [[                         Libs                             ]]
-- ──────────────────────────────────────────────────────────────

iWR = LibStub("AceAddon-3.0"):NewAddon("iWR", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("iWR")
local LDBroker = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

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
-- [[                      Events Handler                      ]]
-- ──────────────────────────────────────────────────────────────

function iWR:OnEnable()
    -- Secure hooks to add custom behavior
    self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddNoteToGameTooltip")
    self:SecureHook("TargetFrame_Update", "SetTargetingFrame")

    -- Print a message to the chat frame when the addon is loaded
    print(L["iWRLoaded"] .. L["VersionNumber"])
end
