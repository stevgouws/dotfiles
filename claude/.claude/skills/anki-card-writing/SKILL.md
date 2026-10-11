---
name: anki-card-writing
description: Write Anki cloze cards that stick, following Wozniak's rules of formulating knowledge. Use whenever ending a reply with Anki cards (a genuinely new concept, or a corrected misconception), or when asked to write, fix, review or add an Anki card or flashcard (cards are added to Anki through AnkiConnect).
---

# Writing Anki cards

Based on Piotr Wozniak, "Twenty rules of formulating knowledge" (SuperMemo, 1999):
https://www.supermemo.com/en/blog/twenty-rules-of-formulating-knowledge

Cards are written one or two at a time at the end of a reply, about something that just came up in the work (usually backend or infrastructure). CLAUDE.md decides **when** to add a card. This skill decides **how** to write it and in what format.

Every rule below serves one goal. The card should be simple, unambiguous and recalled the same way every time, months from now, by someone who doesn't remember this conversation.

## Before writing

- **Is it worth a card?** (rule 20) Card concepts, conventions, behaviours and the reasons behind them, meaning things that will change how the user writes or designs code. Skip trivia, anything that takes seconds to look up, and anything obvious to a senior frontend developer.
- **Is it understood?** (rules 1–2) The card comes after the explanation in the reply, not instead of it. If the reply didn't explain the idea, the card is premature. This applies to cards about the current work. When the user just asks for a card, skip the explanation and pick a topic they already know well enough to card.
- **Basics are fine.** (rule 3) A simple foundational fact the user just got wrong is worth carding: cheap to review, costly to forget.
- **Misconceptions:** card the correct fact, never the wrong belief.

## Writing the card

### One fact per cloze (rule 4)
- Each cloze number tests one fact. Its answer is as short as possible: a term, flag, number or short phrase.
- If an answer runs to a whole clause, find the key term inside it and cloze that instead.
- When splitting, keep the existence fact, not just the detail. "Why X happens" is no use if the user forgets that X happens at all.
- For CLI commands, keep the tool name outside the cloze and cloze only the subcommand or flag: `<code>aws {{c1::s3 sync}}</code>`, not `{{c1::<code>aws s3 sync</code>}}`.

### Cloze numbering (rules 5, 17)
- **Default:** a single `c1`.
- **Term and meaning:** cloze the term as `c1` and what it means or does as `c2` on the same note. That tests it in both directions:
  `In SQS, the {{c1::visibility timeout}} is how long a received message stays {{c2::hidden from other consumers}}.`
- **Paired contrast:** give both halves the same number so they're recalled together:
  `JavaScript default parameters are evaluated when the function is {{c1::called}}, not when it's {{c1::defined}}.`
- At most two cloze numbers per note. Never one number per list item.
- Don't cloze "not", "always", "never" or anything with a yes/no answer. Rephrase the fact positively.
- Add a hint when the type of answer is unclear: `{{c1::30 seconds::duration}}`.
- The rest of the sentence must not give the answer away.

### Only one answer fits (rules 11, 16)
- Open with a short context phrase, as the user's deck does: "In the shell,", "In TypeScript,", "In AWS SNS/SQS,", "In PostgreSQL,". The card is reviewed alone, in a mixed deck.
- Read the sentence with the blank. Could another reasonable answer fit? If so, add a qualifier until only one does.

### Optimise wording (rules 12–13)
- Write a fresh sentence. Never paste a paragraph from docs or a book with a blank in it.
- Cut every word that doesn't help trigger the answer.
- Anchor to frontend knowledge when the analogy is accurate. Don't force it.
- Don't hope side details will rub off. If one matters, put it in Back or a second card.

### Lists (rules 9–10)
Never cloze an unordered list (e.g. the fields of a message as `c1`–`c5`). Card the one member that matters, or list the members in Back as reference, not as recall.

### Volatile facts and sources (rules 18–19)
- Limits, defaults, quotas, pricing and versions change. Stamp them outside the cloze: "(2025)", "(Node 22)".
- When either would do, card the stable concept rather than the volatile number.
- Docs links go in the Ref field, never in the card text.

## Format

Write a line `**Anki**`, then each card in its own fenced code block. Use one line per field, named after the fields of the user's `Cloze` note type:

```
Deck: Main::AWS
In AWS SNS→SQS, <code>raw_message_delivery = true</code> delivers the message body {{c1::without the SNS envelope}}.
Back: Without it, the body is JSON with <code>Message</code>, <code>MessageId</code>, <code>TopicArn</code>, etc.
Ref: https://docs.aws.amazon.com/sns/latest/dg/sns-large-payload-raw-message-delivery.html
```

- **Deck** is the closest existing topic subdeck under `Main::` (e.g. `Main::AWS`, `Main::HTTP`, `Main::Javascript::Typescript`, `Main::System Design`). Use `Main::Default` when nothing fits. Never invent a deck; if unsure what exists, run `anki.py read deckNames`.
- The line after Deck is the **Cloze** field. **Back** and **Ref** are optional; leave out any line with nothing useful in it.
- The fields are HTML, not markdown. Wrap commands, flags, identifiers, config keys and resource names in `<code>…</code>`. Use `<br>` for line breaks. Inside code, escape `<`, `>` and `&` as `&lt;`, `&gt;` and `&amp;`.
- **Back** holds one short thing worth reading after grading: a tiny code example, the reason, or a caveat.
- **Ref** holds a docs URL, or a book name with chapter or item.

## Talking to Anki

`anki.py` in this skill's folder is the only way to reach Anki: it adds new notes and runs read-only lookups. The user's collection holds years of review history, so changing existing notes is always left to the user in Anki.

- **To fix a card**, even one just added: show the corrected card and the user edits it in Anki.
- **When a task needs something `anki.py` can't do:** say so and stop. The script holds the API key and its short action list is what keeps the collection safe, so going around it or widening the list removes that safeguard.

### Adding

Show the cards first. Add them only when the user asks, since added cards skip their review.

Write the cards with the Write tool to a JSON file in the session's scratchpad directory, then pass the file's path to the script. Never put card text in the command itself: its braces and quotes make Claude Code ask the user to approve every run.

```json
[{"deck": "Main::AWS", "cloze": "In AWS SNS→SQS, …", "back": "…", "ref": "https://…"}]
```

- **Default ("add it", "open it", "gui")**: `python3 ~/.claude/skills/anki-card-writing/anki.py gui <scratchpad>/cards.json` opens a single card in Anki's Add window, where the user edits it and clicks Add. The file must hold exactly one card, so open several cards one at a time, waiting for the user between each.
- **Only when the user says "cli"**: `python3 ~/.claude/skills/anki-card-writing/anki.py add <scratchpad>/cards.json` adds every card in the file directly, without the Add window.
- After opening or adding cards, reply with only a confirmation line, such as "✔ Opened in Anki" or "✔ Added 2 cards". Don't add anything else: no summary of the card, no explanation of the topic and no reminder to click Add. The user reads the card in Anki.
- Pass any deck change the user asked for.
- Every note is tagged `added-by-claude::cli` (or `added-by-claude::gui` when opened in Anki's Add window). Add `"tags": ["books::<Book-Title>"]` when the card comes from one of the user's books, matching their existing tags (e.g. `books::A-Philosophy-Of-Software-Design`).
- Report what was added, or the error. A duplicate error means the card already exists, so tell the user rather than retrying.

### Reading

`anki.py read <action> [name=value ...]` runs one read-only AnkiConnect action, e.g. to list decks or check whether a similar card already exists. Values that parse as JSON are sent as JSON, anything else as a string:

```sh
python3 ~/.claude/skills/anki-card-writing/anki.py read findNotes query="deck:Main::HTTP encode"
python3 ~/.claude/skills/anki-card-writing/anki.py read notesInfo notes=[1786808321430]
```

Running it with an action that isn't allowed prints the allowed list.

## Examples

### Good
```
In the shell, {{c1::<code>uniq</code>}} filters out duplicate lines.
Back: Only <i>adjacent</i> duplicates, hence <code>sort | uniq</code>.
```
```
By default, a shell pipe passes on {{c1::<code>stdout</code>}} but not {{c1::<code>stderr</code>}}.
Back: <code>cmd 2&gt;&amp;1 | …</code> pipes both.
```
```
In TypeScript, {{c2::numeric}} enums create a {{c1::reverse mapping}} at runtime.
Back: <code>enum E { A, B }</code> → <code>Object.values(E)</code> is <code>["A", "B", 0, 1]</code>
```

### Bad → fixed
- **List as clozes:** `The SNS {{c1::envelope}} is a {{c2::JSON wrapper}} with things like {{c3::Message}}, {{c4::MessageId}}, {{c5::TopicArn}}`
  → `In AWS SNS→SQS, the {{c1::envelope}} is the {{c2::JSON wrapper}} SNS puts around a published message.` The fields go in Back.
- **Clause as answer:** `The return value from the reducer becomes {{c1::the new value of the first element returned by the useReducer hook}}`
  → `In React, the reducer's return value becomes the new {{c1::state}} from <code>useReducer</code>.`
- **Pasted passage:** a three-sentence book paragraph ending in `…a {{c1::retry storm}}`
  → `When an overloaded service's clients time out and resend requests, load can spiral into a {{c1::retry storm}}.`
- **Binary answer:** `SQS standard queues {{c1::do not}} guarantee ordering.`
  → `For strict message ordering in SQS, use a {{c1::FIFO}} queue.`

## Check before sending

- [ ] Worth remembering, and explained in the reply?
- [ ] Each cloze tests one fact, with the shortest possible answer?
- [ ] At most `c1` and `c2`, with no list split into clozes?
- [ ] Key term clozed, not a filler or yes/no word?
- [ ] Opens with a context phrase, and only one answer fits?
- [ ] Fresh, short sentence rather than a pasted passage?
- [ ] HTML (not markdown), `<code>` on identifiers, special characters escaped?
- [ ] Volatile facts stamped; docs link in Ref?
