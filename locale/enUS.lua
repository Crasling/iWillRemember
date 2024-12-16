-- Bartender4 Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/bartender4/localization/ ;¶


local L = LibStub("AceLocale-3.0"):NewLocale("RememberYouAddon", "enUS", true)

L["VersionNumber"] = "v1.0.0 edit by Crasling"
L["RYOnLoad"] = "|cffff9716[RememberYou]: Personal Modification Version v1.0.0 by Crasling.|r"
L["RYStartNote"] = "\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Note: "
L["RYNotifyBase"] = "|cffff9716Character note: [|r"
L["RYNotifyEnd"] = "|cffff9716] created.|r"
L["RYEditboxName"] = "Player Name"
L["RYEditboxNote"] = "Note"
L["RYDataReset"] = "|cffff9716[RememberYou]: Database cleared.|r"
L["RYDataSendRecent"] = "|cffff9716[RememberYou]: Sending data...|r"
L["RYDataSendFull"] = "|cffff9716[RememberYou]:  Sending data...|r"
L["RYDataImportOn"] = "|cffff9716[RememberYou]: Data sharing is ON.|r"
L["RYDataImportOff"] = "|cffff9716[RememberYou]: Data sharing is OFF.|r"
L["RYSetSkin"] = "|cffff9716[RememberYou]: Skin activated.|r"
L["RYSetSkinToggle"] = "|cffff9716[RememberYou]: Skin changed.|r"
L["RYDataSharedFull"] = "|cffff9716[RememberYou]: Database (Full) was shared with party.|r"
L["RYDataSharedRecent"] = "|cffff9716[RememberYou]: Database (New) was shared with party.|r"
L["RYDataReceived"] = "|cffff9716[RememberYou]: Database was updated from party.|r"


L["RYNoTarget"] = "|cffff9716[RememberYou]: You must target player or write name.|r"
L["RememberYouDefaultNotes"] = {
"PlaceHolder", --// First index 1
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Note: |cffff2121Hated|r \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Skull.blp:14\124t",
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Note: |cffff2121Unfriendly|r \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Dislike.blp:14\124t",
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Note: |cff80f451Friendly \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Like.blp:14\124t",
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Note: |cff80f451Exalted|r \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Friend.blp:14\124t",
}

L["RYHelp1"] = "|cffff9716[RememberYou]: /rememberyou /ry|r"
L["RYHelp2"] = "|cffff9716/ry help|r"
L["RYHelp3"] = "|cffff9716/ry data reset|r **Clear all data."
L["RYHelp4"] = "|cffff9716/ry data send recent|r **Share recent data with guild"
L["RYHelp5"] = "|cffff9716/ry data send full|r **Share all data with guild."
L["RYHelp6"] = "|cffff9716/ry import on|r **Activate guild addon communication."
L["RYHelp7"] = "|cffff9716/ry import off|r **Deactivate guild addon communication."
L["RYHelp8"] = "|cffff9716/ry skin 1-4|r *Change artwork."