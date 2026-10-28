---
name: jira-ticket-voice
description: Write Jira ticket titles and descriptions (tickets, bugs, stories, subtasks, tickets for other teams) the way the user writes them. Use whenever drafting, writing, rewording or tidying a Jira ticket's title or description, including when creating tickets with the jira-tickets skill. This is the default; only switch to the formal style (user story, Gherkin acceptance criteria) when the user asks for it. For Jira comments, use my-voice.
---

# Writing Jira tickets in my voice

Distilled from ~190 tickets I created over a year (SRC, UUI, CRE, VARM, DLT). The goal is a ticket I can create with little or no editing. Same voice as [[my-voice]], but written for whoever picks the ticket up later, maybe months later with no context, so it explains the problem and the why. Default to this style. Only use the formal style below when I ask for it.

## Title

Sentence case, plain, specific. No trailing full stop. Pick one of:

- **The problem, as a statement** (most bugs): `Dev server frequently crashes during hot reload`, `Unable to upload any Document with a dot in the title to a case`, `Typescript checks are not run in CI on PR`, `VX1 sender receives push notification for the message they sent themselves`.
- **An imperative action** (most tasks): Fix, Update, Make, Improve, Remove, Replace, Create, Handle, Add, Move, Investigate, Consider, Retire, Standardise. `Fix CI on main for vs-be-vibe-hcpublisher-svc`, `Make the prod build fail if there are TS errors`, `Consider hardening /temp-media public endpoint`.

Optional prefix when it helps place the ticket:
- Area or platform: `FE:`, `BE:`, `UX:`, `E2E:`, `TFE:`, `WABA:`, `VX1 iOS:`, `Polish:`.
- Kind of work: `SPIKE:`, `QA:` (for issues found while QA-ing a parent), `[DEV-QA]` (dev does the QA), `Missing test case(s):`, `Improve test speed:`, `Policies Step 7:`.
- Parent tickets that just group others: `Incorrect Types from Backend (Parent)`.

Subtask titles follow the sibling pattern on the parent (see the `jira-tickets` skill).

## Description

**Size it to the ticket.** A lot of my tickets are a title plus one or two sentences, and subtasks under a well-described parent often have no description at all. Only bigger or subtle tickets get sections. Don't pad.

**The usual shape**
1. What's wrong or missing now, usually starting with "Currently ...": `Currently the list of allowed file types are [hardcoded on the FE](link), it would be better to fetch it from the BE as it might change.`
2. Why it matters, in concrete terms: `This impacts development speed as you constantly have to faff around with restarting it and checking if it crashed or not.` / `If we don't fix this we will be accumulating all the media sent without cleaning it up as planned, which will result in unnecessary storage costs and could be a potential security risk.`
3. What to do: "We should ...", "This ticket is to ...", or a checklist.

**Bugs**
- Say what happens, then a screenshot or video. Leave a placeholder like `<screenshot>` for me to paste in; Jira attachments can't be added through the API.
- Steps to reproduce as bullets, or a one-liner: `To replicate, just try to register two consecutive users to the same WAB account.`
- Version or environment when relevant: `Version 344 of VX1 app:`.
- What I know and don't, honestly: `Images in S3 are NOT rotated. Seems to happen to most images, although one I tested it did NOT happen to. No idea why.` / `I haven't looked into the practical implications of this in detail but ...`
- A suspected cause or fix if I have one, hedged: `The issue might have been introduced by <PR link> ...`, `I suspect what's happening though is ...`, `Probably worth testing.`

**Tickets for another team (devops, IT, Delta)**
Short, friendly, and the ask is explicit. Say why, and how urgent:
> Currently none of the Source devs have permission to redrive a queue on the `ap-southeast-1` region.
>
> There is a bit of time crunch on this one as we have messages in two DLQs that we need to redrive and in 10 days they will be discarded if we don't do it before then.
>
> Please provide permissions for:

End with "Thanks!" and, when it fits, `(Or let me know if I need to do something).` Starting with "Hey," or "Hi guys," is fine here.

**Tone**
- First person, conversational, full sentences. British/South African spelling (standardise, behaviour).
- Hedge honestly: "I think", "Probably", "Maybe", "I presume", "Not sure if ...", "or something", and a question mark when checking an assumption: `bypasses the problem but is probably not what we want?`
- Suggest options rather than dictating, and say which I'd lean towards: `Other options to explore could be ... The easiest win would maybe be simply to not run the webkit tests on PR`.
- Emphasis with CAPS on the one word that matters (ALL, NOT, EVERY, MUST) or _italics_. Little or no bold.
- Code identifiers, file paths, env vars, commands, error codes and status values in backticks. Repo and service names too: `be-event-catalog`, `comms-svc`, `messaging-gateway`.
- Concrete examples over abstract description: real values, real IDs, a short code block of the error or the payload.

**Links**
- On descriptive text, not bare URLs: `See [Slack thread](url)`, `As per <name> in [Slack](url)`, `Full discussion with <name> on [Slack](url) if needed`, `[Twilio docs](url)`.
- Code links to the exact line on GitHub: `[here](https://github.com/.../file.ts#L76)`.
- Other tickets as `[KEY: summary](url)`, per the `jira-tickets` skill.
- Don't link the ticket's own PRs. Jira picks them up from the ticket key in the branch or PR title. A PR from a different ticket, cited as background (e.g. a suspected cause), is fine.
- Follow-ups and connections: `There will be another ticket later to ...`, `I've logged a follow up to make it required later: [KEY: summary](url).`, `Once this is fixed we can also remove the skip in case.flow.e2e.test.ts for webkit.`

**Checklists**
`- [ ]` items for concrete steps, sites to change, repos to update, or people who need something. Short, start with a verb where it's an action. If the ticket has any other heading (e.g. `## Other notes`), put the checklist under a `# Todo` heading too.

**Sections, only when they earn their place**
Use `##` headings for longer tickets. The ones I actually use:
- `## Context`, `## Goal`, `## Description`, `## Links` (support ticket, Slack thread) at the top of investigation tickets.
- `## Dev notes` / `## Implementation thoughts` for how I'd approach it, with a code snippet if that's quicker than explaining.
- `# Todo` / `## Todo` checklist.
- `## QA notes` (or `# QA Notes`): numbered or bulleted steps to check the change, including commands to run and what to see. `Basically just smoke test that the main app loads in dev` is fine when that's all it needs.
- `## Actions` for what needs to happen next, especially when chasing a vendor.
- `## Security concern`, `## Improvement`, `## Other discarded options` for a proposal with trade-offs.
- `## Other notes` / `## Notes` for loose ends.
- `> UPDATE:` quote line when adding something after creation.

## Things I'd always have to rewrite

- User-story boilerplate ("As a ... I want ... so that ..."), Gherkin and formal acceptance criteria when I haven't asked for the formal style.
- Generic headings like `## Summary`, `## Background`, `## Acceptance Criteria`, `## Expected behaviour / Actual behaviour` on a ticket that doesn't need structure.
- Bold run-in labels like `**What we've seen**` as a substitute for headings or plain sentences.
- Restating the title as the first line.
- Spelling out consequences the reader can work out (`and it's easy for it to hang around forever if we don't clean it up`), or a parenthetical justifying a condition (`(a redriven old event would fail validation)`). Say when and what to do, and stop.
- Pointing to files that live in one repo or on my machine (`More detail in TODO.md in be-comms-svc`). The ticket has to stand on its own.
- Overconfident claims about causes I haven't confirmed. Say "From what I can tell" or "I suspect".
- Salesy or corporate words ("robust", "seamless", "leverage", "ensure"), and em dashes. See [[my-voice]].

## Examples

**Bug, one or two lines**
```
Title: Dropzone file uploads do not display file type validation errors

Currently we just show a generic error message when an Upload fails, rather than for example telling them the file size is too big.

<screenshot>
```

**Task with a why**
```
Title: Restrict images to 5MB in app to adhere to Twilio Media size limit otherwise message will fail

See: [Twilio message size limits](url)

Currently if you try to send an image larger than 5MB it will fail silently. We should probably add a file size restriction in the app so that users know.

<screenshot>
```

**Bug with cause, a suspected fix, and options**
```
Title: Fix CI on main for vs-be-vibe-hcpublisher-svc

CI has [never](url) passed on main for `vs-be-vibe-hcpublisher-svc`.

It [used to error](url) with `Error: No pnpm version is specified.` That was fixed by passing `USE_ACTION_CONFIGURATION` in <PR link>.

Now it errors with ``SemanticReleaseError: Missing `package.json` file.`` The repo itself is not node, so it does not have a `package.json` file.

I suspect what's happening though is that it also doesn't have a `.releaserc.json`, so semantic release is using all defaults which makes it require `package.json`.

Here are some repos that also don't have a package.json that we can use as reference, and/or we could look at the [be-template one](url) and see what's relevant to this project.
```

**Ask to another team**
```
Title: Allow changing the base branch on PRs

Since we've applied the branch protection rules we are no longer able to change the base branch when you've opened a PR. It's very easy to forget to select a feature branch instead of the default main. Previously we could just change it even if you'd opened the PR, however now we have to close and reopen the PR. It would be helpful if we didn't need to do that. Thanks!
```

**Improvement with a checklist and QA notes**
```
Title: Enable TypeScript strict mode for user-guides app

[UUI-738: Move to monorepo with PNPM workspaces](url) flagged that we were not using strict mode in the docs app for TypeScript, so there are a bunch of type errors that need to be fixed when we turn it on. We should be using strict mode for all our apps to help catch bugs before deploying.

- [ ] Set strict mode to `true` in `packages/user-guides/tsconfig.json`
- [ ] Run `pnpm typecheck` in the root and fix all type errors
```

**Proposal with trade-offs**
```
Title: Consider hardening /temp-media public endpoint

## Context

Because AWS pre-signed URLs are too long to be used in Twilio templates we're using a public URL in the template instead. The public endpoint fetches the pre-signed AWS URL when it's called and returns a 302 to download the file.

## Security concern

Because the endpoint is public, theoretically anyone could hit it, and if they somehow guess the UUID of a valid filename and the correct path they would be able to download the media. The window is small because we delete the temp media once it's been processed, so it's very unlikely. However, it's not _impossible_.

## Improvement

We could sign the readUrl with an HMAC signature, then verify the signature when the public endpoint is called. Anyone with the URL can still download the file, but no one can just probe the endpoint with random paths.

## Other discarded options

I also asked Twilio whether the request that fetches the media includes the `X-Twilio-Signature` header, which we could verify. They confirmed that's only for webhooks.
```

## Formal style (only when asked)

When I ask for a more formal ticket (e.g. a story for product or another team's board), use:

```
As a <role> I would like <capability> so that <benefit>.

**Dev Notes:**
- ...

**QA Notes:**
- ...

## Acceptance criteria

**Scenario: <name>**
* Given ...
* When ...
* Then ...
```

Keep the wording plain even here; it's the structure that changes, not the voice.

## Process

1. Work out the kind of ticket (quick bug, task, ask to another team, investigation, proposal) and match the closest example for length and shape.
2. Draft the title and description, then cut anything the person picking it up wouldn't miss.
3. Show me the exact text. Never create or edit the ticket until I've approved it (see the `jira-tickets` skill).
