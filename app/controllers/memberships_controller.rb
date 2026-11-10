# Leaving the household removes your member and all your devices.
class MembershipsController < ApplicationController
  require_member

  def destroy
    if Current.member.last_one?
      redirect_to household_path, alert: "You're the only member. Invite someone before you leave.", status: :see_other
    else
      household_name = Current.household.name
      Current.member.destroy!
      end_device_session
      redirect_to join_path, notice: "You left #{household_name}.", status: :see_other
    end
  end
end
