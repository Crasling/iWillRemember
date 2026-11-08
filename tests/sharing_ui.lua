-- Exercise the actual sharing-page controls and the shared autocomplete.
local fixture = assert(loadfile("tests/sharing.lua"))()
local state = fixture.client("Interface Owner")
local env, addon = state.env, state.addon
local function read(path)
    local file = assert(io.open(path, "rb")); local value = file:read("*a"); file:close()
    return value:gsub("\r\n", "\n")
end
local widgets = {}
local function widget(kind, parent)
    local item = { kind = kind, parent = parent, shown = true, width = 480, text = "" }
    local methods = {}
    function methods:SetText(text) self.text = text; if self.OnTextChanged then self:OnTextChanged() end end
    function methods:GetText() return self.text end
    function methods:SetSize(width, height) self.width, self.height = width, height end
    function methods:SetWidth(width) self.width = width end
    function methods:SetHeight(height) self.height = height end
    function methods:GetWidth() return self.width end
    function methods:GetFrameLevel() return 1 end
    function methods:GetParent() return self.parent end
    function methods:SetScript(event, callback) self[event] = callback end
    function methods:HookScript(event, callback)
        local previous = self[event]
        self[event] = function(self, ...) if previous then previous(self, ...) end; callback(self, ...) end
    end
    function methods:SetShown(value) self.shown = value end
    function methods:Hide() self.shown = false end
    function methods:Show()
        local wasShown = self.shown
        self.shown = true
        if not wasShown and self.OnShow then self:OnShow() end
    end
    function methods:SetChecked(value) self.checked = value end
    function methods:IsShown() return self.shown end
    function methods:HasFocus() return self.focused end
    function methods:SetFocus() self.focused = true; if self.OnEditFocusGained then self:OnEditFocusGained() end end
    function methods:ClearFocus() self.focused = false; if self.OnEditFocusLost then self:OnEditFocusLost() end end
    function methods:CreateFontString() return widget("FontString", self) end
    function methods:CreateTexture() return widget("Texture", self) end
    widgets[#widgets + 1] = item
    return setmetatable(item, { __index = function(_, name)
        if methods[name] then return methods[name] end
        if name:match("^Set") or name:match("^Enable") then return function() end end
    end })
end
env.CreateFrame = function(kind, _, parent) return widget(kind, parent) end
env.CreateSectionHeader = function(_, _, y) return {}, y - 28 end
env.CreateSettingsCheckbox = function(_, _, _, y) return {}, y - 30 end
env.CreateInfoText = function(_, _, y) return {}, y - 40 end
env.CreateSettingsButton = function(parent, text, _, y, callback)
    local button = widget("Button", parent); button:SetText(text); button:SetScript("OnClick", callback)
    return button, y - 34
end
function addon:StyleButton() end
function addon:StyleEditBox() end
function addon:StyleSurface() end
env.StyleSettingsButton = function(button, destructive) addon:StyleButton(button, destructive) end
env.StyleSettingsSurface = function(frame) addon:StyleSurface(frame) end
env.StyleSettingsScroll = function() end
env.L = setmetatable({}, { __index = function(_, key) return key end })
env.syncContent, env.scrollChildren, env.checkboxRefs = widget("Frame"), { {}, widget("Frame") }, {}
local helper = assert(read("iWillRemember_iWRFunctions.lua"):match("(function iWR:AttachAutocomplete%b().-\nend)"))
assert(load("local IWR_BACKDROP = {}; local function IsMouseOverFrame() return false end\n" .. helper, "autocomplete", "t", env))()
local source = read("iWillRemember_OptionsPanel.lua")
local start = assert(source:find('    y = -10\n\n    -- Sync Settings', 1, true))
local stop = assert(source:find('    -- Backup settings', start, true))
assert(load(source:sub(start, stop - 1), "sharing page", "t", env))()
local input
for _, item in ipairs(widgets) do if item.kind == "EditBox" then input = item; break end end
assert(input, "the sharing page has a free-text character field")
input:SetFocus(); input:SetText("Manual Stranger"); input:OnEnterPressed()
assert(addon:GetWhitelistEntry("Manual Stranger"), "Enter adds a manually typed non-friend")
env.iWRMemory.GroupLog = { { name = "Suggested Paladin", realm = "Forever" } }
input:SetFocus(); input:SetText("Sugg")
assert(input.iWRAutocomplete:IsShown(), "typing a prefix opens recent-player suggestions")
input:OnEnterPressed()
assert(addon:GetWhitelistEntry("Suggested Paladin"), "Enter selects and adds a suggested full name")
local remove
for _, item in ipairs(widgets) do
    if item.text == "x" and item.parent.contact and item.parent.contact.name == "Manual Stranger" then remove = item end
end
assert(remove, "each whitelist row has a remove control")
remove:OnClick()
assert(not addon:GetWhitelistEntry("Manual Stranger"), "the row control removes the intended contact")
local refresh, share
for _, item in ipairs(widgets) do
    if item.text == "WhitelistRefreshStatus" then refresh = item end
    if item.text == "WhitelistSyncNow" then share = item end
end
assert(refresh and share, "availability and sharing have separate actions")
refresh:OnClick(); share:OnClick()
assert(#state.sent == 0, "UI actions do not bypass online checks for unknown players")

-- Use the actual DebugMsg gate to check both clicked buttons, including
-- no-op paths, while proving Debug Mode off stays silent.
local functions = read("iWillRemember_iWRFunctions.lua")
local debugMethod = assert(functions:match("(function iWR:DebugMsg%b().-\nend)"))
addon.L.DebugInfo, addon.L.DebugWarning, addon.L.DebugError = "INFO: ", "WARNING: ", "ERROR: "
local messages = {}
function addon:PrintToChat(message) messages[#messages + 1] = message end
assert(load("local L = iWR.L; local print = function(...) iWR:PrintToChat(...) end\n" .. debugMethod, "DebugMsg", "t", env))()
local function logged(fragment, since)
    for index = (since or 0) + 1, #messages do if messages[index]:find(fragment, 1, true) then return true end end
    return false
end
env.iWRSettings.DebugMode = true
refresh:OnClick(); share:OnClick()
assert(logged("Refresh status clicked.") and logged("Sync now clicked."), "both actual buttons log their activation")
assert(logged("whitelisted player(s), ruleset Normal (PvE)") and logged("already pending"),
    "debug output explains the contact count, ruleset, and a pending check")
local since = #messages
env.iWRSettings.DataSharing = false
refresh:OnClick(); share:OnClick()
assert(logged("Refresh status: sharing is disabled", since) and logged("Sync now: sharing is disabled", since),
    "both buttons explain when sharing is disabled")
env.iWRSettings.DataSharing = true
local contacts = env.iWRSettings.SyncList
env.iWRSettings.SyncList = {}
since = #messages; refresh:OnClick(); share:OnClick()
assert(logged("Refresh status: the whitelist is empty", since) and logged("Sync now: the whitelist is empty", since),
    "empty-whitelist clicks are visible in debug output")
env.iWRSettings.SyncList = contacts
state.scopeSecret = true
since = #messages; refresh:OnClick(); share:OnClick()
assert(logged("Refresh status: waiting for the server ruleset", since) and logged("Sync now: waiting for the server ruleset", since),
    "unreadable server rules explain why no request starts")
state.scopeSecret = false
env.iWRSettings.DebugMode = false
since = #messages; refresh:OnClick(); share:OnClick()
assert(#messages == since, "button diagnostics stay silent when Debug Mode is off")

-- Run the complete Settings OnShow callback, not just the sharing tab. The
-- old whitelist function must not survive in the parent window's lifecycle.
local onShowStart = assert(source:find('    settingsFrame:HookScript("OnShow", function()', 1, true))
local onShowStop = assert(source:find('    function iWR:RefreshSettingsPanel()', onShowStart, true))
env.settingsFrame = widget("Frame")
env.checkboxRefs = { DataSharing = widget("CheckButton") }
env.iconPreviewTextures, env.iconRowLabels, env.labelEditBoxes, env.sidebarButtons = {}, {}, {}, {}
env.RefreshLevelColorButtons = function() end
env.iNIFInstalledFrame, env.iNIFPromoFrame = widget("Frame"), widget("Frame")
env.iSTInstalledFrame, env.iSTPromoFrame = widget("Frame"), widget("Frame")
env.iRCInstalledFrame, env.iRCPromoFrame = widget("Frame"), widget("Frame")
local backupRefreshes, statRefreshes, sharingRefreshes = 0, 0, 0
env.UpdateBackupInfoDisplay = function() backupRefreshes = backupRefreshes + 1 end
env.UpdateDatabaseStats = function() statRefreshes = statRefreshes + 1 end
local refreshSharing = addon.RefreshSharingPanel
function addon:RefreshSharingPanel()
    sharingRefreshes = sharingRefreshes + 1
    return refreshSharing(self)
end
assert(load(source:sub(onShowStart, onShowStop - 1), "Settings OnShow", "t", env))()
for _ = 1, 2 do env.settingsFrame:Hide(); env.settingsFrame:Show() end
assert(sharingRefreshes == 2 and backupRefreshes == 2 and statRefreshes == 2,
    "opening and reopening Settings refreshes sharing, backups, and statistics")
assert(env.checkboxRefs.DataSharing.checked == true, "opening Settings also refreshes checkbox state")
print("PASS: sharing-page controls, Settings reopen, button diagnostics, skipped actions, and Debug Mode gating")
