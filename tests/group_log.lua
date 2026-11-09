-- Exercise session persistence and the actual expandable Group Log controls.
local fixture = assert(loadfile("tests/sharing.lua"))()
local state = fixture.client("Group Log Owner")
local env, addon = state.env, state.addon
local members, grouped, raid = { "First Player", "Second Player" }, true, false
local zone, kind, map, difficulty = "The Barrens", "none", 1, 0
env.iWRSettings.GroupLogEnabled = true
addon.LoggedThisSession = {}
addon.CONSTANTS.MAX_GROUP_LOG_ENTRIES = 200
env.date = function(format, stamp) return os.date(format, stamp or env.time()) end
env.IsInGroup = function() return grouped end
env.IsInRaid = function() return raid end
env.GetNumGroupMembers = function() return grouped and #members + 1 or 0 end
env.UnitName = function(unit)
    if unit == "player" then return state.name end
    local index = tonumber(unit:match("%d+"))
    if raid and index == #members + 1 then return state.name end
    return members[index]
end
env.UnitExists = function(unit) return env.UnitName(unit) ~= nil end
env.UnitIsUnit = function(unit) return env.UnitName(unit) == state.name end
env.UnitClass = function() return "Paladin", "PALADIN" end
env.UnitRace = function() return "Undead", "Scourge" end
env.UnitFactionGroup = function() return "Horde" end
env.GetRealZoneText = function() return zone end
env.IsInInstance = function() return kind ~= "none", kind end
env.GetInstanceInfo = function() return zone, kind, difficulty, "Normal", 5, 0, false, map end
local function reload() assert(loadfile("iWillRemember_GroupLog.lua", "t", env))() end
reload()
local function log() addon:LogGroupMembers(); return env.iWRMemory.GroupLog end
local entries = log()
assert(#entries == 2 and #entries[1].visits == 1, "one row per group member")
local first, second = entries[1], entries[2]
log(); log()
assert(#entries == 2 and #first.visits == 1, "repeated roster events do not duplicate rows or visits")
zone = "Durotar"; log()
assert(#entries == 2 and #first.visits == 2, "outdoor zones collect under the existing player")
zone, kind, map = "Ragefire Chasm", "party", 389; log(); log()
zone, kind, map = "Wailing Caverns", "party", 43; log()
assert(#first.visits == 4 and first.visits[3].mapID == 389 and first.visits[4].mapID == 43,
    "different dungeons are retained in the same group session")
zone, kind, map = "The Barrens", "none", 1; log()
zone, kind, map = "Wailing Caverns", "party", 43; log()
assert(#first.visits == 6, "another entrance to the same dungeon is retained as a separate visit")
reload(); log()
assert(#entries == 2 and #first.visits == 6, "reload in the same instance preserves the group and current visit")
addon:OnGroupLogWorldEvent("PLAYER_ENTERING_WORLD", false, true)
assert(#first.visits == 6, "the reload world-entry event does not create another dungeon visit")
addon:OnGroupLogWorldEvent("PLAYER_LEAVING_WORLD")
addon:UpdateGroupLogZone(); log()
assert(#first.visits == 6, "roster and zone events during a loading screen do not record stale locations")
addon:OnGroupLogWorldEvent("PLAYER_ENTERING_WORLD", false, false)
addon:UpdateGroupLogZone(); log()
assert(#entries == 2 and #first.visits == 7,
    "a new entrance to another copy of the same dungeon survives even when its map ID is unchanged")
raid = true; log()
assert(#entries == 2, "party-to-raid conversion does not create another group session")
raid = false
members = { "Second Player" }; log()
members = { "First Player", "Second Player" }; log()
assert(#entries == 2, "a returning player stays in the same group session")
table.remove(entries, 1); reload(); log()
assert(#entries == 1 and entries[1] == second, "a dismissed player stays dismissed after roster updates and reload")
grouped = false; log()
grouped = true; log()
assert(#entries == 3 and entries[2].session ~= second.session, "leaving and regrouping starts a distinct session")
local previousMemory = env.iWRMemory
env.iWRMemory = { GroupLog = {} }; log()
assert(#env.iWRMemory.GroupLog == 2 and #previousMemory.GroupLog == 3, "ruleset history and active sessions remain isolated")
env.iWRMemory = previousMemory
local old = { name = "Legacy Player", realm = "Forever", timestamp = 100, date = "2026-11-01", zone = "Old Dungeon", isInstance = true }
entries[#entries + 1] = old
entries[#entries + 1] = { name = old.name, realm = old.realm, timestamp = 200, date = old.date, zone = old.zone, isInstance = true }
addon:NormalizeGroupLog()
assert(#entries == 5 and entries[4].visits[1].timestamp == 100 and entries[5].visits[1].timestamp == 200,
    "old encounters without session IDs are preserved instead of deleting possible dungeon runs")
local secret = setmetatable({}, { __tostring = function() error("secret converted to text") end })
local oldSecret = env.issecretvalue
env.issecretvalue = function(value) return rawequal(value, secret) or oldSecret(value) end
members = { secret }; log()
assert(#entries == 5, "secret player names are not compared, formatted, or stored")
members = { "First Player", "Second Player" }
local savedInfo, savedGroup = env.GetInstanceInfo, env.IsInGroup
env.GetInstanceInfo = function() return secret end
local currentVisits = #entries[3].visits
log()
env.GetInstanceInfo = savedInfo
env.IsInGroup = function() return secret end
log()
env.IsInGroup = savedGroup
log()
assert(#entries == 5 and #entries[3].visits == currentVisits,
    "unreadable instance and group data cannot invent zone changes or end the current session")
addon.CONSTANTS.MAX_GROUP_LOG_ENTRIES = 4
addon:PruneGroupLog(); assert(#entries == 4, "the session history retains the configured row bound")
addon:ClearGroupLog(); log()
assert(#entries == 0, "cleared rows are not immediately recreated in the current session")
print("PASS: group-session rows, reloads, zone/dungeon history, repeat visits, dismissals, and ruleset isolation")

-- Minimal widgets support the real row builder and its expand/dismiss buttons.
local widgets = {}
local function widget()
    local value = { shown = true, height = 34, width = 650, scripts = {} }
    local methods = {}
    function methods:SetScript(name, callback) self.scripts[name] = callback end
    function methods:SetText(text) self.text = text end
    function methods:SetHeight(height) self.height = height end
    function methods:SetWidth(width) self.width = width end
    function methods:GetHeight() return self.height end
    function methods:GetWidth() return self.width end
    function methods:SetSize(width, height) self.width, self.height = width, height end
    function methods:Show() self.shown = true end
    function methods:Hide() self.shown = false end
    function methods:SetShown(shown) self.shown = shown end
    function methods:GetVerticalScroll() return rawget(self, "scroll") or 0 end
    function methods:SetVerticalScroll(value) self.scroll = value end
    function methods:CreateTexture() return widget() end
    function methods:CreateFontString() return widget() end
    setmetatable(value, { __index = function(_, name) return methods[name] or function() end end })
    widgets[#widgets + 1] = value
    return value
end
env.CreateFrame = function() return widget() end
env.glContainer, env.glEmptyText, env.glScrollFrame = widget(), widget(), widget()
env.glScrollFrame.height = 100
env.IWR_RACE_ICONS, env.CLASS_ICON_TCOORDS, env.RAID_CLASS_COLORS = {}, {}, {}
env.L, addon.Colors.Default = {}, ""
function addon:StyleButton() end
local file = assert(io.open("iWillRemember_Frames.lua", "rb"))
local source = file:read("*a"):gsub("\r\n", "\n"); file:close()
source = assert(source:match("local glRowCache = %{%}.-\nend\n"))
assert(load(source, "Group Log rows", "t", env))()
entries[1] = first
addon:PopulateGroupLog()
local row
for _, item in ipairs(widgets) do if type(rawget(item, "expand")) == "table" then row = item; break end end
assert(row and row:GetHeight() == 34 and row.expandText.text == "+", "session row starts collapsed")
row.expand.scripts.OnClick()
local visitText = addon:GetGroupLogVisitLines(first)
assert(row:GetHeight() > 34 and #row.visitLines == #first.visits, "expansion creates a separate line for each retained visit")
for index, text in ipairs(visitText) do
    assert(row.visitLines[index].shown and row.visitLines[index].text == text,
        "each visit's zone and timestamp is rendered in its own visible line")
end
assert(row.visitLines[4].text:find("Wailing Caverns", 1, true), "the expanded history includes later dungeon visits")
row.expand.scripts.OnClick()
assert(row:GetHeight() == 34, "collapse restores a compact row")
for _, line in ipairs(row.visitLines) do assert(not line.shown, "collapse hides every history line") end
local sixVisits = env.CopyTable(first)
while #sixVisits.visits > 6 do table.remove(sixVisits.visits) end
entries[1] = sixVisits
addon:PopulateGroupLog()
row.expand.scripts.OnClick()
assert(row:GetHeight() == 34 + 6 * 18 + 10 and addon:GetGroupLogSummary(sixVisits) == "6 visits",
    "the six-visit summary and expanded height agree")
for index = 1, 6 do
    assert(row.visitLines[index].shown and row.visitLines[index].text == addon:GetGroupLogVisitLines(sixVisits)[index],
        "all six visits are individually visible")
end
assert(not row.visitLines[7].shown, "reusing a row with fewer visits hides the previous player's extra lines")
row.dismissBtn.scripts.OnClick()
assert(#entries == 0, "dismiss removes the intended session row")
print("PASS: actual Group Log expand, collapse, and dismiss controls")
