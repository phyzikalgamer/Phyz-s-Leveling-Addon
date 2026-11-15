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
    end
end

-- Run after upstream refreshes so its banner never covers the native colours.
hooksecurefunc(addon, 'SetupGuideWindow', Skin)
hooksecurefunc(addon.RXPFrame, 'UpdateVisuals', Skin)
hooksecurefunc(addon, 'RenderFrame', Skin)
