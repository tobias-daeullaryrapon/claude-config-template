#!/bin/zsh
# Weekly reconciliation of memory/ against CLAUDE.md. Opens a PR when something changed, a GitHub
# issue when the run fails. Claude only edits files; git and gh run here.

set -uo pipefail

REPO=${0:A:h:h}
CLAUDE_DIR=$HOME/.claude
MEMORY_LINK=""
CONSOLIDATION_MODEL=opus
[ -f "$REPO/local.env" ] && . "$REPO/local.env"

export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

RUN=$(date +%Y-%m-%d)
LOGDIR=$HOME/Library/Logs/claude-memory-consolidation
WORK=$(mktemp -d /tmp/memcon.XXXXXX)
mkdir -p "$LOGDIR"
exec >>"$LOGDIR/$RUN.log" 2>&1
trap 'rm -rf "$WORK"' EXIT

echo "=== run $(date '+%Y-%m-%d %H:%M:%S %Z') ==="

alert() {
  local title=$1 body=$2 url
  echo "ALERT: $title"
  echo "$body"
  url=$(cd "$REPO" && gh issue create --title "$title" --body "$body" 2>&1 | grep -oE 'https://github.com/[^ ]+/issues/[0-9]+')
  if [ -n "$url" ]; then echo "failure issue opened: $url"; else echo "WARN: could not open a failure issue"; fi
}

# 1. Relink anything an atomic write replaced with a real file; that copy is newer, so it wins.
HEALED=0
heal() {
  local link=$1 target=$2
  if [ -L "$link" ]; then return 0; fi
  if [ -e "$link" ]; then
    echo "DETACHED: $link is a real path, folding its content into $target"
    if [ -d "$link" ]; then cp -R "$link/." "$target/"; else cp "$link" "$target"; fi
    rm -rf "$link"
    HEALED=1
  fi
  ln -s "$target" "$link"
  echo "relinked $link -> $target"
}
heal "$CLAUDE_DIR/CLAUDE.md" "$REPO/CLAUDE.md"
heal "$CLAUDE_DIR/skills"    "$REPO/skills"
heal "$CLAUDE_DIR/hooks"     "$REPO/hooks"
[ -n "$MEMORY_LINK" ] && heal "$MEMORY_LINK" "$REPO/memory"

cd "$REPO" || { alert "Memory consolidation failed to start" "Cannot cd into $REPO."; exit 1; }

# 2. Sync main, committing any stray local edits first.
git checkout -q main || { alert "Memory consolidation failed to start" "Cannot check out main in $REPO."; exit 1; }
if [ -n "$(git status --porcelain)" ]; then
  if [ "$HEALED" -eq 1 ]; then
    MSG="chore: restore content from a detached symlink"
  else
    MSG="chore: sync local config changes written since the last run"
  fi
  echo "committing to main: $MSG"
  git add -A && git commit -q -m "$MSG"
fi
if ! git pull -q --rebase --autostash; then
  git rebase --abort 2>/dev/null
  git stash pop 2>/dev/null
  echo "FATAL: could not rebase local main onto origin/main"
  alert "Memory consolidation $RUN aborted on a rebase conflict" "Local main will not rebase onto origin/main. Nothing was changed. Resolve by hand in $REPO."
  exit 1
fi
git push -q origin main 2>/dev/null || true

# 3. Fresh branch; a same-day re-run gets a time suffix.
BRANCH="memory-consolidation/$RUN"
if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
  BRANCH="$BRANCH-$(date +%H%M)"
  echo "branch for today already on origin, using $BRANCH"
fi
git branch -D "$BRANCH" >/dev/null 2>&1
git checkout -q -b "$BRANCH" || { alert "Memory consolidation $RUN failed" "Cannot create branch $BRANCH."; exit 1; }

BODY="$WORK/pr-body.md"
SUMMARY="$WORK/summary.txt"

read -r -d '' PROMPT <<EOF
You are maintaining this repo, a personal Claude Code configuration checkout. Your working directory is its root.

Layout:
- CLAUDE.md is the global instruction file loaded into every Claude Code session on this machine.
- memory/ holds one fact per file, each with YAML frontmatter (name, description, metadata.type of user | feedback | project | reference).
- memory/MEMORY.md is the index loaded into every session: one line per memory, format "- [Title](file.md) - hook". It holds no memory content itself.
- skills/, hooks/, launchd/ and scripts/ are NOT your concern. Do not modify them.

Reconcile memory/ against CLAUDE.md in five passes.

1. PROMOTE. A memory whose guidance applies to every project, not only one project, belongs in CLAUDE.md, not in memory/. For each: add it to the most appropriate existing CLAUDE.md section in that section's voice and brevity, delete the memory file, and delete its line from memory/MEMORY.md. Prefer extending an existing rule over adding a bullet. Do not create new top-level sections unless nothing fits.

2. CHALLENGE. Where a memory contradicts a rule already in CLAUDE.md, do not silently pick a winner. Quote both in the PR body, say which is newer and what evidence each carries, and propose which should win and why. Make the edit only where the memory is clearly both newer and evidence-backed. Leave the rest as open questions.

3. PRUNE. A memory whose own text records the problem as resolved, shipped, merged or verified is a deletion candidate. Propose removal and quote the line saying it is done. Keep any memory that is a regression guard against a real past failure, even if that failure is fixed.

4. INDEX HYGIENE. Every file in memory/ except MEMORY.md must have exactly one MEMORY.md line. No MEMORY.md line may point at a missing file. Every [[wikilink]] should resolve to an existing memory's name: slug. List unresolved ones in the PR body rather than deleting them, since an unresolved link can legitimately mark something not yet written.

5. INVARIANT. memory/MEMORY.md opens by stating that global preferences live in ~/.claude/CLAUDE.md and that these memories are project-specific only. Your changes must leave that true.

Writing constraints:
- English only.
- Never use an em-dash.
- Be concise. CLAUDE.md is read in full at the start of every session, so every added line costs context.
- Do not restate in CLAUDE.md anything it already says.

Write two files when you are done.

First, $BODY, the pull request body, with exactly three level-2 sections: "## Promoted" (what moved and why it is global), "## Challenged" (contradictions with both sides and your proposal, plus unresolved wikilinks), "## Pruned" (what you propose deleting and the evidence it is done). Write "None." under any section with nothing in it.

Second, $SUMMARY, at most three short plain-text lines. Say what you changed and what most needs the owner's attention. If you changed nothing, say what you checked and why nothing needed changing.

Do not run git. Do not commit. Editing files and writing those two reports is your entire job.

Doing nothing is a valid and expected outcome. If there is nothing to change, make no edits and still write both files. Never invent work to justify a run.
EOF

echo "--- claude start ---"
claude -p "$PROMPT" \
  --model "$CONSOLIDATION_MODEL" \
  --allowedTools Read Write Edit Glob Grep \
  --permission-mode acceptEdits \
  --add-dir "$WORK"
CLAUDE_EXIT=$?
echo "--- claude exit=$CLAUDE_EXIT ---"

# A failed agent leaves a clean tree, which must not be read as "nothing to consolidate".
if [ "$CLAUDE_EXIT" -ne 0 ]; then
  echo "FATAL: claude exited $CLAUDE_EXIT, no consolidation happened"
  git checkout -q -- . 2>/dev/null
  git checkout -q main
  git branch -D "$BRANCH" >/dev/null 2>&1
  alert "Memory consolidation $RUN failed" "claude exited $CLAUDE_EXIT, nothing was consolidated. See $LOGDIR/$RUN.log on the machine."
  exit 1
fi

[ -s "$SUMMARY" ] && SUM=$(cat "$SUMMARY") || SUM="(the agent wrote no summary)"

# 4. No changes: no PR.
if [ -z "$(git status --porcelain)" ]; then
  echo "nothing to consolidate, no PR opened"
  echo "$SUM"
  git checkout -q main
  git branch -D "$BRANCH" >/dev/null 2>&1
  echo "=== done $(date '+%H:%M:%S') ==="
  exit 0
fi

# 5. Changes: commit, push, PR.
echo "--- changes ---"
git status --short
git add -A
git commit -q -m "chore: consolidate memories into CLAUDE.md ($RUN)"
git push -q -u origin "$BRANCH" || { alert "Memory consolidation $RUN failed" "Push of $BRANCH failed. See $LOGDIR/$RUN.log on the machine."; exit 1; }

[ -s "$BODY" ] || echo "Automated weekly consolidation. The agent wrote no report." > "$BODY"
printf '\n## Summary\n\n%s\n' "$SUM" >> "$BODY"
PR_URL=$(gh pr create --title "chore: memory consolidation $RUN" --body-file "$BODY" --base main --head "$BRANCH" 2>&1 | grep -oE 'https://github.com/[^ ]+/pull/[0-9]+')

if [ -n "$PR_URL" ]; then
  echo "PR opened: $PR_URL"
else
  echo "FATAL: gh pr create failed"
  alert "Memory consolidation $RUN could not open its PR" "Changes were pushed to $BRANCH but gh pr create failed. See $LOGDIR/$RUN.log on the machine."
fi
git checkout -q main
find "$LOGDIR" -name '*.log' -mtime +90 -delete 2>/dev/null
echo "=== done $(date '+%H:%M:%S') ==="
