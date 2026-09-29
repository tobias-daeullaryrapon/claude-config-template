# Baseline testing

**A skill written without a baseline teaches whatever felt right at the time.** The baseline tells
you what a session actually does unprompted, so the skill can address that instead of a guess.

## RED, before writing a line

Dispatch one subagent, `model: sonnet` (the model that will run the skill), on a realistic task in
the skill's domain, **without** the skill.

Keep it read-only: tell the agent to produce its answer inline and write no files. Nothing needs to
exist yet for the probe to be useful.

Two probe shapes, both cheap:

| Probe | Prompt shape | Reveals |
|---|---|---|
| Cold task | "The user says: `<realistic request>`. Produce exactly what you would produce." | What the default output looks like, and what it omits |
| Mid-run challenge | "You used this skill and produced X. The user now says: `<objection>`. Write your reply, then list every action you would take." | Whether follow-up gets absorbed or dropped |

Ask for an honest self-check at the end ("what did you *actually* do by default, not what is
ideal"). Agents report their own omissions accurately when asked directly.

**Record the rationalizations verbatim.** They are the raw material for the rationalization table.
Paraphrasing them loses the exact wording the next session will reach for.

**"The gap is obvious from reading it" is not a reason to skip.** What a text implies and what a
session does with it are different things. Skip the baseline and the skill addresses your theory of
the failure instead of the failure.

**If the baseline already does the right thing, stop.** There is nothing to teach. Say so rather
than writing a skill that documents what happens anyway.

## GREEN, after writing

Re-run the same task with the skill loaded. Compliance is binary: it either did the thing or it
did not.

**Keep the probe's wording out of the skill.** Tailored examples that quote the probe's scenario turn
GREEN into pattern-matching. Pick examples from a different input, and re-run if they leaked.

## REFACTOR, close the loopholes

A new excuse in the GREEN run is not a failure, it is the next test case. Add an explicit counter,
re-run. Repeat until the excuses stop.

## Cost control

One probe per shape is enough to start. Reach for 5+ repetitions only when testing the *wording* of
a rule that keeps getting negotiated away, and always alongside a no-guidance control, or you
cannot tell whether the rule did anything.

Read every flagged result yourself. Template echoes and quoted counter-examples look like hits and
are not.

## What not to bother testing

Pure reference material: API signatures, path inventories, command syntax. There is no behaviour to
fail. Test retrieval instead: can a session find the right entry and use it?
