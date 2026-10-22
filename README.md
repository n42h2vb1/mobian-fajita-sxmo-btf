# Mobian fajita: Sxmo + BTF

Static integration workspace for OnePlus 6T (`fajita`, SDM845): Mobian Trixie, Sxmo/Sway as the only desktop, Linux 7.3 and verified vmlinux BTF. This is a new repository without imported private history.

## Current status

**Static preparation only. No kernel, package or image has been compiled. No phone has been flashed. This is not yet a complete or tested image recipe.** `build-plan.json` deliberately fails closed until integration is checked and the coordinator authorizes the sole formal build. Do not dispatch the workflow now.

The owner has authorized publication of source, workflows, logs **and final system images**. This does not authorize disclosing credentials, unrelated private history or firmware whose terms clearly prohibit distribution.

## Required integration scope

- Rebase Mobian qcom-linux SDM845 7.2 packaging onto Linux 7.3; retain necessary downstream functionality and avoid reapplying upstream features.
- Build only the fajita DTB/boot image; check S6E3FC2X01 panel, TE GPIO, sleep pinctrl, regulators and pn553/nxp-nci NFC support.
- Remove later DEBUG_INFO_NONE overrides, supply pahole, inspect final .config and verify vmlinux BTF. A config fragment alone proves nothing about the binary.
- Sxmo/Sway as the sole default desktop, with the correct service user; prevent sdm845-support from replacing the custom kernel.
- Fajita profile and SensorProxy autorotation/proximity lock, with matching libssc, hexagonrpcd, SLPI and registry dependencies.
- Experimental ABS_SND_PROFILE slider series, GPIO corrections and Sxmo silent/vibrate/ring policy; never hardcode event device numbers.
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

The eventual workflow is manual workflow_dispatch only: one standard public ubuntu-24.04 job, maximum 360 minutes, no retries. No push, PR or scheduled triggers. Both run_number and run_attempt must equal 1; **even a resource-gate failure must not be rerun**. GitHub Actions has no valid generic retry: 0 YAML key; guards implement that policy.

Before any compiler invocation, the same runner must record actual CPU, RAM, disk, KVM, loop and device-mapper capability. Planning gates require four CPUs, 14 GiB observed RAM and 80 GiB free disk. The disk gate is a conservative planning envelope, not a measured build size. GitHub guarantees only 14 GB SSD: if actual resources fail, stop without compiling, paying, switching runners or retrying.

This workflow is a locked preparation draft, not authorization to start. The coordinator must first review final source pins, patch status, firmware inventory, public scope and risks, then approve the exact commit. No partial or trial compilation is permitted. Do not flash the phone.

## Intended public delivery

After approval and a successful full build, publish a GitHub Release containing final fajita boot/rootfs images, SHA256 sums, final configuration, firmware notices, build evidence and corresponding GPL source. No Actions artifact/cache uploads are configured. Split any asset reaching 2 GiB. Do not call an unsuccessful run a complete image or silently discard completed outputs.

## Sources

- [Linux releases](https://www.kernel.org/) and [Mobian qcom-linux branches](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/branches)
- [Debian OnePlus notes](https://wiki.debian.org/InstallingDebianOn/OnePlus/OnePlus6) and [panel contributions](https://ixit.cz/blog/2026-04-03-kernel-7-0-contribution.md)
- [Slider v8](https://lore.kernel.org/all/20251113-op6-tri-state-v8-0-54073f3874bc@ixit.cz/), [C-PHY v2](https://lore.kernel.org/linux-media/20251204-qcom-cphy-v2-0-6b35ef8b071e@ixit.cz/), [TCPM RFC](https://lore.landau.one/lkml/20260926-typec-v1-0-31adc19f32c6@ixit.cz/), [battery v7](https://lkml.rescloud.iu.edu/2610.2/05320.html)
- [TFA background](https://ixit.cz/blog/2022-07-20-OP6T-audio) and [source](https://github.com/J0SH1X/tfa98xx)
- [Runner specifications](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [job limits](https://docs.github.com/en/actions/reference/limits), [Release limits](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)

Original orchestration scripts are MIT-licensed. Upstream patches and packaging retain their own author notices/licenses; firmware permissions are separate.
