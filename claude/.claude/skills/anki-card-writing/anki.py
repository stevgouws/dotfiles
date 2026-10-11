#!/usr/bin/env python3
"""The only way Claude talks to Anki: add new notes, or run read-only lookups.

  anki.py add <cards.json>         adds every card in a JSON file:
      [{"deck": "Main::HTTP", "cloze": "...", "back": "...", "ref": "...", "tags": ["books::..."]}]
      Only "deck" and "cloze" are required. Every note also gets the "added-by-claude::cli" tag.
  anki.py gui <cards.json>         opens a one-card JSON file in Anki's Add window, so the
      user can edit it there and click Add themselves. The note gets the "added-by-claude::gui" tag.
  anki.py read <action> [name=value ...]
      runs one AnkiConnect action from READ_ONLY_ACTIONS. Values that parse as JSON are
      sent as JSON, anything else as a string, e.g.
        anki.py read findNotes query="tag:added-by-claude"
        anki.py read notesInfo notes=[1786808321430]

Cards come from a file rather than the command line so the command stays short and
plain. Card text full of braces and quotes makes Claude Code ask for approval each time.

Nothing here can change or delete existing notes. Keep it that way: actions that
edit, delete, move, tag or suspend are deliberately left out of READ_ONLY_ACTIONS.
"multi" must stay out too, because it runs any list of actions inside one call.

Anki desktop must be open. The API key is read from the macOS Keychain
(service "anki-connect") so it never shows up in commands or output.
"""

import json
import subprocess
import sys
import urllib.error
import urllib.request

ANKI_CONNECT_URL = "http://127.0.0.1:8765"

READ_ONLY_ACTIONS = {
    "version",
    "deckNames",
    "getDecks",
    "getDeckStats",
    "modelNames",
    "modelFieldNames",
    "getTags",
    "findNotes",
    "findCards",
    "notesInfo",
    "cardsInfo",
    "cardsToNotes",
}


def api_key():
    result = subprocess.run(
        ["security", "find-generic-password", "-s", "anki-connect", "-w"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.exit("No 'anki-connect' key found in the macOS Keychain.")
    return result.stdout.strip()


def call(action, key, **params):
    body = json.dumps({"action": action, "version": 6, "key": key, "params": params})
    request = urllib.request.Request(ANKI_CONNECT_URL, body.encode("utf-8"))
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            reply = json.load(response)
    except urllib.error.URLError:
        sys.exit("Can't reach AnkiConnect. Is Anki open?")
    if reply["error"]:
        raise RuntimeError(reply["error"])
    return reply["result"]


def load_cards(path):
    with open(path, encoding="utf-8") as file:
        return json.load(file)


def to_note(card, added_via):
    return {
        "deckName": card["deck"],
        "modelName": "Cloze",
        "fields": {
            "Cloze": card["cloze"],
            "Back": card.get("back", ""),
            "Ref": card.get("ref", ""),
        },
        "tags": [f"added-by-claude::{added_via}", *card.get("tags", [])],
    }


def add(cards):
    key = api_key()
    failed = False
    for card in cards:
        try:
            note_id = call("addNote", key, note=to_note(card, "cli"))
            print(f"added {note_id} to {card['deck']}")
        except RuntimeError as error:
            failed = True
            print(f"failed ({card['deck']}): {error}\n  {card['cloze']}")
    sys.exit(1 if failed else 0)


def open_in_add_window(cards):
    if len(cards) != 1:
        sys.exit("gui takes exactly one card: Anki's Add window holds a single note.")
    try:
        call("guiAddCards", api_key(), note=to_note(cards[0], "gui"))
    except RuntimeError as error:
        sys.exit(f"AnkiConnect error: {error}")
    print("opened in Anki's Add window")


def parse_params(pairs):
    params = {}
    for pair in pairs:
        name, has_equals, value = pair.partition("=")
        if not has_equals:
            sys.exit(f"Expected name=value, got '{pair}'")
        try:
            params[name] = json.loads(value)
        except json.JSONDecodeError:
            params[name] = value
    return params


def read(action, params):
    if action not in READ_ONLY_ACTIONS:
        sys.exit(f"'{action}' isn't allowed. Read-only actions: {', '.join(sorted(READ_ONLY_ACTIONS))}")
    try:
        result = call(action, api_key(), **params)
    except RuntimeError as error:
        sys.exit(f"AnkiConnect error: {error}")
    print(json.dumps(result, indent=2, ensure_ascii=False))


def main():
    match sys.argv[1:]:
        case ["add", path]:
            add(load_cards(path))
        case ["gui", path]:
            open_in_add_window(load_cards(path))
        case ["read", action, *pairs]:
            read(action, parse_params(pairs))
        case _:
            sys.exit(__doc__)


if __name__ == "__main__":
    main()
