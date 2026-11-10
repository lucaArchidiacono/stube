# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_09_161051) do
  create_table "devices", force: :cascade do |t|
    t.integer "household_id", null: false
    t.integer "member_id"
    t.string "name", null: false
    t.string "token_digest", null: false
    t.date "last_seen_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_devices_on_household_id"
    t.index ["member_id"], name: "index_devices_on_member_id"
    t.index ["token_digest"], name: "index_devices_on_token_digest", unique: true
  end

  create_table "households", force: :cascade do |t|
    t.string "name", null: false
    t.string "time_zone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invites", force: :cascade do |t|
    t.integer "household_id", null: false
    t.integer "member_id"
    t.integer "created_by_member_id", null: false
    t.string "code_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_digest"], name: "index_invites_on_code_digest", unique: true
    t.index ["created_by_member_id"], name: "index_invites_on_created_by_member_id"
    t.index ["household_id"], name: "index_invites_on_household_id"
    t.index ["member_id"], name: "index_invites_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer "household_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_members_on_household_id"
  end

  create_table "shopping_events", force: :cascade do |t|
    t.integer "household_id", null: false
    t.string "action", null: false
    t.string "item_name", null: false
    t.string "old_item_name"
    t.string "by_name", null: false
    t.datetime "created_at", null: false
    t.index ["household_id", "id"], name: "index_shopping_events_on_household_id_and_id"
  end

  create_table "shopping_items", force: :cascade do |t|
    t.integer "household_id", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_shopping_items_on_household_id"
  end

  add_foreign_key "devices", "households"
  add_foreign_key "devices", "members"
  add_foreign_key "invites", "households"
  add_foreign_key "invites", "members"
  add_foreign_key "invites", "members", column: "created_by_member_id"
  add_foreign_key "members", "households"
  add_foreign_key "shopping_events", "households"
  add_foreign_key "shopping_items", "households"
end
