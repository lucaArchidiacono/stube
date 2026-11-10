require "application_system_test_case"

# Two people on the list at the same time, like one at home and one in the shop.
class ShoppingTest < ApplicationSystemTestCase
  test "changes show up on the other device, with the history saying who did what" do
    sign_in_as :luca_mac
    visit shopping_path
    within("#shopping_history") { assert_text "Anna checked off Butter" }

    using_session :anna do
      sign_in_as :anna_iphone
      visit shopping_path
      assert_text "Milk"
    end

    # Adding
    fill_in "Add an item", with: "Oat milk\n"
    assert_selector "#shopping_items li", text: "Oat milk"
    using_session(:anna) { assert_selector "#shopping_items li", text: "Oat milk" }

    # Checking off, seen from the other side
    using_session(:anna) do
      find("button[aria-label='Check off Milk']").click
      assert_text "Milk checked off"
    end
    assert_no_selector "#shopping_items li", text: /\AMilk\z/
    within("#shopping_history") { assert_text "Anna checked off Milk" }

    # Undo
    using_session(:anna) { click_on "Undo" }
    assert_selector "#shopping_items li", text: /\AMilk\z/
    within("#shopping_history") { assert_text "Anna put back Milk" }

    # Editing in place
    find("#shopping_items span", text: "Bread").click
    fill_in "Item", with: "Sourdough\n"
    using_session(:anna) { assert_selector "#shopping_items li", text: "Sourdough" }
    within("#shopping_history") { assert_text "Luca changed Bread to Sourdough" }

    # Deleting, then putting back from the history
    find("#shopping_items span", text: "6 eggs").click
    click_on "Delete"
    using_session(:anna) { assert_no_selector "#shopping_items li", text: "6 eggs" }
    within("#shopping_history") do
      assert_text "Luca deleted 6 eggs"
      within("li", text: "Luca deleted 6 eggs") { click_on "Put back" }
    end
    using_session(:anna) { assert_selector "#shopping_items li", text: "6 eggs" }
  end

  test "the Home card follows the list" do
    sign_in_as :anna_iphone
    visit root_path
    within("#home_shopping_card") { assert_text "Milk" }

    using_session :luca do
      sign_in_as :luca_mac
      visit shopping_path
      fill_in "Add an item", with: "Tea\n"
      assert_selector "#shopping_items li", text: "Tea"
    end

    within("#home_shopping_card") { assert_text "4" }
  end

  test "on a phone the history is its own page" do
    page.driver.browser.manage.window.resize_to(390, 844)
    sign_in_as :luca_mac
    visit shopping_path
    assert_no_selector "#shopping_history"

    click_on "History"
    assert_text "Anna checked off Butter"
    within("li", text: "Anna checked off Butter") { click_on "Put back" }
    assert_text "Butter is back on the list"
  end
end
