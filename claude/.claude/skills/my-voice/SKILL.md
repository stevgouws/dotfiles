---
name: my-voice
description: Write in the user's own voice for messages they will send as themselves — Slack messages and threads, DMs, PR announcements, status updates, heads-ups, replies to colleagues, Jira or PR comments, short emails. Use when asked to draft, write, reply to, word or rewrite something "as me", "in my voice", "for me to send", or to tidy up a message they wrote. Not for code comments, docs or formal documents. For PR titles and descriptions, use pr-voice.
---

# Writing in my voice

Distilled from a year of my Slack messages. The goal is a draft I can send with little or no editing. Text that already sounds like me is also quicker for me to read and check, because I don't have to translate it into how I'd say it. When in doubt, write less and write it plainer.

## Overall feel

Friendly, direct, low-ceremony. A colleague talking to colleagues, not a manager or a support desk. I get to the point fast, add context in parentheses, and soften asks or pushback with warmth and a bit of humour rather than with formality.

## Rules

**Length and shape**
- Short. Most messages are one or two sentences. In DMs I often split a thought into several quick messages rather than one long one; when drafting a DM, it's fine to give a few short lines instead of a paragraph.
- Longer posts (status updates, incident write-ups, asking devops for something) are a few short paragraphs or a bullet list, never an essay. No headings. No sign-off on a single message unless it's a "heads up I'm off" kind of post.
- Lead with the point. Context comes after, often in parentheses: `(self-merging, feel free to check)`, `(will need to be tested in dev)`.

**Tone and words**
- British/South African English spelling: realise, standardise, behaviour.
- Casual openers when starting a thread: "Hey guys", "Hey", "Heya", "Hi mate", "Morning". In DMs "mate", "man", "dude" are normal. Often no greeting at all for a quick question.
- Quick acknowledgements: "Cool", "Cool cool", "Sweet", "Sweet, got it", "Nice", "Awesome thanks", "np", "happy days", "Thanks, merged :+1:", "Nice, approved :white_check_mark:".
- Filler I actually use: "basically", "anyway", "btw", "fwiw", "atm", "just", "I think", "I guess", "presumably", "lol", "ha", "ah okay", "oh damn", "aah".
- Hedge with "I think…?" and end statements with a question mark when I'm checking an assumption: "I think X already mentioned this is expected as we haven't deployed the consumer yet?"
- Self-deprecating and a bit hyperbolic: "roughly a million edge cases", "touched a looot of files", "GitHub Actions is having a bit of a meltdown".
- Own mistakes quickly and lightly: "oh damn my bad", "Sorry, must have been annoying!", "ignore me! I clicked on the wrong channel".
- Asks are polite but not grovelling: "when you have a minute please", "Could I get a re-approve on this one please", ":pray:". Say why I'm asking and how much it matters ("not urgent, but…", "it's now starting to be a blocker", "If it's expensive I can work around it").
- Pushback is direct and fair: acknowledge their point, state mine plainly, keep it warm ("I don't think that's a fair statement mate :laughing:", "I 100% agree that… but…"), then move on ("we can see how it goes :+1:").

**Emoji**
- Slack shortcodes, one per message at most, usually at the end: `:+1:` `:laughing:` `:sweat_smile:` `:pray:` `:wave:` `:wink:` `:white_check_mark:`.
- `:point_right:` before a link in PR or ticket announcements. `:point_up_2:` / `:point_down:` to refer to an adjacent message or attachment.
- `:laughing:` or `:sweat_smile:` to soften a complaint, a correction or an awkward ask.

**Formatting**
- Links go on descriptive text (`<url|PR title>`), not bare URLs, when there's a title to use.
- `cc @person` on its own line at the end when looping someone in.
- Bullets for lists of PRs, questions or status items. No bold, no headings.
- Lowercase starts are fine in quick DMs and replies. Sentence case for anything posted to a channel.

**Things I'd always have to rewrite**
- Em dashes. I use a comma, full stop, parentheses or " - ".
- Stiff or corporate phrasing: "I hope this finds you well", "just circling back", "Great question!", "I'd be happy to", "Let me know if you have any questions", "delve", "leverage", "streamline".
- Over-explaining, over-apologising, or exclamation marks on every sentence.
- Typos. My real messages have some, but don't copy them. A clean draft is what I want.

## Recurring formats

**PR announcement (channel)**
```
PR to :point_right: <url|Fix lint-staged linting everything> (self-merging, feel free to check)
```
Variants: "Small PR to", "Tiny PR to", "One liner to", or `repo-name - <url|title>`. Add a short note after if there's something reviewers should know.

**Several PRs**
```
Bump on vulnerability fix reviews please when you can:

service-a
• <url|Fix vulnerabilities> (not to be merged until we can do decent regression testing)
service-b
• <url|Fix vulnerabilities & convert to vite> (will need to be tested in dev)
```

**Heads up / FYI**
```
FYI I've merged main into dev so we have the latest fixes from main
```
```
Heads up I'm off tomorrow.
• I've reviewed <name>'s <url|PR> to get the e2e tests running in the pipeline.
• <name> I'm still reviewing your e2e tests, and as discussed I'm tweaking things to match the <url|testing guidance>

Catch y'all on Wednesday :wave:
```

## Examples by situation

**Reporting a problem to another team**
> Hey guys, not urgent, but I can't see changes deploying to dev.
>
> • <url|Here> is a successful release job from last night
> • Everything in Argo looks fine, but it shows last sync was 12 days ago
> • In Kargo there's a red outline but it's not really obvious to me what that means?

**Asking for something, with the reason**
> Hey guys, would it be very expensive to start sandbox2 from 6am UTC on workdays instead? I usually start work around 6:30-7am BST which is 5:30-6am UTC. I don't always need it, but the main annoyance is that our e2e tests run against it, so I can't work on them and any PRs I open fail e2e until I go back and re-trigger the job.
>
> If it's expensive I can work around it, but if we could bump it down it would be great.

**Explaining an incident in plain terms**
> These alerts have been firing most days for the last 10 days or so. From what I can tell, when nodes get replaced a lot of pods get rescheduled onto the same node (11 on one node this morning). They use a lot of CPU when starting up, so the node maxes out, their health checks time out, and Kubernetes restarts them. That keeps the CPU pinned, so it turns into a restart loop until they all eventually get through startup, which took about an hour today.
>
> I've logged <url|Investigate recurring pod restart loops> with more details.
>
> cc @lead

**Quick how-to for a teammate**
> Basically:
>
> Merge your fix to main
>
> Create a branch called release-candidate/1.88.5 at the point where 1.88.5 was released.
>
> Cherry-pick your fix into that branch & push.
>
> That should generate a 1.88.5-rc1 package you can use on main without getting the changes you don't want.
>
> More details <url|here> if needed, or just give me a shout.

**Pushing back**
> @name I don't think that's a fair statement mate :laughing:. I 100% agree alerts should NOT be ignored, but it's really difficult when the scope is so wide and there's so much going on at once, while we're also under pressure to ship features. So I'm still learning what's what. Where possible, alerts should be scoped to only who needs to know, which is why I asked.
>
> I understand in this case it's also our concern, so it's fine as is, we can see how it goes :+1:

**Chasing something that's stalled**
> I flagged this a couple of weeks ago and logged <url|TICKET-123>, which has been in progress for a while.
>
> Could we maybe get an update when you can please @name, as it's now starting to be a blocker

**Owning a mistake**
> PRs to fix lint-staged linting everything instead of only staged files. (I introduced this in the linting PRs, didn't realise lint-staged silently passes the staged files as arguments when it calls an npm script.) Sorry, must have been annoying!

**Asking to take over someone's PR**
> hey for the e2e tests PR, do you mind if I just make and push some changes myself? Some of it will be faster to change than to explain what I'd like, and sometimes I want to play around with things anyway. Then you can review what I changed in case I missed something.

**Short DM replies**
> Cool, I can have a look on Monday and talk to <name> if needed

> aah, I checked the gitops repo and saw it defined so just assumed it was already plugged into the app. Thanks for catching

> Hey ok will have a look when I'm back. Hope you don't have to work too much on the weekend man

> Signing off dude. Have a good weekend :wave:

## Process

1. Work out the situation (quick reply, PR post, heads-up, ask, pushback, status update) and match the closest example above for length and shape.
2. Draft it. Then cut anything I wouldn't bother typing.
3. Give me the draft ready to paste, in a code block if it's Slack-formatted. If the tone is a judgement call (e.g. pushback to someone senior), offer one alternative at most.
4. Never send or post it yourself unless I've approved the exact text.
