# Static Mode README Screenshot Plan

## Goal

Replace the hand-written Static mode (`-s`) output in `README.md` with an SVG generated from the real static renderer, and extend the existing deterministic screenshot workflow to maintain both README images together.

## Requirements

- Call the real static rendering path instead of reproducing its formatting.
- Reuse the same anonymized fixture as the interactive TUI screenshot.
- Keep both images deterministic and covered by the existing generation and freshness-check commands.
- Preserve the current runtime output of `node-monitor -s`.
- Avoid unrelated formatting or behavior changes.

## Steps

1. Move the shared anonymized nodes into an internal test-fixture package.
2. Extract the static renderer's writer target so tests can capture output without changing CLI behavior.
3. Add an opt-in static capture test with a normalized clock.
4. Extend `scripts/render-readme-tui.sh` to render and check both SVG assets.
5. Replace the README Static mode code block with the generated image and update regeneration wording.
6. Regenerate twice and verify both assets are byte-identical.
7. Visually inspect the static SVG and run all automated checks.
8. Update findings and progress logs.

## Expected Repository Changes

- `README.md`
- `cmd/root.go`
- `cmd/readme_capture_test.go`
- `internal/testfixture/readme.go`
- `internal/tui/readme_capture_test.go`
- `scripts/render-readme-tui.sh`
- `docs/assets/node-monitor-static.svg`
- `logs/findings.md`
- `logs/progress.md`
- This plan file
