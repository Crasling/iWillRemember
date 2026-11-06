-- Whitelist sharing. Notes use a private, ruleset-specific session, never the
-- old friend prefixes. Every transfer has its own buffer and integrity check.
local PREFIX, WIRE = "iWRShareV1", "1"
local CHUNK, MAX_PARTS, MAX_TRANSFERS = 120, 4096, 8
-- Chat delivery can be delayed by minutes on a busy server. Keep request
-- tokens long enough to accept late replies, with bounded transfer retries.
local REPLY_TIMEOUT, TRANSFER_IDLE = 900, 900
local peers, controls, outgoing, incoming, completed = {}, {}, {}, {}, {}
local session, sequence, roundRobin = "", 0, 0
local worker = CreateFrame("Frame")
local elapsed = 0
worker:Hide()
local function now() return GetTime() end
local function key(name)
    if iWR:IsSharingSecret(name) or type(name) ~= "string" then return nil end
    local id = iWR:GetPlayerDatabaseKey(name)
    return id and id:lower()
end
local function token()
    sequence = sequence + 1
    return string.format("%x%x%x", time(), math.floor(now() * 1000) % 65536, sequence)
end
local function validToken(value)
    return type(value) == "string" and #value <= 40 and value:match("^%x+$") ~= nil
end
local function checksum(value)
    local hash = 5381
    for index = 1, #value do hash = (hash * 33 + value:byte(index)) % 2147483647 end
    return string.format("%x", hash)
end
local function enabled() return iWRSettings.DataSharing ~= false and iWR:GetSharingScope() ~= nil end
local function permitted(name) return enabled() and iWR:GetWhitelistEntry(name) ~= nil end
local function notify() if iWR.RefreshSharingPanel then iWR:RefreshSharingPanel() end end
local function checkVersion(version)
    if type(version) ~= "string" or not version:match("^%d+%.%d+%.%d+$")
        or not iWR.Version:match("^%d+%.%d+%.%d+$") then return end
    local function number(value)
        local a, b, c = value:match("^(%d+)%.(%d+)%.(%d+)$")
        return tonumber(a) * 1000000 + tonumber(b) * 1000 + tonumber(c)
    end
    if number(version) > number(iWR.Version) and not iWR.State.VersionMessaged then
        iWR:PrintToChat(iWR.L["NewVersionAvailable"])
        iWR.State.VersionMessaged = true
    end
end
local function peerFor(name)
    local id = key(name)
    if not id then return nil end
    peers[id] = peers[id] or { name = name, notes = {}, removes = {}, checkedAt = -100 }
    return peers[id]
end
local function sendRaw(name, message)
    if not permitted(name) or #message > 255 then return false end
    if C_ChatInfo.InChatMessagingLockdown and iWR:SharingCall(C_ChatInfo.InChatMessagingLockdown) ~= false then return false end
    local result = iWR:SharingCall(C_ChatInfo.SendAddonMessage, PREFIX, message, "WHISPER", name)
    local success = Enum and Enum.SendAddonMessageResult and Enum.SendAddonMessageResult.Success
    return result ~= nil and (result == true or result == (success or 0))
end
local function control(name, kind, nonce)
    if #controls >= 256 then return false end
    local peer = peers[key(name)]
    if peer and (peer.retryAt or 0) > now() then return false end
    local scope = iWR:GetSharingScope()
    if not scope then return false end
    controls[#controls + 1] = { name = name, kind = kind, scope = scope, created = now(), attempts = 0,
        message = table.concat({ WIRE, kind, scope, session, nonce, iWR.Version }, "\t") }
    worker:Show()
    return true
end
local function queueHello(peer)
    if not peer.nonce then
        peer.nonce = token()
        local nonce, currentSession = peer.nonce, session
        C_Timer.After(REPLY_TIMEOUT, function()
            if session == currentSession and peer.nonce == nonce then
                peer.nonce, peer.status, peer.retryAt = nil, "No iWR response", now() + 300
                iWR:DebugMsg("No matching iWR response from " .. peer.name .. "; sharing paused for five minutes.", 2)
                notify()
            end
        end)
    end
    peer.status = "Waiting for iWR"
    return control(peer.name, "HELLO", peer.nonce)
end
local function finite(value) return not iWR:IsSharingSecret(value) and type(value) == "number" and value == value and value >= 0 and value < math.huge end
local function plain(value, maximum) return not iWR:IsSharingSecret(value) and type(value) == "string" and #value <= maximum end
local function validEntry(entry)
    if iWR:IsSharingSecret(entry) or type(entry) ~= "table" or not plain(entry[1], 1024) or not finite(entry[3])
        or iWR:IsSharingSecret(entry[2]) or type(entry[2]) ~= "number" or entry[2] ~= entry[2] or entry[2] < -10 or entry[2] > 10
        or entry[3] > iWR:GetCurrentTimeByHours() + 24 or not plain(entry[4], 300)
        or not plain(entry[5], 80) or not plain(entry[6], 160) or not plain(entry[7], 160)
        or (entry[8] ~= nil and not plain(entry[8], 40))
        or iWR:IsSharingSecret(entry[9]) or (entry[9] ~= nil and entry[9] ~= false) then return false end
    for field in pairs(entry) do
        if iWR:IsSharingSecret(field) or type(field) ~= "number" or field < 1 or field > 11 or field ~= math.floor(field) then return false end
    end
    if iWR:IsForeverClient() and entry[7] ~= "Forever" then return false end
    if entry[10] ~= nil then
        if iWR:IsSharingSecret(entry[10]) or type(entry[10]) ~= "table" or #entry[10] > 10 then return false end
        for _, note in ipairs(entry[10]) do
            if iWR:IsSharingSecret(note) or type(note) ~= "table" or not plain(note[1], 1024)
                or iWR:IsSharingSecret(note[2]) or type(note[2]) ~= "number"
                or note[2] ~= note[2] or note[2] < -10 or note[2] > 10 or not finite(note[3])
                or note[3] > iWR:GetCurrentTimeByHours() + 24
                or not plain(note[4], 80) or not plain(note[5], 160)
                or iWR:IsSharingSecret(note[6]) or (note[6] ~= nil and note[6] ~= false) then return false end
        end
    end
    if entry[11] ~= nil then
        if iWR:IsSharingSecret(entry[11]) or type(entry[11]) ~= "table" then return false end
        local count = 0
        for stamp, deleted in pairs(entry[11]) do
            count = count + 1
            if count > 1000 or not finite(stamp) or iWR:IsSharingSecret(deleted) or deleted ~= true then return false end
        end
    end
    return true
end
local function shareable(entry)
    if iWR:IsSharingSecret(entry) or type(entry) ~= "table" or iWR:IsSharingSecret(entry[9]) then return nil end
    local ok, result = pcall(iWR.CreateShareableEntry, iWR, entry)
    if ok and validEntry(result) then return result end
end
local function refreshNotes()
    iWR:SaveRulesetStorage()
    iWR:UpdateTargetFrame()
    iWR:PopulateDatabase()
    iWR:UpdateTooltip()
end
local function keepEntryPersonal(id, entry)
    entry[9] = true
    for _, history in ipairs(entry[10] or {}) do history[6] = true end
    -- Pending snapshots may predate the privacy choice. Rebuild affected
    -- transfers from the database instead of sending those older copies.
    for _, peer in pairs(peers) do
        peer.notes[id], peer.removes[id] = nil, nil
    end
    for index = #outgoing, 1, -1 do
        local job = outgoing[index]
        if job.noteKeys and job.noteKeys[id] or job.kind == "REMOVE" and job.removeName == id then
            local peer = peers[key(job.name)]
            if peer and job.kind == "NOTES" then peer.full = true end
            table.remove(outgoing, index)
        end
    end
    refreshNotes()
    iWR:DebugMsg("Kept " .. StripColorCodes(entry[4]) .. " as personal after a shared removal.", 3)
end
local function mergePayload(payload, sender)
    local ok, success, data = pcall(iWR.Deserialize, iWR, payload)
    if not ok or not success or type(data) ~= "table" then return false end
    if data.kind == "REMOVE" then
        if not plain(data.name, 200) then return false end
        local id = iWR:NormalizePlayerDatabaseKey(data.name)
        local entry = id and iWRDatabase[id]
        if entry and not entry[9] then
            for _, request in ipairs(iWR.Queues.RemoveRequests) do
                if request.NoteName == id and key(request.Sender) == key(sender) then return true end
            end
            if #iWR.Queues.RemoveRequests < 100 then
                iWR.Queues.RemoveRequests[#iWR.Queues.RemoveRequests + 1] = {
                    NoteName = id, Sender = sender, scope = iWR:GetSharingScope(),
                }
                iWR:ProcessRemoveRequestQueue()
            end
        end
        return true
    end
    if data.kind ~= "NOTES" or type(data.entries) ~= "table" then return false end
    local count, normalized = 0, {}
    -- Validate the entire transfer before changing any local notes.
    for id, entry in pairs(data.entries) do
        count = count + 1
        if count > 10000 or not plain(id, 200) or not validEntry(entry) then return false end
        local resolved = iWR:NormalizePlayerDatabaseKey(id, entry)
        if not resolved then return false end
        normalized[resolved] = entry
    end
    for id, entry in pairs(normalized) do
        local existing = iWRDatabase[id]
        if existing and existing[9] then
            -- Personal notes never enter a shared merge.
        elseif iWR:IsEntryFullyTombstoned(id, entry) then iWR:SendRemoveRequestToPlayer(id, sender)
        else
            entry = iWR:ApplyGlobalTombstones(id, entry)
            if entry then
                if not existing then iWRDatabase[id] = entry
                elseif iWR:IsNeedToUpdate(existing[3], entry[3]) then
                    iWR:MergeNoteHistory(existing, entry)
                    iWRDatabase[id] = entry
                else iWR:MergeNoteHistory(entry, existing) end
            end
        end
    end
    refreshNotes()
    iWR:DebugMsg("Received " .. count .. " shared player notes from " .. sender .. ".", 3)
    return true
end
local flushPeer
local function buildJob(peer, data)
    local ok, payload = pcall(iWR.Serialize, iWR, data)
    if not ok or type(payload) ~= "string" or #payload > CHUNK * MAX_PARTS then
        iWR:DebugMsg("Sharing transfer is too large or could not be serialized for " .. peer.name .. ".", 2)
        return false
    end
    local noteKeys
    if data.kind == "NOTES" then
        noteKeys = {}
        for id in pairs(data.entries) do noteKeys[id] = true end
    end
    outgoing[#outgoing + 1] = { name = peer.name, scope = iWR:GetSharingScope(), remote = peer.remote,
        id = token(), payload = payload, hash = checksum(payload), total = math.ceil(#payload / CHUNK),
        kind = data.kind, removeName = data.name, noteKeys = noteKeys,
        index = 1, created = now(), lastProgress = now(), checkedAt = now(), attempts = 0 }
    worker:Show()
    iWR:DebugMsg("Queued sharing transfer to " .. peer.name .. " (" .. #payload .. " bytes).", 3)
    return true
end
flushPeer = function(peer)
    if not permitted(peer.name) or not peer.remote or (peer.readyUntil or 0) <= now() or #outgoing >= MAX_TRANSFERS then return end
    for _, job in ipairs(outgoing) do if key(job.name) == key(peer.name) then return end end
    if peer.full then
        local entries, current = {}, iWR:GetCurrentTimeByHours()
        for id, entry in pairs(iWRDatabase) do
            if type(entry) == "table" and finite(entry[3]) and current - entry[3] <= 2400 then
                local shared = shareable(entry)
                if shared then entries[id] = shared end
            end
        end
        if buildJob(peer, { kind = "NOTES", entries = entries }) then peer.full, peer.notes = nil, {} end
    elseif next(peer.notes) then
        if buildJob(peer, { kind = "NOTES", entries = peer.notes }) then peer.notes = {} end
    elseif next(peer.removes) then
        local id = next(peer.removes)
        if buildJob(peer, { kind = "REMOVE", name = id }) then peer.removes[id] = nil end
    end
end

function iWR:ConnectSharingPeer(contact, allowWho, debugAction)
    if not enabled() or not contact then return end
    local function report(message)
        if debugAction then self:DebugMsg(debugAction .. ": " .. contact.name .. "; " .. message, 3) end
    end
    local peer = peerFor(contact.name)
    if (peer.readyUntil or 0) > now() then
        report("using the confirmed iWR session.")
        flushPeer(peer)
        if not allowWho then return end
    end
    if peer.nonce and not allowWho then return end
    if peer.checking then report("an availability check is already pending."); return end
    if (peer.retryAt or 0) > now() then
        report("checks are paused for " .. math.ceil(peer.retryAt - now()) .. " seconds (" .. (peer.status or "cooldown") .. ").")
        return
    end
    if now() - peer.checkedAt < 30 and (not allowWho or peer.allowWho) then
        report("availability was checked recently; recheck in " .. math.ceil(30 - (now() - peer.checkedAt)) .. " seconds.")
        return
    end
    local scope, currentSession = self:GetSharingScope(), session
    peer.checking, peer.checkedAt, peer.allowWho = true, now(), allowWho == true
    report("checking online availability.")
    self:CheckSharingPresence(contact, allowWho, function(online)
        if session ~= currentSession or scope ~= self:GetSharingScope() or not permitted(contact.name) then
            report("check cancelled because the session, ruleset, or whitelist changed.")
            return
        end
        peer.checking = nil
        if not online then
            peer.status = self:GetSharingPresence(contact.name)
            report("no handshake sent; availability is " .. peer.status .. ".")
            notify()
            return
        end
        if queueHello(peer) then report("online confirmed; iWR handshake queued, waiting for a response.")
        else report("online confirmed, but the iWR handshake could not be queued.") end
        notify()
    end)
end
local function manualAction(action)
    iWR:DebugMsg(action .. " clicked.", 3)
    if iWRSettings.DataSharing == false then
        iWR:DebugMsg(action .. ": sharing is disabled; no requests started.", 3)
        return nil
    end
    if not iWR:GetSharingScope() then
        iWR:DebugMsg(action .. ": waiting for the server ruleset; no requests started.", 3)
        return nil
    end
    local contacts = iWRSettings.SyncList or {}
    if #contacts == 0 then
        iWR:DebugMsg(action .. ": the whitelist is empty; no requests started.", 3)
        return nil
    end
    iWR:DebugMsg(action .. ": " .. #contacts .. " whitelisted player(s), ruleset " .. iWR:GetSharingRulesetLabel() .. ".", 3)
    return contacts
end
function iWR:RefreshSharingStatus()
    local contacts = manualAction("Refresh status")
    if not contacts then return end
    for _, contact in ipairs(contacts) do self:ConnectSharingPeer(contact, true, "Refresh status") end
end
function iWR:SendFullDBUpdateToWhitelist()
    if not enabled() then return end
    for _, contact in ipairs(iWRSettings.SyncList or {}) do
        peerFor(contact.name).full = true
        self:ConnectSharingPeer(contact, false)
    end
end
function iWR:ShareWithWhitelist()
    local contacts = manualAction("Share now")
    if not contacts then return end
    for _, contact in ipairs(contacts) do
        peerFor(contact.name).full = true
        self:ConnectSharingPeer(contact, true, "Share now")
    end
end
function iWR:SendNewDBUpdateToWhitelist()
    if not enabled() then return end
    local ok, success, data = pcall(self.Deserialize, self, self.Cache.Data)
    if not ok or not success or type(data) ~= "table" then return end
    for _, contact in ipairs(iWRSettings.SyncList or {}) do
        local peer = peerFor(contact.name)
        for id, entry in pairs(data) do
            local shared = shareable(entry)
            if shared then peer.notes[id] = CopyTable(shared) end
        end
        self:ConnectSharingPeer(contact, false)
    end
end
function iWR:SendRemoveRequestToPlayer(id, name)
    if not permitted(name) then return end
    peerFor(name).removes[id] = true
    self:ConnectSharingPeer(self:GetWhitelistEntry(name), false)
end
function iWR:SendRemoveRequestToWhitelist(id)
    self:UpdateTargetFrame()
    if not enabled() then return end
    for _, contact in ipairs(iWRSettings.SyncList or {}) do self:SendRemoveRequestToPlayer(id, contact.name) end
end
function iWR:GetSharingPeerStatus(name)
    if not self:GetSharingScope() then return "Waiting for server ruleset" end
    local peer = peers[key(name)]
    if peer then
        if peer.checking then return "Checking" end
        if peer.nonce then return "Waiting for iWR" end
        if (peer.readyUntil or 0) > now() then return "iWR ready" end
        if peer.status and peer.status ~= "iWR ready" and peer.checkedAt + 300 > now() then return peer.status end
    end
    return self:GetSharingPresence(name)
end
function iWR:ForgetSharingPeer(name)
    local id = key(name)
    if not id then return end
    if id then peers[id] = nil end
    for index = #outgoing, 1, -1 do if key(outgoing[index].name) == id then table.remove(outgoing, index) end end
    for index = #controls, 1, -1 do if key(controls[index].name) == id then table.remove(controls, index) end end
    incoming[id], completed[id] = nil, nil
end
function iWR:ResetSharingSession()
    peers, controls, outgoing, incoming, completed = {}, {}, {}, {}, {}
    session = token()
    self.Queues.RemoveRequests, self.State.PopupActive = {}, false
    if StaticPopup_Hide then StaticPopup_Hide("IWR_SHARED_REMOVE") end
    self:ResetSharingPresence()
    worker:Hide()
end
local function adoptSession(peer, remote)
    if peer.remote == remote then return end
    peer.retired = peer.retired or {}
    if peer.remote then peer.retired[peer.remote] = now() end
    local count, oldest, oldestAt = 0, nil, math.huge
    for old, at in pairs(peer.retired) do
        if now() - at > 3600 then peer.retired[old] = nil
        else
            count = count + 1
            if at < oldestAt then oldest, oldestAt = old, at end
        end
    end
    if count > 8 then peer.retired[oldest] = nil end
    incoming[key(peer.name)] = nil
    for index = #outgoing, 1, -1 do
        local job = outgoing[index]
        if key(job.name) == key(peer.name) then
            if job.kind == "REMOVE" then peer.removes[job.removeName] = true else peer.full = true end
            table.remove(outgoing, index)
        end
    end
    peer.remote = remote
end
function iWR:OnSharePacket(prefix, message, distribution, sender)
    if prefix ~= PREFIX or distribution ~= "WHISPER" or self:IsSharingSecret(message)
        or self:IsSharingSecret(sender) or not plain(message, 255) or not permitted(sender)
        or key(sender) == key(self:SharingCall(self.GetUnitPlayerIdentity, self, "player")) then return end
    local parts, rest = {}, message
    for index = 1, 9 do
        local at = rest:find("\t", 1, true)
        if not at then parts[index] = rest; rest = nil; break end
        parts[index], rest = rest:sub(1, at - 1), rest:sub(at + 1)
    end
    if rest then parts[10] = rest end
    if parts[1] ~= WIRE or not validToken(parts[4]) then return end
    local peer = peerFor(sender)
    if parts[3] ~= self:GetSharingScope() then
        if peer.reportedScope ~= parts[3] then
            peer.status, peer.checkedAt, peer.reportedScope = "Different ruleset", now(), parts[3]
            iWR:DebugMsg("Ignored sharing from " .. sender .. ": the server ruleset does not match.", 3)
            notify()
        end
        return
    end
    if parts[2] == "HELLO" then
        if not validToken(parts[5]) or (peer.retired and peer.retired[parts[4]])
            or (peer.remote == parts[4] and now() - (peer.lastHello or -100) < 5) then return end
        adoptSession(peer, parts[4])
        peer.lastHello, peer.remote, peer.readyUntil = now(), parts[4], now() + 120
        peer.status, peer.version, peer.nonce = "iWR ready", parts[6], nil
        local contact = self:GetWhitelistEntry(sender)
        contact.lastSeen, contact.ruleset = time(), parts[3]
        checkVersion(parts[6])
        control(sender, "READY", parts[5])
        flushPeer(peer)
        notify()
        return
    elseif parts[2] == "READY" then
        if not peer.nonce or parts[5] ~= peer.nonce then return end
        if peer.retired and peer.retired[parts[4]] then return end
        adoptSession(peer, parts[4])
        peer.remote, peer.readyUntil, peer.status, peer.version, peer.nonce = parts[4], now() + 120, "iWR ready", parts[6], nil
        local contact = self:GetWhitelistEntry(sender)
        contact.lastSeen, contact.ruleset = time(), parts[3]
        checkVersion(parts[6])
        self:DebugMsg("Sharing confirmed with " .. sender .. " on " .. self:GetSharingRulesetLabel() .. ".", 3)
        flushPeer(peer)
        notify()
        return
    elseif parts[2] == "ACK" then
        if peer.remote ~= parts[4] or not validToken(parts[5]) then return end
        for index = #outgoing, 1, -1 do
            local job = outgoing[index]
            if key(job.name) == key(sender) and job.remote == parts[4] and job.id == parts[5] then
                table.remove(outgoing, index)
                self:DebugMsg("Shared notes received by " .. sender .. ".", 3)
                peer.readyUntil = now() + 120
                flushPeer(peer)
                for _, waiting in pairs(peers) do
                    if #outgoing >= MAX_TRANSFERS then break end
                    if waiting.full or next(waiting.notes) or next(waiting.removes) then
                        iWR:ConnectSharingPeer(iWR:GetWhitelistEntry(waiting.name), false)
                    end
                end
                return
            end
        end
        return
    end
    if parts[2] ~= "DATA" or not validToken(parts[5]) or not validToken(parts[6]) then return end
    if parts[5] ~= session then
        if now() - (peer.lastReset or -100) >= 30 then
            peer.lastReset = now()
            queueHello(peer)
        end
        return
    end
    if peer.remote ~= parts[4] then return end
    local index, total = tonumber(parts[7]), tonumber(parts[8])
    if not index or not total or index ~= math.floor(index) or total ~= math.floor(total)
        or index < 1 or index > total or total > MAX_PARTS or not plain(parts[9], 8)
        or not parts[9]:match("^%x+$") or not plain(parts[10], CHUNK) then return end
    local id, transfer = key(sender), incoming[key(sender)]
    local recent = completed[id] and completed[id][parts[6]]
    if recent and now() - recent.at < 3600 then
        if now() - recent.ackAt >= 10 then recent.ackAt = now(); control(sender, "ACK", parts[6]) end
        return
    end
    if transfer and (now() - transfer.lastAt > TRANSFER_IDLE or now() - transfer.startedAt > 3600) then incoming[id], transfer = nil, nil end
    if not transfer then
        local count = 0
        for entryId, entry in pairs(incoming) do
            if now() - entry.lastAt > TRANSFER_IDLE then incoming[entryId] = nil else count = count + 1 end
        end
        if count >= MAX_TRANSFERS then return end
        transfer = { id = parts[6], total = total, hash = parts[9], chunks = {}, count = 0, startedAt = now() }
        incoming[id] = transfer
    end
    if transfer.id ~= parts[6] or transfer.total ~= total or transfer.hash ~= parts[9] then return end
    if transfer.chunks[index] and transfer.chunks[index] ~= parts[10] then incoming[id] = nil; return end
    if not transfer.chunks[index] then transfer.chunks[index], transfer.count = parts[10], transfer.count + 1 end
    transfer.lastAt, peer.readyUntil = now(), now() + 120
    if transfer.count == total then
        incoming[id] = nil
        local payload = table.concat(transfer.chunks)
        if checksum(payload) == transfer.hash and mergePayload(payload, sender) then
            completed[id] = completed[id] or {}
            local count, oldestId, oldestAt = 0, nil, math.huge
            for savedId, receipt in pairs(completed[id]) do
                if now() - receipt.at >= 3600 then completed[id][savedId] = nil
                else
                    count = count + 1
                    if receipt.at < oldestAt then oldestId, oldestAt = savedId, receipt.at end
                end
            end
            if count >= 32 then completed[id][oldestId] = nil end
            completed[id][transfer.id] = { at = now(), ackAt = now() }
            control(sender, "ACK", transfer.id)
        else self:DebugMsg("Rejected an invalid sharing transfer from " .. sender .. ".", 2) end
    end
end

worker:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < 0.1 then return end
    elapsed = 0
    if not enabled() then controls, outgoing = {}, {}; worker:Hide(); return end
    for index = #controls, 1, -1 do
        if now() - controls[index].created > 30 then
            iWR:DebugMsg("Sharing " .. controls[index].kind .. " to " .. controls[index].name .. " expired in the send queue.", 2)
            table.remove(controls, index)
        end
    end
    for index = #outgoing, 1, -1 do
        if now() - outgoing[index].created > 3600 then table.remove(outgoing, index) end
    end
    if #controls == 0 and #outgoing == 0 then
        for _, peer in pairs(peers) do flushPeer(peer) end
        if #outgoing == 0 then worker:Hide(); return end
    end
    if C_ChatInfo.InChatMessagingLockdown and iWR:SharingCall(C_ChatInfo.InChatMessagingLockdown) ~= false then return end
    if #controls > 0 then
        local item = controls[1]
        item.attempts = item.attempts + 1
        local allowed = item.scope == iWR:GetSharingScope() and now() - item.created <= 30 and permitted(item.name)
        local sent = allowed and sendRaw(item.name, item.message)
        if sent then iWR:DebugMsg("Sharing " .. item.kind .. " sent to " .. item.name .. ".", 3)
        elseif allowed and item.attempts >= 3 then
            iWR:DebugMsg("Sharing " .. item.kind .. " to " .. item.name .. " could not be sent after three attempts.", 2)
        end
        if not allowed or sent or item.attempts >= 3 then table.remove(controls, 1) end
        return
    end
    roundRobin = roundRobin % #outgoing + 1
    local job = outgoing[roundRobin]
    local peer = peers[key(job.name)]
    if job.cancelled or not permitted(job.name) or job.scope ~= iWR:GetSharingScope() or not peer or peer.remote ~= job.remote
        or (not job.waitingAck and now() - job.lastProgress > 120) or now() - job.created > 3600 then
        table.remove(outgoing, roundRobin); return
    end
    if job.waitingAck then
        if now() - job.waitingAck < REPLY_TIMEOUT then return end
        job.retries = (job.retries or 0) + 1
        if job.retries > 2 then
            table.remove(outgoing, roundRobin)
            peer.status, peer.readyUntil, peer.retryAt = "Transfer incomplete", nil, now() + 300
            iWR:DebugMsg("Sharing transfer to " .. job.name .. " was not confirmed after two retries.", 2)
            notify()
            return
        end
        job.index, job.waitingAck, job.lastProgress = 1, nil, now()
    end
    if now() - job.checkedAt >= 20 then
        if not job.checking then
            job.checking = true
            iWR:CheckSharingPresence(iWR:GetWhitelistEntry(job.name), true, function(online)
                job.checking, job.checkedAt, job.lastProgress = nil, now(), now()
                if not online then
                    job.cancelled, peer.full = true, true
                    peer.readyUntil, peer.status = nil, iWR:GetSharingPresence(job.name)
                    notify()
                end
            end)
        end
        return
    end
    local chunk = job.payload:sub((job.index - 1) * CHUNK + 1, job.index * CHUNK)
    local message = table.concat({ WIRE, "DATA", job.scope, session, job.remote, job.id,
        job.index, job.total, job.hash, chunk }, "\t")
    if sendRaw(job.name, message) then
        job.index, job.lastProgress, job.attempts = job.index + 1, now(), 0
        if job.index > job.total then
            job.waitingAck = now()
        end
    else
        job.attempts = job.attempts + 1
        if job.attempts >= 3 then
            table.remove(outgoing, roundRobin)
            peer.status, peer.readyUntil, peer.retryAt = "Send failed", nil, now() + 300
            iWR:DebugMsg("Sharing paused after a failed send to " .. job.name .. ".", 2)
            notify()
        end
    end
end)

function iWR:ProcessRemoveRequestQueue()
    if self.State.PopupActive or self:SharingCall(InCombatLockdown) then return end
    local request = table.remove(self.Queues.RemoveRequests, 1)
    if not request then return end
    local entry = iWRDatabase[request.NoteName]
    if request.scope ~= self:GetSharingScope() or not permitted(request.Sender) or not entry or entry[9] then
        return self:ProcessRemoveRequestQueue()
    end
    local function canApply()
        return request.scope == self:GetSharingScope() and permitted(request.Sender)
            and iWRDatabase[request.NoteName] == entry and not entry[9]
    end
    self.State.PopupActive = true
    StaticPopupDialogs["IWR_SHARED_REMOVE"] = {
        text = request.Sender .. " removed their note for " .. StripColorCodes(entry[4]) .. ". Remove your shared entry too?",
        button1 = self.L["Yes"], button2 = self.L["No"], button3 = self.L["KeepAsPersonal"],
        selectCallbackByIndex = true, timeout = 0, whileDead = true, hideOnEscape = true,
        OnAccept = function()
            if canApply() then
                self:TombstoneEntireEntry(request.NoteName, entry)
                iWRDatabase[request.NoteName] = nil
                refreshNotes()
            end
        end,
        OnCancel = function() end,
        OnButton3 = function()
            if canApply() then keepEntryPersonal(request.NoteName, entry) end
        end,
        OnHide = function() self.State.PopupActive = false; self:ProcessRemoveRequestQueue() end,
    }
    StaticPopup_Show("IWR_SHARED_REMOVE")
end
function iWR:InitializeSharing()
    self:RegisterComm(PREFIX, "OnSharePacket")
    self:ResetSharingSession()
    if not self.sharingTicker then self.sharingTicker = C_Timer.NewTicker(3600, function() self:SendFullDBUpdateToWhitelist() end) end
end

function iWR:OnSharingSystemMessage(message)
    self:OnSharingWhoMessage(message)
    if self:IsSharingSecret(message) or type(message) ~= "string" or not ERR_CHAT_PLAYER_NOT_FOUND_S then return end
    local pattern = ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.-)")
    local name = message:match("^" .. pattern .. "$")
    local peer = name and peers[key(name)]
    if not peer then return end
    peer.readyUntil, peer.nonce, peer.retryAt, peer.status, peer.checkedAt = nil, nil, now() + 300, "Offline", now()
    for index = #outgoing, 1, -1 do if key(outgoing[index].name) == key(name) then table.remove(outgoing, index) end end
    for index = #controls, 1, -1 do if key(controls[index].name) == key(name) then table.remove(controls, index) end end
    self:DebugMsg("Paused sharing to " .. name .. " after the server reported that player offline.", 2)
    notify()
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "CAN_LOCAL_WHISPER_TARGET_RESPONSE", "WHO_LIST_UPDATE", "PLAYER_LOGOUT",
    "PLAYER_REGEN_ENABLED", "PLAYER_ENTERING_WORLD", "GAME_RULES_CHANGED", "ACTIVE_GAME_MODE_UPDATED",
    "GROUP_ROSTER_UPDATE", "GUILD_ROSTER_UPDATE", "BN_FRIEND_INFO_CHANGED", "CHAT_MSG_SYSTEM",
    "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_RAID", "CHAT_MSG_SAY", "CHAT_MSG_CHANNEL", "CHAT_MSG_WHISPER" }) do
    local valid = not C_EventUtils or iWR:SharingCall(C_EventUtils.IsEventValid, event)
    if valid then pcall(events.RegisterEvent, events, event) end
end
events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGOUT" then iWR:SaveRulesetStorage(); return end
    if event == "CHAT_MSG_SYSTEM" then iWR:OnSharingSystemMessage(...); return end
    if event:find("^CHAT_MSG_") then
        iWR:ObserveSharingChat(select(2, ...), select(12, ...))
        return
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "GAME_RULES_CHANGED" or event == "ACTIVE_GAME_MODE_UPDATED" then
        local previous = iWR:GetSharingScope()
        if iWR:ActivateSharingRuleset() and previous ~= iWR:GetSharingScope() then
            iWR:InitializeSettings()
            iWR:InitializeDatabase()
            refreshNotes()
            notify()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        iWR:ActivateSharingRuleset()
        iWR:PumpSharingWho()
        iWR:ProcessRemoveRequestQueue()
    elseif event == "GROUP_ROSTER_UPDATE" or event == "GUILD_ROSTER_UPDATE" or event == "BN_FRIEND_INFO_CHANGED" then
        iWR:RefreshSharingRoster()
    else iWR:OnSharingPresenceEvent(event, ...) end
end)
