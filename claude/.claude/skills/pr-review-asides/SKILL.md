---
name: pr-review-asides
description: Record code review findings the user decided not to act on in the PR description, in a collapsible "Asides for Agents and other curious fellas" section, so the next reviewer (usually an AI agent running a code review) doesn't flag them again. Use when asked to add dismissed, discarded, won't-fix or "left as is" review findings or comments to a PR, or to update that section after more findings are dismissed or fixed.
---

# Asides for dismissed review findings

The section is for the next reviewer, usually an agent running a code review on the same PR. A finding that was looked at and deliberately left as is should be recognised from the section and not raised again. Each entry says what the finding was and why it was dismissed, so the reviewer can tell whether their finding is the same one and whether the reason still holds.

Write in the user's PR voice (see [[pr-voice]]): plain, first person where it helps, no em dashes.

## What goes in

- Only findings the user dismissed or deferred. Leave out anything they fixed, including fixes made after the section was first written. Remove a finding when it gets fixed.
- One bullet per finding, even if several came from the same review.
- If the user hasn't said why one was dismissed, use the reason from the conversation (e.g. a benchmark, a check against `main`, their decision). If there isn't one, ask rather than invent it.

## Format

Copy this layout exactly, including the `<h2>` inside `<summary>` and the blank lines around the content, which GitHub needs to render the markdown inside `<details>`. Start with a `---` rule, so the asides are visibly separate from the description itself. Keep a blank line above the `---` too: straight after a line of text, markdown turns that text into a heading instead of drawing a rule.

```markdown
---

<details>
<summary><h2>Asides for Agents and other curious fellas</h2></summary>

These came up in an AI code review and were deliberately left as they are, so no need to flag them again unless you feel strongly.

- **<The finding, as a sentence a reviewer would recognise>**
  - <Why it was left: the evidence, then the decision.>
- **<Finding>**
  - <Reason>

</details>
```

If the findings came from a human reviewer rather than an AI review, change "an AI code review" to "review".

Keep findings out of headings. Full sentences in heading size are hard to read, and inline code in a heading renders as large monospace that wraps badly.

### Each finding

- **The finding is a bold top-level bullet**, written as one full sentence with no full stop. Name the exact identifier, file or value (`toSorted`, `displayDate`, `"hour:minute timeZone"`) so a reviewer looking at the same code matches it to their own finding. A short consequence can go in the bold part when it makes the finding clearer, e.g. "**A flag's `ref` points at the _last_ section it covers, not the first, so scrolling to a flag lands on its end**".
- **The reason is a single nested bullet below it**, as brief as it can be while still standing on its own:
  - Evidence first when there is some: "This is the existing behaviour on `main` (I ran the new ref test against `main` and it passes there too)", "skipping it only saves about 2 ms per 5,000 calls (benchmarked in Node)".
  - Then the decision: "so not worth the extra branching", "Keeping it for now", "Could be a follow-up if it ever shows up in a profile", "Preference rather than a problem".
- When the reason is simply a decision or that it's handled elsewhere, a few words are enough: "Fine for our users.", "Consumer will be updated."
- Don't argue with the reviewer or restate the whole finding. Two or three sentences is the most a reason needs.

## Where it goes

- After `## Testing`, at the end of the description. It goes above any markdown link reference lines at the very bottom (e.g. `[UUI-2632]: https://…`), so those stay last.
- If the section already exists, add to it or edit it in place. Never add a second one. If it has no `---` above it yet, add one.
- Leave the rest of the description exactly as it is.

## Updating the PR

1. Get the current body: `gh pr view <number> --json body -q .body > <scratchpad>/body-old.md`.
2. Write the new body to `<scratchpad>/body-new.md`, changing only the asides section. Write it with the Write tool or a short script rather than retyping the rest of the body, so nothing else changes by accident.
3. Show the user the exact section text (or the `diff` of the two files) and wait for their approval before posting, as CLAUDE.md requires. Approval of an earlier draft covers small deletions they asked for (e.g. dropping a finding they've since fixed). Anything reworded needs to be shown again.
4. `gh pr edit <number> --body-file <scratchpad>/body-new.md`, then check that the section is on the PR: `gh pr view <number> --json body -q .body | grep -c "Asides for Agents"`.
5. Reply with the PR link and the number of findings in the section.
