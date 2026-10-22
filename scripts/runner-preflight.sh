#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Run only as part of the one explicitly approved formal workflow.
set -euo pipefail
[[ ${GITHUB_ACTIONS:-} == true ]]
[[ ${RUNNER_ENVIRONMENT:-} == github-hosted ]]
[[ ${GITHUB_REPOSITORY:-} == n42h2vb1/mobian-fajita-sxmo-btf ]]
[[ ${GITHUB_EVENT_NAME:-} == workflow_dispatch ]]
[[ ${GITHUB_RUN_ATTEMPT:-} == 1 ]]
[[ ${GITHUB_RUN_NUMBER:-} == 1 ]] || { echo 'Only the first workflow run is permitted; do not rerun.' >&2; exit 1; }
mkdir -p evidence
{
  date --utc --iso-8601=seconds
  uname -a
  printf 'runner=%s image=%s/%s\n' "${RUNNER_ENVIRONMENT}" "${ImageOS:-unknown}" "${ImageVersion:-unknown}"
  lscpu
  free -b
  df -B1 -T "$GITHUB_WORKSPACE" /tmp
  lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS
  for node in /dev/kvm /dev/loop-control /dev/mapper/control; do
    if [[ -e $node ]]; then ls -l "$node"; else printf 'MISSING %s\n' "$node"; fi
  done
} | tee evidence/runner-resources.txt
python3 - <<'PY' | tee evidence/resource-gates.txt
import os, shutil
ram = int(next(line.split()[1] for line in open('/proc/meminfo') if line.startswith('MemTotal:'))) * 1024
free = shutil.disk_usage(os.environ['GITHUB_WORKSPACE']).free
cpu = len(os.sched_getaffinity(0))
# Conservative planning envelopes, not measured build sizes or promises.
gates = {'cpu': (cpu, 4), 'ram_bytes': (ram, 14 * 1024**3), 'free_disk_bytes': (free, 80 * 1024**3)}
for name, (actual, minimum) in gates.items():
    print(f'{name}: actual={actual}, minimum={minimum}, pass={actual >= minimum}')
if any(actual < minimum for actual, minimum in gates.values()):
    raise SystemExit('Insufficient resources. No compiler has been invoked; no paid fallback or retry is allowed.')
PY
sudo -n modprobe loop
sudo -n modprobe dm_mod
sudo -n test -c /dev/kvm
sudo -n test -c /dev/loop-control
sudo -n test -c /dev/mapper/control
sudo -n losetup --find | tee evidence/free-loop-device.txt
sudo -n dmsetup version | tee evidence/device-mapper.txt
sudo -n python3 - <<'PY' | tee evidence/kvm-api.txt
import fcntl, os
fd = os.open('/dev/kvm', os.O_RDWR | os.O_CLOEXEC)
try:
    version = fcntl.ioctl(fd, 0xAE00, 0)
    print('KVM_GET_API_VERSION:', version)
    if version != 12:
        raise SystemExit('Unsupported KVM API')
finally:
    os.close(fd)
PY
printf 'Resource gate passed. This is not authorization to compile.\n'
