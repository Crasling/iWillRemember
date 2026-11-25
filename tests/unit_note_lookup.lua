-- Exercise real tooltip and target frame paths with mocked Forever unit names.
local fixture = assert(loadfile("tests/sharing.lua"))()
local state = fixture.client("Test Viewer")
local env, addon = state.env, state.addon
local file = assert(io.open("iWillRemember_iWRFunctions.lua", "rb"))
local source = file:read("*a"):gsub("\r\n", "\n")
file:close()
for _, method in ipairs({ "AddNoteToGameTooltip", "GetDatabaseEntry", "FormatNameAndRealm",
    "SetTargetingFrame", "SetTargetFrameForeverDragon", "VerifyTargetClassinDB" }) do
    local body = assert(source:match("(function iWR:" .. method .. "%b().-\nend)"), method)
    assert(load("local L = iWR.L\n" .. body, method, "t", env))()
end

setmetatable(addon.L, { __index = function(_, key) return key end })
addon.Colors[-10], addon.Colors.Classes = "|cffff0000", {}
addon.Colors.Gray, addon.Colors.iWR, addon.Colors.Reset = "|cff808080", "|cffff9716", "|r"
addon.AddonPath, addon.Types = "Interface\\AddOns\\iWillRemember\\", { [-10] = "Hated" }
function addon:GetTypeName(level) return self.Types[level] end
function addon:GetChatIcon() return nil end
function addon:GetLevelColor() return 1, 0, 0 end
local function noop() end
local function widget()
    return setmetatable({
        Show = function(self) self.shown = true end,
        Hide = function(self) self.shown = false end,
        SetText = function(self, text) self.text = text end,
        GetText = function(self) return self.text end,
        IsVisible = function() return true end,
        GetName = function() return "TargetFrame" end,
        GetFrameLevel = function() return 3 end,
    }, { __index = function(_, key)
        if key:match("^Set") or key == "ClearAllPoints" then return noop end
    end })
end

env.TargetFrame, env.iWRPanel, env.iWRNameInput, env.iWRNoteInput = widget(), widget(), widget(), widget()
env.CreateFrame = function()
    local frame = widget()
    frame.CreateTexture = widget
    return frame
end
local first, surname, full = "Example", nil, "Example Surname"
local class, race, faction
env.UnitName = function() return first, surname end
env.GetUnitName = function(_, includeFullName)
    if includeFullName then return full end
    return first
end
env.UnitExists, env.UnitIsPlayer = function() return true end, function() return true end
env.UnitClass = function() return nil, class end
env.UnitRace = function() return nil, race end
env.UnitFactionGroup = function() return faction end
env.GetGuildInfo = function() return nil end
env.strsplit = function(_, value) return value:match("^([^-]+)%-?(.*)$") end
env.iWRSettings.UpdateTargetFrame = true
local key, note = "Example Surname-Forever", "Saved player note"
env.iWRDatabase[key] = { note, -10, [4] = "Example Surname", [7] = "Forever" }

local function tooltipHasNote()
    local lines = {}
    env.GameTooltip = {
        GetUnit = function() return first, "target" end,
        AddLine = function(_, line) lines[#lines + 1] = line end,
    }
    addon:AddNoteToGameTooltip(env.GameTooltip)
    return table.concat(lines, "\n"):find(note, 1, true) ~= nil
end

assert(tooltipHasNote(), "tooltip finds the full Forever name with no class or faction")
addon:SetTargetingFrame()
assert(addon.customFrame and addon.customFrame.shown and env.iWRNoteInput.text == note,
    "target frame and editor find the same note with no class or faction")
env.iWRDatabase["Example-Forever"] = { "Different player", -10, [4] = "Example" }
assert(tooltipHasNote(), "a first-name-only note cannot take precedence over a verified full name")

full = "Example Surname-Forever"
assert(tooltipHasNote(), "an explicit Forever suffix is removed from the full name")
full, surname = "Different Character", "Surname"
assert(tooltipHasNote(), "UnitName's explicit surname takes precedence over the fallback")
surname = nil
assert(not tooltipHasNote(), "the fallback must match the first name")

local secret = setmetatable({}, { __index = function() error("inspected restricted value") end,
    __concat = function() error("concatenated restricted value") end })
env.issecretvalue = function(value) return rawequal(value, secret) end
env.iWRDatabase["Example-Forever"] = nil
full = secret
assert(not tooltipHasNote(), "protected fallback cannot match the note")
addon:SetTargetingFrame()
assert(not addon.customFrame.shown, "failed identity clears the previous target overlay")
full, class, race, faction = "Example Surname", secret, secret, secret
addon:SetTargetingFrame()
assert(tooltipHasNote() and addon.customFrame.shown, "protected metadata does not block a readable identity")
for _, field in ipairs({ 8, 12, 13 }) do
    assert(not env.issecretvalue(env.iWRDatabase[key][field]), "protected metadata is never written")
end

addon.GameTocVersion = 110200
surname, full = "Otherrealm", "Example-Otherrealm"
env.iWRDatabase["Example-Otherrealm"] = { note, -10, [4] = "Example" }
assert(tooltipHasNote(), "native clients keep a readable cross-realm identity")
print("PASS: full Forever names in tooltips and target frames, optional metadata, rejected fallbacks, and native realms")
