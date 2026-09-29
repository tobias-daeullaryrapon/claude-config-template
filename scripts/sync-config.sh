#!/bin/zsh
# SessionStart hook: fast-forwards this repo from origin. Never commits or pushes.

set -uo pipefail

REPO=${0:A:h:h}
LOCK=/tmp/claude-config-sync.lock
STAMP=/tmp/claude-config-sync.stamp
MAX_AGE=900
LOGDIR=$HOME/Library/Logs/claude-config

export GIT_SSH_COMMAND="ssh -o ConnectTimeout=5 -o BatchMode=yes"
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

mkdir -p "$LOGDIR"
exec >>"$LOGDIR/sync.log" 2>&1

mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

cd "$REPO" 2>/dev/null || { echo "$(date '+%F %T') repo missing"; exit 0; }
[ -d .git ] || { echo "$(date '+%F %T') not a git repo"; exit 0; }

# At most one fetch per MAX_AGE seconds; SYNC_FORCE=1 overrides.
if [ "${SYNC_FORCE:-0}" != "1" ] && [ -f "$STAMP" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$STAMP" 2>/dev/null || stat -c %Y "$STAMP" 2>/dev/null || echo 0) ))
  if [ "$age" -lt "$MAX_AGE" ]; then
    echo "$(date '+%F %T') skipped, synced ${age}s ago"
    exit 0
  fi
fi
touch "$STAMP"

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$branch" != "main" ]; then
  echo "$(date '+%F %T') on branch $branch, skipping"
  exit 0
fi

git fetch -q origin 2>/dev/null || { echo "$(date '+%F %T') fetch failed, offline?"; exit 0; }

behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
ahead=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)

if [ "$behind" -eq 0 ]; then
  echo "$(date '+%F %T') up to date"
  exit 0
fi

# Fast-forward only, and only over a clean tracked tree: CLAUDE.md must never get conflict markers.
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo "$(date '+%F %T') $behind commit(s) behind, but tracked files are modified. Skipping pull."
  echo "  Commit or discard them in $REPO."
  exit 0
fi
if [ "$ahead" -gt 0 ]; then
  echo "$(date '+%F %T') $behind behind and $ahead ahead, diverged. Skipping pull, resolve in $REPO"
  exit 0
fi

if git merge -q --ff-only origin/main 2>&1; then
  echo "$(date '+%F %T') fast-forwarded $behind commit(s), now at $(git rev-parse --short HEAD)"
else
  echo "$(date '+%F %T') fast-forward failed, left at $(git rev-parse --short HEAD). Resolve in $REPO"
fi
