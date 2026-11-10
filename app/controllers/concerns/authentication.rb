# No accounts: a device token in a permanent cookie is the identity.
# Every page needs a device, unless a controller says `allow_without_device`.
module Authentication
  extend ActiveSupport::Concern

  COOKIE = :device_token

  included do
    before_action :require_device
    around_action :use_household_time_zone
  end

  class_methods do
    def allow_without_device(**options)
      skip_before_action :require_device, **options
    end

    # Shared devices can look at the household, but can't change it.
    def require_member(**options)
      before_action :require_member, **options
    end
  end

  private
    def require_device
      resume_device || leave_for_start
    end

    def resume_device
      Current.device ||= Device.includes(:household, :member).authenticate(cookies[COOKIE])&.tap(&:seen)
    end

    def require_member
      head :forbidden unless Current.member
    end

    # Without a household the server needs its first setup. With one, this device
    # isn't in it (anymore) and needs an invite.
    def leave_for_start
      if Household.none?
        redirect_to new_setup_path
      else
        flash[:alert] = "You're no longer in this household." if cookies[COOKIE].present?
        cookies.delete(COOKIE)
        redirect_to join_path
      end
    end

    def start_device_session(device)
      cookies.permanent[COOKIE] = { value: device.token, httponly: true, same_site: :lax }
      Current.device = device
    end

    def end_device_session
      cookies.delete(COOKIE)
      Current.device = nil
    end

    def use_household_time_zone(&)
      Time.use_zone(Current.household&.time_zone || "UTC", &)
    end
end
