require "test_helper"

class InviteTest < ActiveSupport::TestCase
  test "a household invite lasts 24 hours" do
    invite = households(:ours).invites.create!(created_by: members(:luca))
    assert_not invite.device_link?
    assert_in_delta 24.hours.from_now, invite.expires_at, 5.seconds
  end

  test "a device link lasts 10 minutes" do
    invite = households(:ours).invites.create!(created_by: members(:luca), member: members(:anna))
    assert invite.device_link?
    assert_in_delta 10.minutes.from_now, invite.expires_at, 5.seconds
  end

  test "only usable invites are found by their code" do
    invite = households(:ours).invites.create!(created_by: members(:luca))
    assert_equal invite, Invite.find_usable(invite.code.downcase)
    assert_equal invites(:open), Invite.find_usable("AAAA-BBBB")
    assert_nil Invite.find_usable("CCCC-DDDD")
    assert_nil Invite.find_usable("")
  end
end
