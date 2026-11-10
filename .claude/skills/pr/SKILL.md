---
name: pr
description: Creates a Pull Request with short and concise information. Use when creating a Pull Request, creating a description and title for the given Pull Request.
---

When creating a Pull Request always use the following:

## Clear PR titles

The title of a PR serves as the first point of interaction and sets the tone for what reviewers can expect. Here are some guidelines:

Be concise and specific: A clear PR title succinctly describes what the change does, not just what area it affects. For instance, instead of "Fix bug", use "Fix login button unresponsive issue on Safari".

Include relevant identifiers: If applicable, reference issue numbers directly in the title to link the PR to related work items. For example, "Add search functionality (#123)".

Avoid vague language: Specificity trumps ambiguity. A title like "Update CSS" is less informative compared to "Refine grid layout for better mobile responsiveness".

Use imperative mood: This aligns with the tone of git commit messages. For example, "Remove deprecated method in API" instead of "Removing".

## Writing effective pull request descriptions

The description provides the context needed to understand the "why" and "how" of the changes made. Here's how to craft effective PR descriptions:

Start with a summary: The first line or two should summarize the changes and their impact. This helps team members quickly grasp the purpose of the PR.

Link to additional resources: Include links to related issues (`Closes #123`), documentation, or any other resources that might help reviewers understand the context.

Break down the changes: Use bullet points or numbered lists to detail what was changed, why, and how. For example:

```
- Refactored authentication logic to simplify token handling
- Introduced caching for user profiles to decrease load times
- Fixed edge case where user session did not expire
```

Only include Pull Request and Repository relevant changes. Do not add any non relevant information like test steps or "Generated with" lines.

Keep the Pull Request as simple as possible. Only mention changes that have been made, plus one line for related work deliberately left out.

## Co-authors

End the description with one `Co-authored-by:` line for everyone who contributed commits to this branch, besides the PR author. That includes AI agents that wrote code, for example `Co-authored-by: Claude <noreply@anthropic.com>`.

Find them in the commits the branch adds to the base:

```sh
git log --format='%aN <%aE>%n%(trailers:key=Co-authored-by,valueonly)' origin/main..HEAD | sort -u
```

## Never include in a pull request description

- Testing steps and information on how to test the Pull Request.
- "Generated with" lines or other tool advertising. This just generates noise and clutters the Pull Request description unnecessarily.

## Wording and grammar style

Use short and straight to the point sentences. Do not over-explain or mention too many things. The Pull Request must be easy to read and have a straight meaning on why and how things got changed.
