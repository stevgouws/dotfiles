---
name: wireframes
description: Make a clickable wireframe walkthrough of a user flow as an HTML artifact, for a designer, PM or other colleague to step through and decide on the UX. Use when asked to wireframe a flow, mock up screens, sketch a login/onboarding/checkout flow, or "build an html for <designer>" to show what's technically possible. Not for changing real UI in a codebase or for polished visual designs.
---

# Wireframes

A wireframe page is for someone deciding how a flow should look and feel. They step through screens; they don't read. Every sentence you add makes the page harder to use, so start minimal and add only when asked.

For VoxSmart work (VX1, VCS, VSP), also read [references/voxsmart.md](references/voxsmart.md).

## Format

One HTML artifact (load the Artifact tool's design guidance as usual), with:

- Grey, sketch-style screens (e.g. Balsamiq Sans) inside a browser frame: tabs and a URL bar.
- A segmented control for each kind of customer or user, then chips for each situation, then Back/Next buttons and arrow keys to step through.
- A link per situation in the hash (e.g. `#vsp-only-sso`), so the user can point people at one flow.
- If one group sees no change, make it the first tab, with a short "no changes" walkthrough, before the new flows.
- Data-driven: screens are small render functions, scenarios are arrays of `{ screen, url, caption, note? }`. That keeps edits one-line.

[examples/vsp-sign-in-flows.html](examples/vsp-sign-in-flows.html) is a finished example to copy the structure from.

## Keep it minimal

- No intro paragraph, no list of what was checked, no list of decisions for the reader.
- One short caption per step, in plain words.
- A note only when it changes a design decision, labelled "Good to know". Never explain what happens behind the screen or how it's built: the reader doesn't need it.
- Short, single-idea sentences. No two-part summaries with colons and lists ("X goes away: the A, and the B on C"). "The VSP sign-in goes away." is the right length.
- At most one callout at the top, for the single fact everyone must know. Leave out nuance that needs explaining; drop the clause rather than qualify it.
- Don't add "your call" prompts. The user raises the decisions themselves.

## Realism where it helps understanding

- When something opens a new tab, show the second tab and highlight it ("← new tab opened"). When the user comes back, highlight the first tab ("← back on this tab") and keep the other tab visible, so it's obvious what happened.
- Use the app's real tab titles and URLs, not the app name alone.
- Use one concrete example rather than a generic placeholder: a Microsoft sign-in page, not "your organisation's identity provider (Entra, Okta or similar)".
- Error states follow what the existing product already does, unless told otherwise. Don't invent new wording for them.
- One form or component that appears in several places looks the same in each; only the container differs (a dialog vs a full page).

## Wording

- On-screen text uses the name customers know. Captions and notes use the name colleagues use. Ask if it's unclear which is which.
- Customer-facing copy in the screens; plain everyday words in the captions.

## Process

1. Check the technical facts first (read the code, try it in a browser, ask the user) so the screens show what's actually possible.
2. Put only the results that affect the design on the page. The detail goes in the chat, not the page.
3. Publish, then republish to the same artifact on every change. After each edit, check the page's script still parses (extract it and run `node --check`).
4. The artifact is private: remind the user to share it with the reader from the page's Share menu.
