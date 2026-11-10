---
name: rails
description: Stube's Ruby on Rails conventions for models, controllers, views, migrations and tests. Use when writing or changing any Rails code in this repo.
---

Stube stays close to `rails new` defaults. Read neighboring code first and match it.

## Models

- Every table except `households` has `household_id`. Reach records through the household: `Current.household.shopping_items`, never `ShoppingItem.find`.
- Put a change and its side effects in one model method, like `ShoppingItem#check_off(by:)`, which removes the item and records the history entry in one transaction. Controllers call that method and nothing else.
- Class methods called on an association keep its scope: `household.shopping_items.add("Milk", by: device)` creates the item in that household.
- Who did something is `device.display_name`: the member's name, or a shared device's own name.
- Use `normalizes` for cleanup (`name.squish`) and plain validations. Use strict locals in partials (`<%# locals: (item:) %>`).
- Times shown to people use `household.time_zone` (`created_at.in_time_zone(household.time_zone)`).
- Secrets and codes are stored as SHA256 digests only. Raw tokens exist just after creation (`attr_reader :token`).

## Controllers

- Every controller requires a device, unless it calls `allow_without_device`. `require_member` blocks shared devices from managing the household.
- `Current.device`, `Current.household` and `Current.member` are set by the `Authentication` concern.
- Non-GET responses either redirect with `status: :see_other` or render `turbo_stream`. Turbo treats a 204 form response as an error.
- A record that's already gone (someone else removed it) is not an error. Render a `turbo_stream.remove` for it, like `ShoppingItemScoped` does.
- Namespaced controllers look up partials under their namespace. Pass `partial: "shopping_items/shopping_item"` explicitly.

## Migrations and data

- Add a table or column only when a screen shows it or a rule needs it.
- Use `t.references :household, null: false, foreign_key: true`. Use `dependent: :destroy` where removal must trigger callbacks, `:delete_all` where it mustn't.
- A history table has only `created_at`. Its rows never change.

## Tests

- `bin/ci` runs everything. Check its exit code, not its output.
- Fixtures: device fixtures use their own name as the raw token (`sign_in_as :luca_mac`). Give fixtures fixed ids when order matters, and fixed hours in the household's time zone when the day matters.
- Integration tests for controllers, model tests for rules, system tests (`test/system`) for anything live or multi-device. System tests switch Action Cable to the async adapter and use `using_session` for a second device.
- Include `Turbo::Broadcastable::TestHelper` or `ActionCable::TestHelper` explicitly where you assert broadcasts. Rails only adds them when Action Cable has loaded, which depends on test order.
- A fixture accessor (`devices(:anna_iphone)`) raises once the row is deleted. Keep the record in a variable before deleting it.

## Gems

Add a gem only when Rails has nothing built in, and say why in the Gemfile. A gem that loads a system library (like `ruby-vips`) gets `require: false`, so the app still boots without it.
