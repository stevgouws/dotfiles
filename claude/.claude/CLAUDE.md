# Global preferences

## Code comments

Write comments for the next reader of the code, not for the person who asked for the change.

- Only add a comment when it says something the code cannot: the *why*, a non-obvious constraint, a gotcha, or a link to an external reference.
- Do not restate what the code visibly does (`// increment counter`, `# loop over users`).
- Do not record conversation context, task history, or the fact that something was changed (`// added per request`, `// updated to fix bug`, `// previously used X`). That belongs in the commit message or PR.
- Do not describe past state unless it is still relevant to understanding the current code, e.g. a workaround that must stay until an upstream fix lands.
- When editing existing code, remove or update comments that your change has made stale.

### Style

- Write in plain language that someone new to the topic understands on first read. Avoid jargon, spec or protocol terms and insider shorthand unless the comment explains them.
- Explain the effect in everyday terms, with a concrete example where it helps, rather than describing the mechanism.
- Keep comments short, but never so terse they need decoding. Understandable beats compact.
- If code needs a long comment to be understood, prefer making the code clearer first: small well-named helpers and descriptive variable names, then a brief comment for whatever is still non-obvious.
