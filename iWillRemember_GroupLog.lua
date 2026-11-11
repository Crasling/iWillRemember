-- Keep one player row for the group session. Zone changes and dungeon
-- entrances belong under that row rather than becoming duplicate players.
local changingWorld = false
local playerIdentity
local function safe(callback, ...)
    return iWR:SharingCall(callback, ...)
end

local function owner()
    if playerIdentity then return playerIdentity end
    local value = safe(UnitGUID, "player") or safe(iWR.GetUnitPlayerIdentity, iWR, "player")
    if type(value) == "string" then playerIdentity = value end
    return playerIdentity
end

local function stateForPlayer()
    if not iWRMemory then return end
    local id = owner()
    if not id then return end
    iWRMemory.GroupLogSessions = iWRMemory.GroupLogSessions or {}
    local states = iWRMemory.GroupLogSessions
    states[id] = states[id] or { sequence = 0 }
    return states[id]
end

function iWR:NormalizeGroupLog()
    if not iWRMemory then return {} end
    iWRMemory.GroupLog = iWRMemory.GroupLog or {}
    local lookup, entries = {}, iWRMemory.GroupLog
    for index, entry in ipairs(entries) do
        if type(entry) == "table" and type(entry.name) == "string" then
            local id, name, realm = self:GetPlayerDatabaseKey(entry.name, entry.realm)
            if id then
                entry.name, entry.realm = name, realm
                -- Old saves have no session identity. Keep each historical
                -- encounter instead of guessing which dungeon runs to discard.
                entry.session = entry.session or ("legacy:" .. index .. ":" .. tostring(entry.timestamp or 0))
                entry.visits = entry.visits or { { zone = entry.zone or "", isInstance = entry.isInstance,
                    instanceType = entry.instanceType, timestamp = entry.timestamp, date = entry.date } }
                lookup[entry.session .. ":" .. id:lower()] = entry
            end
        end
    end
    return lookup
end

function iWR:EndGroupLogSession()
    local state = stateForPlayer()
    if state then state.active = nil end
    wipe(self.LoggedThisSession)
end

local function location(state)
    local zone = safe(GetRealZoneText)
    if type(zone) ~= "string" or zone == "" then return end
    local inside, kind = safe(IsInInstance)
    if type(inside) ~= "boolean" or type(kind) ~= "string" then return end
    local _, instanceKind, difficulty, _, _, _, _, map = safe(GetInstanceInfo)
    if type(GetInstanceInfo) == "function" then
        -- Unreadable or still-loading instance information is not a zone change.
        if instanceKind ~= kind or type(map) ~= "number" or type(difficulty) ~= "number" then return end
    else map, difficulty = 0, 0 end
    local signature = table.concat({ inside and "instance" or "world", kind, map, difficulty, zone }, ":")
    -- A fresh entrance is a distinct visit, even for the same dungeon. Reloads
    -- keep the active visit; ordinary roster updates never create another one.
    if state.location ~= signature then
        state.visitSequence = (state.visitSequence or 0) + 1
        state.location = signature
    end
    return { id = state.visitSequence, zone = zone, isInstance = inside, instanceType = kind,
        mapID = map, difficultyID = difficulty, timestamp = time(), date = date("%Y-%m-%d") }
end

function iWR:LogGroupMembers()
    if changingWorld or not iWRSettings.GroupLogEnabled or not iWRMemory then return end
    local grouped = safe(IsInGroup)
    if grouped == false then self:EndGroupLogSession(); return end
    if grouped ~= true then return end
    local count, raid = safe(GetNumGroupMembers), safe(IsInRaid)
    if type(count) ~= "number" or count <= 1 or type(raid) ~= "boolean" then return end
    local state = stateForPlayer()
    if not state then return end
    if not state.active then
        state.sequence = state.sequence + 1
        state.active = { id = owner() .. ":" .. time() .. ":" .. state.sequence, seen = {}, visitSequence = 0 }
        self:DebugMsg("Group Log: started a new group session.", 3)
    end
    local session = state.active
    local visit = location(session)
    if not visit then return end
    local lookup = self:NormalizeGroupLog()
    for index = 1, math.min(40, raid and count or count - 1) do
        local unit = (raid and "raid" or "party") .. index
        local name, realm = safe(UnitName, unit)
        if type(name) == "string" and name ~= UNKNOWNOBJECT and name ~= "Unknown"
            and safe(UnitExists, unit) == true and safe(UnitIsUnit, unit, "player") == false then
            local id, displayName, displayRealm = self:GetPlayerDatabaseKey(name, realm)
            if id then
                id = id:lower()
                local entry = lookup[session.id .. ":" .. id]
                if not entry and not session.seen[id] then
                    entry = { name = displayName, realm = displayRealm, session = session.id,
                        timestamp = time(), date = date("%Y-%m-%d"), visits = {} }
                    iWRMemory.GroupLog[#iWRMemory.GroupLog + 1] = entry
                    session.seen[id] = true
                    self:DebugMsg("Group Log: added " .. displayName .. " to this session.", 3)
                end
                -- A dismissed row stays dismissed for the rest of this session.
                if entry then
                    local _, class = safe(UnitClass, unit)
                    local _, race = safe(UnitRace, unit)
                    entry.class, entry.race = class or entry.class, race or entry.race
                    entry.faction = safe(UnitFactionGroup, unit) or entry.faction
                    entry.lastSeen = time()
                    entry.zone, entry.isInstance, entry.instanceType = visit.zone, visit.isInstance, visit.instanceType
                    local previous = entry.visits[#entry.visits]
                    if not previous or previous.id ~= visit.id then
                        entry.visits[#entry.visits + 1] = CopyTable(visit)
                    else previous.lastSeen = time() end
                end
            end
        end
    end
    self:PruneGroupLog()
end

function iWR:UpdateGroupLogZone()
    self:LogGroupMembers()
end

function iWR:OnGroupLogWorldEvent(event, initialLogin, reloading)
    changingWorld = event == "PLAYER_LEAVING_WORLD"
    if changingWorld then return end
    -- A loading-screen entrance can lead to another copy of the same dungeon.
    -- Its map ID alone does not distinguish runs. Keep the entrance separately,
    -- but do not count a login or UI reload as another visit.
    if initialLogin == false and reloading == false then
        local state = stateForPlayer()
        if state and state.active then state.active.location = nil end
    end
    self:LogGroupMembers()
end

function iWR:PruneGroupLog()
    if not iWRMemory then return end
    self:NormalizeGroupLog()
    while #iWRMemory.GroupLog > self.CONSTANTS.MAX_GROUP_LOG_ENTRIES do
        table.remove(iWRMemory.GroupLog, 1)
    end
end

function iWR:ClearGroupLog()
    if iWRMemory and iWRMemory.GroupLog then wipe(iWRMemory.GroupLog) end
    self:DebugMsg("Group log cleared.", 3)
end

function iWR:GetGroupLogSummary(entry)
    local visits = entry.visits or {}
    local latestZone
    for index = #visits, 1, -1 do
        local visit = visits[index]
        local zone = type(visit) == "table" and visit.zone
        if type(zone) == "string" and zone ~= "" then
            if visit.instanceType == "party" or visit.instanceType == "raid"
                or (visit.isInstance and visit.instanceType ~= "pvp" and visit.instanceType ~= "arena") then
                return zone
            end
            latestZone = latestZone or zone
        end
    end
    return latestZone or entry.zone or ""
end

function iWR:GetGroupLogVisitLines(entry)
    local lines = {}
    for _, visit in ipairs(entry.visits or {}) do
        local stamp = visit.timestamp and date("%H:%M", visit.timestamp) or ""
        local label = visit.instanceType == "party" and " |cFF00CCFF(Dungeon)|r"
            or visit.instanceType == "raid" and " |cFFFF8800(Raid)|r"
            or visit.isInstance and " |cFF808080(Instance)|r" or ""
        lines[#lines + 1] = "|cFF999999" .. (visit.date or entry.date or "") .. " " .. stamp
            .. "|r  " .. (visit.zone or "") .. label
    end
    return lines
end
