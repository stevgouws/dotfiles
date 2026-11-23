---
name: jira-tickets
description: Create or edit the user's Jira tickets and subtasks (VoxSmart Atlassian site) with the right wording, title format and links. Use when asked to create, raise, add or update a Jira ticket, story, task or subtask, or to add subtasks under a ticket.
---

# Jira tickets

The user's tickets are on the VoxSmart Atlassian site (`https://voxsmart.atlassian.net`). The user is in the Nexus team, so new tickets go in the `UUI` project by default (backlog: https://voxsmart.atlassian.net/jira/software/c/projects/UUI/boards/415/backlog). Older tickets from their time in the Source team are in `SRC`. Use the V2 Atlassian MCP tools (`mcp__claude_ai_Atlassian_MCP__*`), not the deprecated V1 ones (`mcp__claude_ai_Atlassian__*`). Pass `cloudId: "voxsmart.atlassian.net"`. V2 bodies are markdown or HTML only, with no ADF.

## Before creating anything

- For a new ticket, show the proposed wording first (summary and description for each ticket) and wait for the user's go-ahead. Creating a ticket notifies people and is visible to the team.
- For a ticket that already exists, apply the change to the ticket directly and reply with its URL, without previewing it here first; the user finds it easier to review and tweak in Jira. Read the ticket again right before EVERY edit, even one you created minutes ago, because the user edits tickets in Jira straight after creation. Build the edit on what's there now and keep their changes (e.g. a renamed title, reworded sentences, pasted images). A description edit replaces the whole field, and a markdown edit drops embedded images (they can't be re-added from markdown). If the description has an image, write the whole description as HTML (`contentFormat: "html"`) and keep each image as `<figure data-type="media-single" data-layout="center"><div data-type="media" data-media-type="file" data-id="MEDIA_ID" data-width="W" data-height="H"></div></figure>`. Jira finds the image by `data-id` alone. Reads still come back as markdown on our site, even with `responseContentFormat: "html"`, with the image shown as `![](blob:...?id=MEDIA_ID&...&height=H&...&width=W...)`, so take the id, width and height from that link (tested on SRC-2682). After the edit, check that the read-back still has the same `id=`, and ask the user to confirm the image still shows. Only show the text here first when they ask for a preview.
- Read the parent ticket and its existing subtasks first, and match how they're written.
- Ask about anything the wording depends on and you can't settle from the ticket or the conversation, e.g. assignee, or an open product question. Put those questions in the same message as the draft.

## Wording

Write titles and descriptions in my voice using the `jira-ticket-voice` skill ([[jira-ticket-voice]]). That's the default. Only use its formal style (user story, Gherkin acceptance criteria) when I ask for a more formal ticket.

## Titles

- Subtasks follow the parent feature's naming: `<Area>: <Feature> - <Part>`, e.g. `FE: Current User Activity - Users List`, `FE: Current User Activity - User Change Log`.
- Check the sibling subtasks for the current pattern; the user sometimes renames them, so follow what's there now.

## Descriptions

- Size and shape per `jira-ticket-voice`. For subtasks: what the user sees or what the code must do, then what it depends on.
- Whenever the description mentions another ticket, link it, using `<KEY>: <summary>` as the link text: `[SRC-2445: Implement backend API to serve invite & reminder screen for a user](https://voxsmart.atlassian.net/browse/SRC-2445)`, not a bare `SRC-2445`. Jira doesn't turn bare keys in a description into links. Fetch the ticket for its current summary rather than writing it from memory.
- Don't put backticks in link text (``[`file.ts:33`](url)``). The markdown-to-Jira conversion drops the link and keeps only the code. Write `[file.ts:33](url)` instead.
- The markdown conversion doesn't support checklists: `- [ ]` comes out as a plain bullet with a literal `[ ]`. For a description with a checklist, write the whole description in HTML (`contentFormat: "html"`), with the checklist as `<ul data-type="task-list"><li data-type="task-item"><input type="checkbox"> Item with <code>code</code></li></ul>` (tested on SRC-2682). It reads back as `- [ ]`. The full HTML reference comes from `getContentFormatGuide` via `executeRead`, inputs `{toolName: "editJiraIssue"}`.
- When two new tickets refer to each other, create the first without the cross-reference, create the second referencing the first, then edit the first to add the second's key. Never leave a placeholder like `SRC-XXXX` in a created ticket.
- Leave out decisions or details the user has ruled out (e.g. a field that was dropped from the design), even if the prototype still shows them.

## Fields

- Assign only when the user says who. The user's own accountId comes from `atlassianUserInfo`.
- Don't set priority, sprint, labels or story points unless asked; Jira's defaults apply.
- Subtasks: issue type `Sub-task`, with `parent` set to the parent key.
- Story points are `customfield_10004`. A value of `0` means the ticket hasn't been pointed yet.
- To find an epic's tickets, search with `parent = <EPIC KEY>`. Tickets can keep the epic's label after they're moved off it, so the label isn't reliable.

## Moving a ticket to Done

Only when the user asks. Get the transition id with `executeRead` `listJiraIssueTransitions`, then `transitionJiraIssue`. The Done transition needs the CPTO fields, or Jira rejects it with "Please, fill the CPTO required fields". If the ticket doesn't have them yet, pass them in the transition's `fields`, copying the values from a sibling ticket that's already Done (for UUI-2582 tickets: `customfield_11715` "CPTO: Planned?" `{"id": "11029"}` (YES) and `customfield_11714` "CPTO: Work Type" `{"id": "11021"}` (New Product Development)), and tell the user what was set.

## After creating

- Report each new ticket with its key and full URL written out in plain text, e.g. `SRC-2507: https://voxsmart.atlassian.net/browse/SRC-2507`, and what was set (assignee, status, sprint). A markdown link like `[SRC-2507](…)` hides the URL in the terminal.
- If there's a ticket note for the parent (see the `ticket-notes` skill), update its todo to link the new tickets instead of describing the work again.
