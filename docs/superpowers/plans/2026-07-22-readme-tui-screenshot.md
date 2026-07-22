# README TUI Screenshot Plan

## Goal

Replace the hand-drawn Interactive TUI code block in `README.md` with a real image produced from node-monitor's own Bubble Tea/Lip Gloss renderer.

## Requirements

- Render the actual TUI implementation rather than recreating the interface manually.
- Use deterministic, anonymized sample cluster data so the public image does not expose real users, processes, or infrastructure details.
- Preserve the terminal color, Unicode, border, and spacing behavior.
- Store the image in the repository and reference it with a GitHub-compatible relative path.
- Avoid unrelated source-code or formatting changes.

## Steps

1. Inspect the TUI model and available terminal capture/rendering tools.
2. Build a temporary rendering harness that feeds representative sample data into the real TUI renderer.
3. Capture the ANSI output and render it to a high-resolution PNG or SVG.
4. Visually verify text legibility, alignment, colors, and cropping.
5. Add the verified asset under `docs/` and replace the README code block with the image.
6. Run repository tests and validate the README image reference.
7. Record the implementation and verification results in `logs/findings.md` and `logs/progress.md`.

## Expected Repository Changes

- `README.md`
- `docs/assets/node-monitor-tui.png` or `docs/assets/node-monitor-tui.svg`
- `logs/findings.md`
- `logs/progress.md`
- This plan file

Temporary rendering helpers will not remain in the final repository.

## Follow-up

After the image was approved, the temporary capture approach was promoted into the opt-in, deterministic workflow described in `2026-07-22-reproducible-readme-screenshot.md`.
