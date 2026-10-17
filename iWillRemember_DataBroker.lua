-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔ 
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════


-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Minimap button                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iWR.L

iWRSettings.MinimapButton = iWRSettings.MinimapButton or { hide = false, minimapPos = -30 }
iWRSettings.MinimapButton.showInCompartment = true

local minimapButton = LDBroker:NewDataObject("iWillRemember", {
    type = "data source",
    text = "iWillRemember",
    icon = iWR.Icons.iWRIcon,
    iconCoords = { 0.14, 0.86, 0.10, 0.82 },
    OnClick = function(self, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            iWR:DatabaseToggle()
            iWR:PopulateDatabase()
            iWR:MenuClose()
        elseif button == "LeftButton" then
            iWR:MenuToggle()
            iWR:DatabaseClose()
        elseif button == "RightButton" then
            iWR:SettingsToggle()
        end
    end,

    -- Tooltip handling
    OnTooltipShow = function(tooltip)
        -- Name
        tooltip:SetText(iWR.Colors.iWR .. "iWillRemember" .. iWR.Colors.Green .. " v" .. iWR.Version, 1, 1, 1)

        -- Desc
        tooltip:AddLine(" ", 1, 1, 1) 
        tooltip:AddLine(L["MinimapButtonLeftClick"], 1, 1, 1)
        tooltip:AddLine(L["MinimapButtonRightClick"], 1, 1, 1)
        tooltip:AddLine(L["MinimapButtonShiftLeftClick"], 1, 1, 1)
        tooltip:Show()  -- Make sure the tooltip is displayed
    end,
})

-- Register the minimap button with LibDBIcon
LDBIcon:Register("iWillRemember", minimapButton, iWRSettings.MinimapButton)
