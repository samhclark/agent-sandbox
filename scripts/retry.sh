#!/usr/bin/env bash
# Retry a command up to 5 times with a 15s backoff. Guards image builds
# against transient network failures (e.g. upstream HTTP 504) in the
# vendored installer scripts.
set -euo pipefail

for attempt in 1 2 3 4 5; do
    if "$@"; then
        exit 0
    fi
    echo "attempt ${attempt} failed: $* — retrying in 15s" >&2
    sleep 15
done

echo "command failed after 5 attempts: $*" >&2
exit 1
