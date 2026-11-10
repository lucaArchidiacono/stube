require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as :luca_mac }

  test "you rename yourself, but not others" do
    patch member_path(members(:luca)), params: { name: "Luca A." }
    assert_equal "Luca A.", members(:luca).reload.name

    patch member_path(members(:anna)), params: { name: "Annie" }
    assert_response :forbidden
  end

  test "removing a member removes their devices" do
    device = devices(:anna_iphone)
    delete member_path(members(:anna))
    assert_redirected_to household_path
    assert_not Device.exists?(device.id)
  end

  test "you can't remove yourself, you leave instead" do
    delete member_path(members(:luca))
    assert_response :forbidden
  end

  test "add a device shows a one-time code for that member" do
    post member_device_links_path(members(:anna))
    invite = Invite.last
    assert_equal members(:anna), invite.member
    assert_redirected_to invite_path(invite)

    follow_redirect!
    assert_select "h1", "Add a device for Anna"
    assert_select "input[aria-label='Invite link']"
  end
end
