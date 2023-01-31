# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_05_052013) do

  create_table "idgentable", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "next_value"
  end

  create_table "photo_tags", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "photo_id", null: false
    t.bigint "tag_id", null: false
    t.bigint "time_id", null: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.index ["tag_id", "time_id"], name: "photo_tag_idx"
  end

  create_table "photos", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", default: 0, null: false
    t.string "title", limit: 1024
    t.bigint "time_id", null: false
    t.timestamp "time"
    t.integer "taken_in_tz"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string "img_base_path", limit: 256
    t.float "location_latitude", limit: 53
    t.float "location_longitude", limit: 53
    t.string "location_name", limit: 1024
    t.bigint "source_id", null: false
    t.string "source_name"
    t.text "description", size: :medium
    t.text "metadata", size: :long, collation: "utf8mb4_bin"
    t.text "tags", size: :long, collation: "utf8mb4_bin"
    t.integer "feature_threshold"
    t.text "image_versions", size: :long, collation: "utf8mb4_bin"
    t.index ["title", "description", "location_name"], name: "photos_fulltext", type: :fulltext
    t.index ["user_id", "location_longitude", "location_latitude", "time_id", "feature_threshold"], name: "photos_loc_gis"
    t.index ["user_id", "time", "feature_threshold"], name: "photos_time"
    t.index ["user_id", "time_id", "feature_threshold"], name: "photos_time_id"
  end

  create_table "sources", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "raw_name", limit: 2048, null: false
    t.string "display_name", null: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.bigint "user_id", default: 0, null: false
  end

  create_table "tags", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", default: 0, null: false
    t.string "tag_type", limit: 32, default: "tag", null: false
    t.string "name", null: false
    t.float "location_latitude", limit: 53
    t.float "location_longitude", limit: 53
    t.timestamp "event_date"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string "shortcut_url", limit: 64
    t.text "description", size: :medium
    t.index ["shortcut_url"], name: "shortcut_url", unique: true
    t.index ["user_id", "tag_type", "event_date", "name"], name: "tag_type_event_date"
    t.index ["user_id", "tag_type", "location_longitude", "location_latitude"], name: "tag_type_gis"
    t.index ["user_id", "tag_type", "name"], name: "tag_type_name"
  end

  create_table "user_authentications", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "auth_type", default: 0, null: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string "external_identifier"
    t.text "authentication_data", size: :medium
    t.index ["user_id", "auth_type"], name: "user_authentications_by_user"
  end

  create_table "users", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "username", limit: 64, null: false
    t.timestamp "created_at"
    t.timestamp "update_at"
    t.index ["username"], name: "users_username", unique: true
  end

end
