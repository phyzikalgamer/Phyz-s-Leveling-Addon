local _, addon = ...
local questTags = {accept = true, complete = true, turnin = true}

-- Store a signature as well as the index so updated guide steps are not skipped
-- because a different instruction previously occupied that number.
local function Inspect(step, checkHistory)
    local signature, count, finished = {}, 0, true
    for _, element in ipairs(step.elements or {}) do
        if not element.textOnly then
            local id = tonumber(element.questId)
            if questTags[element.tag] and id and id > 0
                and not element.reverse and not element.questIds then
                count = count + 1
                signature[#signature + 1] = element.tag .. ':' .. id
                if checkHistory and not addon.IsQuestTurnedIn(id) then finished = false end
            elseif element.tag ~= 'goto' then
                -- Mixed steps may contain purchases, trainers, level gates, etc.
                return nil, false
            end
        end
    end
    if count == 0 then return nil, false end
    return table.concat(signature, '|'), finished
end

local function ManualStepKey(step)
    if step.stepId then return tostring(step.stepId) end
    local parts = {}
    for _, e in ipairs(step.elements or {}) do
        parts[#parts + 1] = table.concat({e.tag or '', tostring(e.questId or ''),
            e.text or '', tostring(e.zone or ''), tostring(e.x or ''), tostring(e.y or '')}, ':')
    end
    return table.concat(parts, '|')
end

function addon.IsManuallyCompletedStep(step, guide)
    guide = guide or addon.currentGuide
    local saved = PHYZ2CData and PHYZ2CData.phyzManualCompleted
    local entries = saved and guide and saved[guide.key]
    return step and entries and entries[step.index] == ManualStepKey(step) or false
end

function addon.SetManualStepCompletion(index, complete)
    if InCombatLockdown() then
        print('Phyz: change step completion after combat.')
        return
    end
    local guide = addon.currentGuide
    local step = guide and guide.steps[index]
    if not step or not guide.key or not PHYZ2CData then return end
    PHYZ2CData.phyzManualCompleted = PHYZ2CData.phyzManualCompleted or {}
    local saved = PHYZ2CData.phyzManualCompleted
    saved[guide.key] = saved[guide.key] or {}
    saved[guide.key][index] = complete and ManualStepKey(step) or nil
    PHYZ2CData.stepSkip = PHYZ2CData.stepSkip or {}
    PHYZ2CData.stepSkip[index] = complete and true or nil
    if not complete then
        local checked = PHYZ2CData.phyzQuestChecked
        if checked and checked[guide.key] then checked[guide.key][index] = nil end
        for _, element in ipairs(step.elements or {}) do element.completed = nil end
    end
    step.completed = complete or nil
    local current = addon.GetGuideProgress() or 1
    -- Sticky instructions are activated alongside the main sequence. Rewind
    -- ordinary steps when reopening, but keep concurrent sticky tasks intact.
    if not complete and not step.sticky then current = index end
    if complete and not step.sticky and current == index and index < #guide.steps then
        current = index + 1
    end
    addon.SetStep(current)
    addon.RXPFrame.BottomFrame.UpdateFrame()
    addon.RXPFrame.BottomFrame:StepScroll(current)
end

function addon.IsQuestCheckedStep(step, guide)
    guide = guide or addon.currentGuide
    if addon.IsManuallyCompletedStep(step, guide) then return true end
    local saved = PHYZ2CData and PHYZ2CData.phyzQuestChecked
    local entries = saved and guide and saved[guide.key]
    local signature = entries and step and entries[step.index]
    return signature ~= nil and signature == Inspect(step, false)
end

function addon.CheckCompletedGuideQuests()
    if InCombatLockdown() then
        print('Phyz: check completed quests after combat.')
        return
    end
    local guide = addon.currentGuide
    if not guide or not guide.key or not guide.steps or not PHYZ2CData then
        print('Phyz: select a guide first.')
        return
    end
    PHYZ2CData.phyzQuestChecked = PHYZ2CData.phyzQuestChecked or {}
    local saved = PHYZ2CData.phyzQuestChecked
    saved[guide.key] = saved[guide.key] or {}
    local entries, added, total = saved[guide.key], 0, 0
    for _, step in ipairs(guide.steps) do
        local signature, finished = Inspect(step, true)
        if signature and finished then
            if entries[step.index] ~= signature then added = added + 1 end
            entries[step.index] = signature
            step.completed = true
            total = total + 1
        else
            entries[step.index] = nil
        end
    end
    local current = addon.GetGuideProgress() or 1
    -- Choose a single target rather than recursing through a long completed run.
    while current < #guide.steps and addon.IsQuestCheckedStep(guide.steps[current], guide) do
        current = current + 1
    end
    addon.SetStep(current)
    addon.RXPFrame.BottomFrame.UpdateFrame()
    addon.RXPFrame.BottomFrame:StepScroll(current)
    print(string.format('Phyz: %d completed quest steps checked; %d newly marked. Other actions were kept.', total, added))
end

local footer = addon.RXPFrame.Footer
local button = CreateFrame('Button', nil, footer)
button:SetSize(20, 20)
button:SetPoint('LEFT', footer.cog, 'RIGHT', 5, 0)
button:SetFrameLevel(footer.cog:GetFrameLevel())
button:SetNormalTexture('Interface/Buttons/UI-CheckBox-Check')
button:SetHighlightTexture('Interface/Buttons/ButtonHilight-Square', 'ADD')
button:SetScript('OnClick', addon.CheckCompletedGuideQuests)
button:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Check completed quests', 1, 0.82, 0)
    GameTooltip:AddLine('Check this guide against quests this character has turned in. Marks fully finished quest steps and keeps other actions.', 1, 1, 1, true)
    GameTooltip:Show()
end)
button:SetScript('OnLeave', function() GameTooltip:Hide() end)
footer.text:ClearAllPoints()
footer.text:SetPoint('LEFT', footer, 'LEFT', 78, 1)
footer.text:SetPoint('RIGHT', footer, 'RIGHT', -18, 1)
addon.questCheckButton = button
