require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "without a device you need an invite" do
    get root_path
    assert_redirected_to join_path
    follow_redirect!
    assert_select "p", /scan an invite/
  end

  test "a removed device is told it's no longer in the household" do
    sign_in_as :anna_iphone
    devices(:anna_iphone).destroy!

    get household_path
    assert_redirected_to join_path
    follow_redirect!
    assert_select "[role=status]", "You're no longer in this household."
    assert_empty cookies[Authentication::COOKIE].to_s
  end

  test "a device is remembered and marked as seen today" do
    sign_in_as :luca_mac
    get root_path
    assert_response :success
    assert_equal households(:ours).today, devices(:luca_mac).reload.last_seen_on
  end

  test "times use the household's time zone" do
    sign_in_as :luca_mac
    get household_path
    assert_select "span", /valid until #{invites(:open).expires_at.in_time_zone("Europe/Zurich").strftime("%a %H:%M")}/
  end
end
