require "application_system_test_case"

# The whole way into a household, in a real browser: first setup, an invite,
# joining with a personal and a shared device, and leaving.
class OnboardingTest < ApplicationSystemTestCase
  setup { Household.destroy_all }

  test "set up, invite, join and leave" do
    visit root_path
    fill_in "Setup code", with: Household.setup_code.downcase
    fill_in "Your name", with: "Luca"
    fill_in "Household name", with: "Our home"
    click_on "Create household"
    assert_selector "#home_shopping_card"

    visit household_path
    click_on "Invite someone"
    assert_text "Scan this to join Our home"
    invite_path = URI(find("input[aria-label='Invite link']").value).path

    using_session :anna do
      visit invite_path
      assert_text "Luca invited you to"
      fill_in "Your name", with: "Anna"
      click_on "Join"
      assert_selector "#home_shopping_card"
    end

    using_session :kitchen do
      visit invite_path
      find("label", text: "Shared").click
      fill_in "Device name", with: "Kitchen iPad"
      click_on "Join"
      assert_selector "#home_shopping_card"

      visit household_path
      assert_text "Kitchen iPad (this device)"
      assert_no_button "Invite someone"
    end

    visit household_path
    assert_link "Anna"
    assert_link "Kitchen iPad"

    using_session :anna do
      visit household_path
      accept_confirm { click_on "Leave household" }
      assert_text "You left Our home."
    end

    visit household_path
    assert_no_link "Anna"
  end
end
