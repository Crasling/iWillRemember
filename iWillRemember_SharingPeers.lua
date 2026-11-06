-- Only explicit whitelist entries may become sharing peers. Native presence
-- checks and paced Who searches never send chat whispers to discover a name.
local known, checks, whoQueue = {}, {}, {}
local whoActive, nextWhoAt, rosterAt = nil, 0, -100
local MAX_CONTACTS, PRESENCE_TTL = 100, 20

local function now() return GetTime() end
local function safe(callback, ...) return iWR:SharingCall(callback, ...) end
local function key(name)
    if iWR:IsSharingSecret(name) or type(name) ~= "string" then return nil end
    local value = iWR:GetPlayerDatabaseKey(name)
    return value and value:lower()
end
local function guid(value)
    return not iWR:IsSharingSecret(value) and type(value) == "string" and #value <= 80
        and value:match("^Player%-%w[%w%-]*$") and value or nil
end
local function changed()
    if iWR.RefreshSharingPanel then iWR:RefreshSharingPanel() end
end

function iWR:GetWhitelistEntry(name)
    local wanted = key(name)
    if not wanted then return nil end
    for _, entry in ipairs(iWRSettings.SyncList or {}) do
        if type(entry) == "table" and entry.type == "wow" and key(entry.name) == wanted then return entry end
    end
end

function iWR:NormalizeSharingWhitelist()
    local normalized, seen, archived = {}, {}, {}
    for _, entry in ipairs(iWRSettings.SyncList or {}) do
        local name
        if type(entry) == "table" and (entry.type == nil or entry.type == "wow") then
            local _, resolved = self:GetPlayerDatabaseKey(entry.name, entry.realm)
            name = resolved
        end
        local id = name and key(name)
        if id and #name <= 120 and not name:find("[%c|:%d]")
            and (not self:IsForeverClient() or name:find("%S+%s+%S+")) and #normalized < MAX_CONTACTS then
            if not seen[id] then
                seen[id], entry.name, entry.realm, entry.type = true, name, self.CurrentRealm, "wow"
                entry.guid = guid(entry.guid)
                normalized[#normalized + 1] = entry
            end
        else archived[#archived + 1] = entry end
    end
    iWRSettings.SyncList = normalized
    if #archived > 0 and iWRRulesetStores then
        iWRRulesetStores.archivedContacts = iWRRulesetStores.archivedContacts or {}
        for _, entry in ipairs(archived) do iWRRulesetStores.archivedContacts[#iWRRulesetStores.archivedContacts + 1] = entry end
        self:DebugMsg("Preserved " .. #archived .. " old sharing entries outside the active whitelist; re-add valid full character names to share with them.", 2)
    end
end

function iWR:AddSharingContact(name)
    if not self:GetSharingScope() then return false, "The server ruleset is not available yet." end
    if self:IsSharingSecret(name) or type(name) ~= "string" or #name > 120
        or name:find("[%c|:%d]") then return false, "Enter a full character name." end
    local _, resolved = self:GetPlayerDatabaseKey(name)
    if not resolved or (self:IsForeverClient() and not resolved:find("%S+%s+%S+")) then
        return false, "Enter the character's first and last name."
    end
    if self:GetWhitelistEntry(resolved) then return false, "This player is already on the whitelist." end
    if key(resolved) == key(self:SharingCall(self.GetUnitPlayerIdentity, self, "player")) then
        return false, "You cannot add this character to its own whitelist."
    end
    iWRSettings.SyncList = iWRSettings.SyncList or {}
    if #iWRSettings.SyncList >= MAX_CONTACTS then return false, "The whitelist is full (100 players)." end
    local entry = { name = resolved, realm = self.CurrentRealm, type = "wow" }
    iWRSettings.SyncList[#iWRSettings.SyncList + 1] = entry
    self:SaveRulesetStorage()
    self:DebugMsg("Added sharing contact: " .. resolved .. ".", 3)
    changed()
    return true
end

function iWR:RemoveSharingContact(name)
    for index, entry in ipairs(iWRSettings.SyncList or {}) do
        if key(entry.name) == key(name) then
            table.remove(iWRSettings.SyncList, index)
            if self.ForgetSharingPeer then self:ForgetSharingPeer(entry.name) end
            self:SaveRulesetStorage()
            changed()
            return true
        end
    end
    return false
end

local function remember(name, playerGuid, online)
    local id = key(name)
    if not id or iWR:IsSharingSecret(online) then return end
    local entry = known[id] or {}
    entry.name, entry.at, entry.online = name, now(), online == true
    entry.guid = guid(playerGuid) or entry.guid
    known[id] = entry
    local contact = iWR:GetWhitelistEntry(name)
    if contact and entry.guid then contact.guid = entry.guid end
end

function iWR:RefreshSharingRoster()
    if now() - rosterAt < 2 then return end
    rosterAt = now()
    local units = { "target", "mouseover" }
    local raid = safe(IsInRaid)
    local count = safe(raid and GetNumGroupMembers or GetNumSubgroupMembers) or 0
    if type(count) ~= "number" then count = 0 end
    for index = 1, math.min(40, count) do units[#units + 1] = (raid and "raid" or "party") .. index end
    for _, unit in ipairs(units) do
        if safe(UnitIsPlayer, unit) then
            local name = safe(self.GetUnitPlayerIdentity, self, unit)
            if name then remember(name, safe(UnitGUID, unit), safe(UnitIsConnected, unit)) end
        end
    end
    count = safe(GetNumGuildMembers) or 0
    if type(count) ~= "number" then count = 0 end
    for index = 1, math.min(1000, count) do
        local name, _, _, _, _, _, _, _, online, _, _, _, _, _, _, _, playerGuid = safe(GetGuildRosterInfo, index)
        if name then remember(name, playerGuid, online) end
    end
    if C_BattleNet and BNGetNumFriends then
        count = safe(BNGetNumFriends) or 0
        if type(count) ~= "number" then count = 0 end
        for index = 1, math.min(500, count) do
            local accounts = safe(C_BattleNet.GetFriendNumGameAccounts, index) or 0
            if type(accounts) ~= "number" then accounts = 0 end
            for account = 1, math.min(20, accounts) do
                local info = safe(C_BattleNet.GetFriendGameAccountInfo, index, account)
                if type(info) == "table" and not self:IsSharingSecret(info.characterName)
                    and not self:IsSharingSecret(info.wowProjectID) and info.wowProjectID == WOW_PROJECT_ID
                    and not self:IsSharingSecret(info.isOnline) and info.isOnline == true then
                    local name = self:SharingCall(self.ResolvePlayerIdentity, self, info.characterName, info.realmName)
                    if not self:IsSharingSecret(info.isInCurrentRegion) and info.isInCurrentRegion == true
                        and not self:IsSharingSecret(info.isAppearOffline) and info.isAppearOffline ~= true then
                        remember(name, info.playerGuid, true)
                    end
                end
            end
        end
    end
end

function iWR:GetSharingSuggestions()
    self:RefreshSharingRoster()
    local values, seen = {}, {}
    local function add(name)
        local id = key(name)
        if id and not seen[id] and not self:GetWhitelistEntry(name) then
            seen[id] = true
            values[#values + 1] = { value = name, label = name }
        end
    end
    for _, entry in pairs(known) do if now() - entry.at < 300 then add(entry.name) end end
    for _, entry in ipairs(iWRMemory.GroupLog or {}) do add(entry.name) end
    for _, entry in pairs(iWRDatabase) do add(StripColorCodes(entry[4] or "")) end
    table.sort(values, function(a, b) return a.value < b.value end)
    return values
end

function iWR:GetSharingPresence(name)
    local entry = known[key(name)]
    if entry and now() - entry.at <= PRESENCE_TTL then
        return entry.online and "Online" or "Offline"
    end
    return "Unknown"
end

function iWR:ResetSharingPresence()
    known, checks, whoQueue, whoActive, rosterAt, nextWhoAt = {}, {}, {}, nil, -100, 0
    self.sharingWhoScheduled = nil
end

function iWR:CheckSharingPresence(contact, allowWho, callback)
    local scope = self:GetSharingScope()
    if not scope or not self:GetWhitelistEntry(contact.name) then return callback(false) end
    self:RefreshSharingRoster()
    local observation = known[key(contact.name)]
    local playerGuid = guid(contact.guid) or (observation and observation.guid)
    if playerGuid and C_ChatInfo and C_ChatInfo.RequestCanLocalWhisperTarget then
        local check = checks[playerGuid]
        if check then
            if #check.callbacks < 8 then check.callbacks[#check.callbacks + 1] = callback else callback(false) end
            return
        end
        check = { name = contact.name, callbacks = { callback }, scope = scope }
        checks[playerGuid] = check
        safe(C_ChatInfo.RequestCanLocalWhisperTarget, playerGuid)
        C_Timer.After(5, function()
            if checks[playerGuid] ~= check then return end
            checks[playerGuid] = nil
            for _, listener in ipairs(check.callbacks) do listener(false) end
        end)
        return
    end
    if observation and now() - observation.at <= PRESENCE_TTL then return callback(observation.online == true) end
    if allowWho then
        for _, request in ipairs(whoQueue) do if key(request.name) == key(contact.name) then return callback(false) end end
        if whoActive and key(whoActive.name) == key(contact.name) then return callback(false) end
        whoQueue[#whoQueue + 1] = { name = contact.name, scope = scope, callback = callback }
        self:PumpSharingWho()
    else
        callback(false)
    end
end

function iWR:PumpSharingWho()
    if whoActive or #whoQueue == 0 then return end
    if now() < nextWhoAt then
        if self.sharingWhoScheduled then return end
        self.sharingWhoScheduled = true
        C_Timer.After(nextWhoAt - now(), function() self.sharingWhoScheduled = nil; self:PumpSharingWho() end)
        return
    end
    local request = table.remove(whoQueue, 1)
    -- Respect an open Who window and combat; never change Blizzard's Who routing.
    if not self:GetSharingScope() or request.scope ~= self:GetSharingScope()
        or safe(InCombatLockdown) ~= false or (WhoFrame and WhoFrame:IsShown()) or not C_FriendList then
        request.callback(false); self:PumpSharingWho(); return
    end
    whoActive, nextWhoAt = request, now() + 10
    self:DebugMsg("Checking whitelist availability: " .. request.name .. ".", 3)
    safe(C_FriendList.SendWho, 'n-"' .. request.name:gsub('"', '') .. '"')
    C_Timer.After(8, function()
        if whoActive ~= request then return end
        whoActive = nil
        request.callback(false)
        self:PumpSharingWho()
    end)
end

function iWR:OnSharingPresenceEvent(event, ...)
    if event == "CAN_LOCAL_WHISPER_TARGET_RESPONSE" then
        local playerGuid, status = ...
        if not guid(playerGuid) or self:IsSharingSecret(status) then return end
        local check = checks[playerGuid]
        if not check then return end
        checks[playerGuid] = nil
        local statuses = Enum and Enum.ChatWhisperTargetStatus or {}
        local allowed = status == (statuses.CanWhisper or 0) or status == (statuses.CanWhisperGuild or 1)
        allowed = allowed and check.scope == self:GetSharingScope() and self:GetWhitelistEntry(check.name) ~= nil
        if status == (statuses.Offline or 2) then remember(check.name, playerGuid, false)
        elseif allowed then remember(check.name, playerGuid, true) end
        for _, callback in ipairs(check.callbacks) do callback(allowed) end
        changed()
    elseif event == "WHO_LIST_UPDATE" and whoActive then
        local request = whoActive
        whoActive = nil
        local count = safe(C_FriendList.GetNumWhoResults) or 0
        local online = false
        if type(count) ~= "number" then count = 0 end
        for index = 1, math.min(50, count) do
            local info = safe(C_FriendList.GetWhoInfo, index)
            if type(info) == "table" and key(info.fullName) == key(request.name) then online = true end
        end
        if request.scope == self:GetSharingScope() then
            -- An empty or unrelated Who result is not proof that someone is offline.
            if online then remember(request.name, nil, true) end
            request.callback(online)
        end
        changed()
        self:PumpSharingWho()
    end
end

function iWR:ObserveSharingChat(name, playerGuid)
    if self:GetWhitelistEntry(name) and guid(playerGuid) then remember(name, playerGuid, true) end
end

local function escapePattern(value)
    return (value:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- A short Who query may be returned as a localized system line instead of
-- WHO_LIST_UPDATE. Read its name argument without redirecting the Who UI.
function iWR:OnSharingWhoMessage(message)
    if not whoActive or self:IsSharingSecret(message) or type(message) ~= "string" then return end
    for _, globalName in ipairs({ "WHO_LIST_FORMAT", "WHO_LIST_GUILD_FORMAT" }) do
        local format = _G[globalName]
        if type(format) == "string" then
            local pattern, position, argument, found = "^", 1, 0, false
            while true do
                local first, last, explicit, kind = format:find("%%(%d*)%$?([sd])", position)
                if not first then pattern = pattern .. escapePattern(format:sub(position)) .. "$"; break end
                argument = argument + 1
                local index = tonumber(explicit) or argument
                pattern = pattern .. escapePattern(format:sub(position, first - 1))
                if kind == "s" and index == 1 then pattern, found = pattern .. "(.-)", true
                elseif kind == "d" then pattern = pattern .. "%d+"
                else pattern = pattern .. ".-" end
                position = last + 1
            end
            local name = found and message:match(pattern)
            if name then
                name = name:match("|Hplayer:([^:|]+)") or StripColorCodes(name):match("^%[(.-)%]$") or StripColorCodes(name)
                if key(name) == key(whoActive.name) then
                    local request = whoActive
                    whoActive = nil
                    if request.scope == self:GetSharingScope() then
                        remember(request.name, nil, true)
                        request.callback(true)
                    end
                    changed()
                    self:PumpSharingWho()
                    return
                end
            end
        end
    end
end
