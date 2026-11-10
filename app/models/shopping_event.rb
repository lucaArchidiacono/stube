# One line of the shopping list's history: what happened to which item, who
# did it and when. Entries never change. Names are kept as they were.
class ShoppingEvent < ApplicationRecord
  PAGE = 50

  belongs_to :household

  enum :action, { added: "added", renamed: "renamed", checked_off: "checked_off", deleted: "deleted", put_back: "put_back" }

  scope :newest_first, -> { order(id: :desc) }

  after_create_commit -> { broadcast_prepend_to history_stream, target: "shopping_history_today" }

  # A checked-off or deleted item can come back, unless it's already on the list.
  def put_back_possible?
    (checked_off? || deleted?) && household.shopping_items.named(item_name).none?
  end

  # Returns the new item, or nil if it was already back on the list.
  def put_back(by:)
    return unless put_back_possible?

    household.shopping_items.add(item_name, by:, action: :put_back).tap do
      broadcast_replace_to history_stream, locals: { put_back: false }
    end
  end

  def time
    created_at.in_time_zone(household.time_zone)
  end

  def day
    time.to_date
  end

  private
    def history_stream
      [ household, :shopping_history ]
    end
end
