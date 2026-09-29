# Global preferences

These apply to every project. A project's own CLAUDE.md wins where it conflicts.

## Agent configuration repo
- **This agent's own configuration is version controlled.** `~/.claude/CLAUDE.md`, `~/.claude/skills`,
  `~/.claude/hooks` and each project's `~/.claude/projects/<slug>/memory` are symlinks into one git
  repository. `readlink ~/.claude/CLAUDE.md` names it. Editing any of them edits that repo.
- **Commit and push every change to that repo immediately,** with a real message describing what
  changed. Do not ask first, and do not batch changes for later. This is a standing authorisation for
  this repo only; it does not extend to any other repository.
- **A `PostToolUse` hook (`hooks/commit-config-repo.sh`) nudges commit+push after edits land here.**
  Act on its reminder without asking again.
- A `SessionStart` hook (`scripts/sync-config.sh`) fast-forwards the checkout, and skips the pull
  whenever tracked files are modified. Uncommitted work therefore leaves the machine stuck behind origin.
