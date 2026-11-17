---
name: slack-formatting
description: Format text the user will paste into Slack (links, lists of tickets or PRs, snippets, messages) so it comes out right after pasting. Use whenever output is meant for Slack, e.g. "Slack paste", "for Slack", "links for Slack", "something I can paste in Slack", even when it isn't a message in the user's voice. For wording a message as the user, also use my-voice.
---

# Formatting for Slack

The user copies from the terminal and pastes into Slack's message box. Slack converts some markup on paste and not other markup, so format for what survives the paste.

## Rules

- Give the text in a code block, so the user can copy it straight from the terminal without the terminal's own formatting getting in the way.
- Links go on descriptive text as Markdown: `[SRC-2682: Spike: Add a content-only keyword search](https://...)`. Slack's message box turns these into links on paste. Use bare URLs only when there's no title to use.
- Never use Slack's own `<url|text>` syntax. It only works through the API and pastes as literal text.
- For a ticket, use `<KEY>: <summary>` as the link text, with the summary fetched from Jira, not written from memory.
- Write lists with `•` bullets, one item per line.
- Put repo, service, endpoint and code names in backticks: `comms-svc`, `/json/activity`.
- Leave out bold and headings.

## Example

```
• [SRC-2682: Spike: Add a content-only keyword search for VSP communications](https://voxsmart.atlassian.net/browse/SRC-2682)
• [SRC-2684: Spike: Add a far party filter for VSP communications](https://voxsmart.atlassian.net/browse/SRC-2684)
```

## Don't

- Don't put the text on the clipboard unless the user asks. They'd rather copy it from the reply. If they do ask, write HTML to the macOS pasteboard as `public.html`, with a plain-text fallback (JXA `NSPasteboard`). It needs to run outside the sandbox, otherwise the clipboard isn't touched and nothing errors.
- Never post to Slack yourself unless the user has approved the exact text.
