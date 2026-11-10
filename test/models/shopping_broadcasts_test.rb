require "test_helper"
require "turbo/broadcastable/test_helper"

# Each change sends one small partial, to the screens that show it.
class ShoppingBroadcastsTest < ActiveSupport::TestCase
  # turbo-rails only adds these once Action Cable has loaded, which depends on test order.
  include Turbo::Broadcastable::TestHelper

  setup do
    @list = [ households(:ours), :shopping ]
    @history = [ households(:ours), :shopping_history ]
    @home = [ households(:ours), :home ]
  end

  test "adding sends the item, the new count and the Home card" do
    actions = capture_turbo_stream_broadcasts(@list) { households(:ours).shopping_items.add("Tea", by: devices(:luca_mac)) }
    assert_equal [ "append", "update" ], actions.map { it["action"] }
    assert_equal "shopping_items", actions.first["target"]
    assert_equal "4", actions.last.at("template").inner_html

    assert_turbo_stream_broadcasts @home, count: 1
    assert_equal "prepend", capture_turbo_stream_broadcasts(@history).last["action"]
  end

  test "checking off removes the item everywhere and adds a history line with Put back" do
    list = capture_turbo_stream_broadcasts(@list) { shopping_items(:bread).check_off(by: devices(:anna_iphone)) }
    assert_equal [ "remove", "update" ], list.map { it["action"] }

    history = capture_turbo_stream_broadcasts(@history).last
    assert_match "Anna", history.inner_html
    assert_match "Put back", history.inner_html
  end

  test "renaming replaces just that item" do
    list = capture_turbo_stream_broadcasts(@list) { shopping_items(:bread).rename("Sourdough", by: devices(:luca_mac)) }
    assert_equal "replace", list.first["action"]
    assert_equal "shopping_item_#{shopping_items(:bread).id}", list.first["target"]
  end

  test "moving sends the item to its new place" do
    list = capture_turbo_stream_broadcasts(@list) { shopping_items(:bread).move_to(1) }
    assert_equal [ "remove", "after" ], list.first(2).map { it["action"] }
    assert_equal "shopping_item_#{shopping_items(:milk).id}", list.second["target"]

    first = capture_turbo_stream_broadcasts(@list) { shopping_items(:bread).move_to(0) }
    assert_equal [ "remove", "prepend" ], first.first(2).map { it["action"] }
  end

  test "the history never sends anything to the list on a phone" do
    assert_no_turbo_stream_broadcasts(@list) do
      households(:ours).shopping_events.create!(action: :added, item_name: "Tea", by_name: "Luca")
    end
  end
end
