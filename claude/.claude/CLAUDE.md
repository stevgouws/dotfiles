# Global preferences

## Code comments

Write comments for the next reader of the code, not for the person who asked for the change.

- Only add a comment when it says something the code cannot: the *why*, a non-obvious constraint, a gotcha, or a link to an external reference.
- Do not restate what the code visibly does (`// increment counter`, `# loop over users`).
- Do not record conversation context, task history, or the fact that something was changed (`// added per request`, `// updated to fix bug`, `// previously used X`). That belongs in the commit message or PR.
- Do not describe past state unless it is still relevant to understanding the current code, e.g. a workaround that must stay until an upstream fix lands.
- When editing existing code, remove or update comments that your change has made stale.
