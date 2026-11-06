-- Independent clients exercise the real serializer, scope storage, peer
-- discovery, handshakes, and transfer queues without WoW or network access.
local function read(path)
    local file = assert(io.open(path, "rb")); local value = file:read("*a"); file:close()
    return value:gsub("\r\n", "\n")
end
local functions = read("iWillRemember_iWRFunctions.lua")
local clients, wire, clock = {}, {}, 100
local secret = {}
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}; for k, v in pairs(value) do result[copy(k)] = copy(v) end; return result
end
local function note(name, private)
    return { "helpful player", 6, 999999, name, "2026-11-06", "Note Author", "Forever", "Alliance", private }
end
local function client(name, options)
    options = options or {}
    local env, addon, state = {}, { L = { Yes = "Yes", No = "No", KeepAsPersonal = "Keep as personal" },
        Version = "0.24.1", GameTocVersion = 16001, CurrentRealm = "Forever" }, {}
    setmetatable(env, { __index = _G }); env._G = env
    env.iWR, env.unpack = addon, table.unpack
    env.strmatch = string.match
    env.wipe = function(value) for k in pairs(value) do value[k] = nil end; return value end
    env.iWRSettings = { DataSharing = true, SyncList = copy(options.whitelist or {}), DeletedEntries = {}, MyCharacters = {} }
    env.iWRDatabase, env.iWRDatabaseBackup, env.iWRMemory = copy(options.database or {}), {}, { GroupLog = {} }
    env.iWRRulesetStores = copy(options.stores)
    addon.Queues, addon.State, addon.Colors = { RemoveRequests = {} }, {}, { Reset = "|r" }
    addon.Cache = { Data = "" }
    addon.SettingsDefault = {}
    addon.CONSTANTS = { MAX_NOTES_PER_PLAYER = 10 }
    state.env, state.addon, state.name, state.guid = env, addon, name, "Player-1-" .. tostring(#clients + 1)
    state.hardcore, state.mode, state.record = options.hardcore == true, 0, 10
    state.pvp, state.rp = options.pvp == true, options.rp == true
    state.scopeSecret = options.scopeSecret
    state.roster, state.frames, state.timers, state.sent, state.logs, state.who = {}, {}, {}, {}, {}, {}
    env.WOW_PROJECT_ID = 18
    env.issecretvalue = function(value) return rawequal(value, secret) end
    env.GetTime = function() return clock end
    env.time = function() return 1800000000 + math.floor(clock) end
    env.GetCurrentRegion = function() return 3 end
    env.CopyTable, env.StripColorCodes = copy, function(value) return value:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") end
    env.C_GameRules = {
        GetActiveGameMode = function() return state.scopeSecret and secret or state.mode end,
        GetCurrentGameModeRecordID = function() return state.record end,
        IsHardcoreActive = function() return state.hardcore end,
        IsGameRuleActive = function(rule)
            if state.secretRule == rule then return secret end
            if rule == 1 then return state.hardcore end
            if rule == 2 then return state.pvp end
            if rule == 3 then return state.rp end
            error("unexpected server rule")
        end,
    }
    env.UnitGUID = function(unit) return unit == "player" and state.guid or nil end
    env.UnitName = function() return name end
    env.UnitIsPlayer = function() return false end
    env.IsInRaid, env.GetNumSubgroupMembers = function() return false end, function() return 0 end
    env.InCombatLockdown = function() return state.combat == true end
    env.GetNumGuildMembers = function() return #state.roster end
    env.GetGuildRosterInfo = function(index)
        local member = state.roster[index]
        return member.name, nil, nil, nil, nil, nil, nil, nil, member.online, nil, nil, nil, nil, nil, nil, nil, member.guid
    end
    env.Enum = { SendAddonMessageResult = { Success = 0 }, ChatWhisperTargetStatus = { CanWhisper = 0, Offline = 2 },
        GameRule = { HardcoreRuleset = 1, PvPRuleset = 2, RPRuleset = 3 } }
    env.C_EventUtils = { IsEventValid = function() return true end }
    env.C_ChatInfo = {
        InChatMessagingLockdown = function() return state.locked or false end,
        RequestCanLocalWhisperTarget = function(playerGuid)
            state.preflights = (state.preflights or 0) + 1
            if state.preflightTimeout then return end
            local status = 2
            for _, member in ipairs(state.roster) do if member.guid == playerGuid and member.online then status = 0 end end
            state:event("CAN_LOCAL_WHISPER_TARGET_RESPONSE", playerGuid, state.secretStatus and secret or status)
        end,
        SendAddonMessage = function(prefix, message, distribution, target)
            assert(#message <= 255 and distribution == "WHISPER", "all sharing packets fit one private addon packet")
            state.sent[#state.sent + 1] = { prefix = prefix, message = message, target = target }
            if state.sendError then return 7 end
            wire[#wire + 1] = { from = state, target = target, message = message, prefix = prefix }
            return 0
        end,
    }
    env.C_FriendList = {
        GetNumFriends = function() error("legacy friends must not be consulted") end,
        AddFriend = function() error("sharing must never add friends") end,
        SendWho = function(query) state.who[#state.who + 1] = query end,
        GetNumWhoResults = function() return #(state.whoResults or {}) end,
        GetWhoInfo = function(index) return state.whoResults[index] end,
    }
    env.ERR_CHAT_PLAYER_NOT_FOUND_S = "No player named '%s' is currently playing."
    env.StaticPopupDialogs = {}
    env.StaticPopup_Show = function(id) state.popup = env.StaticPopupDialogs[id] end
    env.StaticPopup_Hide = function() state.popup = nil end
    env.C_Timer = {
        After = function(delay, callback) state.timers[#state.timers + 1] = { at = clock + delay, callback = callback } end,
        NewTicker = function(_, callback) state.hourly = callback; return {} end,
    }
    env.CreateFrame = function()
        local frame = { shown = false, events = {} }
        function frame:Hide() self.shown = false end
        function frame:Show() self.shown = true end
        function frame:RegisterEvent(event) self.events[event] = true end
        function frame:SetScript(event, callback) self[event] = callback end
        state.frames[#state.frames + 1] = frame
        return frame
    end
    function state:event(event, ...)
        for _, frame in ipairs(self.frames) do if frame.events[event] and frame.OnEvent then frame:OnEvent(event, ...) end end
    end
    assert(loadfile("libs/LibStub/LibStub.lua", "t", env))()
    assert(loadfile("libs/AceSerializer-3.0/AceSerializer-3.0.lua", "t", env))()
    env.LibStub("AceSerializer-3.0"):Embed(addon)
    local start = assert(functions:find("local function UTF8FirstCharLen", 1, true))
    local stop = assert(functions:find("function iWR:VerifyRealm", start, true))
    assert(load("local L = iWR.L\n" .. functions:sub(start, stop - 1), "identity helpers", "t", env))()
    for _, method in ipairs({ "IsNeedToUpdate", "CreateShareableEntry", "MergeNoteHistory", "TombstoneEntireEntry",
        "IsEntryFullyTombstoned", "ApplyGlobalTombstones" }) do
        local body = assert(functions:match("(function iWR:" .. method .. "%b().-\nend)"), method)
        assert(load(body, method, "t", env))()
    end
    function addon:DebugMsg(message) state.logs[#state.logs + 1] = message end
    function addon:PrintToChat() end
    function addon:GetCurrentTimeByHours() return 1000000 end
    function addon:UpdateTargetFrame() end
    function addon:PopulateDatabase() end
    function addon:UpdateTooltip() end
    function addon:RegisterComm(prefix, method) state.prefix, state.method = prefix, method end
    for _, file in ipairs({ "iWillRemember_SharingScope.lua", "iWillRemember_SharingPeers.lua", "iWillRemember_Sharing.lua" }) do
        assert(loadfile(file, "t", env))()
    end
    assert(addon:ActivateSharingRuleset() == (not options.scopeSecret))
    addon:InitializeSharing()
    clients[#clients + 1] = state
    return state
end
local function link(a, b, online)
    a.roster[#a.roster + 1] = { name = b.name, guid = b.guid, online = online ~= false }
end
local function whitelist(a, b) assert(a.addon:AddSharingContact(b.name)) end
local drop
local function advance(seconds)
    local stop = clock + seconds
    while clock < stop do
        clock = math.min(stop, clock + 0.1)
        for _, state in ipairs(clients) do
            for index = #state.timers, 1, -1 do
                local timer = state.timers[index]
                if timer.at <= clock then table.remove(state.timers, index); timer.callback() end
            end
            for _, frame in ipairs(state.frames) do if frame.shown and frame.OnUpdate then frame:OnUpdate(0.1) end end
        end
        local packets = wire; wire = {}
        for _, packet in ipairs(packets) do
            if not drop or not drop(packet) then
                for _, target in ipairs(clients) do
                    if target.name == packet.target:gsub("-", " ") then
                        target.addon[target.method](target.addon, packet.prefix, packet.message, "WHISPER", packet.from.name:gsub(" ", "-"))
                    end
                end
            end
        end
    end
end

local a, b = client("Alice Paladin"), client("Bob Warrior")
link(a, b); link(b, a)
whitelist(a, b)
a.env.iWRDatabase["Helpful Healer-Forever"] = note("Helpful Healer")
a.addon:SendFullDBUpdateToWhitelist()
advance(4)
assert(not next(b.env.iWRDatabase) and #b.sent == 0, "one-sided whitelisting cannot receive or trigger a reply")
whitelist(b, a)
advance(31)
a.addon:ShareWithWhitelist()
advance(10)
assert(b.env.iWRDatabase["Helpful Healer-Forever"], "mutually whitelisted non-friends can share: "
    .. table.concat(a.logs, " / ") .. " | " .. table.concat(b.logs, " / ") .. " packets=" .. #a.sent .. "/" .. #b.sent)
assert(a.addon:GetSharingPeerStatus(b.name) == "iWR ready", "a matching handshake confirms iWR availability")
assert(a.env.iWRSettings.SyncList[1].lastSeen, "a real response records last seen")
local sent = #a.sent + #b.sent
advance(30)
assert(#a.sent + #b.sent == sent, "idle clients send no periodic whispers")

local private = note("Secret Person", true)
a.env.iWRDatabase["Secret Person-Forever"] = private
local public = note("Public Person")
public[10] = { { "private history", 1, 999998, "date", "author", true }, { "public history", 1, 999997, "date", "author", false } }
a.env.iWRDatabase["Public Person-Forever"] = public
a.addon:ShareWithWhitelist(); advance(10)
assert(not b.env.iWRDatabase["Secret Person-Forever"], "private entries do not travel")
assert(#b.env.iWRDatabase["Public Person-Forever"][10] == 1, "private history does not travel")

local c = client("Carol Mage")
link(c, b); link(b, c); whitelist(c, b); whitelist(b, c)
for index = 1, 20 do
    a.env.iWRDatabase["Alice Note" .. index .. "-Forever"] = note("Alice Note" .. index)
    c.env.iWRDatabase["Carol Note" .. index .. "-Forever"] = note("Carol Note" .. index)
end
a.addon:ShareWithWhitelist(); c.addon:ShareWithWhitelist(); advance(25)
assert(b.env.iWRDatabase["Alice Note20-Forever"] and b.env.iWRDatabase["Carol Note20-Forever"],
    "interleaved senders have independent receive buffers")

local dropped = false
drop = function(packet)
    if packet.from == c and packet.message:find("\tDATA\t", 1, true) and not dropped then dropped = true; return true end
end
c.env.iWRDatabase["Retry Person-Forever"] = note("Retry Person")
c.addon:ShareWithWhitelist(); advance(15)
assert(not b.env.iWRDatabase["Retry Person-Forever"], "an incomplete snapshot cannot partially merge")
advance(950)
assert(b.env.iWRDatabase["Retry Person-Forever"], "a lost fragment recovers through a bounded retransmission")
drop = nil

a.addon:RemoveSharingContact(b.name)
local before = #a.sent
b.addon:ShareWithWhitelist(); advance(10)
assert(#a.sent == before, "removing a contact cancels access immediately")

local oldScope = b.addon:GetSharingScope()
b.env.iWRSettings.DeletedEntries["Old Person-Forever"] = { timestamps = { [1] = true }, deletedAt = 1 }
b.addon:SaveRulesetStorage()
b.hardcore = true
assert(b.addon:ActivateSharingRuleset())
assert(not next(b.env.iWRDatabase) and #b.env.iWRSettings.SyncList == 0 and not next(b.env.iWRSettings.DeletedEntries),
    "notes, whitelist, and deletion history are separate on Hardcore")
assert(b.addon:GetSharingScope() ~= oldScope)
b.env.iWRDatabase["Hardcore Only-Forever"] = note("Hardcore Only")
b.hardcore = false; b.addon:ActivateSharingRuleset()
assert(b.env.iWRDatabase["Helpful Healer-Forever"] and not b.env.iWRDatabase["Hardcore Only-Forever"], "switching back restores only the original ruleset")
assert(b.env.iWRSettings.DeletedEntries["Old Person-Forever"], "tombstones return with their ruleset")
b.scopeSecret = true
assert(not b.addon:GetSharingScope(), "secret ruleset information blocks sharing rather than defaulting to Normal")
before = #b.sent; b.addon:ShareWithWhitelist(); advance(1)
assert(#b.sent == before)
b.scopeSecret = false

local d = client("Dana Rogue")
assert(d.addon:AddSharingContact("Unknown Player"))
d.addon:SendFullDBUpdateToWhitelist(); advance(1)
assert(#d.sent == 0 and #d.who == 0, "unknown names do not cause blind whispers or background Who searches")
d.addon:RefreshSharingStatus()
assert(#d.who == 1 and #d.sent == 0, "manual status refresh starts a lookup before sending")
d.whoResults = { { fullName = "Different Player" } }; d:event("WHO_LIST_UPDATE"); advance(1)
assert(#d.sent == 0 and d.addon:GetSharingPresence("Unknown Player") == "Unknown", "unrelated Who results are not proof of offline status")

local e, f = client("Erin Priest"), client("Finn Hunter")
link(e, f, false); whitelist(e, f)
e.addon:ShareWithWhitelist(); advance(1)
assert(#e.sent == 0 and e.addon:GetSharingPresence(f.name) == "Offline", "native offline status prevents a whisper")
e.roster[1].online = true
advance(31); e.secretStatus = true; e.addon:ShareWithWhitelist(); advance(6)
assert(#e.sent == 0, "secret native status does not permit a whisper")

local legacy = client("Legacy Owner", { database = { ["Legacy Note-Forever"] = note("Legacy Note") }, whitelist = { { name = "Saved Contact", realm = "Forever", type = "wow" } } })
assert(legacy.env.iWRDatabase["Legacy Note-Forever"] and #legacy.env.iWRSettings.SyncList == 1)
assert(legacy.env.iWRRulesetStores.legacy.database["Legacy Note-Forever"], "an untouched copy of unscoped saves is retained")
legacy.hardcore = true; legacy.addon:ActivateSharingRuleset()
assert(not next(legacy.env.iWRDatabase) and #legacy.env.iWRSettings.SyncList == 0, "legacy notes are assigned once, not copied into every ruleset")

local p, q = client("Iris Druid"), client("Jules Paladin")
link(p, q); link(q, p); whitelist(p, q); whitelist(q, p)
p.env.iWRDatabase["Incremental Person-Forever"] = note("Incremental Person")
q.env.iWRDatabase["Private Local-Forever"] = note("Private Local", true)
p.addon:ShareWithWhitelist(); advance(5)
local updated = note("Incremental Person"); updated[1], updated[3] = "updated note", 1000000
p.addon.Cache.Data = p.addon:Serialize({ ["Incremental Person-Forever"] = updated,
    ["Private Local-Forever"] = note("Private Local") })
p.addon:SendNewDBUpdateToWhitelist(); advance(5)
assert(q.env.iWRDatabase["Incremental Person-Forever"][1] == "updated note", "new-note updates use the same whitelist session")
assert(q.env.iWRDatabase["Private Local-Forever"][9] == true, "shared notes never overwrite a local personal entry")
q.combat = true
p.addon:SendRemoveRequestToWhitelist("Incremental Person-Forever"); advance(5)
assert(#q.addon.Queues.RemoveRequests == 1 and not q.popup, "removal confirmations wait for combat")
q.combat = false; q:event("PLAYER_REGEN_ENABLED")
assert(q.popup, "a shared removal asks for confirmation")
local confirmation = q.popup
q.addon:RemoveSharingContact(p.name)
confirmation.OnAccept()
assert(q.env.iWRDatabase["Incremental Person-Forever"], "revoking trust also invalidates an open confirmation")
confirmation.OnButton3()
assert(not q.env.iWRDatabase["Incremental Person-Forever"][9], "revoking trust also invalidates keep-as-personal")
q.env.iWRSettings.DataSharing = false
before = #q.sent; p.addon:ShareWithWhitelist(); advance(5)
assert(#q.sent == before, "disabling sharing prevents incoming requests from sending replies")

local author, keeper, observer = client("Removal Author"), client("Personal Keeper"), client("Personal Observer")
link(author, keeper); link(keeper, author); whitelist(author, keeper); whitelist(keeper, author)
local keptId = "Retained Player-Forever"
local retained = note("Retained Player")
retained[10] = { { "earlier shared note", 1, 999998, "date", "Earlier Author", false } }
author.env.iWRDatabase[keptId] = retained
author.addon:ShareWithWhitelist(); advance(10)
local localCopy = assert(keeper.env.iWRDatabase[keptId])
keeper.env.iWRDatabase["Unaffected Player-Forever"] = note("Unaffected Player")
link(keeper, observer); link(observer, keeper); whitelist(keeper, observer); whitelist(observer, keeper)
keeper.addon:RefreshSharingStatus(); advance(10)
assert(not next(observer.env.iWRDatabase), "availability checks do not enqueue a new full snapshot")
-- Queue a snapshot before the privacy choice, but prevent it from being sent.
keeper.locked = true
keeper.addon:ShareWithWhitelist()
author.addon:SendRemoveRequestToWhitelist(keptId); advance(5)
local popup = assert(keeper.popup, "shared deletion presents a decision")
assert(popup.button3 == "Keep as personal" and popup.selectCallbackByIndex and popup.OnButton3 and popup.OnCancel,
    "the modern popup routes all three buttons, including the no-change choice")
popup.OnCancel()
assert(keeper.env.iWRDatabase[keptId] == localCopy and not localCopy[9], "No keeps the note shared")
popup.OnButton3()
popup.OnHide()
keeper.popup = nil
assert(keeper.env.iWRDatabase[keptId] == localCopy and localCopy[1] == retained[1] and localCopy[9],
    "Keep as personal retains the original note and sets its privacy flag")
assert(localCopy[10][1][1] == "earlier shared note" and localCopy[10][1][6] == true,
    "retained history is also personal so a later public edit cannot expose it")
assert(not keeper.env.iWRSettings.DeletedEntries[keptId], "keeping as personal does not delete or tombstone the local note")
assert(keeper.env.iWRRulesetStores.buckets[keeper.addon:GetSharingScope()].database[keptId][9],
    "the personal choice is saved in the active ruleset store")
-- A recipient's deletion request must not invalidate a newly personal copy.
author.addon:SendRemoveRequestToWhitelist(keptId); advance(5)
assert(not keeper.popup and #keeper.addon.Queues.RemoveRequests == 0, "repeated shared removals ignore the personal copy")
keeper.locked = false
keeper.addon:ShareWithWhitelist(); advance(15)
assert(observer.env.iWRDatabase["Unaffected Player-Forever"] and not observer.env.iWRDatabase[keptId],
    "future sharing excludes the retained private note while sending unrelated notes")
assert(not author.env.iWRDatabase[keptId][9] and not author.env.iWRDatabase[keptId][10][1][6],
    "keeping a local personal copy does not change the sender's own copy")

local hc = client("Hardcore Warrior", { hardcore = true })
link(p, hc); link(hc, p); whitelist(p, hc); whitelist(hc, p)
p.addon:ShareWithWhitelist(); advance(6)
assert(not next(hc.env.iWRDatabase) and hc.addon:GetSharingPeerStatus(p.name) == "Different ruleset",
    "a whitelist entry does not bypass the wire ruleset check")

local blocked, available = client("Blocked Sender"), client("Available Receiver")
link(blocked, available); link(available, blocked); whitelist(blocked, available); whitelist(available, blocked)
blocked.sendError = true
blocked.addon:ShareWithWhitelist(); advance(8)
assert(#blocked.sent == 3 and not next(available.env.iWRDatabase), "numeric transport errors get only bounded retries")
local locked = client("Locked Sender")
link(locked, available); whitelist(locked, available); whitelist(available, locked)
locked.locked = secret
locked.addon:ShareWithWhitelist(); advance(4)
assert(#locked.sent == 0, "an unreadable messaging lock fails closed")
locked.locked = false; advance(5)
assert(locked.addon:GetSharingPeerStatus(available.name) == "iWR ready", "a short messaging restriction can recover")
locked:event("CHAT_MSG_SYSTEM", "No player named 'Available Receiver' is currently playing.")
before = #locked.sent
locked.addon:ShareWithWhitelist(); advance(10)
assert(#locked.sent == before and locked.addon:GetSharingPeerStatus(available.name) == "Offline", "the server's offline error pauses further whispers")

local waiting = client("Waiting Owner", { scopeSecret = true,
    database = { ["Existing Note-Forever"] = note("Existing Note") } })
waiting.env.iWRDatabase = { ["Pending Note-Forever"] = note("Pending Note") }
waiting.addon:SaveRulesetStorage()
waiting.scopeSecret = false; waiting.addon:ActivateSharingRuleset()
assert(waiting.env.iWRDatabase["Existing Note-Forever"] and waiting.env.iWRDatabase["Pending Note-Forever"],
    "waiting for ruleset data preserves old saves and notes created while waiting")

local big, receiver = client("Large Sender"), client("Large Receiver")
link(big, receiver); link(receiver, big); whitelist(big, receiver); whitelist(receiver, big)
for index = 1, 1000 do big.env.iWRDatabase["Large Note" .. index .. "-Forever"] = note("Large Note" .. index) end
big.addon:ShareWithWhitelist(); advance(240)
assert(receiver.env.iWRDatabase["Large Note1000-Forever"], "a thousand-note transfer completes through renewed native presence checks")
assert(big.preflights > 1, "long transfers renew native availability instead of trusting the login snapshot forever")

local modern, modernFriend = client("Modern Owner"), client("Modern Friend")
whitelist(modern, modernFriend); whitelist(modernFriend, modern); link(modernFriend, modern)
modern.env.BNGetNumFriends = function() return 1 end
modern.env.C_BattleNet = {
    GetFriendNumGameAccounts = function() return 1 end,
    GetFriendGameAccountInfo = function() return { characterName = modernFriend.name, wowProjectID = 18,
        isOnline = true, isInCurrentRegion = true, isAppearOffline = false, playerGuid = modernFriend.guid } end,
}
modern.env.C_ChatInfo.RequestCanLocalWhisperTarget = function(playerGuid)
    assert(playerGuid == modernFriend.guid, "new friends supply the native player GUID")
    modern:event("CAN_LOCAL_WHISPER_TARGET_RESPONSE", playerGuid, 0)
end
modern.env.iWRDatabase["Modern Note-Forever"] = note("Modern Note")
modern.addon:ShareWithWhitelist(); advance(5)
assert(modernFriend.env.iWRDatabase["Modern Note-Forever"], "new WoW friends can supply presence without the legacy friend list")

local lookupSender, lookup = client("Lookup Sender"), client("Lookup Receiver")
whitelist(lookup, lookupSender)
lookupSender.env.iWRDatabase["Lookup Note-Forever"] = note("Lookup Note")
assert(lookupSender.addon:AddSharingContact(lookup.name))
lookupSender.addon:ShareWithWhitelist()
lookupSender.whoResults = { { fullName = lookup.name } }
lookupSender:event("WHO_LIST_UPDATE"); advance(6)
assert(lookup.env.iWRDatabase["Lookup Note-Forever"], "a positive name lookup can start sharing without a friend or known GUID")

local chatLookup, chatReceiver = client("Chat Lookup"), client("Chat Receiver")
whitelist(chatLookup, chatReceiver); whitelist(chatReceiver, chatLookup)
chatLookup.env.WHO_LIST_FORMAT = "%s: Level %d %s - %s"
chatLookup.env.iWRDatabase["Chat Result-Forever"] = note("Chat Result")
chatLookup.addon:ShareWithWhitelist()
chatLookup:event("CHAT_MSG_SYSTEM", "Other Person: Level 60 Paladin - Stormwind")
assert(#chatLookup.sent == 0, "a different Who result cannot confirm the requested player")
chatLookup:event("CHAT_MSG_SYSTEM", "|Hplayer:Chat-Receiver|h[Chat Receiver]|h: Level 60 Paladin - Stormwind")
advance(6)
assert(chatReceiver.env.iWRDatabase["Chat Result-Forever"], "chat-routed Who results also support manually entered non-friends")

local ordered = client("Ordered Lookup")
assert(ordered.addon:AddSharingContact("Ordered Player"))
ordered.env.WHO_LIST_FORMAT = "%2$d / %1$s / %3$s"
ordered.addon:ShareWithWhitelist()
ordered:event("CHAT_MSG_SYSTEM", "60 / Ordered Player / Paladin")
assert(ordered.addon:GetSharingPresence("Ordered Player") == "Online", "localized positional Who formats identify the name argument")

local restart, restarted = client("Restart Sender"), client("Restart Receiver")
link(restart, restarted); link(restarted, restart); whitelist(restart, restarted); whitelist(restarted, restart)
for index = 1, 60 do restart.env.iWRDatabase["Restart Note" .. index .. "-Forever"] = note("Restart Note" .. index) end
restart.addon:ShareWithWhitelist(); advance(2)
restarted.addon:ResetSharingSession(); advance(20)
assert(restarted.env.iWRDatabase["Restart Note60-Forever"], "a receiver reload restarts the session and pending share")

local function forge(from, target, data, transferId)
    local template
    for index = #from.sent, 1, -1 do
        if from.sent[index].message:find("\tDATA\t", 1, true) then template = from.sent[index].message; break end
    end
    local fields = {}; for value in template:gmatch("[^\t]+") do fields[#fields + 1] = value end
    local payload, hash = from.addon:Serialize(data), 5381
    for index = 1, #payload do hash = (hash * 33 + payload:byte(index)) % 2147483647 end
    local total = math.ceil(#payload / 120)
    for index = 1, total do
        target.addon:OnSharePacket("iWRShareV1", table.concat({ "1", "DATA", fields[3], fields[4], fields[5], transferId,
            index, total, string.format("%x", hash), payload:sub((index - 1) * 120 + 1, index * 120) }, "\t"), "WHISPER", from.name)
    end
end
local invalid = note("Invalid Player"); invalid[2] = "bad relation"
forge(restart, restarted, { kind = "NOTES", entries = {
    ["Must Not Merge-Forever"] = note("Must Not Merge"), ["Invalid Player-Forever"] = invalid,
} }, "abcdef001")
assert(not restarted.env.iWRDatabase["Must Not Merge-Forever"], "malformed entries reject the whole snapshot before any merge")
local privateInjection = note("Injected Private", true)
forge(restart, restarted, { kind = "NOTES", entries = { ["Injected Private-Forever"] = privateInjection } }, "abcdef002")
assert(not restarted.env.iWRDatabase["Injected Private-Forever"], "a peer cannot inject personal-flagged entries")

local lag, lagReceiver = client("Delayed Sender"), client("Delayed Receiver")
link(lag, lagReceiver); link(lagReceiver, lag); whitelist(lag, lagReceiver); whitelist(lagReceiver, lag)
lag.env.iWRDatabase["Delayed Note-Forever"] = note("Delayed Note")
drop = function(packet)
    if packet.from ~= lag and packet.from ~= lagReceiver then return false end
    local target = packet.from == lag and lagReceiver or lag
    target.env.C_Timer.After(300, function()
        target.addon:OnSharePacket(packet.prefix, packet.message, "WHISPER", packet.from.name)
    end)
    return true
end
lag.addon:ShareWithWhitelist(); advance(1250)
assert(lagReceiver.env.iWRDatabase["Delayed Note-Forever"], "five-minute one-way chat delays preserve the original handshake and transfer")
for _, message in ipairs(lag.logs) do assert(not message:find("not confirmed", 1, true), "slow successful transfers do not fail early") end
drop = nil

local migration = client("Migration Owner", { whitelist = {
    { name = "Crasling", realm = "Mordaine", type = "wow" },
    { name = "Crasling Mordaine", realm = "Forever", type = "wow" },
    { name = "Account Alias", type = "bnet" },
} })
migration.addon:NormalizeSharingWhitelist()
assert(#migration.env.iWRSettings.SyncList == 1 and migration.addon:GetWhitelistEntry("Crasling-Mordaine"),
    "old full-name forms migrate and deduplicate")
assert(not migration.addon:GetWhitelistEntry("Account Alias") and #migration.env.iWRRulesetStores.archivedContacts == 1,
    "an old account alias is preserved but never becomes character-name authorization")

b.env.iWRDatabaseBackup = { ["Normal Backup-Forever"] = note("Normal Backup") }
b.env.iWRSettings.iWRDatabaseBackupInfo = { backupDate = "normal backup" }
b.addon:SaveRulesetStorage()
b.hardcore = true; b.addon:ActivateSharingRuleset()
assert(not next(b.env.iWRDatabaseBackup), "another ruleset cannot restore the previous ruleset's backup")
b.env.iWRDatabaseBackup = { ["Hardcore Backup-Forever"] = note("Hardcore Backup") }
b.addon:SaveRulesetStorage()
local reloaded = client(b.name, { hardcore = true, stores = b.env.iWRRulesetStores,
    database = { ["Stale Global-Forever"] = note("Stale Global") } })
assert(reloaded.env.iWRDatabase["Hardcore Only-Forever"] and not reloaded.env.iWRDatabase["Stale Global-Forever"],
    "a new addon instance selects its saved ruleset instead of stale active globals")
assert(reloaded.env.iWRDatabaseBackup["Hardcore Backup-Forever"] and #reloaded.env.iWRSettings.SyncList == 0,
    "backups and the whitelist survive a real environment reload in the correct ruleset")
reloaded.hardcore = false; reloaded.addon:ActivateSharingRuleset()
assert(reloaded.env.iWRDatabaseBackup["Normal Backup-Forever"]
    and reloaded.env.iWRSettings.iWRDatabaseBackupInfo.backupDate == "normal backup", "switching back restores the matching backup metadata")

print("PASS: whitelist-only non-friend sharing, private notes/history, parallel transfers, lost packets, immediate revocation, ruleset isolation, secret/offline guards, paced lookups, and safe migration")

local rules = client("Ruleset Reader")
rules.env.UnitIsPVP = function() error("a character's PvP flag is not a server ruleset") end
rules.env.C_PvP = { IsWarModeDesired = function() error("War Mode is not a server ruleset") end }
rules.env.C_GameRules.IsHardcoreActive = function() error("read the actual server rule flags") end
local categories = {
    { "Normal (PvE)", false, false, false },
    { "PvP", false, true, false },
    { "Hardcore", true, false, false },
    { "RP-PvP", false, true, true },
    { "RP-PvE", false, false, true },
}
local scopes = {}
for _, category in ipairs(categories) do
    rules.hardcore, rules.pvp, rules.rp = category[2], category[3], category[4]
    assert(rules.addon:ActivateSharingRuleset())
    assert(rules.addon:GetSharingRulesetLabel() == category[1], "the display names all five actual server rulesets")
    local scope = rules.addon:GetSharingScope()
    assert(not scopes[scope], "each server category has a distinct storage/sharing key")
    scopes[scope] = true
    assert(not next(rules.env.iWRDatabase) and #rules.env.iWRSettings.SyncList == 0, "new categories start with their own notes and whitelist")
    local entry = note("Only Note"); entry[1] = category[1]
    rules.env.iWRDatabase["Only Note-Forever"] = entry
    assert(rules.addon:AddSharingContact("Only Contact"))
end
for _, category in ipairs(categories) do
    rules.hardcore, rules.pvp, rules.rp = category[2], category[3], category[4]
    assert(rules.addon:ActivateSharingRuleset())
    assert(rules.env.iWRDatabase["Only Note-Forever"][1] == category[1] and #rules.env.iWRSettings.SyncList == 1,
        "returning to each of the five categories restores only its own data")
end
rules.secretRule = rules.env.Enum.GameRule.PvPRuleset
assert(not rules.addon:GetSharingScope(), "an unreadable PvP rule never silently becomes PvE")
rules.secretRule = nil
local rpRule = rules.env.Enum.GameRule.RPRuleset
rules.env.Enum.GameRule.RPRuleset = nil
assert(not rules.addon:GetSharingScope(), "a missing RP rule never silently becomes a non-RP namespace")
rules.env.Enum.GameRule.RPRuleset = rpRule

local oldKey = "f-18-3-10-0-0"
local corrected = client("Old Test Owner", { pvp = true, stores = { buckets = {
    [oldKey] = { database = { ["Old Test Note-Forever"] = note("Old Test Note") }, backup = {}, memory = {},
        settings = { SyncList = { { name = "Old Test Contact", realm = "Forever", type = "wow" } } } },
} } })
assert(corrected.env.iWRDatabase["Old Test Note-Forever"] and corrected.addon:GetWhitelistEntry("Old Test Contact"),
    "early 0.24.1 test data is preserved in the currently confirmed PvP namespace")
assert(corrected.env.iWRRulesetStores.buckets[oldKey].database["Old Test Note-Forever"], "the old test bucket remains an untouched recovery copy")
corrected.pvp = false; corrected.addon:ActivateSharingRuleset()
assert(not next(corrected.env.iWRDatabase) and #corrected.env.iWRSettings.SyncList == 0,
    "the old ambiguous test bucket is adopted once, not also copied into PvE")

local pvpSender, pvpReceiver, pveReceiver = client("PvP Sender", { pvp = true }), client("PvP Receiver", { pvp = true }), client("PvE Receiver")
for _, target in ipairs({ pvpReceiver, pveReceiver }) do
    link(pvpSender, target); link(target, pvpSender); whitelist(pvpSender, target); whitelist(target, pvpSender)
end
pvpSender.env.iWRDatabase["PvP Only-Forever"] = note("PvP Only")
pvpSender.addon:ShareWithWhitelist(); advance(7)
assert(pvpReceiver.env.iWRDatabase["PvP Only-Forever"] and not pveReceiver.env.iWRDatabase["PvP Only-Forever"],
    "PvP clients can share with each other while the same-project PvE client rejects their notes")
print("PASS: all five server rulesets, separate data stores, secret-rule guards, early test-save migration, and PvP/PvE wire isolation")

local diagnostic, offline = client("Diagnostic Sender"), client("Offline Contact")
link(diagnostic, offline, false); whitelist(diagnostic, offline)
diagnostic.addon:RefreshSharingStatus()
diagnostic.addon:ShareWithWhitelist()
local function hasLog(fragment)
    for _, message in ipairs(diagnostic.logs) do if message:find(fragment, 1, true) then return true end end
    return false
end
assert(hasLog("no handshake sent; availability is Offline") and hasLog("availability was checked recently; recheck in"),
    "manual actions explain native offline status and the short recheck cooldown")
diagnostic:event("CHAT_MSG_SYSTEM", "No player named 'Offline Contact' is currently playing.")
diagnostic.addon:ShareWithWhitelist()
assert(hasLog("checks are paused for 300 seconds (Offline)"), "manual actions report the full offline pause rather than only the short recheck delay")
return { client = client, advance = advance }
