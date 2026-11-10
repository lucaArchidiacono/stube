require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  test "a new device gets a token and stores only its digest" do
    device = households(:ours).devices.create!(name: "Firefox on Linux")
    assert_equal 32, device.token.length
    assert_equal device, Device.authenticate(device.token)
    assert_not_equal device.token, device.token_digest
  end

  test "authenticate ignores missing and unknown tokens" do
    assert_nil Device.authenticate(nil)
    assert_nil Device.authenticate("nope")
    assert_equal devices(:kitchen), Device.authenticate("kitchen")
  end

  test "a shared device has no member and shows its own name" do
    assert devices(:kitchen).shared?
    assert_equal "Kitchen iPad", devices(:kitchen).display_name
    assert_equal "Luca", devices(:luca_mac).display_name
  end

  test "last seen is written at most once a day" do
    device = devices(:luca_mac)
    device.seen
    assert_equal households(:ours).today, device.reload.last_seen_on

    assert_no_changes -> { device.reload.updated_at } do
      device.seen
    end
  end

  test "names come from the browser" do
    {
      "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1" => "Safari on iPhone",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36" => "Chrome on Mac",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0" => "Edge on Windows",
      "Mozilla/5.0 (Android 15; Mobile; rv:132.0) Gecko/132.0 Firefox/132.0" => "Firefox on Android",
      nil => "Browser"
    }.each do |user_agent, name|
      assert_equal name, Device.name_from(user_agent)
    end
  end
end
