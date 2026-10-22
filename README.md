# Mobian fajita: Sxmo + BTF

Static integration workspace for OnePlus 6T (`fajita`, SDM845): Mobian Trixie, Sxmo/Sway as the only desktop, Linux 7.3. BTF is a required build-time gate, not yet produced; see [BTF and packaging](docs/btf-and-packaging.md). This is a new repository without imported private history.

## Current status

**Static preparation only. No kernel, package or image has been compiled. No phone has been flashed. This is not yet a complete or tested image recipe.** `build-plan.json` deliberately fails closed until integration is checked and the coordinator authorizes the sole formal build. Do not dispatch the workflow now. The 2026-10-22 static audit found 0 Actions runs, no `scripts/build-once.sh`, all 12 `static_audit` items still `pending`, and an 80 GiB preflight disk gate that cannot pass on the standard 14 GB runner. See [patch status](docs/patch-manifest.md), [BTF and packaging](docs/btf-and-packaging.md), and [runner feasibility](docs/resource-and-runner.md).

Evidence for these gates: `build-plan.json` L3/L8/L17-L29, `scripts/runner-preflight.sh` L30, `scripts/validate-plan.py` L10-L25, and `.github/workflows/final-build.yml` L33/L52.

The owner has authorized publication of source, workflows, logs **and final system images**. This does not authorize disclosing credentials, unrelated private history or firmware whose terms clearly prohibit distribution.

## Required integration scope

- Rebase Mobian qcom-linux SDM845 7.2 packaging onto Linux 7.3; retain necessary downstream functionality and avoid reapplying upstream features.
- Build only the fajita DTB/boot image; check S6E3FC2X01 panel, TE GPIO, sleep pinctrl, regulators and pn553/nxp-nci NFC support.
- Remove later DEBUG_INFO_NONE overrides, supply pahole, inspect final .config and verify vmlinux BTF. A config fragment alone proves nothing about the binary.
- Sxmo/Sway as the sole default desktop, with the correct service user; prevent sdm845-support from replacing the custom kernel.
- Fajita profile and SensorProxy autorotation/proximity lock, with matching libssc, hexagonrpcd, SLPI and registry dependencies.
- Upstream `ABS_SND_PROFILE` slider events plus Sxmo silent/vibrate/ring policy; never hardcode event device numbers, and do not add a duplicate kernel series.
- Verify existing oneplus_sdm845 Wi-Fi calibration rather than duplicating it.
- Experimental CAMSS C-PHY, IMX519, fajita camera graph, actuator and matching libcamera dependencies.
- Complete experimental PMI8998 TCPM sink-only RFC, not a dr_mode-only change. It does not power peripherals and may regress USB gadget/networking.
- bq27xxx autodetection with the original bq27411 path retained; explicitly record the untested physical bq27411 regression case.
- Full TFA9894 driver/firmware/DTS/UCM chain and the minimal qcom-phone-utils audio fix, with separate firmware provenance.

GPS, call reliability, suspend/resume and camera operation are not promised as fixed. No fingerprint driver is claimed. RFC/WIP status and static checking do not imply device validation.

## Firmware permission

For tfa98xx.cnt, the owner reports that its author permits learning use and has instructed inclusion on that basis. This is a **user-provided learning-use permission statement**, not an independently verified binary license or commercial grant. The source repository LICENSE.txt licenses "this program" under GPLv2; this wording alone does not conclusively establish the firmware binary's rights. Any conflicting declaration must be recorded and resolved before publication.

Other firmware is evaluated separately. The TFA statement is not permission for Qualcomm, OnePlus, NXP or other blobs. Prefer Debian packages with redistribution terms, or documented runtime use of firmware already on the phone, rather than copying unknown Android partition contents into a public image. Preserve applicable notices.

## One formal build, no trial compilation

The eventual workflow is manual workflow_dispatch only: one standard public ubuntu-24.04 job, maximum 360 minutes, no retries. No push, PR or scheduled triggers. Both run_number and run_attempt must equal 1; **even a resource-gate failure must not be rerun**. GitHub Actions has no valid generic retry: 0 YAML key; guards implement that policy. The workflow has 0 runs, so the first dispatch is run #1 and a preflight failure consumes it.

Before any compiler invocation, the same runner must record actual CPU, RAM, disk, KVM, loop and device-mapper capability. Planning gates require four CPUs, 14 GiB observed RAM and 80 GiB free disk. The disk gate is a conservative planning envelope, not a measured build size. The public standard `ubuntu-24.04` runner provides 4 vCPU, 16 GB RAM and a 14 GB SSD, so the 80 GiB gate **cannot pass** there; this is a planning blocker, not evidence that the image fits. Do not lower the gate merely to pass preflight. If actual resources fail, stop without compiling, paying, switching runners or retrying.

`scripts/build-once.sh` is absent, so even a resource pass would fail `scripts/validate-plan.py` before any build. Do not add a placeholder to bypass that gate; the real build entry point must be reviewed first.

This workflow is a locked preparation draft, not authorization to start. The coordinator must first review final source pins, patch status, firmware inventory, public scope and risks, then approve the exact commit. No partial or trial compilation is permitted. Do not flash the phone.

## Intended public delivery

After approval and a successful full build, publish a GitHub Release containing final fajita boot/rootfs images, SHA256 sums, final configuration, firmware notices, build evidence and corresponding GPL source. No Actions artifact/cache uploads are configured. Split any asset reaching 2,000,000,000 bytes, matching `build-plan.json` L16. Do not call an unsuccessful run a complete image or silently discard completed outputs.

## Sources

- [Linux releases](https://www.kernel.org/) and [Mobian qcom-linux branches](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/branches)
- [Debian OnePlus notes](https://wiki.debian.org/InstallingDebianOn/OnePlus/OnePlus6) and [panel contributions](https://ixit.cz/blog/2026-04-03-kernel-7-0-contribution.md)
- [Slider v8](https://lore.kernel.org/all/20251113-op6-tri-state-v8-0-54073f3874bc@ixit.cz/), [C-PHY v2](https://lore.kernel.org/linux-media/20251204-qcom-cphy-v2-0-6b35ef8b071e@ixit.cz/), [TCPM RFC](https://lore.landau.one/lkml/20260926-typec-v1-0-31adc19f32c6@ixit.cz/), [battery v7](https://lkml.rescloud.iu.edu/2610.2/05320.html)
- [TFA background](https://ixit.cz/blog/2022-07-20-OP6T-audio) and [source](https://github.com/J0SH1X/tfa98xx)
- [Runner specifications](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [job limits](https://docs.github.com/en/actions/reference/limits), [Release limits](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)
- [Static patch status](docs/patch-manifest.md), [BTF and packaging findings](docs/btf-and-packaging.md), [runner and resource findings](docs/resource-and-runner.md)

Original orchestration scripts are MIT-licensed. Upstream patches and packaging retain their own author notices/licenses; firmware permissions are separate.
