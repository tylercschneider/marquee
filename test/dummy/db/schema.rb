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

ActiveRecord::Schema[8.1].define(version: 2026_03_03_000002) do
  create_table "marquee_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.text "custom_css"
    t.text "custom_js"
    t.text "meta_description"
    t.string "meta_title"
    t.string "og_image"
    t.string "page_type", default: "custom", null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at"
    t.text "schema_markup"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "template"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_marquee_pages_on_position"
    t.index ["slug"], name: "index_marquee_pages_on_slug", unique: true
    t.index ["status"], name: "index_marquee_pages_on_status"
  end

  create_table "marquee_sections", force: :cascade do |t|
    t.json "content", default: {}
    t.datetime "created_at", null: false
    t.string "css_class"
    t.integer "page_id", null: false
    t.integer "position", default: 0, null: false
    t.string "section_type", null: false
    t.json "settings", default: {}
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true, null: false
    t.index ["page_id", "position"], name: "index_marquee_sections_on_page_id_and_position"
    t.index ["page_id"], name: "index_marquee_sections_on_page_id"
  end

  add_foreign_key "marquee_sections", "marquee_pages", column: "page_id"
end
