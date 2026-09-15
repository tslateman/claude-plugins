#!/bin/sh
set -eu

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
manifest="$repo_root/.claude-plugin/marketplace.json"

schema_url="$(grep -o '"\$schema"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" | sed -E 's/.*"([^"]+)"$/\1/' || true)"

if [ -z "$schema_url" ]; then
  echo "no \$schema field present; nothing to validate"
  exit 0
fi

status="$(curl -sL -o /dev/null -w '%{http_code}' "$schema_url")"

if [ "$status" != "200" ]; then
  echo "FAIL: \$schema URL $schema_url returned HTTP $status (expected 200)"
  exit 1
fi

echo "PASS: \$schema URL $schema_url returned HTTP 200"
