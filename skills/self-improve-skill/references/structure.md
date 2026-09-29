# Skill shape

## Layout

```
skills/<name>/
  SKILL.md              # required: overview, workflow, self-improvement
  references/*.md       # one file per dimension, loaded only when it applies
```

An inventory-style `references/` file (repos, channels, schemas, model IDs) has its own upkeep
rules: `reference-files.md`.

Name the folder for **what you do**, verb-first and kebab-case: `triage-flaky-tests`, not
`flaky-test-helper`. Letters, numbers and hyphens only.

## Frontmatter

```yaml
---
name: <folder name, exactly>
description: >
  Use when <triggering conditions>. Triggers on "<verbatim phrase>", "<verbatim phrase>".
argument-hint: "<arg shape>"     # only if the skill takes arguments
---
```

**The description says when to reach for the skill, never how it works.** A description that
summarises the workflow gets followed *instead of* the skill body. The body becomes documentation
the next session skips.

| | |
|---|---|
| Bad | `Reviews a PR by checking correctness, then tests, then posting findings` |
| Good | `Use when asked to review a branch, diff or PR, or to grade a PR` |

Write it in the third person. Pack in the words someone would actually type: error strings,
symptoms, tool names, synonyms. Keep it under ~500 characters.

## Body

| Section | Holds |
|---|---|
| Title + one line | What it produces |
| Core principle | The one insight, bolded, 1-2 sentences |
| Paths | Where the skill reads and writes, full paths |
| Workflow | Numbered, imperative, each step independently actionable |
| Quick reference | A table for the things looked up mid-run |
| Common mistakes | What goes wrong, and the fix |
| Self-improvement | Mandatory. See `self-improvement.md` |

Tables over prose for anything enumerable. A flowchart only where a decision is genuinely
non-obvious, never for linear steps or reference material.

## Match the form to the failure

Pick the form from what the baseline actually did wrong:

| Baseline failure | Form that works | Form that backfires |
|---|---|---|
| Knows the rule, skips it under pressure | Prohibition + rationalization table | "prefer", "consider" |
| Complies, but the output is the wrong shape | A recipe: state what the output **is**, its parts in order | "do not X", "never Y" |
| Leaves out a required element | A required slot in the template they already fill | Prose reminders nearby |
| Behaviour should vary by situation | A conditional on something observable | One rule plus exemptions |

No nuance clauses. "Do not X unless it matters" reopens the negotiation; express a real exception as
its own conditional.

## Budget

~500 words of authored content per file, `wc -w` to check. The embedded self-improvement block is
excluded: it is identical in every skill, so counting it would force real guidance out of SKILL.md
to make room for boilerplate.

Over budget, lift a whole dimension into `references/<dimension>.md`. Never split mid-topic, and
never let SKILL.md decay into an index of fragments. It must read end to end on its own.

Cross-reference other skills by name (`<skill-name>`, or `<plugin>:<skill-name>` for a plugin skill), never with `@`, which
force-loads the file and burns context before it is needed.
