# Firmware and redistribution inventory

This is a static policy inventory, not a claim that every runtime firmware file has been located or tested. The final build must also preserve the installed packages' per-file copyright notices and produce an actual filename/hash/package inventory.

## TFA9894 speaker

Source: [J0SH1X/tfa98xx](https://github.com/J0SH1X/tfa98xx), linked as the required firmware by [the iXit audio article](https://ixit.cz/blog/2022-07-20-OP6T-audio). Driver code and firmware are distinct works.

The repository LICENSE.txt states that "this program" is licensed under GPLv2. It does not explicitly identify tfa98xx.cnt. The binary was introduced separately as a needed firmware blob, without a separate embedded license. No conflicting declaration was found in the reviewed public material, but this is not proof of an unrestricted firmware grant.

The owner reports author permission for learning use and explicitly instructed integration on that basis. Record that statement as the basis for this learning image; do not label the firmware GPL merely because the driver is GPL, and do not claim commercial permission. Preserve the exact upstream commit, download URL and SHA256 in the source lock. Do not extend this statement to any other firmware.

## Debian-distributed firmware

Debian firmware-qcom-soc, firmware-qcom-dsp and firmware-atheros may provide applicable files, but package names are not a blanket license. Only use files genuinely belonging to the installed package and covered by its own per-file license entries. Preserve /usr/share/doc/<package>/copyright and the relevant license texts in the rootfs and accompanying notices.

Qualcomm/Atheros entries may permit unmodified binary redistribution for use with their chips, with copyright/disclaimer retention and restrictions on modification or reverse engineering. These terms do not automatically cover a OnePlus-specific file sharing the same basename.

Primary reference: [Debian firmware-nonfree copyright](https://metadata.ftp-master.debian.org/changelogs//non-free-firmware/f/firmware-nonfree/firmware-nonfree_20250410-2_copyright). The actual package versions selected for the final rootfs must be inventoried rather than assumed from this example version.

## Device-resident OnePlus/Qualcomm firmware

Do not copy unknown Android partition blobs into the public image. Preserve the droid-juicer runtime extraction chain for firmware/calibration already present on the user's phone. Missing extraction inputs must be reported explicitly; excluding redistribution must not silently disable the sensor, modem, GPU or audio integration.

[Mobian's fajita configuration](https://gitlab.com/mobian1/droid-juicer/-/blob/master/configs/oneplus%2Cfajita.toml) describes extraction from vendor, modem, bluetooth, dsp and persist partitions. Relevant categories include:

| Category | Runtime requirement | Public-image rule |
|---|---|---|
| A630 ZAP / IPA | Device-specific signed firmware | Extract at runtime unless an exact Debian-covered file is used |
| ADSP / CDSP / SLPI | Remoteproc and sensors/audio DSP firmware | Do not bundle unknown Android blobs |
| MBA / modem / WLAN DSP / Venus | Modem, radio and video firmware | Keep separate provenance; runtime extraction where required |
| Wi-Fi/BT calibration and firmware | crnv21.bin, crbtfw21.tlv and related data | Do not substitute generic package licenses for device files |
| Sensors registry/calibration / ACDB | DSP sensor registry and audio calibration | Device-local extraction; never publish a user's persist data |
| tfa98xx.cnt | Speaker DSP container | Only the separate user-reported learning-use basis above applies |

The extraction configuration historically uses qcom/sdm845/oneplus6 and qca/oneplus6. New kernel DTS paths use case-sensitive qcom/sdm845/OnePlus/enchilada and qca/OnePlus/enchilada. Check the exact target DTS and implement the mapping in the extraction/boot path, including early-initramfs GPU needs. A path-only mismatch can look like missing driver support.

Sources: [Debian device notes](https://wiki.debian.org/InstallingDebianOn/OnePlus/OnePlus6), [droid-juicer](https://gitlab.com/mobian1/droid-juicer), [qcom-support metadata](https://salsa.debian.org/Mobian-team/devices/qcom-support/-/raw/mobian/debian/control).

## Support software is not firmware permission

qcom-support is a metapackage; droid-juicer extracts from device partitions to avoid redistributing proprietary blobs. The reviewed source licenses are qcom-support GPL-3+, droid-juicer MIT, libssc GPLv3, and hexagonrpcd/sensh GPL-3+. Preserve their original notices. These software licenses do not relicense the firmware, registry or calibration files they load.

## Release checks

Before a public release: inventory every installed firmware file, its SHA256, owning package or external source, applicable notice and redistribution basis. Reject unexplained Android blobs and personal persist/calibration copies. Include the final inventory and notices alongside corresponding source. No automatic publication is permitted while this audit remains incomplete.
