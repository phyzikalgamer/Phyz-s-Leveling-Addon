local addonName, addon = ...

-- Theme only: keep RestedXP's navigation, rendering and quest logic.
addon.themes['WoW Classic'] = {
    name = 'WoW Classic',
    displayName = 'WoW Classic',
    author = 'Phyz',
    applicable = true,
    background = {0.055, 0.045, 0.025, 1},
    bottomFrameBG = {0.09, 0.065, 0.025, 1},
    bottomFrameHighlight = {0.25, 0.18, 0.06, 1},
    mapPins = {1, 0.82, 0, 1},
    tooltip = '|cFFFFD100',
    texturePath = 'Interface/AddOns/' .. addonName .. '/Textures/',
    headerTexture = 'rxp-banner',
    font = GameFontNormal:GetFont(),
    textColor = {0.9, 0.86, 0.76},
    bgTextures = {
        edge = 'Interface/Buttons/WHITE8X8',
        guideName = 'Interface/Buttons/WHITE8X8',
        bottom = 'Interface/Buttons/WHITE8X8',
    },
    edges = {
        edge = 'Interface/Tooltips/UI-Tooltip-Border',
        guideName = 'Interface/Tooltips/UI-Tooltip-Border',
    },
}
