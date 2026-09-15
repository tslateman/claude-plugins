#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

fail=0

plugins=$(jq -c '.plugins[]' .claude-plugin/marketplace.json)

echo "$plugins" | while IFS= read -r plugin; do
  name=$(echo "$plugin" | jq -r '.name')
  desc=$(echo "$plugin" | jq -r '.description')
  url=$(echo "$plugin" | jq -r '.source.url')
  repo=$(echo "$url" | sed -E 's#^https://github.com/##; s#\.git$##')

  archived=$(gh api "repos/$repo" --jq .archived)
  if [ "$archived" != "false" ]; then
    echo "FAIL: $name ($repo) is archived on GitHub"
    exit 1
  fi

  claimed=$(echo "$desc" | grep -oE '[0-9]+ .*skills' | grep -oE '^[0-9]+' || true)
  if [ -n "$claimed" ]; then
    branch=$(gh api "repos/$repo" --jq .default_branch)
    actual=$(gh api "repos/$repo/git/trees/$branch?recursive=1" \
      --jq '[.tree[] | select(.path | test("^skills/[^/]+/SKILL.md$"))] | length')
    if [ "$claimed" != "$actual" ]; then
      echo "FAIL: $name claims $claimed skills, repo has $actual"
      exit 1
    fi
  fi
done
