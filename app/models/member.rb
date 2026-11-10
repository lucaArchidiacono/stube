class Member < ApplicationRecord
  belongs_to :household
  has_many :devices, dependent: :destroy
  has_many :device_links, class_name: "Invite", dependent: :destroy
  has_many :created_invites, class_name: "Invite", foreign_key: :created_by_member_id, inverse_of: :created_by, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }

  after_commit -> { household&.refresh_settings }

  scope :alphabetically, -> { order(:name) }

  def last_one?
    household.members.excluding(self).none?
  end
end
