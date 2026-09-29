---
name: self-improve-skill
description: >
  Use when the user asks to create, write, author or draft a skill: "/self-improve-skill", "make a skill for
  X", "turn this into a skill". Also when they ask to change, extend, fix, split or audit an
  existing one, including "/self-improve-skill skill:<name>". The default way skills are built here:
  baseline-tested before writing, modular files under ~500 words, and a mandatory self-improvement
  section so that every later run of the skill is a chance to revise it.
argument-hint: "<what the skill should do> | skill:<name> [<the change>]"
---

# Self-improve skill

Builds and changes skills that improve every time they are used, not static checklists that rot.

**Core principle: a skill is where judgment gets written down.** When a run goes wrong, the skill
was silent exactly where guidance was needed. That silence is the defect, not the judgment.

## Paths

| What | Where |
|---|---|
| Skill | `~/.claude/skills/<name>/SKILL.md` |
| Bundled files | `~/.claude/skills/<name>/references/*.md` |

When `~/.claude/skills` is a symlink into a config repo, editing there edits that repo. Commit and
push that skill and nothing else, as the repo's CLAUDE.md rule says.

## Modes

| Invocation | Mode |
|---|---|
| `/self-improve-skill <what it should do>` | Create, below |
| `/self-improve-skill skill:<name> <the change>` | Modify |
| `/self-improve-skill skill:<name>` | Audit against the guidelines, report, change nothing |

Modify and audit: `references/modifying.md`, read before touching an existing skill.

## Create

1. **Pin the trigger.** One sentence on when a future session should reach for this, one on what
   "done" produces. If you cannot name a verbatim user phrase that should fire it, ask.
2. **RED, before writing a line.** Dispatch one subagent without the skill on a realistic task,
   record its rationalizations verbatim. Method: `references/baseline-testing.md`. If the baseline
   already behaves, stop and say so.
3. **Write it.** Layout, frontmatter, naming, and matching the form to the observed failure:
   `references/structure.md`.
4. **Embed the self-improvement section.** Mandatory unless the user waives it. Copy it verbatim
   from `references/self-improvement.md`, tailoring only the examples.
5. **GREEN.** Re-run the same task with the skill loaded. A fresh excuse is the next test case:
   counter it explicitly, re-run.
6. **Report.** Full path, the invocation, and what the baseline did before and after.

## Budget

~500 words of **your own** content per file, `wc -w` the real file before reporting done. The
embedded self-improvement block is boilerplate and does not count. Over budget, lift a dimension
into `references/`; rules in `references/structure.md`.

## Self-improvement

Bound by the same gate it embeds: `references/self-improvement.md`. Apply it to these files.

### Memory

| Date | Signal | Rule now in force |
|---|---|---|
