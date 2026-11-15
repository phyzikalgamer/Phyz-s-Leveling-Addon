# Phyz 0.2.0 — RestedXP baseline

Rebuilt directly from installed RestedXP Guides v4.11.36 on 15 November 2026.
The earlier AUDIT.md describes the archived OpenXP-based version only.

RestedXP's engine, classic guide window, map pins, waypoint targeting and arrow
are retained. OpenXP's card, Smart Start, travel/terrain/path-hint modules and
custom later-level guides are absent. Default presentation is a WoW Classic
theme: opaque dark panels, native font, gold headings and Blizzard borders.
The window defaults to 360 by 180. Theme and presentation hooks are separate
from route logic. V2 remains an optional upstream feature.

PHYZ2* saved variables are separate from both earlier Phyz and RestedXP.
The guide compatibility global is PhyzEngine instead of RXP so Shortest Path's
automatic RestedXP integration does not replace this fork's navigation.
RestedXP/OpenXP must remain disabled because other engine globals are shared.
Shortest Path settings and existing saved data have not been edited.

Validation: all 1,658 TOC/XML file references resolve; license byte comparison
passed; saved-variable isolation, command registration, private engine identity,
theme load order and removal of OpenXP modules checked. No Lua interpreter or
game session was available for runtime or visual testing.

Backups are stored in backups/ outside the active addon installation.
The upstream installed RXPGuides folder is unchanged.
