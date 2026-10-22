# Fajita patch inventory — draft

This is a static candidate list only. No patches have been fully rebased, compiled, or tested on hardware. Keep `ready_for_formal_build` false until every item is resolved.

## Base
- Target: Mobian Trixie, OnePlus 6T `fajita` / SDM845, Linux v7.3, SXMO/Sway only, BTF enabled.
- Mobian qcom-linux candidate: `mobian-sdm845-7.2`, commit `78907c8df8475ad4567034ecefca3db67f098a72` (7.2.11-1). Its 164 inherited packaging patches still need a complete static rebase onto v7.3.
- Linux v7.3 tarball checksum and all final immutable source pins are still missing.

## Already upstream: verify, do not duplicate
- Panel/DT: S6E3FC2X01, TE GPIO, sleep pinctrl and regulator commits `c9b98b9dad9749bf2eb7336a6fca31a6af1039d7`, `45d1f42d3e84b5880cf9fab1eb24a7818320eeb7`, `ad33ee060be46794a03d033894c9db3a9d6c1a0f`, `8dda2fecf76b6c4db5f4c1b81a765b73a7a878ed`, `a3da84c36b1a6b80814b5a72ca1546648aba9e75`. Check presence in v7.3 and fajita DT before backporting.
- PN553 NFC: reported included by the Linux 7.2 DTS pull; confirm it is in v7.3, then package `nxp-nci` support if missing.
- Wi-Fi `oneplus_sdm845` calibration variant: already in newer common DTS; confirm it exists, do not add a duplicate.
- Three-position slider kernel events: reportedly already present in v7.3. Verify before adding only the SXMO policy; never hard-code `/dev/input/eventN`.

## Experimental candidates — unresolved
- SXMO: use the fajita-specific device profile and SensorProxy autorotate/proximity scripts; verify Mobian/glibc SensorProxy, libssc, hexagonrpcd, SLPI firmware and sensor registry dependencies.
- Camera: CAMSS SDM845 C-PHY WIP + IMX519 driver + fajita camera graph must match. A patch conflict has been reported; resolve the series revision statically before build. Do not promise autofocus.
- USB-C: use the complete PMI8998 TCPM RFC series, not a DTS-only `dr_mode` change. Sink-only: it does not power peripherals and may affect USB gadget/networking.
- Battery: bq27xxx v7 autodetection remains under review. Preserve the existing bq27411 path and record that the other chip's regression is untested.
- Speaker: TFA9894 driver + `tfa98xx.cnt` + fajita DTS/DAI schema + ALSA UCM are one dependency chain. Owner reports author permits learning use and authorized public image; DTS/DAI and UCM integration remain unresolved. Do not label it commercially licensed.
- BTF: check final `.config` after all fragments and verify BTF in `vmlinux`; a config fragment alone is insufficient. Ensure no later `CONFIG_DEBUG_INFO_NONE=y` override.

## Firmware and release
- Keep unknown modem/DSP and per-device calibration blobs out of the public image; retain first-boot extraction from the user's existing Android partitions and check the new case-sensitive firmware paths.
- Before release, inventory each included firmware file, hash, package/source, applicable notice and redistribution basis. Include corresponding GPL source and SHA256 sums.
- No formal build, workflow dispatch, or phone flashing until all pending items have evidence and the coordinator reviews the exact final commit.
