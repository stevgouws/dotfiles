"""Turn a JSON list of spelling words per week into an Anki import file.

Usage: python3 make_import.py <words.json> <output.txt>

words.json maps each week label to its words, in sheet order:
    {"Week 1": ["admission", "discussion"], "Week 2": ["direction"]}

The output is a tab-separated file with Anki's header lines, so File > Import
picks the note type, deck and tags without any manual mapping.
"""

import json
import sys

NOTE_TYPE = "Retina Images + large text"
DECK_PREFIX = "Zoe::Spelling::"
TAG = "added-by-claude::desktop"


def build_lines(weeks: dict[str, list[str]]) -> list[str]:
    lines = [
        "#separator:tab",
        "#html:true",
        f"#notetype:{NOTE_TYPE}",
        f"#tags:{TAG}",
        "#deck column:1",
    ]
    for week, words in weeks.items():
        for word in words:
            word = word.strip()
            if word:
                # The only field column goes to the note type's first field, Front,
                # which is also the field Anki matches on to spot words already added.
                lines.append(f"{DECK_PREFIX}{week.strip()}\t{word}")
    return lines


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("Usage: python3 make_import.py <words.json> <output.txt>")
    with open(sys.argv[1], encoding="utf-8") as f:
        weeks = json.load(f)
    lines = build_lines(weeks)
    with open(sys.argv[2], "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    card_count = sum(1 for line in lines if not line.startswith("#"))
    print(f"Wrote {card_count} cards across {len(weeks)} weeks to {sys.argv[2]}")


if __name__ == "__main__":
    main()
