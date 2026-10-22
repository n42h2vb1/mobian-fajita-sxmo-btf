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

核对完了，我之前确实把“Mobian 7.2.11 补丁包已有的东西”和“Linux 7.3 主线已有的东西”混在了一起。相机、IMX519、C‑PHY、TFA9894 内核驱动都不能再整套重复加；真正卡点是 BTF 配置覆盖、内核打包版本仍写 7.2、TCPM/电量计补丁和 fajita 启动镜像链。

请在 `docs/patch-manifest.md` 末尾追加下面这段，更新完告诉我，我再核对：

## Coverage review of Mobian 7.2.11 packaging

The Mobian qcom-linux candidate already contains the following kernel-side work. Do not import the external series a second time. This is a static inventory only; the complete 164-patch series has not been rebased onto Linux 7.3.

- Camera: `sdm845/0062-...imx519...`, `0065-...oneplus-camera-bringup...`, `0092-...camera-actuat...`, and `0106`–`0114` CAMSS C-PHY patches are already listed in `debian/patches/series`. Reconcile their exact contents against Linux 7.3 before any additional patching. The old external C-PHY series overlaps and one patch conflicts; do not stack it wholesale.
- Speaker: `sdm845/0103-...fajita-Enable-speaker...`, `0104-...TFA98XX...binding...`, and `0105-...support-for-TFA98xx...` already add the TFA9894 DTS, binding and driver. Check the `reset-gpio` vs `reset-gpios` property and DAI cell count mismatch. Firmware `tfa98xx.cnt`, ALSA UCM and the user-reported learning-use permission are separate integration items.
- Mainline already has the OnePlus panel/TE/regulator updates, PN553 NFC node, `oneplus_sdm845` Wi-Fi calibration variant and `ABS_SND_PROFILE` slider event. Verify these in Linux 7.3; do not backport duplicates.
- TCPM: the full PMI8998 Type-C/TCPM RFC series is not in this Mobian patch series. The existing PMI8998 fuel-gauge patch is a different driver.
- Battery: the bq27541 autodetection v7 patch is not in this series. Keep the existing bq27411-compatible path; do not change DTS compatible as a substitute.
- BTF: `debian/rules` applies `debian/config/mobian.config` after the arm64 fragment; the later `CONFIG_DEBUG_INFO_NONE=y` overrides the earlier BTF setting. The build rules also need a `pahole` dependency and a final-config plus `vmlinux` BTF check.
- Packaging/boot: the candidate `debian/rules` still sets `KVER=7.2`; this must be ported to 7.3. Fajita DTB exists upstream, but the Mobian Android boot-image parameters are not yet verified. Patch `mobian/0157-Revert-arm64-dts-qcom-sdm845-oneplus-Update-firmware.patch` restores older `oneplus6` firmware paths, so the first-boot extractor must match the final DTS paths.
