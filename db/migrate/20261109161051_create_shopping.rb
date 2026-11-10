# The shopping list and its history.
class CreateShopping < ActiveRecord::Migration[8.1]
  def change
    # Only what's still on the list. Checking off or deleting removes the row.
    create_table :shopping_items do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.timestamps
    end

    # The history. Entries never change, so there's no updated_at. Names are
    # stored as they were, so the history stays true after renames and removals.
    create_table :shopping_events do |t|
      t.references :household, null: false, foreign_key: true, index: false
      t.string :action, null: false
      t.string :item_name, null: false
      t.string :old_item_name
      t.string :by_name, null: false
      t.datetime :created_at, null: false
      t.index %i[household_id id]
    end
  end
end
