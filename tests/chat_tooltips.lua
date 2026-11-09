-- Exercise chat hover callbacks without attaching scripts to Blizzard frames.
local function read(path)
    local file = assert(io.open(path)); local source = file:read("*a"); file:close(); return source
end
local source = read("iWillRemember_iWRFunctions.lua")
local first = assert(source:find("local chatIconTooltipEventsRegistered", 1, true))
local last = assert(source:find("function iWR:HandleHyperlink", first, true))
local secret = setmetatable({}, { __tostring = function() error("secret value was formatted") end })
local addon, callbacks, logs = {}, {}, {}
local env = setmetatable({ iWR = addon }, { __index = _G }); env._G = env
env.issecretvalue = function(value) return value == secret end
env.iWRSettings = { ShowChatIcons = true, TooltipShowAuthor = true }
env.iWRDatabase = { ["Party Member-Forever"] = { "Helpful healer", 6, nil, "Party Member", "2026-11-08", "Note Author" } }
addon.L = { ChatIconTooltipTitle = "iWR: %s", ChatIconTooltipPlayer = "Player: %s",
    DetailAuthor = "Author:", ChatIconTooltipClick = "Click to open the note" }
function addon:NormalizePlayerDatabaseKey(key) return key end
function addon:GetPlayerDatabaseKey() return "Party Member-Forever", "Party Member", "Forever" end
function addon:IsForeverClient() return true end
function addon:GetTypeName() return "Respected" end
function addon:GetChatIcon() return "RatingIcon" end
function addon:DebugMsg(message) logs[#logs + 1] = message end
local tooltip = { mouse = true }
env.GameTooltip = tooltip
function tooltip:IsMouseEnabled() return self.mouse end
function tooltip:EnableMouse(value) self.mouse = value end
function tooltip:SetOwner(owner) self.owner = owner end
function tooltip:SetText(value) self.title, self.lines = value, {} end
function tooltip:AddLine(value) self.lines[#self.lines + 1] = value end
function tooltip:Show() self.shown = true end
function tooltip:Hide() self.shown = false end
local processingMessage, registrations = false, 0
env.EventRegistry = {}
function env.EventRegistry:RegisterCallback(event, callback, owner)
    assert(not processingMessage, "chat callbacks must be registered outside message processing")
    registrations = registrations + 1
    callbacks[event] = function(...) callback(owner, ...) end
end
local setup = "local iWR = ...\nlocal L = iWR.L\nlocal function StripColorCodes(v) return v end\n"
    .. source:sub(first, last - 1) .. "\nreturn AddRelationshipIconToChat"
local filter = assert(load(setup, "chat tooltip callbacks", "t", env))(addon)
local registry = env.EventRegistry
env.EventRegistry = nil
assert(not addon:InitializeChatIconTooltips() and not addon:InitializeChatIconTooltips() and #logs == 1,
    "an unavailable registry is reported once without attempting protected frame hooks")
env.EventRegistry = registry
assert(addon:InitializeChatIconTooltips())
assert(addon:InitializeChatIconTooltips() and registrations == 2, "initialization is idempotent")
local chat = { HookScript = function() error("Cannot hook scripts across partitions") end,
    SetScript = function() error("existing chat scripts must not be replaced") end }
processingMessage = true
local filtered, message = filter(chat, "CHAT_MSG_PARTY", "Hello", "Party Member", "", 123)
processingMessage = false
assert(not filtered and message:find("|Haddon:iWR:Party Member-Forever", 1, true),
    "the chat filter adds clickable icons without touching protected scripts")
assert(registrations == 2)
local enter, leave = callbacks["ChatFrame.OnHyperlinkEnter"], callbacks["ChatFrame.OnHyperlinkLeave"]
enter(chat, "addon:iWR:Party Member-Forever")
assert(tooltip.shown and tooltip.owner == chat and tooltip.title == "iWR: Respected" and not tooltip.mouse)
assert(table.concat(tooltip.lines, " "):find("Helpful healer", 1, true)
    and table.concat(tooltip.lines, " "):find("Note Author", 1, true), "hover preserves the note and author details")
leave(chat)
assert(not tooltip.shown and tooltip.mouse, "leaving restores tooltip mouse behavior")
local temporaryChat = { HookScript = chat.HookScript }
enter(temporaryChat, "addon:iWR:Party Member-Forever")
assert(tooltip.shown and tooltip.owner == temporaryChat, "new whisper windows work without individual frame hooks")
leave(temporaryChat)
tooltip.title, tooltip.shown, tooltip.owner = "Party member unit tooltip", true, {}
enter(chat, "item:123")
assert(tooltip.shown and tooltip.title == "Party member unit tooltip", "unrelated unit and item tooltips are untouched")
enter(chat, secret)
assert(tooltip.title == "Party member unit tooltip", "secret links are not inspected")
env.iWRSettings.ShowChatIcons = false
enter(chat, "addon:iWR:Party Member-Forever")
assert(tooltip.title == "Party member unit tooltip", "disabled chat icons cannot open a note tooltip")
local _, sameMessage = filter(chat, "CHAT_MSG_PARTY", secret, secret, "")
assert(sameMessage == secret, "restricted chat values pass through unchanged")

local events = read("iWillRemember_EventHandler.lua")
assert(events:find("function iWR:OnEnable()\n    iWR:ActivateSharingRuleset()\n    iWR:InitializeChatIconTooltips()", 1, true),
    "chat hover callbacks are registered during addon enable")
assert(events:find("function iWR:OnPlayerLogin()\n    self:InitializeChatIconTooltips()", 1, true),
    "login can initialize callbacks if the registry was not ready earlier")
print("PASS: partition-safe chat hover events, clickable icons, note details, temporary windows, ordinary tooltips, secret guards and disabled settings")
