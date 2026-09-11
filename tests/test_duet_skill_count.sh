#!/bin/sh
set -eu

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

marketplace_count=$(jq -r '.plugins[] | select(.name=="duet") | .description' \
  "$repo_root/.claude-plugin/marketplace.json" \
  | grep -oE '[0-9]+ framework-grounded skills' | grep -oE '^[0-9]+')

readme_count=$(grep -oE 'duet.*[0-9]+ framework-grounded skills' "$repo_root/README.md" \
  | grep -oE '[0-9]+ framework-grounded skills' | grep -oE '^[0-9]+')

upstream_count=$(gh api "repos/tslateman/duet/git/trees/HEAD?recursive=1" \
  --jq '.tree[] | select(.path | test("^skills/[^/]+/SKILL\\.md$")) | .path' | wc -l | tr -d ' ')

if [ "$marketplace_count" != "$upstream_count" ]; then
  echo "FAIL: marketplace.json advertises $marketplace_count skills, upstream duet has $upstream_count"
  exit 1
fi

if [ "$readme_count" != "$upstream_count" ]; then
  echo "FAIL: README.md advertises $readme_count skills, upstream duet has $upstream_count"
  exit 1
fi

echo "OK: duet skill count ($upstream_count) matches marketplace.json and README.md"
