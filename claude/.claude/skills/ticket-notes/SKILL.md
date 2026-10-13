---
name: ticket-notes
description: Structure and update the user's per-ticket markdown notes (todos, decisions, waiting-for items, PR notes, meeting notes). Use when asked to add a todo, decision, or "mention on PR" item to a ticket note, create a note for a ticket, or when the user refers to "the ticket", "the note", "Obsidian", "in Obsidian" or an Obsidian file.
---

# Ticket notes

The user keeps one markdown note per ticket, usually in `~/obsidian-sync/VoxSmart/tickets/`, named `<TICKET-KEY> - <title>.md` (e.g. `SRC-2150 - Wham Reporting Current Activity.md`).

"Obsidian", "in Obsidian" or "the Obsidian file" just means one of these markdown files; Obsidian is the editor the user writes them in. Nothing Obsidian-specific is needed: read and edit the file like any other markdown file. If it's unclear which note is meant, look in the tickets folder for the ticket key from the branch name or conversation.

## Before editing

- The user edits these notes too, often between your edits. Always re-read the file right before changing it, and build on what's there.
- Keep the user's wording and structure. If they've reorganised a section, follow their new layout from then on rather than restoring yours.
- Edit only what was asked. Don't tidy, reword or reorder other sections.

## Structure

Sections in this order. Leave out any that have nothing in them; add them when the first item arrives.

```markdown
---
tags:
  - ticket
URL:
  - <Jira link>
---
## Waiting for

- [ ] **<what>** #waiting-for <who or which ticket/PR, with link>
	- <details>

## Todo

### <group, e.g. "When the API is ready", "Still to build">

- [ ] <task>
	- <sub-points: file paths, precedent to follow, open questions>

### Before release

- [ ] <things that must happen before it ships, e.g. feature flag, translation check>

### Mention on PR

- [ ] <short note for the PR description>

### Optional improvements

- [ ] <nice-to-have, not needed for this ticket>

## Decided

- <decision, with who decided and when if known>

## YYYY-MM-DD - <meeting or topic, e.g. "Catchup with Istvan about data">

- <notes>
```

### Section rules

- **Waiting for:** blockers owned by someone else. Tag each with `#waiting-for` and link the PR or ticket. Remove an item once it's resolved, and move any lasting outcome into Decided.
- **Todo:** checkbox tasks grouped under `###` headings. Include the file paths, existing code to copy and open questions needed to pick the task up cold. Don't tick a task when you finish the code: the user reviews and commits it first, and ticks it or asks you to.
- **Before release:** must happen before the feature ships, but isn't building the feature.
- **Mention on PR:** things a reviewer should know that aren't obvious from the diff, especially changes to shared code outside the ticket's scope (e.g. a fix to a shared table component). One or two short sentences each: what changed and why. Checkboxes, ticked once it's in the PR description.
- **Optional improvements:** ideas that aren't needed for the ticket. Always last in the Todo section.
- **Decided:** settled decisions, so they aren't reopened. Name who decided where known. When a decision changes, update it in place rather than adding a contradicting one.
- **Dated sections:** meeting notes and research findings, headed `## YYYY-MM-DD - <topic>` with an absolute date, newest first, after Decided. Keep them as a record; don't rewrite them when things change later, update Decided or Todo instead.

## Writing style

- Short bullets, plain language. Use `code` formatting for file paths, identifiers and values.
- Write paths relative to the repo root (e.g. `wfe/app/src/...`).
- Each item should make sense to someone reading the note cold in a week's time.
