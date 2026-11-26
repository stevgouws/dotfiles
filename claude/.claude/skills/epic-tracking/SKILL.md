---
name: epic-tracking
description: Track a Jira epic in Obsidian - one note per ticket with order, points, status and depends_on in the frontmatter, an epic overview Base, and day estimates against the due date from the shared Estimation note. Use when setting up an epic in Obsidian, when asked to sync an epic's notes with Jira ("update obsidian", "check points", "we've pointed more tickets", "update titles"), to change the work order, mark a ticket done, or to change the estimates, BAU or due date of an epic.
---

# Epic tracking in Obsidian

How the user tracks an epic and its tickets in their Obsidian vault (`~/obsidian-sync/VoxSmart`), built on UUI-2582 (New VSP UI - Communications Page). Follow [[ticket-notes]] for everything inside a note (sections, `#link`/`#claude` markers, re-reading before editing, writing style) and [[jira-tickets]] for anything that writes to Jira. This skill covers what ties the notes together: frontmatter, the Base, estimates and syncing with Jira.

## The pieces

| File | Where | What it is |
|---|---|---|
| One note per ticket | `tickets/<KEY> - <title>.md` | Frontmatter below, plus the ticket's own notes |
| Epic note | `tickets/<KEY> - Epic - <title>.md` | Overview, refinement notes, decisions, and the Estimates section |
| Epic overview Base | `tickets/<KEY> - Epic overview.base` | Table views over every note with the epic's tag |
| Estimation | `Estimation.md` (vault root) | Shared by all epics: points-to-days scale and BAU |

Templates for the Base, the Estimates summary and Estimation are in `templates/` next to this file. Copy them rather than writing them from scratch, since they're the versions that are known to work.

## Ticket note frontmatter

```yaml
---
tags:
  - ticket
  - new-vsp-ui        # the epic's tag, which is what the Base filters on
URL:
  - https://voxsmart.atlassian.net/browse/UUI-2595
epic: "[[UUI-2582 - Epic - New VSP UI - Communications Page|UUI-2582]]"
order: 24             # work order, lowest first
stretch: true         # only on stretch goals / nice-to-haves, left out otherwise
status: New           # copied from Jira, exactly as Jira spells it
assignee: Steven      # who does the ticket; the Base and summary only show the user's own
points: 1             # story points, empty when not pointed yet
depends_on:
  - "[[UUI-2590 - Local time display using the VSP Admin timezone setting|UUI-2590]]"
---
```

- `depends_on` is `[]` when there's nothing. The Base's "Needed by" column comes from backlinks, so it doesn't need its own property.
- `assignee` mirrors the Jira assignee's first name (`Steven Gouws` → `Steven`). When a ticket has no assignee in Jira yet, keep what the note says, since the user sometimes knows who'll do it first. Tickets someone else does (e.g. QA) keep the epic's tag, so the sync still finds them, but have that person's name, so the Base and summary leave them out.
- `stretch: true` marks a nice-to-have. The summary counts must-haves and stretch goals separately, and the Estimates view shows the flag.
- `order` values are spaced out (10, 20, 30...) so a ticket can go between two others without renumbering. The user often reorders them in Obsidian, so keep their values.
- The epic note has `tags: [ticket]` (not the epic tag, so it isn't a row in the Base), `Related:` links to related notes (instead of a "Related notes" section), and `due: YYYY-MM-DD`, which the Estimates summary reads.

## File names

- `<KEY> - <Jira summary>`, with characters that can't be in a file name or break Obsidian links swapped out: `:` and `/` become ` -` or are dropped (`BE: Add X to /Activity API` → `BE - Add X to Activity API`), and `[`, `]`, `#`, `^` and `|` are dropped (`[QA] - Parity check` → `QA - Parity check`).
- Renaming a note outside Obsidian doesn't update links to it. After renaming, replace `[[<old name>` with `[[<new name>` in every `.md` and `.base` file in the vault, and grep for the old name to check nothing's left. Links to headings (`[[note#heading]]`) use the heading text, so leave headings that are link targets as they are.

## The Base

Start from `templates/epic-overview.base` and replace `{{EPIC_TAG}}` with the epic's tag and `{{ASSIGNEE}}` with the user's name (`Steven`). The Base only shows tickets with both. Its views:

- **Estimates:** tickets that aren't Done, in work order, with Days pre-AI and Dev days (with AI) columns and sums. Embedded in the epic note's Estimates section with `![[<KEY> - Epic overview.base#Estimates]]`.
- **Work order:** every ticket by `order`, with depends on and needed by.
- **All tickets**, **By status**, **Not pointed**.

The grouped views (All tickets, By status) only show the statuses listed in their `groupOrder`, so a ticket in any other status silently drops out of them. Keep every status the epic uses in that list (`New`, `To Do`, `In Progress`, `Ready for review`, `Done`), and add a new one when a ticket moves into it.

The day columns are formulas that read the scale from Estimation: `file("Estimation.md").properties["with_ai_" + points.toString()]`. Bases don't refresh values read from another note by themselves, so after changing Estimation the user may need to reopen the Base.

## Estimates

`Estimation.md` holds the scale as flat properties, `pre_ai_<points>` and `with_ai_<points>` for 1, 2, 3, 5 and 8, plus `bau_points_per_week`, and the days off as lists of dates: `bank_holidays` (England and Wales, from gov.uk) and `leave` (one date per day off). Its body shows them with inline Dataview (`= this.with_ai_5`), so the properties are the only place the numbers live. Change the numbers there, never in the Base or the summary. If Estimation doesn't exist yet, copy `templates/Estimation.md` to the vault root and ask the user for their scale.

The Estimates section is the first section of the epic note, straight after the Due callout. It has the Dataview summary first and then the embedded Base view. The summary is from `templates/estimates-summary.md` (replace `{{EPIC_TAG}}` and `{{ASSIGNEE}}`). The summary only counts the user's own tickets that aren't Done. It:

- counts working days (Mon-Fri, less `bank_holidays` and `leave`) from tomorrow until the epic note's `due`
- adds up the Dev days of the must-haves, and shows the stretch goals' days separately underneath
- shows one table with a column for with BAU (`bau_points_per_week`, counted as one ticket of that size per week) and one for without. Two separate tables side by side don't fit in the note's width, so they wrap
- shows how many days ahead or short that is, and the same in points ("4 points spare", "7 points over"), using the average days per point of the must-haves left
- lists the tickets that aren't counted because they have no points

The table is built with `createEl` rather than `dv.table`, which adds a result count to the header. Values are wrapped in `<code>`.

When the user asks for figures in chat, work them out from the notes the same way and say they're from today. Ready for review counts as remaining until it's Done.

## Desktop widget

A Hammerspoon desktop widget shows the epic against its due date: `~/dotfiles/hammerspoon/.config/hammerspoon/widgets/epic.lua` and `widgets/epic.html`, set up in that folder's `init.lua`. It reads the same notes and Estimation properties as the summary and redraws when a note changes, so keep the two in step: a change to how the summary counts days or points belongs in the widget too.

## Syncing with Jira

When asked to update Obsidian from Jira, check points, or similar:

1. Fetch the epic's tickets: `searchJiraIssuesUsingJql` with `parent = <EPIC> ORDER BY key` and fields `summary`, `status`, `customfield_10004` (story points).
2. List the notes with the epic's tag and their `status` and `points`, and compare.
3. Update `status`, `points` and `assignee` in each note that differs (fetch the `assignee` field too). Jira returns `0` points for a ticket that isn't pointed yet, so leave `points` empty for those.
4. A ticket that's no longer on the epic: remove the epic's tag from its note so it leaves the Base. Don't delete the note. Tickets can keep the epic's Jira label after leaving it, so go by `parent`, not the label.
5. A ticket on the epic without a note: create one (see [[ticket-notes]]) with the frontmatter above, and ask the user who's doing it and where it goes in the work order.
6. A changed summary: rename the note and fix the links (see File names).
7. A ticket that's now Done: also remove it from every other note's `depends_on`, leaving `[]` if nothing's left.
8. Dependencies: compare each note's `depends_on` with the ticket's "is blocked by" links in Jira (`searchJiraIssuesUsingJql` with `issue in linkedIssues(<KEY>, "is blocked by")`, or `getJiraIssue` with `view: "evidence"`, which returns the links).
	- A link in Jira that's missing from `depends_on`: add it to the note.
	- A Jira link that's no longer in `depends_on`: there's no MCP operation to delete issue links, so tell the user exactly where to remove it, ticket first: "Go to UUI-2829, and under 'blocks' remove the link to UUI-2592".
	- A dependency only in the notes: list it, and only add it to Jira when the user asks, since the tickets belong to other people too (Stu reports most of them). Link it with `executeWrite` `createJiraIssueLink`, `linkType: "Blocks"`, with the blocker as `inwardIssue` and the blocked ticket as `outwardIssue`. Use these links for dependencies rather than a "Depends on" line in the description.
	- While comparing, flag dependencies that look wrong rather than copying them across: a blocker that's no longer on the epic, or a loose one where the ticket only picks something up once the other is done (e.g. a date that will use the Admin's timezone after UUI-2590). Ask the user before removing them.
9. Report what changed in a short table, and the new estimate figures if they moved.

## Marking a ticket done

When the user asks to move a ticket to Done, transition it in Jira (see [[jira-tickets]] for the required fields), set `status: Done` in its note, and remove it from other notes' `depends_on`.

## Epic-specific notes

Things that only apply to one epic. Check here before syncing or changing that epic.

### UUI-2582 - New VSP UI - Communications Page

- Tag `new-vsp-ui`, Base `tickets/UUI-2582 - Epic overview.base`, due 20 Dec 2026.
- UUI-2607 (QA parity check and usability retest) is done by Mans, so its note has `assignee: Mans` and it's not in the user's estimates. It's unassigned in Jira for now, so keep `Mans` when syncing.
- Stretch goals: from 2026-11-23, everything from UUI-2590 onwards in the work order (`stretch: true`). #Stu will move some of these to phase 2. Keep them in the notes until they leave the epic in Jira.
