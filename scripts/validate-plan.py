#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Validate metadata only. Never invokes configuration generators or compilers."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
plan = json.loads((root / 'build-plan.json').read_text())
errors = []
if plan.get('ready_for_formal_build') is not True:
    errors.append('Static integration is not marked ready.')
for name, value in plan.get('static_audit', {}).items():
    if value not in ('integrated-static-checked', 'already-upstream-static-checked'):
        errors.append(f'Incomplete audit: {name}={value}')
a = plan.get('approvals', {})
if not a.get('public_final_images'):
    errors.append('Final-image publication is not authorized.')
if not a.get('formal_build_start'):
    errors.append('The coordinator has not authorized the formal build start.')
e = plan.get('execution', {})
if (e.get('runner'), e.get('job_count'), e.get('timeout_minutes'), e.get('retry')) != ('ubuntu-24.04', 1, 360, 0):
    errors.append('Execution constraints differ from the approved one-shot standard-runner plan.')
for name in ('scripts/build-once.sh', 'sources.lock.json', 'docs/firmware-inventory.md'):
    if not (root / name).is_file():
        errors.append(f'Missing audited build input: {name}')
if errors:
    raise SystemExit('\n'.join(errors))
print('Static plan gates passed. This does not constitute hardware validation.')
