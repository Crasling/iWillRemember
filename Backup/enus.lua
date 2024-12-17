-- Bartender4 Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/bartender4/localization/ ;¶


local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "enUS", true)

L["VersionNumber"] = "v0.1.0"
L["iWRLoaded"] = "|cffff9716[iWR]: iWillRemember Version |r"
L["NotifyBase"] = "|cffff9716Character note: [|r"
L["NotifyEnd"] = "|cffff9716] created.|r"
L["EditboxName"] = "Player Name"
L["EditboxNote"] = "Note"
L["DataReset"] = "|cffff9716[iWR]: Database cleared.|r"
L["DataSendRecent"] = "|cffff9716[iWR]: Sending data...|r"
L["DataSendFull"] = "|cffff9716[iWR]:  Sending data...|r"
L["DataShareOn"] = "|cffff9716[iWR]: Data sharing is ON.|r"
L["DataShareOff"] = "|cffff9716[iWR]: Data sharing is OFF.|r"
L["DataSharedFull"] = "|cffff9716[iWR]: Database (Full) was shared with party.|r"
L["DataSharedRecent"] = "|cffff9716[iWR]: Database (New) was shared with party.|r"
L["DataReceived"] = "|cffff9716[iWR]: Database was updated from: |r"
L["NoTarget"] = "|cffff9716[iWillRemember]: You must target player or write name.|r"

-- Default Notes
L["iWRDefaultNotes"] = {
"\124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Custom.blp:14\124t Note: |cffff2121Hated|r \124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Skull.blp:14\124t",
"\124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Custom.blp:14\124t Note: |cffff2121Unfriendly|r \124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Dislike.blp:14\124t",
"\124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Custom.blp:14\124t Note: |cff80f451Friendly \124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Like.blp:14\124t",
"\124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Custom.blp:14\124t Note: |cff80f451Exalted|r \124TInterface\\AddOns\\iWillRemember\\Img\\Icons\\Friend.blp:14\124t",
}