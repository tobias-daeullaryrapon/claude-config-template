#!/bin/zsh
# PostToolUse (Write|Edit) hook: asks Claude to commit and push when an edit lands in this repo.
set -euo pipefail

REPO=${0:A:h:h}

input="$(cat)"
# Write returns tool_response as a plain string, so a failed index must not abort under set -e.
raw_path="$(jq -r '.tool_response.filePath? // .tool_input.file_path? // empty' <<< "$input")"
[ -z "$raw_path" ] && exit 0

resolved="$(realpath "$raw_path" 2>/dev/null || true)"
[ -z "$resolved" ] && exit 0

case "$resolved" in
  "$REPO"/*) ;;
  *) exit 0 ;;
esac

git_status="$(git -C "$REPO" status --porcelain 2>/dev/null || true)"
[ -z "$git_status" ] && exit 0

reason="The agent configuration repo has uncommitted changes after editing $resolved. Per CLAUDE.md's Agent configuration repo rule, commit and push this now with a real descriptive message (git -C $REPO add/commit/push)."
jq -n --arg reason "$reason" '{continue: true, hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $reason}}'
