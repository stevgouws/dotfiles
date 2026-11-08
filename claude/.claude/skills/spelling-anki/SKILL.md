---
name: spelling-anki
description: Turn a photo or scan of Zoe's school spelling sheet into an Anki import file, one card per word, each week's column in its own Zoe::Spelling::Week N deck. Use when the user shares a spelling list or sheet of spelling words and asks for Anki cards, flashcards or an import file.
---

# Spelling sheet → Anki import file

The user gives a sheet of spelling words laid out in week columns (e.g. "Year 4 Spelling – Michaelmas B"). Produce a `.txt` file they import with Anki's File > Import. Don't add cards through AnkiConnect or `anki.py`.

## Card format

- **Note type:** `Retina Images + large text` (fields: `Front`, `Large_text_question`, `Back`).
- **Field:** the word goes in `Front` only, exactly as printed (keep the sheet's spelling and capitalisation, e.g. British `centre`, `favourite`, and `Olympic`).
- **Deck:** each week column maps to `Zoe::Spelling::Week N`, using the column heading's number.
- **Tag:** `added-by-claude::desktop` on every card.
- One card per word, including the coloured topic words at the bottom of each column. Skip headings, instructions and anything that isn't a spelling word.

## Steps

1. **Transcribe** every column top to bottom. Read carefully: handwriting-style fonts and photo angles make letters easy to misread (`ll`/`ii`, `rn`/`m`, double letters). Count the words per column; sheets usually have the same number in each, so a short column means a missed word.
2. **Write the words** with the Write tool to `words.json` in the session's scratchpad directory, mapping each week label to its words in sheet order:
   ```json
   {"Week 1": ["admission", "discussion"], "Week 2": ["direction"]}
   ```
3. **Build the import file** in `~/Downloads`, named after the sheet (e.g. `zoe-spelling-michaelmas-b.txt`):
   ```sh
   python3 ~/.claude/skills/spelling-anki/make_import.py <scratchpad>/words.json ~/Downloads/zoe-spelling-michaelmas-b.txt
   ```
   The script writes Anki's header lines (`#notetype`, `#deck column`, `#tags`), so the import needs no field mapping. Include every word: Anki's import skips the ones already there (see below), so don't look them up through AnkiConnect.
4. **Reply** with a compact table of the words per week so the user can check the transcription against the sheet, the file's full path, the card count, and a one-line reminder to set **Existing notes** to **Preserve** when importing. Flag any word you weren't sure you read correctly.

## Importing (for the user)

In Anki: File > Import, pick the `.txt` file. The note type, decks and tag are pre-set by the file header; Anki creates any missing `Zoe::Spelling::Week N` decks.

Anki treats a row as a duplicate when a note of the same note type already has that word in `Front`, wherever that note is. To skip those words, set **Existing notes** to **Preserve** and **Match scope** to **Note type** in the import dialog. The file header can't set either option. Anki's default, **Update**, would rewrite the existing notes from the file instead of leaving them alone.
