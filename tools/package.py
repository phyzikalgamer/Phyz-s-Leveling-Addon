"""Validate the addon and build an installable release ZIP (standard library only)."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / 'PhyzLeveling'
toc = ADDON / 'PhyzLeveling.toc'
version = re.search(r'^## Version:\s*(\S+)', toc.read_text(encoding='utf-8'), re.M)[1]
references = 0
for path in ADDON.rglob('*'):
    if path.suffix == '.toc':
        refs = [line.split(' [')[0].strip()
                for line in path.read_text(encoding='utf-8-sig').splitlines()
                if line.strip() and not line.startswith('#')]
    elif path.suffix == '.xml':
        refs = [e.attrib['file'] for e in ET.parse(path).iter()
                if 'file' in e.attrib and e.tag.rsplit('}', 1)[-1] in ('Include', 'Script')]
    else:
        continue
    for ref in refs:
        ref = ref.replace('\\', '/')
        # WoW's Windows file lookup ignores case; GitHub's runner does not.
        def exists(candidate):
            if candidate.is_file():
                return True
            try:
                relative = candidate.relative_to(ADDON)
            except ValueError:
                return False
            current = ADDON
            for part in relative.parts:
                current = next((p for p in current.iterdir() if p.name.lower() == part.lower()), None)
                if current is None:
                    return False
            return current.is_file()
        if not exists(path.parent / ref) and not exists(ADDON / ref):
            raise SystemExit(f'Missing reference: {path.relative_to(ROOT)} -> {ref}')
        references += 1
for required in ('LICENSE', 'NOTICE.md', 'PhyzTheme.lua', 'PhyzUI.lua'):
    assert (ADDON / required).is_file(), required
output = ROOT / 'dist' / f'PhyzLeveling-{version}.zip'
output.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(ADDON.rglob('*')):
        if path.is_file():
            archive.write(path, path.relative_to(ROOT).as_posix())
print(f'Validated {references} references; built {output.name}')
