# Swift-Only Backport Ledger

Base: `6fde9b910a6dd531eeaf3892499729120ae75f49`
Source range: `6fde9b9..origin/main`

This branch is a selective Swift-only backport. It must not import Zig source,
`COmniWMKernels`, Zig build plumbing, kernel ABI tests, or current-main kernel
adapter code.

## Prerequisites

- Create this work in an isolated worktree rooted at the base commit.
- Keep `Frameworks/GhosttyKit.xcframework/macos-arm64_x86_64/libghostty.a`
  available locally.
- `Scripts/ghostty-preflight.sh verify` must pass before `make build`,
  `make test`, or `make verify`.

## Buckets

- `direct-dry-run`: eligible for `merge-tree`/`cherry-pick --no-commit`, then audit.
- `swift-contextual`: Swift-only file list, but likely needs semantic review.
- `settings-final-state`: manual TOML/config port, not a JSON-then-TOML cherry-pick.
- `mixed-investigate-only`: only write a targeted Swift-native patch if the bug reproduces.
- `zig-build-skip`: Zig/kernel/build surface; skip.
- `merge-release-doc-skip`: merge, release, or nonessential docs/media churn.

## Record Template

```text
Commit:
Original subject:
Touched Swift files:
Touched Zig/build files:
Bug reproducible on 6fde9b9? yes/no/unknown
Tests added or updated:
Action: direct-dry-run / swift-contextual / settings-final-state / mixed-investigate-only / zig-build-skip / merge-release-doc-skip
Reason:
Backport commit:
```

## Records

Records are added as commits are accepted, skipped, or manually translated.
