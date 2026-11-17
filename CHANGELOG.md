# Changelog

## 0.3.5 — 2026-11-17

- Dock active item buttons at the right of their owning step, with text clearance.
- Preserve secure item actions, tooltips and cooldowns; clip icons to the viewport.
- Defer secure layout changes during combat; unmatched actions retain their existing container.

## 0.3.4 — 2026-11-17

- Restored visible native grunge texture in the step panels with brighter texture tints.
- Added a small chamfer mask for clipped panel corners, preserving border-free highlighting.
- Includes v0.3.3's extra right-side scrollbar clearance.

## 0.3.3 — 2026-11-17

- Added 10px of right-side clearance between guide rows and the scrollbar area.

## 0.3.2 — 2026-11-16

- Docked Active Targets in its own section above the footer, preserving secure click-to-target buttons.
- Keep current NPC buttons available after interaction for retargeting; refresh them with guide target updates.
- Show the NPC name for a single target and an empty-state message when none are available.
- Defer docking changes during combat; automatic targeting still requires a player click under the client's secure-action rules.

## 0.3.1 — 2026-11-16

- Centred the round map emblem inside a plain bronze rim, removing the offset tracking artwork.
- Replaced purple scrollbar controls with native WoW arrows and a bronze thumb.
- Restyled the navigation pointer and distance label in gold without changing routing or rotation.

## 0.3.0 — 2026-11-16

- Restyled the guide after the classic profession-window reference: one bronze frame, round map emblem, dark textured body and integrated header/footer.
- Added a green guide-progress strip below the title.
- Replaced footer icons with red-and-gold Settings, My step and Check quests buttons.
- Matched Active Targets to the same bronze and dark-panel styling.
- Preserved guide behaviour, location captions, completed-step colours and border-free current-step highlighting.

## 0.2.12 — 2026-11-15

- Removed the active-step border; retained the background highlight and all other styling.

## 0.2.11 — 2026-11-15

- Replaced the active-step border artwork with a simple one-pixel yellow outline.

## 0.2.10 — 2026-11-15

- Added small zone and coordinate captions from each step's guide waypoint when available.
- Restored softer rounded border artwork while retaining scroll clipping.
- Matched row width to the viewport so both sides of the highlight have equal clearance.

## 0.2.9 — 2026-11-15

- Inset the active-step border and clip child highlights to the guide viewport.

## 0.2.8 — 2026-11-15

- Completed steps use grey text and a darker background, including embedded text colours.
- Current step has a yellow border glow and warm highlight; future steps keep their existing appearance.
- Added a Go to current step footer button to align the active step at the top of the guide viewport.

## 0.2.7 — 2026-11-15

- Added a check button beside Settings to reconcile the current guide with turned-in quests.
- Saves completion per character and guide, with signatures to avoid skipping changed quest instructions.
- Advances past checked quest steps and dims them in the list; retains mixed and unfinished actions.
- Reports newly marked and total checked steps without modifying the quest log.

## 0.2.6 — 2026-11-15

- Align the current step's top edge with the guide viewport when advancing.
- Use actual row positions to avoid scrolling drift with wrapped text.
- Allow the last steps to align at the top as well.

## 0.2.5 — 2026-11-15

- Reduced the quest header icon to 20px and removed its overlapping class badge.
- Reduced the guide title font to 11 and added padding and line spacing in a taller header.

## 0.2.4 — 2026-11-15

- Added a saved “Show active-step boxes” setting under Guide Window, off by default.
- Hiding the boxes leaves the main guide list, step logic and navigation running.
- Re-enabling restores boxes immediately, including after a temporary alpha command.

## 0.2.3 — 2026-11-15

- Added prominent step headings instead of small corner numbers in the guide list.
- Improved wrapped objective padding, line spacing and active-step card spacing.
- Separated the guide header from the first row and active-step boxes.
- Raised the default font to 12, including a one-time migration for existing profiles.

## 0.2.2 — 2026-11-15

- Added optional local personal-guide companion support using the native importer.
- Personal guide payloads remain outside this repository and release ZIPs.

## 0.2.1 — 2026-11-15

- Fixed release packaging to include the Phyz theme and UI modules.
- Added GitHub publishing and installable release ZIP automation.

## 0.2.0 — 2026-11-15

- Rebuilt directly from RestedXP Guides v4.11.36.
- Retained RestedXP's guide window, step engine, map pins and waypoint navigation.
- Added a WoW Classic theme with opaque dark panels, native font and Blizzard borders.
- Added private settings and `/phyz` commands.
- Removed the earlier OpenXP modules and routes.
- Kept Shortest Path from automatically taking over Phyz navigation.

Static file-reference and installation checks passed. In-game testing is pending.
