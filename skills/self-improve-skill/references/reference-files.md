# What goes in `references/`

Two kinds of file live there, and they are maintained differently.

| Kind | Example | Kept current by |
|---|---|---|
| Guidance | a per-dimension method, a template, a rubric | you, when the method changes |
| Inventory | repos, channels, schemas, RFCs, model IDs, people | every run that reads it |

## An inventory is a cache, not truth

An inventory records external state that moves on its own. Written once and left, it goes wrong
silently and the next run trusts it anyway.

A skill that stores one carries three things:

1. **A stamp.** `Verified: <YYYY-MM-DD>` at the top of the file, or one per section.
2. **A verification step in the workflow, before the inventory is used.** Re-resolve only what this
   run will rely on, cheaply. Say in the output when the check could not run.
3. **A write-back step before the run ends.** What was newly discovered, corrected or has
   disappeared goes back into the file, and the stamp is bumped even when nothing changed, since
   that records the check happened. A claim that turned out wrong is retracted in place, never
   deleted, or the next run re-derives it.

Keep entry formats byte-stable when a workflow step diffs the file.

**A skill that cannot keep an inventory fresh should not store one.** Say so where the list would
have been, and make discovery a workflow step instead.
