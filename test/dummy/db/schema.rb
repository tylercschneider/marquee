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

ActiveRecord::Schema[8.1].define(version: 2026_03_05_000002) do
  create_table "marquee_assignments", force: :cascade do |t|
    t.bigint "experiment_id", null: false
    t.bigint "variant_id", null: false
    t.string "visitor_token", null: false
    t.datetime "assigned_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["experiment_id", "visitor_token"], name: "idx_marquee_assignments_experiment_visitor", unique: true
    t.index ["experiment_id"], name: "index_marquee_assignments_on_experiment_id"
    t.index ["variant_id"], name: "index_marquee_assignments_on_variant_id"
    t.index ["visitor_token"], name: "index_marquee_assignments_on_visitor_token"
  end


  create_table "marquee_experiments", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.string "name", null: false
    t.string "status", default: "draft", null: false
    t.string "metric", default: "lead_capture", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.bigint "winning_variant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_marquee_experiments_on_page_id"
  end

  create_table "marquee_variants", force: :cascade do |t|
    t.bigint "experiment_id", null: false
    t.string "name", null: false
    t.string "template_path", null: false
    t.integer "weight", default: 1, null: false
    t.boolean "is_control", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["experiment_id"], name: "index_marquee_variants_on_experiment_id"
  end


  create_table "marquee_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.string "current_version"
    t.text "meta_description"
    t.string "meta_title"
    t.string "og_image"
    t.string "page_type", default: "custom", null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at"
    t.text "schema_markup"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "template_path"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_marquee_pages_on_position"
    t.index ["slug"], name: "index_marquee_pages_on_slug", unique: true
    t.index ["status"], name: "index_marquee_pages_on_status"
  end

  create_table "marquee_versions", force: :cascade do |t|
    t.string "versionable_type", null: false
    t.bigint "versionable_id", null: false
    t.bigint "user_id"
    t.string "action", null: false
    t.json "changeset", default: {}
    t.json "snapshot", default: {}
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["versionable_type", "versionable_id"], name: "idx_marquee_versions_on_versionable"
    t.index ["user_id"], name: "index_marquee_versions_on_user_id"
  end
end
