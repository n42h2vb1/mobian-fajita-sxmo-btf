# Experimental OnePlus 6T (fajita) image

Mobian Trixie with Sxmo/Sway as the sole desktop and Linux 7.3. BTF is a required build-time gate; no build or BTF verification has been performed, so this note is a template rather than a completed-image announcement. This is an experimental integration, including RFC/WIP components, not a claim of hardware validation or reliable daily operation.

No phone has been flashed. Do not use an enchilada boot image on fajita. Device unlocking and incorrect partition writes can erase data or prevent boot. No automatic flashing instructions or commands are included in this release.

Read the accompanying final-image-manifest, firmware inventory, configuration, checksums and static audit before use. GPS, calls, suspend/resume, USB roles, camera and speaker behavior may remain partial or regress. The intended Type-C experiment is sink-only and would not power attached peripherals; the required PMI8998 TCPM series is not present, so that work remains pending. No fingerprint support is promised.

The learning-use basis for tfa98xx.cnt is the owner's report of permission from its author. This is not a claim of commercial permission or that the binary is GPL-licensed. Other firmware retains separate terms. Some device-specific firmware and calibration data may need runtime extraction from the user's existing Android partitions; those blobs must not be assumed present in the distributed rootfs.

The corresponding kernel/driver source, build scripts, configuration, upstream notices and patch provenance must accompany the images. These artifacts have not yet been generated; Debian package copyright notices must be preserved in the rootfs.

Every individual asset must remain below 2,000,000,000 bytes, matching `build-plan.json` L16. For a split file, concatenate .part000, .part001 and subsequent numerically ordered parts before decompression/use; verify SHA256SUMS for the downloaded parts first. Checksums establish transfer integrity, not device safety.

A successful build and BTF check are not a successful boot or device-function test.

**Template status (2026-10-22):** no build exists. `build-plan.json` has `ready_for_formal_build=false` (L3) and `formal_build_start=false` (L8), and all 12 static audit entries are `pending` (L17-L29). Do not publish this text as a release announcement until the build, BTF assertion and image manifest exist.
