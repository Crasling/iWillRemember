-- Run from the addon directory. Exercise saved colors, picker callbacks and
-- the real drake/border renderers without a game or saved-variable writes.
local function read(path)
    local file = assert(io.open(path)); local source = file:read("*a"); file:close()
    return source
end
local source, options, main = read("iWillRemember_iWRFunctions.lua"), read("iWillRemember_OptionsPanel.lua"), read("iWillRemember_Main.lua")
local addon = { SettingsDefault = { GoodLevels = 3, BadLevels = 2 }, Theme = { gold = { 1, 0.6, 0.1, 1 }, goldSoft = { 1, 0.7, 0.2, 1 } } }
local env = setmetatable({ iWR = addon, iWRSettings = { GoodLevels = 3, BadLevels = 2, LevelColors = {} } }, { __index = _G })
env._G = env
env.unpack = table.unpack
local first = assert(main:find("iWR.PositiveKeyMap =", 1, true))
local last = assert(main:find("\nend", assert(main:find("function iWR.GetLevelKeys", first, true)), true)) + 3
assert(load(main:sub(first, last), "level maps", "t", env))()
addon.Types = assert(load("return " .. assert(main:match("iWR%.Types%s*=%s*(%b{})"))))()
first = assert(source:find("function iWR:ResolveLevel(", 1, true))
last = assert(source:find("function iWR:GetIcon(", first, true))
assert(load(source:sub(first, last - 1), "level colors", "t", env))()
local redraws, menus = 0, 0
function addon.UpdateMenuMode() menus = menus + 1 end
function addon:UpdateTargetFrame() redraws = redraws + 1 end
function addon:DebugMsg() end
local function equal(color, r, g, b)
    assert(math.abs(color[1] - r) < 0.0001 and math.abs(color[2] - g) < 0.0001 and math.abs(color[3] - b) < 0.0001)
end
equal({ addon:GetLevelColor(-10) }, 0.9, 0, 0)
addon.SettingsDefault.LevelColors = {}
env.iWRSettings.LevelColors = addon.SettingsDefault.LevelColors
assert(addon:SetLevelColor(-10, 0.2, 0.4, 0.8))
assert(next(addon.SettingsDefault.LevelColors) == nil, "editing fresh settings cannot change the reset defaults")
equal({ addon:GetLevelColor(-10) }, 0.2, 0.4, 0.8)
equal({ addon:GetLevelColor(-1) }, 0.7, 0, 0)
assert(menus == 1 and redraws == 1, "saving refreshes the note menu and current target")
assert(not addon:SetLevelColor(-10, 0 / 0, 0, 0) and not addon:SetLevelColor(-10, 2, 0, 0))
equal({ addon:GetLevelColor(-10) }, 0.2, 0.4, 0.8)
env.iWRSettings.BadLevels = 3
assert(addon:SetLevelColor(-6, 0.8, 0.5, 0.1))
equal({ addon:GetLevelColor(-7) }, 0.8, 0.5, 0.1)
equal({ addon:GetLevelColor(-10) }, 0.2, 0.4, 0.8)
assert(addon:SetLevelColor(-6))
equal({ addon:GetLevelColor(-7) }, 0.9, 0, 0)

local function widget()
    return setmetatable({ scripts = {} }, { __index = function(_, key)
        if key == "CreateTexture" then return widget end
        if key == "SetVertexColor" or key == "SetBackdropBorderColor" then return function(self, ...) self.color = { ... } end end
        if key == "SetBackdropColor" then return function(self, ...) self.backgroundColor = { ... } end end
        if key == "SetBackdrop" then return function(self) self.backgroundColor, self.color = {1, 1, 1, 1}, {1, 1, 1, 1} end end
        if key == "GetName" then return function() return "TargetFrame" end end
        if key == "GetFrameLevel" then return function() return 1 end end
        if key == "IsEnabled" then return function() return true end end
        if key == "SetEnabled" then return function(self, value) self.enabled = value end end
        if key:match("^Set") or key == "Show" or key == "Hide" or key == "ClearAllPoints" then return function() end end
    end })
end
local button = widget()
button.iWRButtonBg, button.iWRButtonBackdrop, button.iWRRatingLevel = widget(), widget(), -10
first = assert(source:find("local function setButtonVisual(", 1, true))
last = assert(source:find("function iWR:StyleButton(", first, true))
local paint = assert(load(source:sub(first, last - 1) .. "\nreturn setButtonVisual", "button color", "t", env))()
for _, hover in ipairs({ false, true }) do
    button.iWRHovered = hover
    paint(button, false); equal(button.iWRButtonBackdrop.color, 0.2, 0.4, 0.8)
    paint(button, true); equal(button.iWRButtonBackdrop.color, 0.2, 0.4, 0.8)
end

-- Blizzard resets backdrop colors when the Settings skin replaces its texture.
local activeMethod = assert(source:match("(function iWR:SetButtonActive%b().-\nend)"))
assert(load("local setButtonVisual = ...\n" .. activeMethod, "button active", "t", env))(paint)
function addon:StyleButton(control, destructive)
    control.iWRDestructive = destructive == true
    control.iWRButtonBg, control.iWRButtonBackdrop = widget(), widget()
    paint(control, control.iWRActive)
end
local settingsStyle = assert(options:match("(local function StyleSettingsButton%b().-\nend)"))
local styleSettings = assert(load("local SETTINGS_BACKDROP = {}\n" .. settingsStyle .. "\nreturn StyleSettingsButton",
    "settings button tint", "t", env))()
local settingsButton = widget()
styleSettings(settingsButton)
equal(settingsButton.iWRButtonBackdrop.backgroundColor, 0.035, 0.030, 0.022)
equal(settingsButton.iWRButtonBackdrop.color, 0.52, 0.38, 0.17)
local dangerButton = widget()
styleSettings(dangerButton, true)
equal(dangerButton.iWRButtonBackdrop.backgroundColor, 0.16, 0.035, 0.025)
equal(dangerButton.iWRButtonBackdrop.color, 0.72, 0.20, 0.12)
local ratingButton = widget()
ratingButton.iWRRatingLevel = -10
styleSettings(ratingButton)
equal(ratingButton.iWRButtonBackdrop.color, 0.2, 0.4, 0.8)

env.ColorPickerFrame = {
    SetupColorPickerAndShow = function(self, info) self.info = info end,
    GetColorRGB = function(self) return table.unpack(self.chosen) end,
}
function addon:StyleButton(control) if control.iWRRatingLevel then paint(control, false) end end
env.StyleSettingsButton = function(control, destructive) addon:StyleButton(control, destructive) end
first = assert(options:find("    local function RefreshLevelColorButtons()", 1, true))
last = assert(options:find("    local function BuildCustomizeContent()", first, true))
local open = assert(load("local colorButtons = ...\n" .. options:sub(first, last - 1) .. "\nreturn ShowLevelColorPicker",
    "color picker", "t", env))({ [-10] = { color = button, reset = widget() } })
local original = env.iWRSettings.LevelColors[-10]
open(-10)
assert(env.ColorPickerFrame.info.hasOpacity == false)
env.ColorPickerFrame.chosen = { 0.1, 0.8, 0.3 }; env.ColorPickerFrame.info.swatchFunc()
equal({ addon:GetLevelColor(-10) }, 0.1, 0.8, 0.3)
env.ColorPickerFrame.info.cancelFunc()
assert(env.iWRSettings.LevelColors[-10] == original, "Cancel restores the original saved color")
assert(addon:SetLevelColor(-10))
open(-10); env.ColorPickerFrame.info.swatchFunc(); env.ColorPickerFrame.info.cancelFunc()
assert(env.iWRSettings.LevelColors[-10] == nil, "Cancel preserves an unset default")
assert(addon:SetLevelColor(-10, 0.2, 0.4, 0.8))
open(-10)
local oldSettings = env.iWRSettings
env.iWRSettings = { GoodLevels = 3, BadLevels = 2, LevelColors = {} }
env.ColorPickerFrame.info.swatchFunc(); env.ColorPickerFrame.info.cancelFunc()
assert(next(env.iWRSettings.LevelColors) == nil, "an old picker cannot write to another ruleset's settings")
env.iWRSettings = oldSettings

env.TargetFrame, env.CreateFrame = widget(), widget
env.GetUnitName = function(_, full) return full and "Example-Realm" or "Example" end
env.strsplit = function() return "Example", "Realm" end
env.iWRDatabase = { ["Example-Realm"] = { [2] = -10 } }
addon.AddonPath, addon.CurrentRealm = "Interface/AddOns/iWillRemember/", "Realm"
function addon:FormatNameAndRealm(name, realm) return name, realm end
first = assert(source:find("function iWR:SetTargetFrameForeverDragon()", 1, true))
last = assert(source:find("function iWR:SetTargetFrameDefault()", first, true))
assert(load(source:sub(first, last - 1), "drake color", "t", env))()
addon:SetTargetFrameForeverDragon()
equal(addon.customFrame.texture.color, 0.2, 0.4, 0.8)
assert(addon:SetLevelColor(-10)); addon:SetTargetFrameForeverDragon()
equal(addon.customFrame.texture.color, 0.9, 0, 0)
print("PASS: per-level drake and border colors, configured-level inheritance, immediate refresh, hover stability, reset, picker Cancel, and settings isolation")
