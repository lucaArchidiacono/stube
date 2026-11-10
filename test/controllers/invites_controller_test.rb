require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as :luca_mac }

  test "a new invite shows its code once" do
    post invites_path
    invite = Invite.last
    follow_redirect!
    assert_select "svg[aria-label='QR code']"
    assert_match %r{/join/\w{4}-\w{4}\z}, css_select("input[aria-label='Invite link']").first["value"]

    get invite_path(invite)
    assert_select "svg[aria-label='QR code']", count: 0
    assert_select "p", /only shown once/
  end

  test "revoking an invite deletes it" do
    delete invite_path(invites(:open))
    assert_redirected_to household_path
    assert_nil Invite.find_usable("AAAA-BBBB")
  end
end
