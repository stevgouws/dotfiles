---
name: jira-tickets
description: Create or edit the user's Jira tickets and subtasks (VoxSmart Atlassian site) with the right wording, title format and links. Use when asked to create, raise, add or update a Jira ticket, story, task or subtask, or to add subtasks under a ticket.
---

# Jira tickets

The user's tickets are on the VoxSmart Atlassian site (`https://voxsmart.atlassian.net`), mostly in the `SRC` (Source) project. Use the Atlassian MCP tools; get the `cloudId` once with `getAccessibleAtlassianResources`.

## Before creating anything

- Show the proposed wording first (summary and description for each ticket) and wait for the user's go-ahead. Creating a ticket notifies people and is visible to the team.
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
- When two new tickets refer to each other, create the first without the cross-reference, create the second referencing the first, then edit the first to add the second's key. Never leave a placeholder like `SRC-XXXX` in a created ticket.
- Leave out decisions or details the user has ruled out (e.g. a field that was dropped from the design), even if the prototype still shows them.

## Fields

- Assign only when the user says who. The user's own accountId comes from `atlassianUserInfo`.
- Don't set priority, sprint, labels or story points unless asked; Jira's defaults apply.
- Subtasks: issue type `Sub-task`, with `parent` set to the parent key.

## After creating

- Report each new ticket with its key and full URL written out in plain text, e.g. `SRC-2507: https://voxsmart.atlassian.net/browse/SRC-2507`, and what was set (assignee, status, sprint). A markdown link like `[SRC-2507](…)` hides the URL in the terminal.
- If there's a ticket note for the parent (see the `ticket-notes` skill), update its todo to link the new tickets instead of describing the work again.
