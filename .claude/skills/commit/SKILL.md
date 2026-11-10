---
name: commit
description: Creates a commit with very short and concise information. Use when creating a commit, creating an optional description and title for the given commit.
---

When creating a commit always use the following:

## Clear commit titles

The title of a commit serves as the first point of interaction and the first thing that is noticed. It sets the tone for what has been changed, added or removed. Here are some guidelines:

Use imperative mood: For example, "Remove deprecated method in API" instead of "Removing".

Be concise and specific: A clear commit title succinctly describes what the change does, not just what area it affects. For instance, instead of "Fix bug", use "Fix login button unresponsive issue on Safari".

Include optional description: If applicable and if the title is not enough information, add a description to the commit message. It's preferred to only have a commit title and no additional message. But if the title does not have enough information or is too long, keep the title as short as possible and add additional information into the message body.

## Writing effective commits

The title gives developers instant feedback on what has been changed in the given commit. It's very important that the title is kept short and concise.
If the title gets too long (max 50 characters), then add more information to the message body.
But it's very much recommended to have a title which already contains all the necessary information and keep the message body empty.

Only include commit relevant changes. Do not add any non relevant information like test steps or "Generated with" lines.

Keep the commit as simple as possible. Only mention changes that have been made.

Before committing, run `bin/ci` and check its exit code, not just its output.

## Co-authors

Add a `Co-authored-by:` trailer for whoever created the code besides the committer, for example an AI agent that wrote it:

```
Add undo bar after checking off an item

Co-authored-by: Claude <noreply@anthropic.com>
```

The trailer goes at the very end, after a blank line. It's the only thing allowed after the title besides an optional description.

## Never include in a commit

- Testing steps and information on how to test the commit.
- "Generated with" lines or other tool advertising. This just generates noise and clutters the commit message unnecessarily.

## Wording and grammar style

Use short and straight to the point wording. Do not over-explain or mention too many things. The commit must be easy to read and have a straight meaning on what got changed.
