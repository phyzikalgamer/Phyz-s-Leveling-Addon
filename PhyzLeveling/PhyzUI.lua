local _, addon = ...
local WHITE = 'Interface/Buttons/WHITE8X8'
local BORDER = 'Interface/DialogFrame/UI-DialogBox-Border'

local function Skin()
    if not addon.activeTheme or addon.activeTheme.name ~= 'WoW Classic' then return end
    if addon.v2 and addon.v2:IsGuideWindowEnabled() then return end
    local frame = addon.RXPFrame
    if not frame or not frame.BottomFrame then return end
    frame.BottomFrame:SetBackdrop({
        bgFile = WHITE, edgeFile = BORDER, edgeSize = 20,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    frame.BottomFrame:SetBackdropColor(0.055, 0.045, 0.025, 1)
    frame.BottomFrame:SetBackdropBorderColor(0.7, 0.6, 0.38, 1)
    for _, panel in ipairs({frame.GuideName, frame.Footer}) do
        if panel.bg then
            panel.bg:SetTexture(WHITE)
            panel.bg:SetVertexColor(0.13, 0.085, 0.025, 1)
        end
        if panel.text then panel.text:SetTextColor(1, 0.82, 0) end
    end
    if frame.GuideName.icon then
        frame.GuideName.icon:SetTexture('Interface/GossipFrame/AvailableQuestIcon')
        frame.GuideName.icon:ClearAllPoints()
        frame.GuideName.icon:SetPoint('LEFT', frame.GuideName, 'LEFT', 10, 0)
        frame.GuideName.icon:SetSize(20, 20)
    end
    -- Keep the two-line guide title clear of the icon and border.
    frame.GuideName:SetHeight(44)
    frame.GuideName.text:ClearAllPoints()
    frame.GuideName.text:SetPoint('TOPLEFT', frame.GuideName, 'TOPLEFT', 42, -7)
    frame.GuideName.text:SetPoint('BOTTOMRIGHT', frame.GuideName, 'BOTTOMRIGHT', -12, 7)
    frame.GuideName.text:SetFont(addon.font, 11, '')
    frame.GuideName.text:SetSpacing(2)
    frame.GuideName.text:SetWordWrap(true)
    frame.GuideName.classIcon:Hide()
end

-- Run after upstream refreshes so its banner never covers the native colours.
hooksecurefunc(addon, 'SetupGuideWindow', Skin)
hooksecurefunc(addon.RXPFrame, 'UpdateVisuals', Skin)
hooksecurefunc(addon, 'RenderFrame', Skin)
hooksecurefunc(addon, 'UpdateGuideFontSize', Skin)

function addon.UpdateActiveStepVisibility()
    local p = addon.settings and addon.settings.profile
    local current = addon.RXPFrame.CurrentStepFrame
    if not p or not p.showActiveStepBoxes then
        current:Hide()
    elseif addon.currentGuide and not addon.v2:IsGuideWindowEnabled() then
        -- Also undo the temporary alpha command offered before this setting.
        current:SetAlpha(1)
        current.UpdateText()
    end
end

-- The engine refreshes these frames as quests change. Hide the presentation
-- while allowing its step processing, quest detection and navigation to run.
addon.RXPFrame.CurrentStepFrame:HookScript('OnShow', function(self)
    local p = addon.settings and addon.settings.profile
    if p and not p.showActiveStepBoxes then self:Hide() end
end)

-- Apply the readability defaults once to existing profiles as well as new ones.
-- Later font choices remain under the player's control.
hooksecurefunc(addon.settings, 'InitializeDatabase', function()
    local p = addon.settings.profile
    if p and not p.phyzReadableLayout then
        p.guideFontSize = math.max(p.guideFontSize or 9, 12)
        p.phyzReadableLayout = true
    end
    addon.UpdateActiveStepVisibility()
end)
