# Phyz Leveling Addon

A personal fork of **RestedXP Guides v4.11.36** with a classic World of Warcraft
interface. Uses RestedXP's original guide engine, map pins and waypoint arrow.

## Install

Download the ZIP from [Releases](https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon/releases)
and extract it into your Forever client's `Interface/AddOns` folder. The result
must be `AddOns/PhyzLeveling/PhyzLeveling.toc`.

Disable OpenXP and RestedXP Guides, enable Phyz Leveling Addon and restart WoW.
Right-click the guide header to choose a guide. Use `/phyz` for settings.

Forever's bundled leveling guides cover roughly levels 1–20/22, with additional
special-purpose guides. A complete 1–60 guide pack is not included.

## Development and releases

Source lives in `PhyzLeveling/`. Run `python tools/package.py` to validate and
build `dist/PhyzLeveling-VERSION.zip`. Each version tag (`vVERSION`) publishes
a GitHub release with that installable ZIP through GitHub Actions.

For Lua syntax and UI callback smoke tests, install `lupa==2.8` and run
`python tools/test_ui.py`. The release workflow runs these checks before packaging.
These tests use simulated frames; visual verification still needs the WoW client.

See [CHANGELOG.md](CHANGELOG.md), [rebase details](REBASE.md), and the
[addon documentation](PhyzLeveling/README.md).

## Attribution

Based on [RestedXP Guides](https://github.com/RestedXP/RXPGuides) by RestedXP.
Not affiliated with or endorsed by RestedXP. Distributed under the original
[CC BY-NC-SA 4.0 license](PhyzLeveling/LICENSE); bundled libraries retain their
own licenses. See [NOTICE.md](PhyzLeveling/NOTICE.md).
