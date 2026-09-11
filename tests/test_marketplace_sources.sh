#!/bin/sh
set -eu

root_dir="$(cd "$(dirname "$0")/.." && pwd)"
marketplace="$root_dir/.claude-plugin/marketplace.json"

urls=$(jq -r '.plugins[].source.url' "$marketplace")

status=0
for url in $urls; do
  if GIT_TERMINAL_PROMPT=0 git -c credential.helper= ls-remote "$url" >/dev/null 2>&1; then
    echo "OK   $url"
  else
    echo "FAIL $url"
    status=1
  fi
done

exit $status
