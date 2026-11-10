require "test_helper"

class JoinsControllerTest < ActionDispatch::IntegrationTest
  test "an invite asks whose device this is" do
    get join_path(code: "AAAA-BBBB")
    assert_response :success
    assert_select "h1", "Our home"
    assert_select "input[name=kind]", 2
  end

  test "an expired invite says so" do
    get join_path(code: "CCCC-DDDD")
    assert_select "h1", "This invite has expired"

    post join_path(code: "CCCC-DDDD"), params: { name: "Mia" }
    assert_response :gone
  end

  test "joining with your own device creates a member" do
    assert_difference -> { Member.count } => 1, -> { Device.count } => 1 do
      post join_path(code: "aaaa bbbb"), params: { kind: "mine", name: "Mia" }
    end
    assert_redirected_to root_path

    device = Device.last
    assert_equal "Mia", device.member.name
    follow_redirect!
    assert_response :success
  end

  test "joining with a shared device creates no member" do
    assert_difference -> { Member.count } => 0, -> { Device.count } => 1 do
      post join_path(code: "AAAA-BBBB"), params: { kind: "shared", device_name: "Hallway iPad" }
    end
    assert Device.last.shared?
    assert_equal "Hallway iPad", Device.last.name
  end

  test "a household invite works more than once until it expires" do
    post join_path(code: "AAAA-BBBB"), params: { kind: "mine", name: "Mia" }
    cookies.delete(Authentication::COOKIE)
    post join_path(code: "AAAA-BBBB"), params: { kind: "mine", name: "Noah" }
    assert_equal %w[Anna Luca Mia Noah], Member.order(:name).pluck(:name)
  end

  test "a missing name is reported" do
    post join_path(code: "AAAA-BBBB"), params: { kind: "mine", name: "" }
    assert_response :unprocessable_entity
  end

  test "a device link adds a device for that member and works once" do
    get join_path(code: "EEEE-FFFF")
    assert_select "h1", "Add this device for Anna?"

    link = invites(:anna_link)
    assert_difference -> { members(:anna).devices.count } => 1 do
      post join_path(code: "EEEE-FFFF")
    end
    assert_not Invite.exists?(link.id)

    cookies.delete(Authentication::COOKIE)
    post join_path(code: "EEEE-FFFF")
    assert_response :gone
  end

  test "a device that's already in the household is told so" do
    sign_in_as :luca_mac
    get join_path(code: "AAAA-BBBB")
    assert_select "h1", "You're already in Our home"
  end
end
