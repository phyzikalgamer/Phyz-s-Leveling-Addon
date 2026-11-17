# Phyz Leveling Addon

A leveling guide addon for **World of Warcraft: Forever**, based on RestedXP
Guides and styled with Blizzard's native window and button templates.

Follow your guide, find your next destination, and use quest items and target
buttons from one window.

[Download the latest release](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/releases/latest)
· [Changelog](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/blob/main/CHANGELOG.md)
· [Report an issue](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/issues)

## Features

- Step-by-step guide list with a progress bar and zone coordinates where available.
- Native WoW frame, fonts, buttons and scroll controls.
- A highlighted current step and greyed-out completed steps.
- **My step** button to bring the current step back to the top of the list.
- **Check quests** button to mark fully completed quest steps using your character's turned-in quest history. Steps with other unfinished actions remain open.
- Clickable active targets in their own section of the window.
- Active quest-item buttons beside their step, with tooltips and cooldowns.
- RestedXP's waypoint arrow and map/minimap markers.
- Adjustable window size, font size and visibility settings.

## Installation

1. Download **PhyzLeveling-VERSION.zip** from the [latest release](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/releases/latest). Use the addon ZIP attached to the release.
2. Close WoW and extract the `PhyzLeveling` folder into:

   ```text
   World of Warcraft/_forever_/Interface/AddOns/
   ```

   The final path should be:

   ```text
   Interface/AddOns/PhyzLeveling/PhyzLeveling.toc
   ```

3. In the character-selection AddOns menu, enable **Phyz Leveling Addon** and disable **RestedXP Guides** and **OpenXP**. These addons share internal names and must not run together.
4. Start the game. Right-click the guide header to choose a guide, or click **Settings** to open the menu.

To update, close WoW and replace the existing `PhyzLeveling` folder with the
new release. Your settings and progress are stored separately from the addon files.

## Guides and optional addons

The public download includes RestedXP's bundled guides. For Forever, these
cover early leveling—roughly **levels 1–20/22**—and additional special-purpose
guides. **A complete Forever 1–60 guide pack is not included.**

Personal guide packs are not distributed with this project. Guide imports use
the original importer and retain its account checks. If you have a separately
configured **Phyz Personal Guides** companion, enable it alongside Phyz Leveling.

**Questie is optional.** Phyz uses RestedXP's own navigation by default;
Shortest Path Forever and TomTom are not required. A waypoint arrow does not
mean a continuous route line will appear: world-map lines depend on the guide's
path data, and the minimap uses waypoint markers.

## Controls

| Control | Action |
| --- | --- |
| `/phyz` or `/phyzleveling` | Open addon options. |
| **Settings** | Open the guide and settings menu. |
| **My step** | Align the current step with the top of the list. |
| **Check quests** | Check this guide against quests your character has turned in. |
| Target portrait | Click to target or retarget the displayed NPC or creature. |
| Quest-item icon | Click to use the item associated with that step. |

Separate active-step boxes are hidden by default. You can enable them under
**Guide Window → Show active-step boxes**. The native window styling is available
through the **WoW Classic** theme.

Targeting and item use require a player click. Changes to secure-button layouts
wait until combat ends.

## Help and feedback

This addon is under active development for WoW Forever. If something looks wrong
or a step fails to update, [open an issue](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/issues)
with the addon version, guide name, step number, a screenshot and any Lua error.
Do not post personal guide imports or account details.

For development tools and validation instructions, see
[DEVELOPMENT.md](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/blob/main/DEVELOPMENT.md).

## Credits and license

Based on [RestedXP Guides](https://github.com/RestedXP/RXPGuides) v4.11.36 by
RestedXP. Phyz Leveling Addon is not affiliated with or endorsed by RestedXP
or Blizzard Entertainment. Original guide names and author credits are retained.

Distributed under **CC BY-NC-SA 4.0**: attribution is required, commercial use is
not permitted, and adaptations must use the same license. Bundled libraries
retain their own licenses. See [LICENSE](PhyzLeveling/LICENSE) and [NOTICE.md](PhyzLeveling/NOTICE.md).
