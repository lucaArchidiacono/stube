---
name: issue
description: Creates or updates a GitHub issue for planned work, a feature, a decision or a bug. Use whenever something needs planning, since Stube keeps all planning in GitHub issues and never in the repo.
---

Stube's plan lives in GitHub issues on `lucaArchidiacono/stube`. The repo holds no planning, scope or design documents. Issues are public, so write them for anyone reading along.

## Title

Imperative and specific: "Add to-dos with assignee and due date", not "To-dos". Keep it under 60 characters.

## Body

Keep it short. Use only the sections that apply:

```
One or two sentences: what this is and why it matters to a household.

## Screens
- Phone: …
- Tablet: …
- Desktop: …

## Data
- table: columns, and which screen shows each one

## Out of scope
- One line per thing deliberately left out.
```

- A feature lists its screens at all three widths and the data each one needs before any code is written. That's the "design first" rule.
- A decision issue states the question, the options and a recommendation.
- Link related issues with `#123`. Mention what blocks it: "After #12".
- No implementation chatter, no testing steps, no "Generated with" lines.

## Labels

Use one or two of: `feature`, `ios`, `cloud`, `launch`, `decision`, `design`, `chore`, `bug`.

## Commands

```sh
gh issue create --repo lucaArchidiacono/stube --title "…" --label feature --body-file body.md
gh issue edit 12 --repo lucaArchidiacono/stube --body-file body.md
gh issue list --repo lucaArchidiacono/stube
```

When work on an issue is done, reference it from the pull request (`Closes #12`) rather than closing it by hand.
