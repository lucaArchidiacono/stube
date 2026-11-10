class MembersController < ApplicationController
  require_member only: %i[update destroy]
  before_action :set_member

  # A live refresh can land here after someone removed this member.
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to household_path, alert: "That person is no longer in the household."
  end

  def show
    @devices = @member.devices.alphabetically
  end

  # People rename only themselves.
  def update
    return head :forbidden unless @member == Current.member

    if @member.update(name: params[:name])
      redirect_to member_path(@member), notice: "Saved.", status: :see_other
    else
      redirect_to member_path(@member), alert: @member.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # Removing yourself is leaving, see MembershipsController.
  def destroy
    return head :forbidden if @member == Current.member

    @member.destroy!
    redirect_to household_path, notice: "#{@member.name} was removed.", status: :see_other
  end

  private
    def set_member
      @member = Current.household.members.find(params[:id])
    end
end
