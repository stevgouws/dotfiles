---
name: slack-formatting
description: Format text the user will paste into Slack (links, lists of tickets or PRs, snippets, messages) so it comes out right after pasting. Use whenever output is meant for Slack, including "gimme slack", even when it isn't a message in the user's voice. For wording a message as the user, also use my-voice.
---

# Formatting for Slack

The user copies from the terminal and pastes into Slack's message box. Slack converts some markup on paste and not other markup, so format for what survives the paste.

## Rules

- Put the text on the clipboard with `printf '%s' '...' | pbcopy`, and also show it in a code block in the reply. Copying it from the terminal doesn't work: Claude Code puts real line breaks where long lines wrap, so a copy in tmux copy mode splits links across lines. Run `pbcopy` outside the sandbox, otherwise the clipboard isn't touched and nothing errors. Say in the reply that it's on the clipboard.
- Never start the reply with the text to paste. The terminal puts its `⏺` reply marker at the start of the reply's first line, so copying that line picks up the marker too. Start the reply with this callout instead, then the code block on the lines below:

  ```
  > ***✓ Copied***
  ```
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

- Never post to Slack yourself unless the user has approved the exact text.
