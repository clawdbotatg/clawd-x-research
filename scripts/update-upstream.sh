#!/usr/bin/env bash
# (Re)fetch the upstream X algorithm and pin its commit SHA.
# xAI updates the public repo ~every 4 weeks; run this to refresh and diff.
set -euo pipefail
cd "$(dirname "$0")/.."

UPSTREAM_REPO="https://github.com/xai-org/x-algorithm.git"

if [ -d upstream/.git ]; then
  echo "updating existing upstream..."
  git -C upstream fetch --depth 1 origin
  git -C upstream reset --hard origin/HEAD
else
  rm -rf upstream
  echo "cloning $UPSTREAM_REPO ..."
  git clone --depth 1 "$UPSTREAM_REPO" upstream
fi

SHA=$(git -C upstream rev-parse HEAD)
DATE=$(git -C upstream log -1 --format=%ci)
printf 'repo: xai-org/x-algorithm\ncommit: %s\ndate: %s\nfetched_into: ./upstream\n' \
  "$SHA" "$DATE" > UPSTREAM_VERSION

echo
echo "pinned:"
cat UPSTREAM_VERSION
