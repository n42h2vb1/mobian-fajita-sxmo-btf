#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Publication only; never invokes a compiler or retries a build.
set -euo pipefail
cd "$(dirname "$0")/.."
[[ ${GITHUB_ACTIONS:-} == true && ${GITHUB_RUN_ATTEMPT:-} == 1 ]]
[[ ${GITHUB_REPOSITORY:-} == n42h2vb1/mobian-fajita-sxmo-btf ]]
python3 scripts/validate-plan.py
python3 - <<'PY'
import json, pathlib
out = pathlib.Path('out/release')
m = json.loads((out / 'final-image-manifest.json').read_text())
if m.get('complete') is not True or m.get('device') != 'fajita' or m.get('btf_verified') is not True:
    raise SystemExit('Refusing to publish incomplete or wrong-device output')
for key in ('boot_image', 'rootfs_image', 'corresponding_source', 'firmware_inventory', 'final_config'):
    name = m.get(key, '')
    p = (out / name).resolve()
    if not name or out.resolve() not in p.parents or not p.is_file() or p.stat().st_size == 0:
        raise SystemExit(f'Missing valid release input: {key}')
PY
mkdir -p out/assets
python3 - <<'PY'
from pathlib import Path
import hashlib, shutil
src, dest = Path('out/release'), Path('out/assets')
cap = 2_000_000_000  # Strictly below GitHub's 2 GiB per-asset limit.
for p in sorted(src.iterdir()):
    if not p.is_file():
        raise SystemExit(f'Unexpected non-file release entry: {p}')
    if p.stat().st_size < cap:
        # Same filesystem: no second copy of a potentially large image.
        import os
        os.link(p, dest / p.name)
    else:
        with p.open('rb') as reader:
            n = 0
            while True:
                first = reader.read(min(1024 * 1024, cap))
                if not first:
                    break
                part = dest / f'{p.name}.part{n:03d}'
                with part.open('wb') as writer:
                    writer.write(first)
                    left = cap - len(first)
                    while left:
                        block = reader.read(min(left, 1024 * 1024))
                        if not block:
                            break
                        writer.write(block)
                        left -= len(block)
                n += 1
sums = []
for p in sorted(dest.iterdir()):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    sums.append(f'{h.hexdigest()}  {p.name}\n')
(dest / 'SHA256SUMS').write_text(''.join(sums))
PY
tag="fajita-7.3-sxmo-btf-${GITHUB_SHA:0:12}"
# Draft creation and uploads are single attempts. Do not rerun the job.
gh release create "$tag" --repo "$GITHUB_REPOSITORY" --draft --prerelease \
  --target "$GITHUB_SHA" --title "Experimental fajita / Linux 7.3 / Sxmo / BTF" \
  --notes-file docs/release-notes.md
while IFS= read -r -d '' asset; do
  gh release upload "$tag" "$asset" --repo "$GITHUB_REPOSITORY"
done < <(find out/assets -maxdepth 1 -type f -print0 | sort -z)
gh release edit "$tag" --repo "$GITHUB_REPOSITORY" --draft=false --prerelease
printf 'PUBLIC_RELEASE=https://github.com/%s/releases/tag/%s\n' "$GITHUB_REPOSITORY" "$tag"
