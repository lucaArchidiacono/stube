require "test_helper"

class ShoppingEventsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as :luca_mac }

  test "the history, newest first, grouped by day" do
    get shopping_history_path
    assert_response :success
    assert_select "#shopping_history_today li", 3
    assert_select "h3", text: "Yesterday"
    assert_select "#shopping_history_today li:first-child", text: /Anna checked off Butter/
    assert_select "li", text: /Luca changed 2 eggs to 6 eggs/
  end

  test "Put back only where it can bring something back" do
    get shopping_history_path
    assert_select "##{dom_id(shopping_events(:butter_checked_off))} button", text: "Put back"
    assert_select "##{dom_id(shopping_events(:chips_deleted))} button", text: "Put back"
    assert_select "##{dom_id(shopping_events(:eggs_renamed))} button", count: 0
    # Milk is on the list again.
    assert_select "##{dom_id(shopping_events(:milk_checked_off_yesterday))} button", count: 0
  end

  test "older entries load a page at a time" do
    household = households(:ours)
    ShoppingEvent::PAGE.times { |i| household.shopping_events.create!(action: :added, item_name: "Thing #{i}", by_name: "Luca") }

    get shopping_history_path
    assert_select "#shopping_history li", ShoppingEvent::PAGE
    link = css_select("a").find { it.text == "Show earlier" }
    assert link

    get link["href"]
    assert_select "turbo-frame li", 4
    assert_select "a", text: "Show earlier", count: 0
  end

  test "putting back from the history" do
    post shopping_event_put_back_path(shopping_events(:butter_checked_off)), as: :turbo_stream
    assert_select "turbo-stream[action=append][target=shopping_items]"
    assert_select "turbo-stream[target=shopping_undo] template", text: /Butter is back on the list/
    assert_equal "Butter", households(:ours).shopping_items.ordered.last.name
  end

  test "putting back twice adds it once" do
    2.times { post shopping_event_put_back_path(shopping_events(:butter_checked_off)), as: :turbo_stream }
    assert_select "turbo-stream[target=shopping_undo] template", text: /Butter is already on the list/
    assert_equal 1, households(:ours).shopping_items.named("Butter").count
  end

  private
    def dom_id(record) = ActionView::RecordIdentifier.dom_id(record)
end
