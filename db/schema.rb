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

ActiveRecord::Schema[8.1].define(version: 2025_12_10_100712) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "attendance_at", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.uuid "group_id", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.uuid "user_id", null: false
    t.index ["attendance_at"], name: "index_attendances_on_attendance_at"
    t.index ["group_id"], name: "index_attendances_on_group_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "group_users", primary_key: ["group_id", "user_id"], force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.uuid "group_id", null: false
    t.string "relation", null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.uuid "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_group_users_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "about"
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.string "grades"
    t.string "name", null: false
    t.boolean "same_school", default: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
  end

  create_table "hellos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "mobile_number"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.string "alternate_mobile_number"
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.date "date_of_birth"
    t.jsonb "experience"
    t.string "father_name"
    t.string "gender"
    t.string "mother_name"
    t.string "name"
    t.jsonb "roll_specific_detail"
    t.integer "steamer_id"
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.index ["steamer_id"], name: "index_profiles_on_steamer_id", unique: true
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.datetime "expires_at"
    t.string "token"
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.uuid "user_id", null: false
    t.index ["token"], name: "index_refresh_tokens_on_token"
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "school_users", primary_key: ["school_id", "user_id"], force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.string "relation", null: false
    t.uuid "school_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.uuid "user_id", null: false
    t.index ["school_id", "user_id"], name: "index_school_users_on_school_id_and_user_id", unique: true
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.string "city_village"
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.string "district", null: false
    t.string "landmark"
    t.integer "pincode"
    t.string "school_name", null: false
    t.integer "steamer_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.index ["steamer_id"], name: "index_schools_on_steamer_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by"
    t.string "email"
    t.string "encrypted_password"
    t.string "mobile_number"
    t.datetime "remember_created_at"
    t.string "roles", default: [], array: true
    t.datetime "updated_at", null: false
    t.uuid "updated_by"
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["mobile_number"], name: "index_users_on_mobile_number"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "attendances", "groups"
  add_foreign_key "attendances", "users"
  add_foreign_key "attendances", "users", column: "created_by"
  add_foreign_key "attendances", "users", column: "updated_by"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "group_users", "users", column: "created_by"
  add_foreign_key "group_users", "users", column: "updated_by"
  add_foreign_key "groups", "users", column: "created_by"
  add_foreign_key "groups", "users", column: "updated_by"
  add_foreign_key "profiles", "users", column: "created_by"
  add_foreign_key "profiles", "users", column: "id"
  add_foreign_key "profiles", "users", column: "updated_by"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "refresh_tokens", "users", column: "created_by"
  add_foreign_key "refresh_tokens", "users", column: "updated_by"
  add_foreign_key "school_users", "schools"
  add_foreign_key "school_users", "users"
  add_foreign_key "school_users", "users", column: "created_by"
  add_foreign_key "school_users", "users", column: "updated_by"
  add_foreign_key "schools", "users", column: "created_by"
  add_foreign_key "schools", "users", column: "updated_by"
  add_foreign_key "users", "users", column: "created_by"
  add_foreign_key "users", "users", column: "updated_by"
end
