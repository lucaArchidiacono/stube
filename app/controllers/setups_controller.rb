# The first person on a new server creates the household with the setup code
# from the server log. Closed for good once a household exists.
class SetupsController < ApplicationController
  allow_without_device
  before_action :require_no_household

  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_setup_path, alert: "Too many tries. Wait a few minutes." }

  layout "card"

  def new
    log_setup_code
  end

  def create
    unless Household.setup_code?(params[:code])
      log_setup_code
      return render_error("That setup code isn't right. It's in the server log.")
    end

    device = Household.transaction do
      household = Household.create!(name: params[:household_name], time_zone: Household.time_zone_or_utc(params[:time_zone]))
      member = household.members.create!(name: params[:name])
      household.devices.create!(member:, name: Device.name_from(request.user_agent))
    end

    start_device_session(device)
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid => error
    render_error(error.record.errors.full_messages.to_sentence)
  end

  private
    def require_no_household
      redirect_to root_path if Household.exists?
    end

    def log_setup_code
      logger.info "Stube setup code: #{Household.setup_code}"
    end

    def render_error(message)
      flash.now[:alert] = message
      render :new, status: :unprocessable_entity
    end
end
