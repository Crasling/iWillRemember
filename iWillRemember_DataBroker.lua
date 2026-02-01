-- ════════════════════════════════════════════
-- ██╗ ██╗    ██╗ ██████╗     ██████╗  ██████╗
-- ╚═╝ ██║    ██║ ██╔══██╗    ██╔══██╗ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝    ██║══██╗ ██████╗
-- ██║ ██║███╗██║ ██  ██╔     ██║══██╗ ██╔══██║
-- ██║ ╚███╔███╔╝ ██   ██╗    ██╚══██╗ ██╚══██║
-- ╚═╝  ╚══╝╚══╝  ╚══════╝    ██████╗  ██████╗
-- ════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Minimap button                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local minimapButton = LDBroker:NewDataObject("iWillRemember_MinimapButton", {
    type = "data source",
    text = "iWillRemember",
    icon = iWR.Icons.iWRIcon,
    OnClick = function(self, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            iWR:DatabaseToggle()
            iWR:PopulateDatabase()
            iWR:MenuClose()
        elseif button == "LeftButton" then
            iWR:MenuToggle()
            iWR:DatabaseClose()
        elseif button == "RightButton" then
            Settings.OpenToCategory(OptionsCategory:GetID())
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
LDBIcon:Register("iWillRemember_MinimapButton", minimapButton, iWRSettings.MinimapButton)
