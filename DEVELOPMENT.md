# Development references

This project uses the [wow-addon-dev skill](https://github.com/TheMizeGuy/wow-addon-dev)
and the [Forever addon kit](https://github.com/Thunderz96/forever-addon-kit).
The skill was already installed; the kit is cloned locally under the ignored
`backups/developer-tools/forever-addon-kit` folder. Neither is required by players.

The kit's captured API baseline is useful for checking Forever's modern UI APIs
despite Interface 16001. Its September beta bug reports are historical; they
must not be treated as confirmation that a current client still has those bugs.

Phyz 0.4 uses `ButtonFrameTemplate` (with `BasicFrameTemplateWithInset` fallback)
and `UIPanelButtonTemplate` for native frame art and button sizing. The guide
engine, secure item actions and target macros remain separate from decoration.

Validation:

- `python tools/test_ui.py` — Lua 5.1 compilation and simulated UI/action tests.
- `python tools/package.py` — TOC/XML references and installable ZIP structure.
- The skill's `scripts/validate-toc.ps1` — TOC metadata and file checks.
- The kit's API scanner — advisory only; it reports historical and cross-client
  upstream calls as well as local code, so findings require manual review.

Simulated UI tests do not verify Blizzard art dimensions or actual game rendering.
After installation, restart WoW and inspect resizing, scrolling, item cooldowns,
retargeting and entering/leaving combat in the actual client.
