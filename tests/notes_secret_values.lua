-- Reproduce a readable editor name with protected hostile-target data. Secret
-- stand-ins throw if any code tries to format, concatenate, or inspect them.
local fixture = assert(loadfile("tests/sharing.lua"))()
local state = fixture.client("Crasling Mordaine")
local env, addon = state.env, state.addon
local file = assert(io.open("iWillRemember_iWRFunctions.lua", "rb"))
local source = file:read("*a"):gsub("\r\n", "\n"); file:close()
local function forbidden() error("attempted to inspect or convert a secret value") end
local secret = setmetatable({}, { __tostring = forbidden, __concat = forbidden, __index = forbidden, __len = forbidden })
local existingSecretCheck = env.issecretvalue
env.issecretvalue = function(value) return rawequal(value, secret) or existingSecretCheck(value) end
local function plain(value)
    assert(not env.issecretvalue(value), "secret values never reach output or saved notes")
    if type(value) == "table" then for key, item in pairs(value) do plain(key); plain(item) end end
end
local output = {}
env.print = function(...) for index = 1, select("#", ...) do plain(select(index, ...)) end; output[#output + 1] = {...} end
setmetatable(addon.L, { __index = function(_, key) return key end })
addon.Colors.iWR, addon.Colors.Gray, addon.Colors.Reset = "|cffff9716", "|cFF808080", "|r"
addon.Colors[-10], addon.Colors[6] = "|cFFFF0000", "|cFF00FF00"
addon.Colors.Classes = { DRUID = "|cFFFF7D0A", WARLOCK = "|cFF8787ED", MAGE = "|cFF3FC7EB" }
addon.Cache.DataTable = {}
env.iWRSettings.DataSharing = false
env.iWRNameInput, env.iWRNoteInput = { ClearFocus = function() end }, { ClearFocus = function() end }
function addon:GetTypeName() return "Hated" end
function addon:GetCurrentTimeByHours() return 1000000, "2026-11-09" end
for _, method in ipairs({ "VerifyInputName", "VerifyInputNote", "CreateNote", "AddNewNote", "ClearNote",
    "ColorizePlayerNameByClass", "GetDatabaseEntry", "DebugMsg" }) do
    local body = assert(source:match("(function iWR:" .. method .. "%b().-\nend)"), method)
    assert(load("local L = iWR.L\n" .. body, method, "t", env))()
end
local targetName, targetRealm, targetClass, targetRace, targetFaction = secret, secret, secret, secret, secret
local playerName, playerRealm, playerClass = "Crasling", "Mordaine", "WARLOCK"
local metadataReads, legacyNameReads = 0, 0
env.UnitName = function(unit)
    if unit == "player" then return playerName, playerRealm end
    return targetName, targetRealm
end
env.GetUnitName = function() legacyNameReads = legacyNameReads + 1; return secret end
env.UnitClass = function(unit)
    if unit == "player" then return "Warlock", playerClass end
    metadataReads = metadataReads + 1
    return "Druid", targetClass
end
env.UnitRace = function() metadataReads = metadataReads + 1; return "Tauren", targetRace end
env.UnitFactionGroup = function() metadataReads = metadataReads + 1; return targetFaction end
local coloredName, key = "|cFFFF7D0AArgonous Moo|r", "Argonous Moo-Forever"
for _, debug in ipairs({false, true}) do
    env.iWRSettings.DebugMode = debug
    addon:AddNewNote(coloredName, "Ninja", -10, false)
    local entry = assert(env.iWRDatabase[key])
    assert(entry[1] == "Ninja" and entry[2] == -10 and entry[4]:find("Argonous Moo", 1, true),
        "the exact reported editor values save while the target name is secret")
    assert(entry[12] == "DRUID" and entry[13] == "" and entry[8] == "",
        "class is safely inferred from the readable name color without inventing target data")
    assert(entry[6]:find("Crasling Mordaine", 1, true), "the author keeps the current character's full name")
    plain(entry)
end
assert(legacyNameReads == 0 and metadataReads == 0,
    "saving no longer calls GetUnitName or reads optional target details when identity is hidden")
targetName, targetRealm = "Argonous", secret
addon:CreateNote(coloredName, "Hidden surname", -10, false)
assert(env.iWRDatabase[key][1] == "Hidden surname" and not env.iWRDatabase["Argonous-Forever"],
    "a protected second-name field cannot create an incomplete Forever identity")
assert(addon:GetPlayerDatabaseKey("Argonous", secret) == nil and not addon:IsSamePlayerName(secret, "Argonous Moo"),
    "identity helpers reject protected names and surnames before string operations")
targetName, targetRealm = "Argonous", "Moo"
local entry = env.iWRDatabase[key]
entry[8], entry[12], entry[13] = "Horde", "DRUID", "Tauren"
addon.PendingNoteIdentity = { name = "Argonous Moo", class = secret, race = secret }
addon:CreateNote(coloredName, "Updated", -10, nil)
entry = env.iWRDatabase[key]
assert(entry[1] == "Updated" and entry[8] == "Horde" and entry[12] == "DRUID" and entry[13] == "Tauren",
    "unreadable target and pending metadata preserve the existing class, race, and faction")
assert(entry[10] and entry[10][#entry[10]][1] == "Hidden surname", "editing still preserves note history")
plain(entry)
targetClass, targetRace, targetFaction = "DRUID", "Tauren", "Horde"
addon:CreateNote("Argonous Moo", "Readable target", 6, true)
entry = env.iWRDatabase[key]
assert(entry[12] == "DRUID" and entry[13] == "Tauren" and entry[8] == "Horde" and entry[9],
    "readable matching target details and personal-note settings still work")
playerClass = secret
addon:CreateNote(coloredName, "Hidden author class", -10, true)
plain(env.iWRDatabase[key])
playerClass = "WARLOCK"
local unchanged = env.iWRDatabase[key]
addon:AddNewNote(coloredName, secret, -10, false)
addon:CreateNote(secret, "No save", -10, false)
addon:CreateNote(coloredName, "No save", secret, false)
addon:CreateNote(coloredName, "No save", -10, secret)
playerName = secret
addon:CreateNote(coloredName, "No author", -10, false)
playerName = "Crasling"
assert(env.iWRDatabase[key] == unchanged, "restricted editor or author values do not partially overwrite a note")
assert(not addon:VerifyInputName(secret) and not addon:VerifyInputNote(secret), "validators do not compare protected input")
targetName, targetRealm = secret, secret
addon:ClearNote(secret)
assert(env.iWRDatabase[key], "a protected deletion input cannot remove any entry")
addon:ClearNote(coloredName)
assert(not env.iWRDatabase[key] and env.iWRSettings.DeletedEntries[key],
    "deleting by the entered name still works with a protected target and records tombstones")
targetName, targetRealm = "Different", "Person"
addon:CreateNote("Manual Player", "Manual", 6, true)
assert(env.iWRDatabase["Manual Player-Forever"][12] == "", "a different target cannot supply another player's identity details")
addon.GameTocVersion = 110200
targetName, targetRealm = "Argonous", "Otherrealm"
local nativeKey, _, _, targetMatches = addon:ResolveNoteIdentity("Argonous")
assert(nativeKey == "Argonous-Otherrealm" and targetMatches, "native clients retain the readable target's realm for an unqualified name")
nativeKey, _, _, targetMatches = addon:ResolveNoteIdentity("Argonous-Explicitrealm")
assert(nativeKey == "Argonous-Explicitrealm" and not targetMatches, "an explicit realm is never replaced by a different target realm")
addon.GameTocVersion = 16001
local reader = fixture.client("Protected Note Reader")
state.roster[#state.roster + 1] = { name = reader.name, guid = reader.guid, online = true }
reader.roster[#reader.roster + 1] = { name = state.name, guid = state.guid, online = true }
assert(addon:AddSharingContact(reader.name) and reader.addon:AddSharingContact(state.name))
env.iWRSettings.DataSharing = true
targetName, targetRealm = secret, secret
addon:CreateNote(coloredName, "Shared after safe save", -10, false)
plain(addon.Cache.DataTable)
fixture.advance(8)
local received = assert(reader.env.iWRDatabase[key], "a note saved with a protected target still reaches its authorized sharing peer")
assert(received[1] == "Shared after safe save" and received[12] == "DRUID",
    "sharing retains the safely saved note and readable class details")
plain(received)
plain(env.iWRDatabase)
print("PASS: protected target names/surnames, manual and colored-name saves, safe class/race/faction metadata, author guards, note history, personal flags, deletion, and native realm handling")
