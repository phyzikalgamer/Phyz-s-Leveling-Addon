"""Lua 5.1 UI smoke checks. Requires lupa (a local backups/test-runtime install works)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'backups' / 'test-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
compile_lua = lua.eval('function(source, name) local f, e = loadstring(source, name); return f ~= nil, e end')
files = list((ROOT / 'PhyzLeveling').rglob('*.lua'))
for path in files:
    ok, error = compile_lua(path.read_text(encoding='utf-8-sig'), str(path))
    assert ok, error

lua.execute(r'''
local methods = {}
function NewFrame()
    return setmetatable({width=400, height=360, shown=true, scripts={}}, {__index=methods})
end
for _, name in ipairs({'SetBackdrop','SetBackdropColor','SetBackdropBorderColor','SetVertexColor',
    'SetColorTexture','SetTexCoord','EnableMouse','SetStatusBarTexture','SetStatusBarColor',
    'SetFont','SetTextColor','SetDrawLayer','SetSpacing','SetWordWrap','SetJustifyH','AddMaskTexture',
    'SetMovable','SetClampedToScreen','SetClipsChildren','RegisterEvent','ClearBackdrop'}) do
    methods[name] = function(self, ...) self[name .. 'Args'] = {...} end
end
function methods:SetPoint(...) self.pointCount=(self.pointCount or 0)+1; self.points=self.points or {}; table.insert(self.points,{...}) end
function methods:ClearBackdrop()
    self.clearCount=(self.clearCount or 0)+1
    if NotifyLayout and addon and addon.RXPFrame.scripts.OnSizeChanged then
        addon.RXPFrame.scripts.OnSizeChanged()
    end
end
function methods:ClearAllPoints() self.points={} end
function methods:SetAllPoints() end
function methods:SetSize(w,h) self.width=w; self.height=h end
function methods:SetWidth(w) self.width=w end
function methods:SetHeight(h) self.height=h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetParent(p) self.parent=p end
function methods:SetFrameLevel(n) self.level=n end
function methods:GetFrameLevel() return self.level or 6 end
function methods:SetText(s) self.textValue=s; if self.fontString then self.fontString.textValue=s end end
function methods:GetText() return self.textValue end
function methods:GetFontString() self.fontString=self.fontString or NewFrame(); return self.fontString end
function methods:SetTexture(s) self.texture=s end
function methods:SetNormalTexture(s) self.normal=NewFrame(); self.normal.texture=s end
function methods:SetPushedTexture(s) self.pushed=NewFrame() end
function methods:SetHighlightTexture(s) self.highlight=NewFrame() end
function methods:GetNormalTexture() return self.normal end
function methods:GetPushedTexture() return self.pushed end
function methods:GetHighlightTexture() return self.highlight end
function methods:SetThumbTexture(path) self.thumb=NewFrame(); self.thumb.texture=path end
function methods:GetThumbTexture() return self.thumb end
function methods:CreateTexture() return NewFrame() end
function methods:CreateMaskTexture() return NewFrame() end
function methods:CreateFontString() return NewFrame() end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetShown(v) self.shown=not not v end
function methods:IsShown() return self.shown end
function methods:SetAlpha(v) self.alpha=v end
function methods:SetMinMaxValues(a,b) self.minimum=a; self.maximum=b end
function methods:SetValue(v) self.value=v end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event,fn) self.scripts[event]=fn end
function methods:RegisterEvent(event)
    assert(self.scripts.OnEvent, 'Install event handler before registering ' .. event)
end
function CreateFrame(kind,name,parent,template)
    if ForceBasicFrame and template=='ButtonFrameTemplate' then error('Portrait template unavailable') end
    local f=NewFrame(); f.template=template; f.parent=parent
    if template=='ButtonFrameTemplate' or template=='BasicFrameTemplateWithInset' then
        f.TitleText=NewFrame(); f.portrait=NewFrame(); f.CloseButton=NewFrame()
    end
    if template=='UIPanelButtonTemplate' then f.fontString=NewFrame() end
    return f
end
function InCombatLockdown() return false end
function hooksecurefunc(object,key,callback)
    local original=assert(object[key],key)
    object[key]=function(...) original(...); callback(...) end
end
GameTooltip=NewFrame()
function GameTooltip:SetOwner() end
function GameTooltip:AddLine() end
C_Map={GetMapInfo=function() return {name='Undercity'} end}
PHYZ2CData={stepSkip={}}
addon={font='Fonts/FRIZQT__.TTF',activeTheme={name='WoW Classic'},
    colors={bottomFrameBG={0.035,0.034,0.030,0.94}}, settings={profile={guideFontSize=12}},
    v2={IsGuideWindowEnabled=function() return false end},targeting={},RXPFrame=NewFrame()}
local f=addon.RXPFrame
f.BottomFrame=NewFrame(); f.GuideName=NewFrame(); f.Footer=NewFrame(); f.CurrentStepFrame=NewFrame()
for _, panel in ipairs({f.GuideName,f.Footer}) do panel.bg=NewFrame(); panel.text=NewFrame() end
f.GuideName.icon=NewFrame(); f.GuideName.classIcon=NewFrame()
f.Footer.cog=NewFrame(); f.Footer.icon=NewFrame()
f.ScrollFrame=NewFrame(); f.ScrollFrame.ScrollBar=NewFrame()
for _, direction in ipairs({'Up','Down'}) do
    local button=NewFrame()
    for _, part in ipairs({'Normal','Pushed','Highlight','Disabled'}) do button[part]=NewFrame() end
    f.ScrollFrame.ScrollBar['Scroll' .. direction .. 'Button']=button
end
addon.arrowFrame=NewFrame(); addon.arrowFrame.texture=NewFrame(); addon.arrowFrame.text=NewFrame()
function addon.arrowFrame:UpdateVisuals() end
function f.UpdateScrollBar() end
function f.UpdateVisuals() end
function f.CurrentStepFrame.UpdateText() end
function f.BottomFrame.UpdateFrame() end
function f.BottomFrame:StepScroll(n) addon.scrolled=n end
function addon.SetupGuideWindow() end
function addon.SetupArrow() end
function addon.UpdateItemFrame() end
function addon.OnInitialize() end
function addon.RenderFrame() end
function addon.UpdateGuideFontSize() end
progressIndex=9
function addon.SetStep(n) addon.changedStep=n; progressIndex=n end
function addon.GetGuideProgress() return progressIndex end
function addon.settings:InitializeDatabase() end
function addon.settings.ToggleActive() addon.toggled=true end
function addon.targeting:CreateTargetFrame() end
function addon.targeting:UpdateTargetFrame() end
addon.currentGuide={steps={}}
for i=1,20 do addon.currentGuide.steps[i]={index=i} end
local pending={}
C_Timer={After=function(_,fn) pending[#pending+1]=fn end}
function PendingTimers() return #pending end
function RunPendingTimers()
    local batch=pending; pending={}
    for _, fn in ipairs(batch) do fn() end
end
''')
lua.execute("assert(loadstring(...))('PhyzLeveling', addon)", (ROOT / 'PhyzLeveling' / 'PhyzUI.lua').read_text(encoding='utf-8'))
lua.execute(r'''
-- Quest checker loads after PhyzUI, before the addon's initialization event.
addon.questCheckButton=NewFrame()
addon.settings:InitializeDatabase()
addon.SetupGuideWindow()
assert(addon.RXPFrame.phyzProgress.label.textValue=='STEP 9 / 20')
assert(addon.RXPFrame.phyzProgress.value==8)
assert(addon.RXPFrame.phyzChrome.template=='ButtonFrameTemplate')
assert(addon.RXPFrame.phyzChrome.TitleText.textValue=='Phyz Leveling')
assert(addon.RXPFrame.phyzChrome.portrait.texture=='Interface/Icons/INV_Misc_Map_01')
ForceBasicFrame=true
addon.RXPFrame.phyzChrome=nil
addon.SetupGuideWindow()
assert(addon.RXPFrame.phyzChrome.template=='BasicFrameTemplateWithInset')
ForceBasicFrame=false
assert(addon.RXPFrame.ScrollFrame.ScrollBar.thumb.texture=='Interface/Buttons/UI-ScrollBar-Knob')
addon.SetupArrow()
assert(addon.arrowFrame.texture.texture=='Interface/Minimap/MinimapArrow')
assert(addon.arrowFrame.scripts.OnUpdate==nil, 'Arrow skin must not replace navigation callbacks')
assert(addon.RXPFrame.Footer.cog.phyzLabel.textValue=='Settings')
assert(addon.questCheckButton.phyzLabel.textValue=='Check quests')
assert(not addon.RXPFrame.Footer.text.shown)
assert(addon.phyzCurrentButton.phyzNative.template=='UIPanelButtonTemplate')
assert(not addon.phyzCurrentButton.shown, 'Original icon must be hidden behind native replacement')
addon.phyzCurrentButton.phyzNative.scripts.OnClick()
assert(addon.scrolled==9 and addon.changedStep==nil, 'My step must not change progress')
addon.RXPFrame.phyzClose.scripts.OnClick()
assert(addon.toggled)
for _, width in ipairs({220,400,640}) do
    addon.RXPFrame.width=width
    addon.RXPFrame.scripts.OnSizeChanged()
    RunPendingTimers()
    local button=addon.questCheckButton.phyzNative
    assert(button.points[1][4]+button.width <= width-18, 'Footer buttons overflow')
end
-- Regression: resize bursts schedule only one layout; layout-triggered callbacks
-- cannot recursively enter layout or schedule a perpetual chain of work.
for i=1,20 do addon.RXPFrame.scripts.OnSizeChanged() end
assert(PendingTimers()==1)
NotifyLayout=true
RunPendingTimers()
assert(PendingTimers()==0, 'Layout re-entry must not schedule another resize')
local before=addon.RXPFrame.clearCount
for i=10,20 do addon.SetStep(i) end
assert(addon.RXPFrame.clearCount==before, 'Advancing steps must not rebuild window chrome')
assert(addon.RXPFrame.phyzProgress.label.textValue=='STEP 20 / 20')
NotifyLayout=false
progressIndex=9
local row=NewFrame(); row.text=NewFrame(); row.step={index=8,completed=true,elements={}}
assert(addon.FormatGuideRow(row,'|cFF00FF00Talk to NPC|r'):find('|cFF888888',1,true))
assert(not addon.FormatGuideRow(row,'|cFF00FF00Talk to NPC|r'):find('FF00FF00',1,true))
-- Dock existing secure target buttons without changing their click action.
addon.settings.profile.enableTargetFrame=true
local target=NewFrame(); target.title=NewFrame(); target.title.text=NewFrame()
local secure=NewFrame(); secure.targetData={name='Innkeeper Shay'}
secure.attributes={type='macro',macrotext='/targetexact Innkeeper Shay'}
target.friendlyTargetButtons={secure}; target.enemyTargetButtons={}
addon.targeting.activeTargetFrame=target
addon.DockActiveTargets()
assert(target.parent==addon.RXPFrame.phyzTargetPanel)
assert(secure.width==26 and secure.attributes.macrotext=='/targetexact Innkeeper Shay')
assert(addon.RXPFrame.phyzTargetPanel.caption.textValue=='Innkeeper Shay')
local parent=target.parent
InCombatLockdown=function() return true end
addon.RXPFrame.phyzTargetPanel=nil
addon.DockActiveTargets()
assert(target.parent==parent and addon.RXPFrame.phyzTargetPanel==nil, 'Do not reparent secure targets in combat')
InCombatLockdown=function() return false end
-- Inline item layout preserves the original secure action and item identity.
local item=NewFrame(); item.itemId=123; item.attributes={type1='item',item='item:123'}
local itemRow=NewFrame(); itemRow.text=NewFrame(); itemRow.step={index=9,activeItems={[123]=true}}
addon.RXPFrame.ScrollChild={framePool={[9]=itemRow}}
addon.RXPFrame.activeSteps={itemRow.step}
addon.activeItemFrame=NewFrame(); addon.activeItemFrame.buttonList={item}
addon.DockActiveItems()
assert(item.parent==addon.RXPFrame.phyzItemClip and itemRow.phyzInlineItems==1)
assert(item.attributes.item=='item:123' and item.width==28)
assert(addon.activeItemFrame.alpha==0)
assert(addon.activeItemFrame.EnableMouseArgs[1]==false)
local anchors=item.pointCount
addon.updateBottomFrame=false
addon.DockActiveItems()
assert(item.pointCount==anchors and not addon.updateBottomFrame, 'Unchanged docking must not redraw or reanchor')
addon.SetGuideRowText(itemRow, 'Use item')
local anchors=itemRow.text.pointCount
local clears=itemRow.clearCount
addon.SetGuideRowText(itemRow, 'Use item')
assert(itemRow.text.pointCount==anchors and itemRow.clearCount==clears)
''')

# Run the actual guide-list layout function against a long guide, rather than
# duplicating its algorithm in the test. Native anchor walks must stay shallow.
source = (ROOT / 'PhyzLeveling' / 'GuideWindow.lua').read_text(encoding='utf-8')
layout = re.search(r'local function LayoutGuideRows\(\).*?^end', source, re.M | re.S)[0]
factory = lua.execute('return function(ScrollChild, ScrollFrame, stepPos)\n' + layout + '\nreturn LayoutGuideRows end')
lua.globals().layout_factory = factory
lua.execute(r'''
local container, viewport, positions=NewFrame(),NewFrame(),{}
viewport.height=180
container.framePool={}
for i=1,209 do
    local row=NewFrame(); row.height=40+(i%4)*12
    container.framePool[i]=row
end
local layout=layout_factory(container,viewport,positions)
layout()
for i,row in ipairs(container.framePool) do
    assert(#row.points==2 and row.points[1][2]==container and row.points[2][2]==container,
        'Every guide row must anchor to the container, never a previous row')
end
local anchorCount=container.framePool[55].pointCount
layout()
assert(container.framePool[55].pointCount==anchorCount, 'Unchanged rows must not be reanchored')
local before=container.framePool[55].points[1][5]
container.framePool[46].height=container.framePool[46].height+30
layout()
assert(container.framePool[55].points[1][5]==before-30, 'Later row positions must follow changed heights')
container.framePool[46].phyzRowHidden=true
layout()
assert(container.framePool[47].points[1][5]==container.framePool[46].points[1][5], 'Hidden rows take no space')
assert(container.height==positions[0]+viewport.height, 'Keep space to align the final step')
local visits=0
local function walk(frame)
    visits=visits+1; assert(visits<20, 'Native anchor walk grows with step number')
    for _,point in ipairs(frame.points or {}) do walk(point[2]) end
end
walk(container.framePool[55])
assert(visits==3)
''')
print(f'Lua 5.1 syntax: {len(files)} files passed; UI lifecycle, progress, controls, widths and completed colours passed.')
print('Long-guide regression: 209 flat-anchored rows; step 46/55 reflow, hidden rows and final-step spacing passed.')

# Exercise the actual scroll method with deliberately stale screen coordinates.
scroll = re.search(r'function BottomFrame:StepScroll\(n\).*?^end', source, re.M | re.S)[0]
lua.globals().scroll_factory = lua.execute('return function(addon, BottomFrame, ScrollChild, ScrollFrame, IsFrameShown)\n' + scroll + '\nreturn BottomFrame end')
lua.execute(r'''
local container, viewport, bottom=NewFrame(),NewFrame(),NewFrame()
container.height=20000; viewport.height=300; viewport.ScrollBar=NewFrame()
local row=NewFrame(); row.phyzRowY=12345
-- Screen coordinates intentionally disagree with the new calculated layout.
function container:GetTop() return 100 end
function row:GetTop() return -11000 end
container.framePool={[105]=row}
local engine={currentGuide={steps={[105]={index=105}}},v2={}}
function engine.GetGuideProgress() return 105 end
function engine.v2:IsGuideWindowEnabled() return false end
scroll_factory(engine,bottom,container,viewport,function() return true end)
bottom:StepScroll(102)
assert(viewport.ScrollBar.value==12345, 'Scroll must use current row layout, not stale screen coordinates')
row.phyzRowY=13000
bottom:StepScroll()
assert(viewport.ScrollBar.value==13000, 'Repeated clicks must follow changed wrapping')
assert(engine.GetGuideProgress()==105, 'Scrolling must preserve progress')
''')
print('Current-step scrolling: stale screen coordinates and changed row offsets passed.')

lua.execute(r'''
-- Main sequence 105 with unfinished sticky steps 102-104: the displayed
-- current step must follow the earliest active task, not the main counter.
progressIndex=105
for i=21,126 do addon.currentGuide.steps[i]={index=i} end
local travel={index=102,active=true,sticky=true,elements={}}
local rare={index=103,active=true,sticky=true,elements={}}
local completed={index=101,active=true,sticky=true,completed=true}
addon.RXPFrame.activeSteps={rare,completed,travel}
assert(addon.GetCurrentGuideStep()==102)
addon.phyzCurrentButton.phyzNative.scripts.OnClick()
assert(addon.scrolled==102 and progressIndex==105, 'My step must show active sticky tasks without rewinding engine progress')
addon.SetStep(105)
assert(addon.RXPFrame.phyzProgress.label.textValue=='STEP 102 / 126')
local row=NewFrame(); row.text=NewFrame(); row.step=travel
addon.FormatGuideRow(row,'Travel')
assert(row.phyzStyleState=='current')
travel.completed=true
assert(addon.GetCurrentGuideStep()==103)
PHYZ2CData.stepSkip[103]=true
assert(addon.GetCurrentGuideStep()==105)
PHYZ2CData.stepSkip[103]=nil
addon.RXPFrame.activeSteps={}
''')
print('Sticky-step regression: engine progress 105, active step 102, completion and skipped tasks passed.')

# Execute the real home handler; reject any attempts to dismiss or synthesize
# confirmation, then verify completion only after server acknowledgement.
home_source = (ROOT / 'PhyzLeveling' / 'functions.lua').read_text(encoding='utf-8')
home = re.search(r'function addon.functions.home\(self, \.\.\.\).*?^end', home_source, re.M | re.S)[0]
lua.execute('addon.functions={}\n' + home)
lua.execute(r'''
function IsShiftKeyDown() return shiftHeld end
function GetBindLocation() return bindLocation or 'Orgrimmar' end
function GossipGetOptions() return {{type='binder'}} end
local selections=0
function addon.SelectGossipType(kind) assert(kind=='binder'); selections=selections+1 end
function addon.SetElementComplete(frame) frame.element.completed=true end
local function forbidden() error('Home automation must preserve native confirmation') end
C_PlayerInteractionManager={ConfirmationInteraction=forbidden,ClearInteraction=forbidden}
ConfirmBinder=forbidden
StaticPopup1={Hide=forbidden}
local frame=NewFrame(); frame.element={step={active=true},location='Camp Taurajo'}
addon.settings.profile.enableBindAutomation=true
addon.functions.home(frame,'GOSSIP_SHOW')
assert(selections==1 and not frame.element.completed)
addon.functions.home(frame,'CONFIRM_BINDER')
assert(not frame.element.completed and not frame.scripts.OnUpdate)
addon.functions.home(frame)
assert(selections==1, 'Do not reselect gossip while confirmation is open')
-- Reopening after cancellation permits another attempt.
addon.functions.home(frame,'GOSSIP_SHOW')
assert(selections==2)
addon.functions.home(frame,'CONFIRM_BINDER')
addon.functions.home(frame,'HEARTHSTONE_BOUND')
assert(frame.element.completed)
frame.element.completed=nil; frame.element.confirm=false
addon.settings.profile.enableBindAutomation=false
addon.functions.home(frame,'GOSSIP_SHOW')
assert(selections==2)
addon.functions.home(frame,'HEARTHSTONE_BOUND')
assert(frame.element.completed, 'Manual binds must still complete the guide step')
frame.element.completed=nil; shiftHeld=true
addon.settings.profile.enableBindAutomation=true
bindLocation='Camp Taurajo'
addon.functions.home(frame)
assert(frame.element.completed, 'Existing bind location must be recognized with Shift held')
shiftHeld=false
''')
print('Inn binding: native confirmation preserved; cancellation/retry and manual completion passed.')

# Load the actual completion helpers and exercise persistent manual overrides.
lua.execute("assert(loadstring(...))('PhyzLeveling', addon)", (ROOT / 'PhyzLeveling' / 'PhyzQuestCheck.lua').read_text(encoding='utf-8'))
lua.execute(r'''
local guide={key='manual-test',steps={}}
for i=1,65 do guide.steps[i]={index=i,stepId='manual-'..i,elements={}} end
addon.currentGuide=guide
progressIndex=65
local step=guide.steps[59]; step.sticky=true; step.active=true
step.elements={{tag='deathskip',completed=false}}
addon.RXPFrame.activeSteps={step,guide.steps[65]}
addon.SetManualStepCompletion(59,true)
assert(addon.IsManuallyCompletedStep(step) and addon.IsQuestCheckedStep(step))
assert(PHYZ2CData.stepSkip[59] and addon.GetCurrentGuideStep()==65)
-- Simulate a reload/switch clearing transient flags, retaining SavedVariables.
step.completed=nil; PHYZ2CData.stepSkip={}
assert(addon.IsQuestCheckedStep(step), 'Manual completion must survive transient state resets')
step.stepId='different-step'
assert(not addon.IsManuallyCompletedStep(step), 'Different instructions must not inherit the mark')
step.stepId='manual-59'
addon.SetManualStepCompletion(59,false)
assert(not addon.IsQuestCheckedStep(step) and not PHYZ2CData.stepSkip[59])
assert(not step.elements[1].completed and addon.GetCurrentGuideStep()==59)
step.sticky=false; step.active=nil
addon.SetManualStepCompletion(59,false)
assert(progressIndex==59, 'Reopening an ordinary step must return to it')
addon.SetManualStepCompletion(59,true)
assert(progressIndex==60, 'Completing an ordinary current step must advance')
local other={key='other-guide',steps=guide.steps}
assert(not addon.IsManuallyCompletedStep(step,other), 'Marks must stay scoped to their guide')
''')
menu = re.search(r'RXPFrame.bottomMenu = \{.*?^\}', source, re.M | re.S)[0]
lua.execute('local RXPFrame=addon.RXPFrame; local L=function(s) return s end\n' + menu)
lua.execute(r'''
local menu=addon.RXPFrame.bottomMenu
local calls={}
addon.SetManualStepCompletion=function(index,value) calls[#calls+1]={index,value} end
for _, entry in ipairs(menu) do
    if entry.phyzCompletion then entry.arg1=59; entry.func(NewFrame(),entry.arg1) end
end
assert(#calls==2 and calls[1][1]==59 and calls[1][2]==true and calls[2][2]==false,
    'Context menu actions must address the clicked step and support both states')
''')
print('Manual completion: sticky tasks, undo, persistent marks, guide scoping and context menu actions passed.')
