class Household < ApplicationRecord
  has_many :members, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :shopping_items, dependent: :delete_all
  has_many :shopping_events, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 50 }
  validates :time_zone, presence: true
  validate :time_zone_exists

  after_update_commit :refresh_settings

  # The code that creates the first household, printed to the server log. It's
  # derived from the secret key, so it needs no storage, and it stops working
  # once a household exists.
  def self.setup_code
    Code.from_bytes(Rails.application.key_generator.generate_key("stube/setup-code", 5))
  end

  def self.setup_code?(input)
    ActiveSupport::SecurityUtils.secure_compare(Code.normalize(input), Code.normalize(setup_code))
  end

  # The browser sends its IANA zone, like "Europe/Zurich". Anything else falls back to UTC.
  def self.time_zone_or_utc(name)
    ActiveSupport::TimeZone[name.to_s] ? name : "UTC"
  end

  def today
    Time.find_zone!(time_zone).today
  end

  # The Household pages listen to this stream and refresh whenever the household,
  # its members, devices or invites change. Changes there are rare, so a refresh
  # is enough. Sent right away: it's only a tiny tag, and devices debounce it.
  def refresh_settings
    broadcast_refresh_to self, :settings
  end

  private
    def time_zone_exists
      errors.add(:time_zone, :invalid) if time_zone.present? && ActiveSupport::TimeZone[time_zone].nil?
    end
end
