#!/usr/bin/env bash

set -euo pipefail

mode="${1:-write}"
if [[ "$mode" != "write" && "$mode" != "--check" ]]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
interactive_asset_path="$repo_root/docs/assets/node-monitor-tui.svg"
static_asset_path="$repo_root/docs/assets/node-monitor-static.svg"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/node-monitor-readme.XXXXXX")"
interactive_capture_path="$work_dir/node-monitor-tui.ansi"
static_capture_path="$work_dir/node-monitor-static.ansi"
interactive_render_path="$work_dir/node-monitor-tui.svg"
static_render_path="$work_dir/node-monitor-static.svg"

cleanup() {
  rm -f -- \
    "$interactive_capture_path" \
    "$static_capture_path" \
    "$interactive_render_path" \
    "$static_render_path"
  rmdir "$work_dir" 2>/dev/null || true
}
trap cleanup EXIT

cd "$repo_root"

NODE_MONITOR_README_CAPTURE="$interactive_capture_path" \
  go test ./internal/tui -run '^TestRenderReadmeCapture$' -count=1

NODE_MONITOR_STATIC_README_CAPTURE="$static_capture_path" \
  go test ./cmd -run '^TestRenderStaticReadmeCapture$' -count=1

render_svg() {
  local capture_path="$1"
  local render_path="$2"

  go run github.com/charmbracelet/freeze@v0.2.2 \
    -c full \
    --font.family 'JetBrains Mono, SFMono-Regular, Menlo, Consolas, Apple Color Emoji, Segoe UI Emoji, monospace' \
    --font.size 15 \
    --line-height 1.2 \
    -o "$render_path" \
    < "$capture_path"
}

render_svg "$interactive_capture_path" "$interactive_render_path"
render_svg "$static_capture_path" "$static_render_path"

if [[ "$mode" == "--check" ]]; then
  check_failed=0
  if ! cmp -s "$interactive_render_path" "$interactive_asset_path"; then
    echo "README interactive screenshot is out of date." >&2
    check_failed=1
  fi
  if ! cmp -s "$static_render_path" "$static_asset_path"; then
    echo "README static screenshot is out of date." >&2
    check_failed=1
  fi
  if [[ "$check_failed" -ne 0 ]]; then
    echo "Run: make readme-screenshot" >&2
    exit 1
  fi
  echo "README screenshots are up to date."
  exit 0
fi

mkdir -p "$(dirname "$interactive_asset_path")"
mv "$interactive_render_path" "$interactive_asset_path"
mv "$static_render_path" "$static_asset_path"
echo "Updated README screenshots in docs/assets."
