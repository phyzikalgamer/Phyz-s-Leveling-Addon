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

function addon.IsQuestCheckedStep(step, guide)
    guide = guide or addon.currentGuide
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
