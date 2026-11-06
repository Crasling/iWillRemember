-- Keep notes, sharing contacts, and deletion history in the same server ruleset.
local scopedSettings = { "SyncList", "DeletedEntries", "MyCharacters", "GuildWatchlist", "iWRDatabaseBackupInfo" }
local activeScope

function iWR:IsSharingSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

function iWR:SharingCall(callback, ...)
    if type(callback) ~= "function" then return nil end
    local function pack(...) return { n = select("#", ...), ... } end
    local values = pack(pcall(callback, ...))
    if not values[1] then return nil end
    for index = 2, values.n do
        if self:IsSharingSecret(values[index]) then return nil end
    end
    return unpack(values, 2, values.n)
end

local function integer(value)
    return not iWR:IsSharingSecret(value) and type(value) == "number"
        and value >= 0 and value < 2147483647 and value == math.floor(value)
end

function iWR:ReadSharingRuleset()
    if not C_GameRules or not Enum or not Enum.GameRule then return nil end
    local mode = self:SharingCall(C_GameRules.GetActiveGameMode)
    local record = self:SharingCall(C_GameRules.GetCurrentGameModeRecordID)
    local region = self:SharingCall(GetCurrentRegion)
    local function rule(name)
        local id = Enum.GameRule[name]
        if not integer(id) then return nil end
        return self:SharingCall(C_GameRules.IsGameRuleActive, id)
    end
    local hardcore, pvp, rp = rule("HardcoreRuleset"), rule("PvPRuleset"), rule("RPRuleset")
    if not integer(mode) or not integer(record) or type(hardcore) ~= "boolean"
        or type(pvp) ~= "boolean" or type(rp) ~= "boolean"
        or not integer(region) or not integer(WOW_PROJECT_ID) then return nil end
    local category, label
    if hardcore then category, label = "hc", "Hardcore"
    elseif rp and pvp then category, label = "rppvp", "RP-PvP"
    elseif rp then category, label = "rppve", "RP-PvE"
    elseif pvp then category, label = "pvp", "PvP"
    else category, label = "pve", "Normal (PvE)" end
    -- Server flags define the namespace. Personal PvP/War Mode toggles, zone
    -- type, experience presets, and layer IDs must not switch note databases.
    local key = table.concat({ "s", WOW_PROJECT_ID, region, record, mode, category }, "-")
    local oldKey = table.concat({ "f", WOW_PROJECT_ID, region, record, mode, hardcore and 1 or 0 }, "-")
    return key, label, oldKey
end

function iWR:GetSharingScope()
    local key = self:ReadSharingRuleset()
    if key == activeScope then return key end
end

function iWR:SaveRulesetStorage()
    if not iWRRulesetStores then return end
    local bucket = activeScope and iWRRulesetStores.buckets[activeScope] or iWRRulesetStores.pending
    if not bucket then return end
    bucket.database, bucket.backup, bucket.memory = iWRDatabase, iWRDatabaseBackup, iWRMemory
    for _, key in ipairs(scopedSettings) do bucket.settings[key] = iWRSettings[key] end
end

function iWR:ActivateSharingRuleset()
    local key, label, oldKey = self:ReadSharingRuleset()
    iWRRulesetStores = iWRRulesetStores or { buckets = {} }
    iWRRulesetStores.buckets = iWRRulesetStores.buckets or {}
    if key and key == activeScope then return true end
    self:SaveRulesetStorage()

    -- Old saves did not record a ruleset. Preserve an untouched recovery copy
    -- and assign them only to the first ruleset this client can identify.
    if not iWRRulesetStores.legacy then
        local legacy = { database = iWRDatabase, backup = iWRDatabaseBackup, memory = iWRMemory, settings = {} }
        for _, setting in ipairs(scopedSettings) do legacy.settings[setting] = iWRSettings[setting] end
        iWRRulesetStores.legacy = CopyTable(legacy)
    end
    if not key then
        if not activeScope then
            iWRRulesetStores.pending = iWRRulesetStores.pending or {
                database = {}, backup = {}, memory = {}, settings = {},
            }
            local pending = iWRRulesetStores.pending
            iWRDatabase, iWRDatabaseBackup, iWRMemory = pending.database, pending.backup, pending.memory
            for _, setting in ipairs(scopedSettings) do
                pending.settings[setting] = pending.settings[setting] or {}
                iWRSettings[setting] = pending.settings[setting]
            end
        end
        return false
    end

    local bucket = iWRRulesetStores.buckets[key]
    if not bucket then
        iWRRulesetStores.scopeMigrations = iWRRulesetStores.scopeMigrations or {}
        local oldBucket = oldKey and iWRRulesetStores.buckets[oldKey]
        if oldBucket and not iWRRulesetStores.scopeMigrations[oldKey] then
            -- Early 0.24.1 test builds did not distinguish PvE/PvP/RP. Adopt
            -- that store once for the current server and retain the original.
            bucket = CopyTable(oldBucket)
            iWRRulesetStores.scopeMigrations[oldKey] = key
            iWRRulesetStores.legacyAssignedTo = iWRRulesetStores.legacyAssignedTo or key
        elseif not iWRRulesetStores.legacyAssignedTo then
            bucket = CopyTable(iWRRulesetStores.legacy)
            iWRRulesetStores.legacyAssignedTo = key
        else
            bucket = { database = {}, backup = {}, memory = {}, settings = {} }
        end
        iWRRulesetStores.buckets[key] = bucket
    end
    local pending = iWRRulesetStores.pending
    if pending then
        for name, entry in pairs(pending.database) do
            if not bucket.database[name] then bucket.database[name] = entry end
        end
        if next(pending.backup) then bucket.backup = pending.backup end
        for setting, values in pairs(pending.settings) do
            bucket.settings[setting] = bucket.settings[setting] or {}
            for name, value in pairs(values) do bucket.settings[setting][name] = value end
        end
        bucket.memory.GroupLog = bucket.memory.GroupLog or {}
        for _, entry in ipairs(pending.memory.GroupLog or {}) do
            bucket.memory.GroupLog[#bucket.memory.GroupLog + 1] = entry
        end
        iWRRulesetStores.pending = nil
    end
    activeScope = key
    iWRDatabase, iWRDatabaseBackup, iWRMemory = bucket.database, bucket.backup, bucket.memory
    for _, setting in ipairs(scopedSettings) do
        bucket.settings[setting] = bucket.settings[setting] or {}
        iWRSettings[setting] = bucket.settings[setting]
    end
    iWRSettings.SyncType = nil
    bucket.label, bucket.lastUsed = label, time()
    local character = self:SharingCall(UnitGUID, "player")
    if type(character) == "string" then
        iWRRulesetStores.characters = iWRRulesetStores.characters or {}
        iWRRulesetStores.characters[character] = key
    end
    if self.ResetSharingSession then self:ResetSharingSession() end
    self.WarnedPlayers, self.ExpandedEntries, self.LoggedThisSession = {}, {}, {}
    if self.detailFrame then self.detailFrame:Hide() end
    if self.RefreshSharingPanel then self:RefreshSharingPanel() end
    self:DebugMsg("Active sharing ruleset: " .. label .. " (" .. key .. ").", 3)
    return true
end

function iWR:GetSharingRulesetLabel()
    local key, label = self:ReadSharingRuleset()
    return key and key == activeScope and label or "Waiting for server ruleset"
end
