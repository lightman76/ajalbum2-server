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

ActiveRecord::Schema.define(version: 2020_06_14_041449) do

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
    t.string "title", limit: 1024
    t.bigint "time_id", null: false
    t.timestamp "time"
    t.integer "taken_in_tz"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string "img_base_path", limit: 256
    t.integer "location_gis"
    t.string "location_name", limit: 1024
    t.bigint "source_id", null: false
    t.string "source_name"
    t.text "description", size: :medium
    t.text "metadata", size: :long, collation: "utf8mb4_bin"
    t.text "tags", size: :long, collation: "utf8mb4_bin"
    t.integer "feature_threshold"
    t.text "image_versions", size: :long, collation: "utf8mb4_bin"
    t.index ["time", "feature_threshold"], name: "photos_time"
    t.index ["time_id", "feature_threshold"], name: "photos_time_id"
    t.index ["title", "description", "location_name"], name: "photos_fulltext", type: :fulltext
  end

  create_table "sources", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "raw_name", limit: 2048, null: false
    t.string "display_name", null: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "tags", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type", limit: 32, default: "tag", null: false
    t.string "name", null: false
    t.integer "location_gis"
    t.timestamp "event_date"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.index ["type", "event_date", "name"], name: "tag_type_event_date"
    t.index ["type", "location_gis"], name: "tag_type_gis"
    t.index ["type", "name"], name: "tag_type_name"
  end

end
