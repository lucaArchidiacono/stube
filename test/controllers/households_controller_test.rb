require "test_helper"

class HouseholdsControllerTest < ActionDispatch::IntegrationTest
  test "everyone sees the members, invites and shared devices" do
    sign_in_as :kitchen
    get household_path
    assert_response :success
    assert_select "a", /Anna/
    assert_select "a", /Kitchen iPad/
    assert_select "button", text: "Invite someone", count: 0
  end

  test "a member renames the household" do
    sign_in_as :luca_mac
    patch household_path, params: { name: "The flat" }
    assert_redirected_to household_path
    assert_equal "The flat", households(:ours).reload.name
  end

  test "a shared device can't change the household" do
    sign_in_as :kitchen
    patch household_path, params: { name: "Mine now" }
    assert_response :forbidden

    post invites_path
    assert_response :forbidden

    delete member_path(members(:anna))
    assert_response :forbidden
  end

  test "a member leaves and this device goes back to Join" do
    anna, device = members(:anna), devices(:anna_iphone)
    sign_in_as :anna_iphone
    delete household_membership_path
    assert_redirected_to join_path
    assert_not Member.exists?(anna.id)
    assert_not Device.exists?(device.id)
  end

  test "the last member can't leave" do
    members(:anna).destroy!
    sign_in_as :luca_mac
    delete household_membership_path
    assert_redirected_to household_path
    assert Member.exists?(members(:luca).id)
  end
end
