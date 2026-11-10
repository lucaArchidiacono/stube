# Only the code's digest is stored, so the code travels to the invite page in
# the flash and is shown once. Reloading asks for a new invite.
class InvitesController < ApplicationController
  require_member

  def create
    invite = Current.household.invites.create!(created_by: Current.member)
    redirect_to invite_path(invite), flash: { invite_code: invite.code }, status: :see_other
  end

  def show
    @invite = Current.household.invites.includes(:member).find(params[:id])
    @code = flash[:invite_code]
  end

  def destroy
    invite = Current.household.invites.find(params[:id])
    invite.destroy!
    redirect_to(invite.device_link? ? member_path(invite.member) : household_path, notice: "Invite revoked.", status: :see_other)
  end
end
