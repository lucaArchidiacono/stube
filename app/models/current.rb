class Current < ActiveSupport::CurrentAttributes
  attribute :device

  delegate :household, :member, to: :device, allow_nil: true
end
