# Joining with an invite link or QR. The person says whether this device is
# theirs or shared by the household. Stube never guesses.
class JoinsController < ApplicationController
  allow_without_device
  before_action :resume_device
  before_action :require_household
  before_action :set_invite

  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to join_path(code: params[:code]), alert: "Too many tries. Wait a few minutes." }

  layout "card"

  def show
  end

  def create
    return render(:show, status: :gone) unless @invite

    device = Device.transaction do
      if @invite.device_link?
        @invite.household.devices.create!(member: @invite.member, name: Device.name_from(request.user_agent)).tap { @invite.destroy! }
      elsif params[:kind] == "shared"
        @invite.household.devices.create!(name: params[:device_name])
      else
        member = @invite.household.members.create!(name: params[:name])
        @invite.household.devices.create!(member:, name: Device.name_from(request.user_agent))
      end
    end

    start_device_session(device)
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid => error
    flash.now[:alert] = error.record.errors.full_messages.to_sentence
    render :show, status: :unprocessable_entity
  end

  private
    def require_household
      redirect_to new_setup_path if Household.none?
    end

    def set_invite
      @invite = Invite.includes(:household, :member, :created_by).find_usable(params[:code])
    end
end
