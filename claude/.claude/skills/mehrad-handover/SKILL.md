---
name: mehrad-handover
description: Add or update entries in the user's Mehrad Handover note in Obsidian, the list of big changes Mehrad needs to know when he's back in Feb 2027. Use only when the request names Mehrad, e.g. "add this to Mehrad's handover" or "note this for Mehrad". Not for /handover or "the handover" on its own, which hand work off to another Claude session.
---

# Mehrad handover

The note is `/Users/steven.gouws/obsidian-sync/VoxSmart/Mehrad Handover.md`. Read it before editing, since the user edits it too, and keep their changes.

Mehrad is a developer on the team and is away until Feb 2027. He'll read the note himself or hand it to an agent to catch up, so every entry must make sense to either one without this conversation.

## What goes in

Only big changes: how we merge, release, deploy, test or structure code, and anything that would trip him up if he worked the old way. Skip routine fixes and features.

## How to write it

- Address him directly ("you"), as instructions: what's different now and what to do.
- Terse. One bullet per rule, one line where possible. No background story; the PR has it.
- Each entry ends with " - " and links to the PRs (or tickets) that have the detail, not in parentheses, e.g. `... since the last tag - [#1169](url)`.
- Concrete: exact button names in **bold**, commands, branch names and identifiers in backticks.
- Same voice as [[my-voice]]: British/South African spelling, plain words, no em dashes, nothing salesy or corporate ("robust", "seamless", "ensure").
- CAPS or **bold** only on the one word that matters (**never**, NOT).
- Don't spell out consequences he can work out, or justify a rule at length. Say what to do and stop.
- If something isn't confirmed, say so briefly ("I think", "From what I can tell") rather than stating it as fact.
- Every entry has to stand on its own. Link to GitHub, Jira or Slack, never to files on the user's machine or other Obsidian notes.
- Group by repo under `## \`repo\`` (the name the user uses, e.g. `fe-ui`), then a `###` heading per topic.
- If a change isn't merged yet, end it with ` - pending [#123](url)` and say so in the reply.
- When a later change replaces an earlier entry, update that entry rather than adding a contradicting one.

## Example

```markdown
## `fe-ui`

### Merging

- Release PRs (`beta` → `main`, `main` → `beta`): **Create a merge commit**, never squash. A bot comment reminds you - [#1151](https://github.com/VoxSmartLtd/vs-fe-unified-ui-svc/pull/1151)
```
