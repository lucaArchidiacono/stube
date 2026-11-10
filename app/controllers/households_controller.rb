class HouseholdsController < ApplicationController
  require_member only: :update

  def show
    @members = Current.household.members.alphabetically.includes(:devices)
    @shared_devices = Current.household.devices.shared.alphabetically
    @invites = Current.household.invites.household_invites.usable.order(:expires_at)
  end

  def update
    if Current.household.update(name: params[:name])
      redirect_to household_path, notice: "Saved.", status: :see_other
    else
      redirect_to household_path, alert: Current.household.errors.full_messages.to_sentence, status: :see_other
    end
  end
end
