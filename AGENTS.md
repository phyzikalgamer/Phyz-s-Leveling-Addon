# Phyz Leveling Addon workflow

The user has authorised ongoing commits, pushes to
https://github.com/phyzikalgamer/Phyz-s-Leveling-Addon.git, installation into
their WoW Forever AddOns folder, and a GitHub release for every completed update.
Do not request permission again unless a tool requires escalation or scope changes.

- Active source is PhyzLeveling/. This is a direct RestedXP fork, not OpenXP.
- Preserve upstream licenses/credits. Never commit backups, credentials or WTF data.
- For each completed update, bump PhyzLeveling.toc's Version and add CHANGELOG.md notes.
- Run `python tools/package.py` to validate file references and produce the release ZIP.
- Install the current source into
  `C:\Program Files\World of Warcraft\_forever_\Interface\AddOns\PhyzLeveling`
  for immediate testing. Back up an old installation outside AddOns before replacing it.
- Commit the completed changes, push main, and push a matching vVERSION tag.
  The release workflow builds and publishes the installable ZIP on that tag.
- Check the GitHub Actions run and release result; report failures honestly.
- Keep original RXPGuides and OpenXP installations and user saved variables unchanged.
- Do not claim in-game verification without observing it.
