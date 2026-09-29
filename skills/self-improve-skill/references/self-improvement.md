# The self-improvement section

Copy the block below into every new skill, verbatim. Tailor only the "Looks like" examples. Do not
paraphrase the gate, do not soften it to "consider updating", and do not drop the closing output
line, which is what makes compliance observable. Omit the block only if the user says so explicitly.

---

```markdown
## Self-improvement

**Every run of this skill can change this skill.** Three user signals are gates, not detours:

| Signal | Looks like |
|---|---|
| A new aspect | "also handle X", "what about Y?" |
| A questioned outcome | "why did it do X?", "that is not what I wanted" |
| A request for explanation | "what does X mean here?", "how did you pick X?" |

On any of the three, **before answering**, run the gate:

> Would the next run of this skill, on a **different** input, go better if this were written down?

**Yes: edit this skill first, then answer.** Smallest form that holds it:

| What was missing | Form |
|---|---|
| A step skipped or done wrong | a new numbered step or checklist item |
| A fact or preference that outlives this run | a row in Memory below |
| A dimension the skill never considered | a new section, or a `references/` file |

**No: answer only.** Genuinely specific to this one input, or already covered.

Close with exactly one line. It begins with `Skill update:` only when this run changed the
skill, and with `No skill update:` otherwise. A run that changed nothing never opens the line
with `Skill update:`: not `Skill update: none`, not `none needed`, not `none of the gates
apply`. First word `No`, then the reason.

Not reasons to skip the edit:

| Rationalization | Reality |
|---|---|
| "The skill is sound, I just judged it wrong" | The skill was silent where judgment was needed. That silence is the defect. |
| "I will update it if it happens again" | The next run is a different session with no memory of this one. There is no "again". |
| "The user only asked a question" | A question marks the spot where the skill reads unclearly. That is the signal. |
| "Too small to be worth an edit" | One table row costs nothing. Skipping it costs the next run. |

Keep every file under ~500 words. Split into `references/` rather than growing one file.

### Memory

| Date | Signal | Rule now in force |
|---|---|---|
```

---

## Changing the block itself

Every skill holds a **copy**, not a reference. Editing this file propagates to nothing.
`grep -rln "Close with exactly one line" ~/.claude/skills/` finds the copies; update all
of them in the same commit, or the next audit reports drift that is really your half-done edit.

## Applying the gate well

**The gate is about generality, not about who was at fault.** "I misclassified it" and "the skill
did not say how to classify it" are the same event seen from two sides. Write the rule.

**Edit before answering, not after.** Answer first and the edit becomes optional; it gets dropped
once the user replies to the answer.

**Memory records what happened, never what you expect.** A row citing a baseline you did not run,
or a user objection nobody made, is fiction the next session will trust.

**Prune as well as append.** A row a new section now covers moves into the section rather than
sitting in both. Once Memory alone pushes the file past budget, move it to `references/memory.md`.
