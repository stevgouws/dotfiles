---
name: ticket-notes
description: Structure and update the user's per-ticket markdown notes (todos, decisions, waiting-for items, PR notes, meeting notes). Use when asked to add a todo, decision, or "mention on PR" item to a ticket note, create a note for a ticket, log something as tech debt ("log it as tech-debt", "add a tech-debt ticket"), add screenshots to a note, or when the user refers to "the ticket", "the note", "Obsidian", "in Obsidian" or an Obsidian file.
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

- [ ] **<short title>** #waiting-for <who or which ticket/PR, with link> to <do what>.
	- <what we'll do once it's unblocked, and why it matters>
	- <precedent, file paths, values, questions to ask>

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

- **Waiting for:** blockers owned by someone else. Tag each with `#waiting-for` and link the PR or ticket. Once an item is resolved, don't tick it: remove it, and move any lasting outcome into Decided.
  - Keep the top line to one short sentence: a bold title, the tag, and who or what we're waiting on (e.g. `- [ ] **CSV download route** #waiting-for Istvan to confirm the route.`). Put all detail in nested bullets underneath, so the item collapses to that one line in Obsidian.
  - Example:

    ```markdown
    - [ ] **Permission check on the connectivity endpoint** #waiting-for [PR #202](https://github.com/VoxSmartLtd/vsp/pull/202) merged.
    	- Then make `UserConnectivityReportServlet` only answer users with `connectivity` / `access_screen`, e.g. by returning `UiSection.CONNECTIVITY` from `getUiSection()` like `UserListServlet`. Without it, anyone logged in can call the endpoint.
    ```
- **Todo:** checkbox tasks grouped under `###` headings. Include the file paths, existing code to copy and open questions needed to pick the task up cold. Don't tick a task when you finish the code: the user reviews and commits it first, and ticks it or asks you to.
- **Before release:** must happen before the feature ships, but isn't building the feature.
- **Mention on PR:** things a reviewer should know that aren't obvious from the diff, especially changes to shared code outside the ticket's scope (e.g. a fix to a shared table component). One or two short sentences each: what changed and why. Checkboxes, ticked once it's in the PR description.
- **Optional improvements:** ideas that aren't needed for the ticket. Always last in the Todo section.
- **Decided:** settled decisions, so they aren't reopened. Name who decided where known. When a decision changes, update it in place rather than adding a contradicting one.
- **Dated sections:** meeting notes and research findings, headed `## YYYY-MM-DD - <topic>` with an absolute date, newest first, after Decided. Keep them as a record; don't rewrite them when things change later, update Decided or Todo instead.

### Tagging people

- When a task involves someone (to discuss with them, ask them, or hand to them), tag them inline where their name falls in the sentence: `- [ ] Discuss with #Istvan before finishing:`. Don't add the tag as an extra word at the end of the line.
- Use only these tags:

  | Tag | Person |
  |---|---|
  | `#Istvan` | Istvan Karady |
  | `#DJ` | Daniel Joyce |
  | `#Stu` | Stu Park |
  | `#SteveB` | Steve Blything |
  | `#DM` | Dan Mudd |
  | `#Bernardo` | Bernardo Abreu |

- For anyone else, write their name without a tag and ask the user whether to add a tag for them. Don't make one up: Obsidian tags are freeform, so a new spelling silently starts a separate tag.
- This is separate from `#waiting-for` on Waiting for items, which stays as it is.

## Tech-debt notes

"Log it as tech-debt" (or similar) means: create a new note in the tickets folder for a problem found while working on something else, with no Jira ticket yet.

- Name it `<PROJECT>- - <short title>.md`, leaving the key blank until a Jira ticket exists (e.g. `SRC- - Fall back to English for missing VSP translations.md`). Take the project from the current ticket.
- Add `tech-debt` to the tags and leave `URL` empty:

  ```markdown
  ---
  tags:
    - ticket
    - tech-debt
  URL:
    -
  ---
  ```
- Start with a short intro, before any section: the problem in one or two sentences, then where it was found (linked ticket or PR, and the date), then the evidence as bullets (file paths, counts, examples). It should make the case for the work to someone who wasn't there.
- Then the usual sections from [Structure](#structure), typically Waiting for (e.g. someone deciding whether it's worth doing) and Todo (the proposed fix, its trade-offs, and any cleanup it allows).
- If the current ticket's note mentions the problem, link the new note from it only when asked.

## Screenshots

- Copy the image into `~/obsidian-sync/VoxSmart/_assets/` with a descriptive name, prefixed with the date (e.g. `2026-10-16 missing-translations-widget-menu-zh.png`). Use `cp -n` so an existing file isn't overwritten.
- Embed it with `![[<file name>]]` next to the text it supports. Add `|400` for tall or narrow images, e.g. `![[<file name>|400]]`.
- Update the text the screenshot proves, e.g. change "not yet confirmed" to "confirmed in the browser" with the date.

## Writing style

- Short bullets, plain language. Use `code` formatting for file paths, identifiers and values.
- Write paths relative to the repo root (e.g. `wfe/app/src/...`).
- Each item should make sense to someone reading the note cold in a week's time.
