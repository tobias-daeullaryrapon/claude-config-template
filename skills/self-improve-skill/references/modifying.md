# Modifying an existing skill

## Argument grammar

| Invocation | Means |
|---|---|
| `/self-improve-skill skill:<name> <the change>` | Modify `<name>`. Everything after the target is the change |
| `/self-improve-skill skill:<name>` | Audit only. Report what is off, change nothing, wait |
| No `skill:` prefix | Create mode |

Resolve `<name>` to `~/.claude/skills/<name>/`. No such folder: list what is there and
ask. Never create a skill from a mistyped target, and never silently pick the nearest name.

## Read before editing

**Read every file end to end, SKILL.md and every `references/*.md`.** Never edit a file you have
seen only a fragment of, and never work from the user's description of what the skill contains.

## RED still applies

Baseline the current skill on a task that exercises the change, exactly as for a new one.

**"The gap is obvious from reading it" is not a reason to skip.** What the text implies and what a
session does with it are different things, and the baseline is the only thing that says which. Skip
it and the edit addresses your theory of the failure rather than the failure.

## The edit

Smallest form that holds the change: a step, a table row, a section, a new reference file.

**A skill that did not fire is a description defect.** No body text reaches a run that never loaded
the skill. Put the wording the task actually arrived in, including the name it was filed under
("a quick script", "just a config tweak"), into the description's trigger list.

**Preserve everything you were not asked to change, byte for byte.** Existing Memory rows above all,
because they are observed history and a session that rewrites them destroys the record. Append,
never restate.

Add a Memory row for this change: the date, the signal, the rule now in force.

## Compliance sweep

Check the whole skill every time. What you do with a finding depends on whether you caused it:

| Finding | Do |
|---|---|
| Self-improvement section missing, paraphrased or softened | Fix. It is mandatory |
| Your edit pushed a file over budget | Fix: lift a dimension into `references/` |
| File was already over budget before you touched it | Propose |
| Description summarises the workflow instead of when to use it | Propose |
| Layout missing sections `structure.md` expects | Propose |

Applying unrequested restructures turns a one-line ask into a rewrite nobody can review. List them
and let the user choose.

**The sweep covers the target skill only.** A defect this run exposes in `self-improve-skill`'s own files is
a gate case, not a sweep case: edit it, then answer. "Shall I also fix X in self-improve-skill?" is the
question form of skipping the gate.

## Verify and report

`wc -w` the real files after writing, not the fragment you added. GREEN: re-run the baseline task
against the edited skill.

Report the diff, every file touched by full path, before and after baseline behaviour, and the
sweep's proposals listed separately from what you actually changed.

A finding that the skill conflicts with a CLAUDE.md quotes the rule, its file and line, and its
scope (global or one project), so the user can decide without asking.
