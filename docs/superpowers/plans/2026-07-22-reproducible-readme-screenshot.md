# Reproducible README TUI Screenshot Plan

## Goal

Turn the approved README TUI image into a deterministic, repository-owned generation workflow that can be rerun after future releases or visual redesigns.

## Requirements

- Continue to render the real `tui.Model.View()` implementation.
- Keep all fixture data anonymized and deterministic.
- Normalize dynamic header data so repeated renders are byte-identical.
- Pin the external ANSI-to-SVG renderer version.
- Provide simple Make targets for regeneration and freshness checks.
- Keep normal application tests free of generated-file side effects.
- Document the update command in the README.
- Commit the complete README image change as one atomic commit.

## Steps

1. Add an opt-in TUI capture test containing the anonymized fixture.
2. Normalize the clock in the captured frame and force true-color output.
3. Add a rendering script that uses a pinned Freeze version and temporary files.
4. Add `make readme-screenshot` and `make check-readme-screenshot` targets.
5. Document screenshot regeneration in `README.md`.
6. Regenerate twice and verify byte-for-byte determinism.
7. Run all tests, SVG validation, freshness checks, and diff checks.
8. Update project findings and progress logs.
9. Stage the exact files and create one Conventional Commit.

## Expected Repository Changes

- `Makefile`
- `README.md`
- `internal/tui/readme_capture_test.go`
- `scripts/render-readme-tui.sh`
- `docs/assets/node-monitor-tui.svg`
- `logs/findings.md`
- `logs/progress.md`
- This plan file
