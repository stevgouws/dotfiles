# Global preferences

## About me

- Senior Software Developer at VoxSmart (financial trade compliance). ~10 years commercial experience, full-stack but historically frontend-heavy.
- Strong: React, TypeScript, Redux, TanStack Query, micro-frontends, Vite, testing (Playwright, Vitest, React Testing Library, MSW), Storybook, Tailwind. No need to explain these.
- Growing: backend and infrastructure. That means Node/Express, microservices, event-driven architecture, AWS (SQS, SNS, S3 and related services), Docker, PostgreSQL. I understand most of it at a high level but may have gaps in conventions and practical detail.
- I'm usually on a deadline, so getting the work done comes first.

## Currently reading

Reference these when relevant to the work, but don't assume I know material past my progress point.

- Building Microservices, 2nd ed. (Sam Newman): 6%
- Designing Data-Intensive Applications, 2nd ed. (Kleppmann, Riccomini): 7%
- The Design of Web APIs (Arnaud Lauret): 42%
- Effective TypeScript, 2nd ed. (Dan Vanderkam): halfway through ch. 3
- The Pragmatic Programmer, 20th Anniversary ed. (Thomas, Hunt): 16%
- Effective Shell (Dave Kerr): 35%
- Linux Command Line and Shell Scripting Bible, 4th ed. (Blum, Bresnahan): 15%
- Practical Vim, 2nd ed. (Drew Neil): 27%

Finished: Simplicity (Dave Thomas), tmux 3 (Brian P. Hogan).

## Editing Claude config

- `~/.claude` is managed from my dotfiles. Make global Claude edits (CLAUDE.md, skills, settings, etc.) in `~/dotfiles/claude/.claude`, not in `~/.claude`.

## How to help me learn

- Don't teach by default. Do the task and keep explanations short.
- Watch for learning opportunities, especially in backend/infra code. Call it out when I:
  - make a wrong assumption about how something works
  - use a non-idiomatic or unconventional pattern
  - follow a bad practice (security, data integrity, reliability, performance, cost)
- Do this even when I didn't ask and even when my approach works. Briefly state the conventional approach and why, in a sentence or two, and add a docs link if one helps.
- If something is a matter of preference rather than an established convention, say so.
- Skip nits that linting and formatting already cover.

## Anki cards

- I use Anki daily. When something genuinely new comes up, or you correct a misconception of mine, end your reply with one or two Anki cards at most. Most replies should have none, and routine things don't count.
- Write them using the `anki-card-writing` skill, which covers how to word and format them.

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
