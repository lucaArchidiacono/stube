---
name: hotwire
description: Stube's Hotwire patterns for Turbo Drive, Turbo Streams, Turbo Frames, Stimulus and Hotwire Native. Use when building screens, live updates or JavaScript behavior.
---

Stube renders HTML on the server. Turbo updates the page and Stimulus adds small behaviors. There is no JSON API and no client-side state.

## Live updates (Turbo Streams)

- Each screen subscribes only to what it shows: `turbo_stream_from Current.household, :shopping`. Every page also listens to `turbo_stream_from Current.device`, which refreshes it onto Join once the device is removed.
- Frequent changes send one small partial: `broadcast_append_to`, `broadcast_replace_to`, `broadcast_remove_to`. Never re-send a whole list.
- Rare changes send `broadcast_refresh_to`, and the page morphs in place (`turbo_refresh_method_tag :morph` is in the head).
- Broadcast synchronously in `after_*_commit` callbacks, not with `_later`. The partials are tiny, times render in the request's time zone, and test runs don't execute jobs.
- A partial with strict locals can't be broadcast with an instance's `broadcast_*_to`, because turbo-rails adds the record as an extra local. Use `Turbo::StreamsChannel.broadcast_replace_to` with explicit locals.
- Partials sent over the stream must not depend on who's looking. No `Current` in them.
- The person acting gets the same change in the response (`render turbo_stream: …`) for instant feedback. Append and replace are deduplicated by id, so getting the broadcast too is harmless.
- Action Cable requires the device cookie (`ApplicationCable::Connection`). A removed device is disconnected 5 seconds after its pages were refreshed, so the refresh arrives first.

## Frames

- A lazy frame (`loading: :lazy`) inside a hidden element never loads. Stube uses that to skip the history on phones.
- A lazy frame keeps its own element and only swaps the content inside it. Classes needed on the loaded content belong on a wrapper inside the frame.
- "Show earlier" pages chain nested frames, each with its own id.

## Stimulus

- One small controller per behavior, with a comment saying what it does and why. Examples: `add_item`, `inline_edit`, `sortable`, `dismiss`, `connection`.
- `connection_controller` shows the offline bar and disables inputs when the network or the cable connection drops, then reloads once it's back.
- Use `requestSubmit()` so Turbo handles the form. Guard `setTimeout` callbacks with `this.element.isConnected`.
- JavaScript packages come through importmap (`bin/importmap pin …`), vendored. No Node.

## Tailwind gotchas

- Name groups when they nest: `group/check` with `group-hover/check:`. A plain `group` on a container lights up every child's `group-hover`.
- `form_with` drops a top-level `hidden:` option. Use `html: { hidden: true }`.

## Hotwire Native (iOS and iPadOS, later)

- Every screen stays a web screen. Native Swift only for what the web can't do: the QR scanner, the share extension and push, through bridge components.
- Navigation rules come from a path configuration served by Rails, so most changes ship without an App Store release.
- The app keeps the server address from the invite, so one app works with Stube Cloud and any self-hosted server.
