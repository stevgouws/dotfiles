#!/usr/bin/env python3
"""The only way Claude talks to Anki: add new notes, or run read-only lookups.

  anki.py add                      reads a JSON list of cards from stdin:
      [{"deck": "Main::HTTP", "cloze": "...", "back": "...", "ref": "...", "tags": ["books::..."]}]
      Only "deck" and "cloze" are required. Every note also gets the "added-by-claude" tag.
  anki.py read <action> [params]   runs one AnkiConnect action from READ_ONLY_ACTIONS,
      e.g. anki.py read findNotes '{"query": "tag:added-by-claude"}'

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


def add():
    cards = json.load(sys.stdin)
    key = api_key()
    failed = False
    for card in cards:
        note = {
            "deckName": card["deck"],
            "modelName": "Cloze",
            "fields": {
                "Cloze": card["cloze"],
                "Back": card.get("back", ""),
                "Ref": card.get("ref", ""),
            },
            "tags": ["added-by-claude", *card.get("tags", [])],
        }
        try:
            note_id = call("addNote", key, note=note)
            print(f"added {note_id} to {card['deck']}")
        except RuntimeError as error:
            failed = True
            print(f"failed ({card['deck']}): {error}\n  {card['cloze']}")
    sys.exit(1 if failed else 0)


def read(action, params_json="{}"):
    if action not in READ_ONLY_ACTIONS:
        sys.exit(f"'{action}' isn't allowed. Read-only actions: {', '.join(sorted(READ_ONLY_ACTIONS))}")
    try:
        result = call(action, api_key(), **json.loads(params_json))
    except RuntimeError as error:
        sys.exit(f"AnkiConnect error: {error}")
    print(json.dumps(result, indent=2, ensure_ascii=False))


def main():
    match sys.argv[1:]:
        case ["add"]:
            add()
        case ["read", action]:
            read(action)
        case ["read", action, params_json]:
            read(action, params_json)
        case _:
            sys.exit(__doc__)


if __name__ == "__main__":
    main()
