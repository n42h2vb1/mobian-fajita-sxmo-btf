# BTF and kernel packaging — verified static findings

Date: 2026-10-22. Scope: Mobian qcom-linux candidate `78907c8df8475ad4567034ecefca3db67f098a72` and Linux v7.3. No build, config generation, workflow dispatch, or hardware test was performed.

## Verified facts

1. **Packaging is still 7.2.** `debian/rules` L8 sets `KVER=7.2` ([rules L8](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/rules#L8)); the generated package names remain `linux-image-7.2-sdm845` and `linux-headers-7.2-sdm845` ([control L22](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/control#L22), [L33](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/control#L33)). Replacing only the Linux tarball does not change these names.
2. **Later config fragments win.** `debian/rules` L38-L42 lists `debian.config`, `debian.arm64.config`, `mobian.config`, then `sdm845.config`; L46-L48 concatenates them in that order and runs `olddefconfig` ([rules L38-L48](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/rules#L38)).
3. **The candidate requests BTF and then disables debug info.** `debian/config/debian.arm64.config` L2646 sets `CONFIG_DEBUG_INFO_BTF=y` ([arm64 config L2646](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/config/debian.arm64.config#L2646)); `debian/config/mobian.config` L28 sets `CONFIG_DEBUG_INFO_NONE=y` later in the concatenation ([mobian config L28](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/config/mobian.config#L28)). With this order, the final config cannot produce the requested BTF.
4. **Kconfig gates BTF on debug info and pahole.** In v7.3, `DEBUG_INFO_BTF` is inside `if DEBUG_INFO` ([Kconfig.debug L325](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/Kconfig.debug?h=v7.3#n325)) and depends on `PAHOLE_VERSION >= 122` ([Kconfig.debug L398-L403](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/lib/Kconfig.debug?h=v7.3#n398)). A `CONFIG_DEBUG_INFO_BTF=y` line alone is insufficient.
5. **The build dependency list does not name pahole.** `debian/control` L4-L16 lists the Build-Depends and does not include `pahole`, `dwarves`, or `bpftool` ([control L4-L16](https://salsa.debian.org/Mobian-team/devices/kernels/qcom-linux/-/blob/78907c8df8475ad4567034ecefca3db67f098a72/debian/control#L4)). Whether the chosen build environment happens to provide pahole is not pinned.

Consequence: the current candidate cannot be described as producing vmlinux BTF. `README.md` and `docs/release-notes.md` have been corrected to call BTF a required build-time gate, not a completed result.

## Minimal static fix (not applied here)

This repository does not carry the Mobian packaging tree and must not add a placeholder build script. The fix belongs on the Mobian branch and must be reviewed there:

- Remove or supersede `CONFIG_DEBUG_INFO_NONE=y` in `debian/config/mobian.config` so the final config has `CONFIG_DEBUG_INFO=y` and `CONFIG_DEBUG_INFO_BTF=y`, with `DEBUG_INFO_NONE` not selected.
- Keep the BTF setting after any debug-info mode selection, or reorder the fragments so no later fragment disables debug info.
- Add an explicit `pahole`/`dwarves` Build-Depends entry with a version satisfying `PAHOLE_VERSION >= 122`.
- Bump `KVER` to 7.3 and regenerate the templated `debian/control`, `debian/changelog`, `debian/copyright`, `debian/gbp.conf` and `debian/watch` files rather than hand-editing generated names only.
- Rebase the 164-patch series and resolve the camera/TFA path before claiming the config is buildable.

## Verification still pending

All of the following are `pending`; none was run:

- Apply the static fix to the Mobian branch and complete the 164-patch rebase.
- Run `olddefconfig` (or the packaging equivalent) and inspect the final `.config`.
- Build the kernel and run the project's BTF assertion against `vmlinux`.
- Verify the resulting `linux-image-7.3-sdm845`/headers package names and the fajita boot image.
- Boot on hardware; BTF presence is not a boot or device-function test.
