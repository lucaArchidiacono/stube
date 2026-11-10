# A browser or app that is in a household. Personal devices belong to a member.
# Shared devices, like the kitchen iPad, belong to the household only.
#
# The device's identity is a random token in a cookie. Only its digest is stored.
class Device < ApplicationRecord
  belongs_to :household
  belongs_to :member, optional: true

  validates :name, presence: true, length: { maximum: 50 }

  before_validation :generate_token, on: :create
  after_commit -> { household&.refresh_settings }
  after_destroy_commit :send_open_pages_away

  scope :shared, -> { where(member_id: nil) }
  scope :alphabetically, -> { order(:name) }

  # The raw token, only known right after the device is created.
  attr_reader :token

  def self.authenticate(token)
    find_by(token_digest: digest(token)) if token.present?
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end

  # A starting name from the browser, like "Safari on iPhone". People can rename it.
  def self.name_from(user_agent)
    browser = case user_agent.to_s
    when /Edg\//, /EdgiOS/ then "Edge"
    when /Firefox\//, /FxiOS/ then "Firefox"
    when /Chrome\//, /CriOS/ then "Chrome"
    when /Safari\// then "Safari"
    else "Browser"
    end

    system = case user_agent.to_s
    when /iPhone/ then "iPhone"
    when /iPad/ then "iPad"
    when /Android/ then "Android"
    when /Macintosh/ then "Mac"
    when /Windows/ then "Windows"
    when /Linux/ then "Linux"
    end

    system ? "#{browser} on #{system}" : browser
  end

  def shared?
    member_id.nil?
  end

  # Who this device is in the history: the member, or the shared device itself.
  def display_name
    shared? ? name : member.name
  end

  # Written at most once a day.
  def seen
    today = household.today
    update_column(:last_seen_on, today) unless last_seen_on == today
  end

  private
    # Every page of a device listens to its own stream. Once it's removed, its open
    # pages refresh, which lands them on Join. Shortly after, its live connection
    # closes so it receives nothing more.
    def send_open_pages_away
      broadcast_refresh_to self
      DisconnectDeviceJob.set(wait: DisconnectDeviceJob::DELAY).perform_later(to_gid_param)
    end

    def generate_token
      @token = SecureRandom.base58(32)
      self.token_digest = self.class.digest(@token)
    end
end
