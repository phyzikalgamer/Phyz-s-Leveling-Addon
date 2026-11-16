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
        -- Four plain one-pixel edges, inset and clipped with the row textures.
        local textures = {}
        for _, edge in ipairs({'TOP', 'BOTTOM', 'LEFT', 'RIGHT'}) do
            local texture = frame:CreateTexture(nil, 'OVERLAY')
            texture:SetColorTexture(1, 0.82, 0, 1)
            if edge == 'TOP' or edge == 'BOTTOM' then
                local y = edge == 'TOP' and -2 or 2
                texture:SetPoint(edge .. 'LEFT', frame, edge .. 'LEFT', 2, y)
                texture:SetPoint(edge .. 'RIGHT', frame, edge .. 'RIGHT', -2, y)
                texture:SetHeight(1)
            else
                local x = edge == 'LEFT' and 2 or -2
                texture:SetPoint('TOP' .. edge, frame, 'TOP' .. edge, x, -2)
                texture:SetPoint('BOTTOM' .. edge, frame, 'BOTTOM' .. edge, x, 2)
                texture:SetWidth(1)
            end
            textures[#textures + 1] = texture
        end
        frame.phyzGlow = {SetShown = function(_, shown)
            for _, texture in ipairs(textures) do texture:SetShown(shown) end
        end}
    end
    frame.phyzGlow:SetShown(false)
    if state == 'done' then
        frame:SetBackdropColor(0.025, 0.022, 0.018, 1)
    elseif state == 'current' then
        frame:SetBackdropColor(0.20, 0.14, 0.025, 1)
    else
        frame:SetBackdropColor(unpack(addon.colors.bottomFrameBG))
    end
end

local function StepLocation(step)
    for _, e in ipairs(step.elements or {}) do
        local map, x, y = tonumber(e.zone), tonumber(e.x), tonumber(e.y)
        if e.tag == 'goto' and map and x and y and x >= 0 and x <= 100 and y >= 0 and y <= 100 then
            local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(map)
            if info and info.name then
                return string.format('%s - %.1f, %.1f', info.name, x, y)
            end
        end
    end
end

function addon.FormatGuideRow(frame, text)
    addon.StyleGuideRow(frame)
    if not frame.phyzLocation then
        frame.phyzLocation = frame:CreateFontString(nil, 'OVERLAY')
        frame.phyzLocation:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 10, 7)
        frame.phyzLocation:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -12, 7)
        frame.phyzLocation:SetFont(addon.font, 10, '')
        frame.phyzLocation:SetTextColor(0.62, 0.60, 0.52)
        frame.phyzLocation:SetJustifyH('LEFT')
        frame.phyzLocation:SetWordWrap(false)
    end
    local location = text and text ~= '' and StepLocation(frame.step)
    frame.phyzLocation:SetText(location or '')
    frame.phyzLocation:SetShown(location ~= nil and location ~= false)
    if not text or text == '' then return '' end
    local title = string.format('Step %d', frame.step.index)
    if RowState(frame.step) == 'done' then
        -- Embedded NPC/item colour codes otherwise override the grey font colour.
        text = text:gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', '')
        return '|cFF888888' .. title .. '\n' .. text .. '|r'
    end
    return '|cFFFFD100' .. title .. '|r\n' .. text
end

local function RedButton(button, label)
    button:SetNormalTexture('Interface/Buttons/UI-Panel-Button-Up')
    button:SetPushedTexture('Interface/Buttons/UI-Panel-Button-Down')
    button:SetHighlightTexture('Interface/Buttons/UI-Panel-Button-Highlight', 'ADD')
    for _, texture in ipairs({button:GetNormalTexture(), button:GetPushedTexture(), button:GetHighlightTexture()}) do
        texture:SetTexCoord(0, 0.625, 0, 0.6875)
    end
    if not button.phyzLabel then
        button.phyzLabel = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        button.phyzLabel:SetPoint('CENTER', 0, 1)
    end
    button.phyzLabel:SetText(label)
    button.phyzLabel:SetTextColor(1, 0.82, 0)
end

local function Skin()
    if not addon.activeTheme or addon.activeTheme.name ~= 'WoW Classic' then return end
    if addon.v2 and addon.v2:IsGuideWindowEnabled() then return end
    local frame = addon.RXPFrame
    if not frame or not frame.BottomFrame then return end
    local header, footer, body = frame.GuideName, frame.Footer, frame.BottomFrame
    frame:SetBackdrop({
        bgFile = 'Interface/DialogFrame/UI-DialogBox-Background',
        edgeFile = BORDER, tile = true, tileSize = 32, edgeSize = 24,
        insets = {left = 6, right = 6, top = 6, bottom = 6},
    })
    frame:SetBackdropColor(0.65, 0.58, 0.42, 1)
    frame:SetBackdropBorderColor(0.82, 0.66, 0.36, 1)
    header:ClearAllPoints()
    header:SetPoint('TOPLEFT', frame, 'TOPLEFT', 8, -7)
    header:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -8, -7)
    header:SetHeight(43)
    header:SetBackdrop({bgFile = WHITE})
    header:SetBackdropColor(0.12, 0.075, 0.025, 1)
    header.bg:SetTexture(WHITE)
    header.bg:SetVertexColor(0.12, 0.075, 0.025, 1)
    header.text:ClearAllPoints()
    header.text:SetPoint('TOPLEFT', header, 'TOPLEFT', 68, -6)
    header.text:SetPoint('BOTTOMRIGHT', header, 'BOTTOMRIGHT', -32, 6)
    header.text:SetFont(addon.font, 11, '')
    header.text:SetSpacing(2)
    header.text:SetWordWrap(true)
    header.text:SetTextColor(1, 0.82, 0)
    header.classIcon:Hide()
    if not frame.phyzClose then
        frame.phyzClose = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
        frame.phyzClose:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -3, -3)
        frame.phyzClose:SetSize(28, 28)
        frame.phyzClose:SetScript('OnClick', addon.settings.ToggleActive)
    end
    -- A round quest portrait, modelled on the profession-window medallion.
    header.icon:ClearAllPoints()
    header.icon:SetPoint('CENTER', header, 'LEFT', 24, -5)
    header.icon:SetSize(48, 48)
    header.icon:SetTexture('Interface/Icons/INV_Misc_Map_01')
    if not header.phyzPortraitRing then
        if header.icon.AddMaskTexture then
            local mask = header:CreateMaskTexture()
            mask:SetAllPoints(header.icon)
            mask:SetTexture('Interface/CharacterFrame/TempPortraitAlphaMask')
            header.icon:AddMaskTexture(mask)
            header.phyzPortraitMask = mask
        end
        header.phyzPortraitRing = header:CreateTexture(nil, 'OVERLAY')
        header.phyzPortraitRing:SetTexture('Interface/Minimap/MiniMap-TrackingBorder')
        header.phyzPortraitRing:SetSize(78, 78)
        header.phyzPortraitRing:SetPoint('TOPLEFT', header.icon, 'TOPLEFT', -7, 7)
    end
    if not frame.phyzProgress then
        local progress = CreateFrame('StatusBar', nil, frame, 'BackdropTemplate')
        progress:SetStatusBarTexture('Interface/TargetingFrame/UI-StatusBar')
        progress:SetStatusBarColor(0.12, 0.55, 0.18)
        progress:SetBackdrop({bgFile = WHITE, edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', edgeSize = 8})
        progress:SetBackdropColor(0.025, 0.025, 0.02, 1)
        progress:SetBackdropBorderColor(0.6, 0.48, 0.24, 1)
        progress.label = progress:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        progress.label:SetPoint('CENTER')
        frame.phyzProgress = progress
    end
    local progress = frame.phyzProgress
    progress:ClearAllPoints()
    progress:SetPoint('TOPLEFT', frame, 'TOPLEFT', 78, -53)
    progress:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -18, -53)
    progress:SetHeight(14)
    local total = addon.currentGuide and #addon.currentGuide.steps or 0
    local current = total > 0 and math.min(addon.GetGuideProgress() or 1, total) or 0
    progress:SetMinMaxValues(0, math.max(total, 1))
    progress:SetValue(math.max(0, current - 1))
    progress.label:SetText(total > 0 and string.format('STEP %d / %d', current, total) or 'Choose a guide')
    body:ClearAllPoints()
    body:SetPoint('TOPLEFT', frame, 'TOPLEFT', 9, -78)
    body:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -9, 39)
    body:SetBackdrop({
        bgFile = 'Interface/DialogFrame/UI-DialogBox-Background',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', tile = true, tileSize = 32, edgeSize = 8,
        insets = {left = 2, right = 2, top = 2, bottom = 2},
    })
    body:SetBackdropColor(0.45, 0.45, 0.42, 1)
    body:SetBackdropBorderColor(0.45, 0.36, 0.19, 1)
    footer:ClearAllPoints()
    footer:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 9, 9)
    footer:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -9, 9)
    footer:SetHeight(25)
    footer:SetBackdrop({bgFile = WHITE})
    footer:SetBackdropColor(0.10, 0.09, 0.065, 1)
    footer.bg:SetTexture(WHITE)
    footer.bg:SetVertexColor(0.10, 0.09, 0.065, 1)
    footer.text:Hide()
    footer.cog:SetParent(footer)
    local buttons = {footer.cog, addon.phyzCurrentButton, addon.questCheckButton}
    local labels = {'Settings', 'My step', 'Check quests'}
    local width = math.max(50, (frame:GetWidth() - 46) / 3)
    for i, button in ipairs(buttons) do
        RedButton(button, labels[i])
        button:ClearAllPoints()
        button:SetPoint('LEFT', footer, 'LEFT', 4 + (i - 1) * (width + 7), 0)
        button:SetSize(width, 23)
        button:SetFrameLevel(footer:GetFrameLevel() + 2)
    end
    footer.icon:ClearAllPoints()
    footer.icon:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 2)
end

-- Run after upstream refreshes so its banner never covers the native colours.
hooksecurefunc(addon, 'SetupGuideWindow', Skin)
hooksecurefunc(addon.RXPFrame, 'UpdateVisuals', Skin)
hooksecurefunc(addon, 'RenderFrame', Skin)
hooksecurefunc(addon, 'UpdateGuideFontSize', Skin)

local function SkinTargets()
    if InCombatLockdown() then return end
    if addon.settings.profile.hideActiveTargetsBackground then return end
    local target = addon.targeting and addon.targeting.activeTargetFrame
    if not target or not addon.activeTheme or addon.activeTheme.name ~= 'WoW Classic' then return end
    target:SetBackdrop({
        bgFile = 'Interface/DialogFrame/UI-DialogBox-Background', edgeFile = BORDER,
        tile = true, tileSize = 32, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    target:SetBackdropColor(0.45, 0.45, 0.42, 1)
    target:SetBackdropBorderColor(0.82, 0.66, 0.36, 1)
    if target.title then
        target.title:SetBackdrop({bgFile = WHITE, edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', edgeSize = 8})
        target.title:SetBackdropColor(0.12, 0.075, 0.025, 1)
        target.title:SetBackdropBorderColor(0.6, 0.48, 0.24, 1)
        if target.title.text then target.title.text:SetTextColor(1, 0.82, 0) end
    end
end
hooksecurefunc(addon.targeting, 'CreateTargetFrame', SkinTargets)
hooksecurefunc(addon.targeting, 'UpdateTargetFrame', SkinTargets)

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
addon.phyzCurrentButton = currentButton

hooksecurefunc(addon, 'SetStep', Skin)
addon.RXPFrame:HookScript('OnSizeChanged', Skin)

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
    if p and not p.phyzProfessionChrome then
        p.frameHeight = math.max(p.frameHeight or 0, 360)
        addon.RXPFrame:SetHeight(p.frameHeight)
        p.phyzProfessionChrome = true
    end
    addon.UpdateActiveStepVisibility()
end)
