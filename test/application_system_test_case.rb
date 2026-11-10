require "test_helper"

# Selenium Manager sends usage stats unless told not to.
ENV["SE_AVOID_STATS"] ||= "true"

# Find fields by aria-label too, like the inline name fields.
Capybara.enable_aria_label = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1280, 900 ]

  # Live updates need a real cable adapter. The test adapter only records broadcasts.
  setup do
    # Tests share one browser window, so undo any resizing from the test before.
    page.driver.browser.manage.window.resize_to(1280, 900)

    @cable_config = ActionCable.server.config.cable
    ActionCable.server.config.cable = { "adapter" => "async" }
    ActionCable.server.restart
  end

  teardown do
    ActionCable.server.config.cable = @cable_config
    ActionCable.server.restart
  end

  # Device fixtures use their own name as the raw token, see test/fixtures/devices.yml.
  def sign_in_as(device)
    visit join_path
    page.driver.browser.manage.add_cookie(name: Authentication::COOKIE.to_s, value: device.to_s)
  end
end
