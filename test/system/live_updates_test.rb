require "application_system_test_case"

class LiveUpdatesTest < ApplicationSystemTestCase
  test "household pages update on other devices without reloading" do
    sign_in_as :luca_mac
    visit household_path
    assert_text "Anna"

    using_session :anna do
      sign_in_as :anna_iphone
      visit member_path(members(:anna))
      fill_in "Your name", with: "Annie"
      click_on "Save"
      assert_text "Saved."
    end

    assert_text "Annie"
    assert_no_text "Anna"
  end

  test "a removed device leaves right away" do
    using_session :anna do
      sign_in_as :anna_iphone
      visit root_path
      assert_selector "#home_shopping_card"
    end

    sign_in_as :luca_mac
    visit member_path(members(:anna))
    accept_confirm { click_on "Remove Anna" }
    assert_text "Anna was removed."

    using_session :anna do
      assert_text "You're no longer in this household."
    end
  end

  test "offline shows a bar and disables inputs until the connection is back" do
    sign_in_as :luca_mac
    visit household_path
    assert_field "Household name", disabled: false

    go_offline = <<~JS
      Object.defineProperty(navigator, "onLine", { configurable: true, get: () => false })
      window.dispatchEvent(new Event("offline"))
    JS
    execute_script go_offline
    assert_text "Offline. Changes can't be saved right now."
    assert_field "Household name", disabled: true

    execute_script %(delete navigator.onLine; window.dispatchEvent(new Event("online")))
    assert_no_text "Offline. Changes can't be saved right now."
    assert_field "Household name", disabled: false
  end
end
