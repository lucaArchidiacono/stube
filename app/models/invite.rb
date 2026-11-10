# A way into a household. A household invite lets anyone join for 24 hours.
# A device link (an invite with a member) adds one device for that member,
# works once and lasts 10 minutes.
#
# Only the code's digest is stored, so the code can only be shown right after
# it's made. Expired invites stay in the table and are simply refused.
class Invite < ApplicationRecord
  VALID_FOR = 24.hours
  DEVICE_LINK_VALID_FOR = 10.minutes

  belongs_to :household
  belongs_to :member, optional: true
  belongs_to :created_by, class_name: "Member", foreign_key: :created_by_member_id, inverse_of: :created_invites

  before_validation :generate_code, on: :create
  after_commit -> { household&.refresh_settings }

  scope :usable, -> { where(expires_at: Time.current..) }
  scope :household_invites, -> { where(member_id: nil) }

  # The raw code, only known right after the invite is made.
  attr_reader :code

  def self.find_usable(code)
    usable.find_by(code_digest: Code.digest(code)) if code.present?
  end

  def device_link?
    member_id.present?
  end

  private
    def generate_code
      @code = Code.generate
      self.code_digest = Code.digest(@code)
      self.expires_at ||= (device_link? ? DEVICE_LINK_VALID_FOR : VALID_FOR).from_now
    end
end
