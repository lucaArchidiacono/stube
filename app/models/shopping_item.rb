# One thing on the household's shopping list: plain text, sorted by hand.
# Every change goes through the methods below, so the history records it.
class ShoppingItem < ApplicationRecord
  belongs_to :household

  normalizes :name, with: ->(name) { name.squish }
  validates :name, presence: true, length: { maximum: 100 }

  scope :ordered, -> { order(:position, :id) }

  after_create_commit :broadcast_added
  after_update_commit :broadcast_renamed
  after_destroy_commit :broadcast_gone

  # Called on a household's items, like household.shopping_items.add("Milk", by: device).
  # New items go to the end of the list.
  def self.add(name, by:, action: :added)
    transaction do
      create!(name:, position: (maximum(:position) || -1) + 1).tap { |item| item.record(action, by:) }
    end
  end

  def self.named(name)
    where("lower(name) = ?", name.to_s.squish.downcase)
  end

  def rename(new_name, by:)
    old_name = name
    transaction do
      update!(name: new_name)
      record(:renamed, by:, old_item_name: old_name) unless name == old_name
    end
  end

  # Both remove the item and return the history entry, which can put it back.
  def check_off(by:)
    finish(:checked_off, by:)
  end

  def remove(by:)
    finish(:deleted, by:)
  end

  # Sorting by hand. Not part of the history.
  def move_to(index)
    ids = household.shopping_items.ordered.ids - [ id ]
    ids.insert(index.to_i.clamp(0, ids.size), id)
    transaction do
      ids.each_with_index { |item_id, position| household.shopping_items.where(id: item_id).update_all(position:) }
    end
    broadcast_moved(ids)
  end

  def record(action, by:, old_item_name: nil)
    household.shopping_events.create!(action:, item_name: name, old_item_name:, by_name: by.display_name)
  end

  private
    def finish(action, by:)
      transaction do
        destroy!
        record(action, by:)
      end
    end

    # Live updates. Each sends one small partial to the screens that show it.
    def list_stream
      [ household, :shopping ]
    end

    def broadcast_added
      broadcast_append_to list_stream, target: "shopping_items"
      broadcast_summary
    end

    def broadcast_renamed
      broadcast_replace_to list_stream
      broadcast_summary
    end

    def broadcast_gone
      broadcast_remove_to list_stream
      broadcast_summary
    end

    def broadcast_moved(ids)
      previous_id = ids[ids.index(id) - 1] if ids.index(id).positive?
      broadcast_remove_to list_stream
      if previous_id
        broadcast_after_to list_stream, target: "shopping_item_#{previous_id}"
      else
        broadcast_prepend_to list_stream, target: "shopping_items"
      end
      broadcast_summary
    end

    # The count on the list and the card on Home.
    def broadcast_summary
      broadcast_update_to list_stream, target: "shopping_count", html: household.shopping_items.count.to_s
      Turbo::StreamsChannel.broadcast_replace_to [ household, :home ], target: "home_shopping_card", partial: "homes/shopping_card", locals: { household: }
    end
end
