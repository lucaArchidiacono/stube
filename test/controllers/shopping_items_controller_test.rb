require "test_helper"

class ShoppingItemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as :luca_mac }

  test "the list in order, with the add field" do
    get shopping_path
    assert_response :success
    assert_equal [ "Milk", "6 eggs", "Bread" ], css_select("#shopping_items li [data-inline-edit-target=text]").map { it.text.strip }
    assert_select "input[aria-label='Add an item']"
    assert_select "turbo-frame#shopping_history[loading=lazy]"
  end

  test "adding an item" do
    post shopping_items_path, params: { name: "Tea" }, as: :turbo_stream
    assert_response :success
    assert_select "turbo-stream[action=append][target=shopping_items]"
    assert_equal "Tea", households(:ours).shopping_items.ordered.last.name
  end

  test "an empty item isn't added" do
    post shopping_items_path, params: { name: "" }, as: :turbo_stream
    assert_response :unprocessable_entity
  end

  test "renaming an item" do
    patch shopping_item_path(shopping_items(:bread)), params: { name: "Sourdough" }, as: :turbo_stream
    assert_select "turbo-stream[action=replace]"
    assert_equal "Sourdough", shopping_items(:bread).reload.name
  end

  test "an empty name changes nothing" do
    patch shopping_item_path(shopping_items(:bread)), params: { name: "" }, as: :turbo_stream
    assert_equal "Bread", shopping_items(:bread).reload.name
  end

  test "checking off shows an undo bar" do
    post shopping_item_check_off_path(shopping_items(:milk)), as: :turbo_stream
    assert_select "turbo-stream[action=remove][target=shopping_item_#{shopping_items(:milk).id}]"
    assert_select "turbo-stream[action=update][target=shopping_undo] template", text: /Milk checked off/
    assert_select "turbo-stream[target=shopping_undo] button", text: "Undo"
  end

  test "deleting shows an undo bar" do
    delete shopping_item_path(shopping_items(:bread)), as: :turbo_stream
    assert_select "turbo-stream[target=shopping_undo] template", text: /Bread deleted/
    assert_not ShoppingItem.exists?(shopping_items(:bread).id)
  end

  test "an item someone else already checked off just leaves this page too" do
    item = shopping_items(:milk)
    item.check_off(by: devices(:anna_iphone))

    assert_no_difference -> { ShoppingEvent.count } do
      post shopping_item_check_off_path(item), as: :turbo_stream
    end
    assert_response :success
    assert_select "turbo-stream[action=remove][target=shopping_item_#{item.id}]"
  end

  test "another household's items are out of reach" do
    other = Household.create!(name: "Next door", time_zone: "UTC")
    item = other.shopping_items.create!(name: "Secret", position: 0)

    post shopping_item_check_off_path(item), as: :turbo_stream
    patch shopping_item_path(item), params: { name: "Mine" }, as: :turbo_stream
    assert_equal "Secret", item.reload.name
  end

  test "sorting by hand" do
    patch shopping_item_position_path(shopping_items(:bread)), params: { position: 0 }, as: :turbo_stream
    assert_response :success
    assert_equal [ "Bread", "Milk", "6 eggs" ], households(:ours).shopping_items.ordered.pluck(:name)
  end

  test "a shared device can use the list" do
    sign_in_as :kitchen
    post shopping_item_check_off_path(shopping_items(:milk)), as: :turbo_stream
    assert_equal "Kitchen iPad", ShoppingEvent.last.by_name
  end

  test "without a device, no list" do
    cookies[Authentication::COOKIE] = ""
    get shopping_path
    assert_redirected_to join_path
  end
end
