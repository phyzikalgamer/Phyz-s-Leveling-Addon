local _, addon = ...
local WHITE = 'Interface/Buttons/WHITE8X8'
local BORDER = 'Interface/DialogFrame/UI-DialogBox-Border'

local function RowState(step)
    local current = addon.GetGuideProgress() or 1
    if step.completed or (addon.IsQuestCheckedStep and addon.IsQuestCheckedStep(step))
        or (PHYZ2CData and PHYZ2CData.stepSkip and PHYZ2CData.stepSkip[step.index])
        or (not step.sticky and step.index < current) then return 'done' end
    return step.index == current and 'current' or 'future'
end

function addon.StyleGuideRow(frame)
    if not frame.step then return end
    local state = RowState(frame.step)
    if not frame.phyzGlow then
        -- ScrollFrames clip row textures, but separate child frames can escape
        -- the viewport. Draw an inset texture border so the scrollbar is intact.
        local textures = {}
        for _, edge in ipairs({'TOP', 'BOTTOM', 'LEFT', 'RIGHT'}) do
            for layer = 1, 2 do
                local texture = frame:CreateTexture(nil, 'OVERLAY')
                texture:SetColorTexture(1, 0.82, 0, layer == 1 and 0.18 or 0.9)
                local thickness = layer == 1 and 4 or 1
                if edge == 'TOP' or edge == 'BOTTOM' then
                    local y = edge == 'TOP' and -2 or 2
                    texture:SetPoint(edge .. 'LEFT', frame, edge .. 'LEFT', 2, y)
                    texture:SetPoint(edge .. 'RIGHT', frame, edge .. 'RIGHT', -2, y)
                    texture:SetHeight(thickness)
                else
                    local x = edge == 'LEFT' and 2 or -2
                    texture:SetPoint('TOP' .. edge, frame, 'TOP' .. edge, x, -2)
                    texture:SetPoint('BOTTOM' .. edge, frame, 'BOTTOM' .. edge, x, 2)
                    texture:SetWidth(thickness)
                end
                textures[#textures + 1] = texture
            end
        end
        frame.phyzGlow = {SetShown = function(_, shown)
            for _, texture in ipairs(textures) do texture:SetShown(shown) end
        end}
    end
    frame.phyzGlow:SetShown(state == 'current')
    if state == 'done' then
        frame:SetBackdropColor(0.025, 0.022, 0.018, 1)
    elseif state == 'current' then
        frame:SetBackdropColor(0.20, 0.14, 0.025, 1)
    else
        frame:SetBackdropColor(unpack(addon.colors.bottomFrameBG))
    end
end

function addon.FormatGuideRow(frame, text)
    addon.StyleGuideRow(frame)
    if not text or text == '' then return '' end
    local title = string.format('Step %d', frame.step.index)
    if RowState(frame.step) == 'done' then
        -- Embedded NPC/item colour codes otherwise override the grey font colour.
        text = text:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', '')
        return '|cFF888888' .. title .. '\n' .. text .. '|r'
    end
    return '|cFFFFD100' .. title .. '|r\n' .. text
end

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

local footer = addon.RXPFrame.Footer
local currentButton = CreateFrame('Button', nil, footer)
currentButton:SetSize(20, 20)
currentButton:SetPoint('LEFT', footer.cog, 'RIGHT', 30, 0)
currentButton:SetNormalTexture('Interface/Buttons/UI-SpellbookIcon-NextPage-Up')
currentButton:SetHighlightTexture('Interface/Buttons/ButtonHilight-Square', 'ADD')
currentButton:SetScript('OnClick', function()
    if addon.currentGuide then
        addon.RXPFrame.BottomFrame.UpdateFrame()
        addon.RXPFrame.BottomFrame:StepScroll(addon.GetGuideProgress())
    end
end)
currentButton:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Go to current step', 1, 0.82, 0)
    GameTooltip:AddLine('Align the current step with the top of the guide window.', 1, 1, 1, true)
    GameTooltip:Show()
end)
currentButton:SetScript('OnLeave', function() GameTooltip:Hide() end)

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
