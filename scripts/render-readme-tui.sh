#!/usr/bin/env bash

set -euo pipefail

mode="${1:-write}"
if [[ "$mode" != "write" && "$mode" != "--check" ]]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
asset_path="$repo_root/docs/assets/node-monitor-tui.svg"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/node-monitor-readme.XXXXXX")"
capture_path="$work_dir/node-monitor-tui.ansi"
render_path="$work_dir/node-monitor-tui.svg"

cleanup() {
  rm -f -- "$capture_path" "$render_path"
  rmdir "$work_dir" 2>/dev/null || true
}
trap cleanup EXIT

cd "$repo_root"

NODE_MONITOR_README_CAPTURE="$capture_path" \
  go test ./internal/tui -run '^TestRenderReadmeCapture$' -count=1

go run github.com/charmbracelet/freeze@v0.2.2 \
  -c full \
  --font.family 'JetBrains Mono, SFMono-Regular, Menlo, Consolas, Apple Color Emoji, Segoe UI Emoji, monospace' \
  --font.size 15 \
  --line-height 1.2 \
  -o "$render_path" \
  < "$capture_path"

if [[ "$mode" == "--check" ]]; then
  if ! cmp -s "$render_path" "$asset_path"; then
    echo "README TUI screenshot is out of date; run: make readme-screenshot" >&2
    exit 1
  fi
  echo "README TUI screenshot is up to date."
  exit 0
fi

mkdir -p "$(dirname "$asset_path")"
mv "$render_path" "$asset_path"
echo "Updated docs/assets/node-monitor-tui.svg"
