---
name: pr-voice
description: Write GitHub pull request titles and descriptions the way the user writes them. Use whenever drafting, writing, updating or tidying a PR title or description (including when opening a PR with gh), or a PR comment that explains a change. For Slack posts announcing a PR, use my-voice instead.
---

# Writing PRs in my voice

Distilled from ~330 of my PRs over a year, across frontend, backend and infra repos. The goal is a title and description I can use with little or no editing, in the same voice as [[my-voice]] but a notch more structured, because reviewers read PRs carefully and come back to them later.

## Before writing

1. Look for the repo's PR template (`.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/`) and use its headings. Most of my repos have one with Description, Testing, Screenshots and sometimes Post-Merge Actions.
2. Get the ticket key from the branch name (e.g. `feat/SRC-1234-some-thing`) or ask if there isn't one.
3. Read the diff and recent commits so the description matches what the PR actually does, not what was planned.

## Title

Conventional-commit format, because semantic release reads it:

```
type(TICKET-123): Short summary in sentence case
```

- Types I use: `feat`, `fix`, `chore`, `test`, `docs`, `perf`.
- No ticket: empty scope `feat(): ...`, or `(adhoc)` for small unplanned fixes.
- Several tickets: `fix(UUI-1528-UUI-1577): ...`.
- Summary starts with a capital and is usually an imperative verb: Add, Fix, Handle, Remove, Update, Replace, Support. For a bug fix it can be the ticket's problem statement instead: `fix(SRC-1583): Dev server crashes frequently during hot reload`.
- Short and specific. Mention the environment for infra changes: `Add vibe-comms-whatsapp queue in dev`.

## Description

**Size it to the change.** Most of my PRs are a sentence or two plus the testing line. Only big or subtle changes get extra sections. Don't pad a small PR with headings.

**Opening line.** Almost always starts "This PR ..." and very often "This PR just ..." for small changes:
- `This PR just removes the onError handler that's no longer present on the event-client. (It was only logging anyway.)`
- `This PR adds the detail modal on the Connectivity Page with Changelog and Invites & reminders tabs.`

For several changes, "This PR:" followed by bullets that start with a verb in third person (Adds, Fixes, Replaces, Removes, Deletes, Updates):
```
This PR:

- Updates packages
- Replaces the deprecated react-scripts with vite
- Replaces jest with vitest
- Deletes a bunch of unused CSS and unused husky pre-commit scripts
```

Even two changes get this list form. When the bullets carry on the "This PR" sentence, they start lowercase, with no colon after "This PR":
```
This PR
- adds a new `CALL_PERMISSION_REQUEST` websocket message type, which the app sends when ...
- adds a `message_type` tag to the `message.accepted.count` metric so we can tell ...
```

**Bug fixes: explain the cause first, then the fix.** In plain words, with the concrete effect:
> Previously temp-media deletion was triggered after an event with status `SENT` was received. However when messages are rejected because of the 24h window, they also go through `SENT` before `REJECTED`, which meant that for templated messages the media was deleted before Twilio tried to send the template, so the send failed.
>
> This PR just triggers the media deletion after the `DELIVERED` event instead, which shouldn't really affect non-templated messages (apart from happening slightly later) and correctly deletes templated media _after_ it sends the template.

**Tone**
- First person, conversational, same voice as my Slack messages but in full sentences.
- Honest about uncertainty and limits: "Not super familiar with helm so let me know if there is a better or established pattern for this", "although I'm not 100% sure which bit was causing it. Time will tell if it's completely fixed."
- Give the why behind decisions, often as a short trade-off: "I considered adding validation in the pipeline, but it's pretty complicated, and given no one else is using it yet I thought I'd leave it for now and we can see how it goes."
- Emphasis with CAPS for the one word that matters (`it IS actually always sorted`, `DO NOT MERGE`) or _italics_. Bold sparingly, mainly in tables.
- Code identifiers, env vars, file names, commands and status values in backticks.

**Optional sections, only when they earn their place.** Use whichever fit:
- `## Additional Fixes` for unrelated fixes made along the way.
- `## Pending` or `## Future improvement` for follow-ups, ideally with a ticket: "I've logged [SRC-2452](url) where we can also ..." or "Follow-up ticket 👉 [SRC-2507](url)".
- Risks or things reviewers should know go in a `> [!NOTE]` callout at the end of the Description, not a separate `## Please note` heading. E.g. an accepted risk: what could go wrong, what would actually happen, and why it's acceptable.
- `## Backwards compatibility` when relevant.
- `## Post-Merge Actions` with checkboxes for anything that has to happen after merge: `- [ ] Please merge <link>`.
- `## Detail` / `## More detail` or `## Explanation` for the deeper reasoning, after the short version. Put very deep root-cause detail in a `<details><summary>More details about why ...</summary>` block.
- `## Usage` with a code block for new scripts or commands.
- `## Validation` when I checked something manually that tests don't cover.
- `## Query Performance impact` with the `EXPLAIN` output for query changes.

**Callouts.** GitHub alerts for things a reviewer must not miss:
```
> [!NOTE]
> Pipeline will fail until the queue is created in <link>
```
```
> [!WARNING]
> I suggest a decent smoke/regression test before releasing this one - DO NOT MERGE until testing is practical
```

**Linked PRs and tickets**
- "This PR, along with <link>, changes ..." or "in conjunction with <link>" for changes split across repos.
- "Reverts: <link>" for reverts. "This PR fixes a bug introduced in <link> where ..." when fixing my own earlier change.
- Tickets as `[SRC-1234](url)` or as a link on the ticket title.

**Showing the change**
- Before/after screenshot tables for UI or CI output changes:
  ```
  **Before** | **After**
  :-------------------------:|:-------------------------:
  | <img ...> | <img ...> |
  ```
  Leave a placeholder for me to drop the screenshots in; don't invent image URLs.
- A small table when comparing states across several cases (e.g. which tests ran before, after, and with this PR).
- Before/after code snippets when changing how others write code, followed by "This is for two reasons: 1. ... 2. ...".
- "Most important changes are in" + a short list of files, when a PR touches many files but only a few matter.
- "I've done the actual configuration changes as a separate first commit so it's easier to see what changed among the reformatting" when that helps review.
- "Copied from the Readme changes, for easy reference" under a `---` rule when the PR updates docs that already explain it.

**Testing section.** Keep the template's line and pick one:
- `:white_check_mark: - I have added tests`
- `:x: - No, here's why:` followed by a short reason ("Edge case, not needed", "NA", "Config only").
Add how it was verified if it's not obvious: "Checked that all 32 tests that ran before still run and pass on this branch by running `mvn test` at both commits and comparing the results."

## Things I'd always have to rewrite

- Generic AI-style headings like `## Summary`, `## Changes`, `## Test plan`, `## Why` when the repo template uses Description / Testing.
- Empty template sections or unused options left in (e.g. both the ✅ and ❌ testing lines, an empty Screenshots heading). Remove what doesn't apply. Keeping the template's `<!-- -->` hint comments is fine.
- A template section whose answer is just "No", e.g. `## Post-Merge Actions` with `:x: - No`. Drop the whole section instead; only include it when there is something to do.
- Restating the title as the first line, listing every file changed, or describing obvious mechanics the diff already shows.
- Over-hedged or salesy wording ("This PR significantly improves...", "robust", "comprehensive", "seamless").
- Em dashes, and the other rules in [[my-voice]].

## Examples

**Tiny fix**
```
## Description

This PR just aligns secret naming that's different on dev than other envs. Further cleanup will follow after the service has switched to this value. New secret already populated.
```

**Small feature with template**
```
## Description

This PR implements a middleware that validates that requests to the webhooks are actually coming from Twilio.

## Testing

:white_check_mark: - I have added tests

## Future improvement

We might want to consider some kind of caching layer for the sub-account tokens. Currently we do an API call to look it up on every single message.
```

**Fix with a "no tests" reason**
```
## Description

This PR just prevents the user from being able to select an unsorted table (as it IS actually always sorted). It fixes a bug where if the user toggled all columns to unsorted, the download API would `500` because it requires a sortBy column.

## Testing

:x: - No, here's why:

Edge case, not needed
```

**Infra change that depends on another PR**
```
This PR adds the `sns-vibe-telserver-tsnotifier-main` subscription to `sqs-vibe-comms-telecoms-main`.

> [!NOTE]
> Pipeline will fail until the queue is created in <link to queue PR>
```

**Behaviour change in a shared package**
```
## Description

Currently the SQS eventClient fires `onMessages` even when there are zero messages, resulting in logs like this:

<screenshot>

This PR makes it just not fire when there are 0 messages, which is likely the behaviour consumers expect. I've checked all existing consumers to make sure this doesn't cause anything unexpected. None of them use `onMessages` as a heartbeat.

## Testing

:white_check_mark: - I have added tests
```

**Larger PR with extras**
```
## Description

This PR implements the new Connectivity Page with permissions for a new `connectivity` `ui_section`. Sorting and pagination all happen on the FE for now since we don't expect a tonne of data.

## Additional Fixes

- Fixed `StripedDataGrid` crashing tests with empty tables. This also means the "No results found." empty state now has proper translations instead of just English
- Enabled global `clearMocks` and `restoreMocks` in the Vitest config, and removed the manual `vi.clearAllMocks()` calls

## Pending

- I'll do a follow-up to add the `access_screen` permission once the BE <link|PR> is merged
- Sort order TBC by <name>

## Testing

:white_check_mark: - I have added tests

## Screenshots

### Successful download

<video>
```

**Explaining a choice**
```
## Description

This PR just changes instances of `example` to `examples` and `summary` to `description` to conform to the spec.

## Detail

`example` and `summary` are OpenAPI keywords, but for events we are _not_ using OpenAPI, we're using AsyncAPI, which is based on JSON Schema and uses `examples` and `description` instead.

Conforming to the spec lets us use the `ajv` validator that ships with the generator, so consumers can validate events very easily:

<code snippet>

## More detail

I considered adding linting and validation to the pipeline, but it's pretty complicated, and given no one else is using the validator yet and it's opt-in, I thought I'd leave it for now and we can see how it goes.
```

## Process

1. Draft the title and description, then cut anything a reviewer wouldn't miss.
2. Show me the final title and body. Never create or edit the PR on GitHub until I've approved the exact text.
