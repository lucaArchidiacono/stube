# Households and the ways into them: members, devices and invites.
class CreateHouseholds < ActiveRecord::Migration[8.1]
  def change
    create_table :households do |t|
      t.string :name, null: false
      t.string :time_zone, null: false
      t.timestamps
    end

    create_table :members do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    # A device without a member is a shared device, like the kitchen iPad.
    create_table :devices do |t|
      t.references :household, null: false, foreign_key: true
      t.references :member, foreign_key: true
      t.string :name, null: false
      t.string :token_digest, null: false, index: { unique: true }
      t.date :last_seen_on
      t.timestamps
    end

    # An invite with a member is a device link: it adds a device for that member.
    create_table :invites do |t|
      t.references :household, null: false, foreign_key: true
      t.references :member, foreign_key: true
      t.references :created_by_member, null: false, foreign_key: { to_table: :members }
      t.string :code_digest, null: false, index: { unique: true }
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
