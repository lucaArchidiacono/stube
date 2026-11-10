# "Add a device" on a member's profile: a one-time invite for that member.
# Covers a new phone, and a lost one when another member does it for you.
class DeviceLinksController < ApplicationController
  require_member

  def create
    member = Current.household.members.find(params[:member_id])
    invite = Current.household.invites.create!(member:, created_by: Current.member)
    redirect_to invite_path(invite), flash: { invite_code: invite.code }, status: :see_other
  end
end
