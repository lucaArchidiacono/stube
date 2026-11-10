require "test_helper"

class ShoppingItemTest < ActiveSupport::TestCase
  setup { @items = households(:ours).shopping_items }

  test "adding puts the item at the end and records who added it" do
    item = @items.add("  Oat   milk ", by: devices(:anna_iphone))
    assert_equal "Oat milk", item.name
    assert_equal [ "Milk", "6 eggs", "Bread", "Oat milk" ], @items.ordered.pluck(:name)
    assert_event :added, "Oat milk", by: "Anna"
  end

  test "a shared device shows up under its own name" do
    @items.add("Tea", by: devices(:kitchen))
    assert_event :added, "Tea", by: "Kitchen iPad"
  end

  test "an empty name isn't added" do
    assert_raises(ActiveRecord::RecordInvalid) { @items.add(" ", by: devices(:luca_mac)) }
    assert_equal 3, @items.count
  end

  test "renaming keeps the old name in the history" do
    shopping_items(:bread).rename("Sourdough", by: devices(:luca_mac))
    assert_event :renamed, "Sourdough", by: "Luca"
    assert_equal "Bread", ShoppingEvent.last.old_item_name
  end

  test "renaming to the same name records nothing" do
    assert_no_difference -> { ShoppingEvent.count } do
      shopping_items(:bread).rename("Bread", by: devices(:luca_mac))
    end
  end

  test "checking off and deleting take the item off the list and say why" do
    checked = shopping_items(:milk).check_off(by: devices(:anna_iphone))
    deleted = shopping_items(:bread).remove(by: devices(:kitchen))

    assert_equal [ "6 eggs" ], @items.pluck(:name)
    assert_equal [ "checked_off", "Milk", "Anna" ], [ checked.action, checked.item_name, checked.by_name ]
    assert_equal [ "deleted", "Bread", "Kitchen iPad" ], [ deleted.action, deleted.item_name, deleted.by_name ]
  end

  test "sorting by hand" do
    shopping_items(:bread).move_to(0)
    assert_equal [ "Bread", "Milk", "6 eggs" ], @items.ordered.pluck(:name)

    shopping_items(:bread).move_to(99)
    assert_equal [ "Milk", "6 eggs", "Bread" ], @items.ordered.pluck(:name)
  end

  test "sorting isn't part of the history" do
    assert_no_difference -> { ShoppingEvent.count } do
      shopping_items(:bread).move_to(0)
    end
  end

  test "a checked-off item can be put back once" do
    event = shopping_events(:butter_checked_off)
    assert event.put_back_possible?

    item = event.put_back(by: devices(:luca_mac))
    assert_equal "Butter", @items.ordered.last.name
    assert_equal item, @items.ordered.last
    assert_event :put_back, "Butter", by: "Luca"

    assert_not event.put_back_possible?
    assert_nil event.put_back(by: devices(:luca_mac))
  end

  test "nothing is put back while an item with that name is on the list" do
    assert_not shopping_events(:milk_checked_off_yesterday).put_back_possible?
    assert_nil shopping_events(:milk_checked_off_yesterday).put_back(by: devices(:luca_mac))
  end

  test "only checked-off and deleted items can be put back" do
    assert_not shopping_events(:eggs_renamed).put_back_possible?
    assert shopping_events(:chips_deleted).put_back_possible?
  end

  private
    def assert_event(action, item_name, by:)
      event = households(:ours).shopping_events.newest_first.first
      assert_equal [ action.to_s, item_name, by ], [ event.action, event.item_name, event.by_name ]
    end
end
