# Mobian fajita: Sxmo + BTF

Static integration workspace for OnePlus 6T (`fajita`, SDM845). Target: Mobian Trixie, Sxmo/Sway as the only desktop, Linux 7.3 with verified vmlinux BTF. This is a new repository, not an import of another repository or its history.

## Current status

Preparation only. No kernel, package or image has been compiled. No device has been flashed. This repository is NOT a working or tested image recipe yet. Candidate research is not proof of successful integration.

## Required integration scope

- Audit the Mobian qcom-linux 7.2 packaging branch against Linux 7.3; do not reapply features already upstream.
- Fajita-only DTB/boot image; S6E3FC2X01 panel, TE GPIO, sleep pinctrl, regulators and NFC pn553/nxp-nci.
- Enable DWARF/BTF after removing later DEBUG_INFO_NONE overrides; require pahole, final .config and vmlinux .BTF validation.
- Sxmo-only boot/session and correct service user; prevent sdm845-support from replacing the custom kernel.
- Fajita Sxmo profile; SensorProxy autorotation/proximity; matching libssc, hexagonrpcd, SLPI and registry dependencies.
- Experimental ABS_SND_PROFILE alert-slider v8 with GPIO corrections and device discovery (no hardcoded event number).
- Check existing oneplus_sdm845 Wi-Fi calibration; do not duplicate.
- Experimental SDM845 CAMSS C-PHY v2, IMX519 and correct camera graph; match libcamera dependencies.
- Experimental full PMI8998 TCPM sink-only RFC and Fajita DTS, not a dr_mode-only change. This does not supply power to peripherals and may break USB gadget/networking.
- Experimental bq27xxx autodetection v7; preserve bq27411 support.
- TFA9894 needs the complete downstream driver, firmware, DTS and UCM chain. Firmware redistribution permission is not established; do not bundle tfa98xx.cnt.
- Audit the minimal qcom-phone-utils audio fix. Do not claim a proven GPS, suspend or call fix. No fingerprint driver is promised.

## Safety and publication

Only public source, provenance, patches, configuration and workflow text may be committed. Do not commit credentials, personal data, firmware blobs, kernel binaries, root filesystems or images. Public Actions logs are public. Final images have NOT been authorized for public distribution. No Releases or Actions artifact uploads are configured. A private delivery/retention method must be agreed BEFORE compilation, because hosted-runner storage is ephemeral. Firmware licensing is a separate requirement and cannot be solved merely by encrypting an upload.

The single eventual build must be manually dispatched, use only a standard free public Linux runner, stay within six hours, record actual disk/RAM/CPU/KVM/loop/device-mapper resources in the same job before compilation, and stop if prerequisites fail. No automatic retries, push/PR/scheduled runs, partial builds or trial compilations. GitHub Actions has no general retry: 0 workflow key; a run_attempt guard is required instead. Rerunning a failed build is prohibited. Do not dispatch before the complete static audit, delivery decision and explicit go-ahead.

## Source starting points

- [Linux releases](https://www.kernel.org/)
- [Mobian qcom-linux branches](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/branches)
- [Debian OnePlus 6/6T notes](https://wiki.debian.org/InstallingDebianOn/OnePlus/OnePlus6)
- [Panel/mainline contributions](https://ixit.cz/blog/2026-04-03-kernel-7-0-contribution.md)
- [Slider v8](https://lore.kernel.org/all/20251113-op6-tri-state-v8-0-54073f3874bc@ixit.cz/)
- [C-PHY v2](https://lore.kernel.org/linux-media/20251204-qcom-cphy-v2-0-6b35ef8b071e@ixit.cz/)
- [Type-C RFC](https://lore.landau.one/lkml/20260926-typec-v1-0-31adc19f32c6@ixit.cz/)
- [Battery v7](https://lkml.rescloud.iu.edu/2610.2/05320.html)
- [TFA9894 background](https://ixit.cz/blog/2022-07-20-OP6T-audio)
