"""Lua 5.1 UI smoke checks. Requires lupa (a local backups/test-runtime install works)."""
from pathlib import Path
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
    'SetFont','SetTextColor','SetDrawLayer','SetSpacing','SetWordWrap','SetJustifyH','AddMaskTexture'}) do
    methods[name] = function(self, ...) self[name .. 'Args'] = {...} end
end
function methods:SetPoint(...) self.points=self.points or {}; table.insert(self.points,{...}) end
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
function methods:SetText(s) self.textValue=s end
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
function methods:HookScript(event,fn) self.scripts[event]=fn end
function CreateFrame() return NewFrame() end
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
function addon.OnInitialize() end
function addon.RenderFrame() end
function addon.UpdateGuideFontSize() end
function addon.SetStep(n) addon.changedStep=n end
function addon.GetGuideProgress() return 9 end
function addon.settings:InitializeDatabase() end
function addon.settings.ToggleActive() addon.toggled=true end
function addon.targeting:CreateTargetFrame() end
function addon.targeting:UpdateTargetFrame() end
addon.currentGuide={steps={}}
for i=1,20 do addon.currentGuide.steps[i]={index=i} end
''')
lua.execute("assert(loadstring(...))('PhyzLeveling', addon)", (ROOT / 'PhyzLeveling' / 'PhyzUI.lua').read_text(encoding='utf-8'))
lua.execute(r'''
-- Quest checker loads after PhyzUI, before the addon's initialization event.
addon.questCheckButton=NewFrame()
addon.settings:InitializeDatabase()
addon.SetupGuideWindow()
assert(addon.RXPFrame.phyzProgress.label.textValue=='STEP 9 / 20')
assert(addon.RXPFrame.phyzProgress.value==8)
assert(addon.RXPFrame.GuideName.phyzPortraitRing.width==54)
assert(addon.RXPFrame.GuideName.phyzPortraitRing.points[1][1]=='CENTER')
assert(addon.RXPFrame.ScrollFrame.ScrollBar.thumb.texture=='Interface/Buttons/UI-ScrollBar-Knob')
addon.SetupArrow()
assert(addon.arrowFrame.texture.texture=='Interface/Minimap/MinimapArrow')
assert(addon.arrowFrame.scripts.OnUpdate==nil, 'Arrow skin must not replace navigation callbacks')
assert(addon.RXPFrame.Footer.cog.phyzLabel.textValue=='Settings')
assert(addon.questCheckButton.phyzLabel.textValue=='Check quests')
assert(not addon.RXPFrame.Footer.text.shown)
addon.phyzCurrentButton.scripts.OnClick()
assert(addon.scrolled==9 and addon.changedStep==nil, 'My step must not change progress')
addon.RXPFrame.phyzClose.scripts.OnClick()
assert(addon.toggled)
for _, width in ipairs({220,400,640}) do
    addon.RXPFrame.width=width
    addon.RXPFrame.scripts.OnSizeChanged()
    local button=addon.questCheckButton
    assert(button.points[1][4]+button.width <= width-18, 'Footer buttons overflow')
end
local row=NewFrame(); row.step={index=8,completed=true,elements={}}
assert(addon.FormatGuideRow(row,'|cFF00FF00Talk to NPC|r'):find('|cFF888888',1,true))
assert(not addon.FormatGuideRow(row,'|cFF00FF00Talk to NPC|r'):find('FF00FF00',1,true))
''')
print(f'Lua 5.1 syntax: {len(files)} files passed; UI lifecycle, progress, controls, widths and completed colours passed.')
