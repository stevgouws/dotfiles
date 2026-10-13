---
name: react-testing-library
description: The user's preferences for writing React Testing Library tests (queries, assertions, waiting, test-only code). Use when writing, editing or reviewing component or page tests that use @testing-library/react, user-event or jest-dom, in Vitest or Jest.
---

# React Testing Library

How the user likes RTL tests written. These are preferences on top of the usual RTL guidance (query by role, test what the user sees); follow the surrounding tests where they differ.

## Assert on text with `toHaveTextContent`

When a test checks that something shows a specific value, find the element by something stable and accessible (its role or label), then assert on its text. Don't search for the value itself and check it exists:

```js
// Preferred
expect(screen.getByLabelText('Start date')).toHaveTextContent('Jun 03, 2026');
expect(await screen.findByRole('alert')).toHaveTextContent('Error: Request failed with status code 500');

// Avoid
expect(screen.getByLabelText('Jun 03, 2026')).toBeInTheDocument();
await screen.findByText('Error: Request failed with status code 500');
```

- **Why:** debugging is much easier. When the value is wrong, `toHaveTextContent` fails with exactly what differs:
  ```
  Expected element to have text content:
    Jun 03, 2026
  Received:
    02 Jun 2026
  ```
  Searching for the value instead fails with "Unable to find…" followed by the whole DOM, which you have to read through to work out what was actually rendered.
- It can take a bit more effort, since the element needs an accessible way to find it (a role, a label). That's a good thing: it pushes the component towards better accessibility. Add a label to the component rather than falling back to a test ID or class name.
- With a string, `toHaveTextContent` matches if the text appears anywhere in the element. Use a regex such as `/^…$/` when the whole text must match.

## Don't add redundant assertions

- `getBy*` and `findBy*` already fail when nothing is found, so don't wrap them in `expect(...).toBeInTheDocument()`. A bare `screen.getByRole('row', { name: /Aaliyah/ })` is the assertion.
- Use `toBeInTheDocument()` only with `queryBy*`, in its negative form: `expect(screen.queryByText('…')).not.toBeInTheDocument()`.

## Use Testing Library, not the DOM

- Query through `screen` and `within`, not `document.querySelector`, class names (e.g. `.MuiDataGrid-overlay`) or `container`.
- Scope queries with `within(...)` when the same text could appear elsewhere on the page, e.g. inside the grid or a dialog.
- If an element can't be found by role, check why before falling back. It's often hidden from the accessibility tree, e.g. an open MUI menu or modal sets `aria-hidden` on the rest of the page, and fixing that is usually the better change.

## Waiting

- Wait for the thing the test is about with `findBy*`, or a shared helper (e.g. `waitForTableToLoad` in the project's `testUtils`), rather than relying on an unrelated query to wait indirectly.

## Test-only code

- Don't add props or code to components only to make them testable (e.g. jsdom workarounds). Put those in the test setup, the test theme or the render wrapper.
