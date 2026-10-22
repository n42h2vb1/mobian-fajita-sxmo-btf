# Resource and one-shot runner feasibility

Date: 2026-10-22. Scope: static review of the repository's resource gates and GitHub-hosted runner limits. No workflow was dispatched or rerun, and no compiler was invoked.

## Repository gates

- `scripts/runner-preflight.sh` requires at least 4 CPUs, 14 GiB RAM and 80 GiB free disk ([preflight L30](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/scripts/runner-preflight.sh#L30)); it exits before compilation if any gate fails ([L33-L34](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/scripts/runner-preflight.sh#L33)).
- The same script hard-requires `/dev/kvm`, `/dev/loop-control` and `/dev/mapper/control` and checks KVM API version 12 ([preflight L36-L53](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/scripts/runner-preflight.sh#L36)). A standard runner is not guaranteed to expose KVM, so this is a second feasibility risk after the disk gate.
- The workflow is `workflow_dispatch` only ([final-build.yml L3-L4](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/.github/workflows/final-build.yml#L3)) and uses one `ubuntu-24.04` job with a 360-minute timeout ([L18-L19](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/.github/workflows/final-build.yml#L18)).
- The first step requires `GITHUB_RUN_ATTEMPT == 1` and `GITHUB_RUN_NUMBER == 1` ([final-build.yml L33](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/.github/workflows/final-build.yml#L33)); the preflight repeats the same guard ([preflight L9-L10](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/scripts/runner-preflight.sh#L9)). A failed preflight therefore consumes run #1 and cannot be retried under this design.
- `scripts/validate-plan.py` requires `ready_for_formal_build=true`, all `static_audit` entries to be `integrated-static-checked` or `already-upstream-static-checked`, `formal_build_start=true`, and the presence of `scripts/build-once.sh` ([validate-plan.py L10-L25](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/scripts/validate-plan.py#L10)). The workflow also invokes `scripts/build-once.sh` ([final-build.yml L52](https://github.com/n42h2vb1/mobian-fajita-sxmo-btf/blob/main/.github/workflows/final-build.yml#L52)).
- At audit time `build-plan.json` had `ready_for_formal_build=false`, 12 `pending` audit entries, and `formal_build_start=false`; `scripts/build-once.sh` is absent. These are the current blockers, not values to flip in a documentation pass.

## GitHub-hosted runner facts

- The public standard `ubuntu-24.04` runner is documented as 4 vCPU, 16 GB RAM and a 14 GB SSD, with a 6-hour job limit ([GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [job limits](https://docs.github.com/en/actions/reference/limits)).
- The 80 GiB free-disk gate therefore cannot pass on that runner. The gate is a conservative planning envelope, not a measured build size. Lowering it merely to pass preflight would not establish that a full kernel, packages and images fit; a measured build plan or a different approved resource model is required.
- The workflow's 360-minute timeout is below the 6-hour hosted-runner maximum but leaves no room for a retry. A resource-gate failure is intentionally not retried.

## Consequence

Do not dispatch the workflow. Resolve the resource model before the single formal run: either measure a full build on a suitable host and record the actual peak disk/RAM, or revise the approved plan without weakening the first-run guard. The documentation branch that contains this file is not a build trigger; the only workflow is `workflow_dispatch`-only.

All measurements and any revision of the 80 GiB/KVM gates remain `pending`.
