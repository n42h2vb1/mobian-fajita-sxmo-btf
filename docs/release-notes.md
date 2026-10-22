# Experimental OnePlus 6T (fajita) image

Mobian Trixie with Sxmo/Sway as the sole desktop, Linux 7.3 and build-verified vmlinux BTF. This is an experimental integration, including RFC/WIP components, not a claim of hardware validation or reliable daily operation.

No phone was flashed as part of the build. Do not use an enchilada boot image on fajita. Device unlocking and incorrect partition writes can erase data or prevent boot. No automatic flashing instructions or commands are included in this release.

Read the accompanying final-image-manifest, firmware inventory, configuration, checksums and static audit before use. GPS, calls, suspend/resume, USB roles, camera and speaker behavior may remain partial or regress. The Type-C experiment is sink-only and does not power attached peripherals. No fingerprint support is promised.

The learning-use basis for tfa98xx.cnt is the owner's report of permission from its author. This is not a claim of commercial permission or that the binary is GPL-licensed. Other firmware retains separate terms. Some device-specific firmware and calibration data may need runtime extraction from the user's existing Android partitions; those blobs must not be assumed present in the distributed rootfs.

The corresponding kernel/driver source, build scripts, configuration, upstream notices and patch provenance accompany the images. Debian package copyright notices are preserved in the rootfs.

Every individual asset is below 2 GiB. For a split file, concatenate .part000, .part001 and subsequent numerically ordered parts before decompression/use; verify SHA256SUMS for the downloaded parts first. Checksums establish transfer integrity, not device safety.

A successful build and BTF check are not a successful boot or device-function test.
