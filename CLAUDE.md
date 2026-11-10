# Stube

A private shared space for each household: a family, a WG or friends living together. Open source under AGPL-3.0. Domain: stube.life.

Planning lives in GitHub issues (`gh issue list`), never in the repo. Don't add planning, scope or design documents. Open or update an issue instead (see the `issue` skill).

## Stack

Rails 8.1, SQLite, Hotwire (Turbo, Stimulus), Tailwind and importmap. Solid Queue, Solid Cache and Solid Cable, so no Redis and no Node. Minitest with system tests. `bin/ci` runs style, security checks and every test. The Docker image is the Dockerfile `rails new` generates. The iOS and iPadOS app will be a Hotwire Native shell in `ios/`.

The same image runs two ways: self-hosted (one container, zero config) and on Stube Cloud, where we deploy, update and back up one instance per household.

## How it works

- **Identity:** no accounts. A device token in a permanent cookie is the identity; the server stores only its digest. A device is personal (it belongs to a member) or shared (like a kitchen iPad, which can't manage the household). The person picks which when joining.
- **Ways in:** invites work for 24 hours and for anyone. Device links add one device to a member, once, within 10 minutes. Both are 8-character codes, stored as digests, so they're shown only once.
- **First setup:** the setup code is derived from the secret key and printed to the log. It works until a household exists.
- **Times** use the household's time zone.
- **Live updates:** each screen subscribes only to what it shows. Frequent changes (shopping items) send one small partial. Rare ones (household settings) send a page refresh that morphs in place. Broadcasts are synchronous. A removed device's pages refresh onto Join, and its connection closes 5 seconds later (`DisconnectDeviceJob`).
- **Layouts:** phone under 768 px (tab bar), tablet 768–1023 px (icon rail), desktop from 1024 px (sidebar and columns).

## Rules

- Design first. Settle every screen at phone, tablet and desktop width, and the data it needs, in the issue before building it.
- Barebone UI for now: plain Tailwind that makes the feature usable, no visual polish. A design refresh comes once every feature works.
- Data follows the UI. A table or column exists only if a screen shows it or a rule needs it.
- Send only what changed. A change broadcasts one small partial to the stream of the screens that show it. Never re-send a whole list.
- Stick to Rails defaults. Add a gem only when Rails has nothing built in.
- Server-rendered HTML with Turbo and Stimulus. No JSON API, no SPA, no client-side state.
- Every screen is a web screen. Native Swift only for what the web can't do (QR scanning, share extension, push), through bridge components.
- Every record belongs to a household. Load records through `Current.household` (`Current.household.shopping_items.find(id)`), never by bare id. Non-members get 404.
- No accounts: people never sign up or log in. An invite is the only way into a household. Paying for Stube Cloud happens outside the app.
- Money is integer cents in the household's currency.
- Zero config: the container runs with no environment variables, and all data lives in `storage/`. Outside services (S3, AI) are optional and set by environment variables.
- Self-hosting never depends on a service we run. Stube Cloud runs the same image, so the app has no cloud-only code. Its tooling goes in `cloud/`, outside the Docker image.
- Keep the repo clean: code, tests, `README.md`, `LICENSE`, this file and the skills in `.claude/skills/`. Nothing else.
- Commits and pull requests follow the `commit` and `pr` skills. Check `bin/ci`'s exit code before every commit.
