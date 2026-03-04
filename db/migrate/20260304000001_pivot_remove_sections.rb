class PivotRemoveSections < ActiveRecord::Migration[8.1]
  def up
    drop_table :marquee_sections

    change_table :marquee_pages do |t|
      t.remove :custom_css, :custom_js
      t.rename :template, :template_path
      t.string :current_version
    end
  end

  def down
    change_table :marquee_pages do |t|
      t.remove :current_version
      t.rename :template_path, :template
      t.text :custom_css
      t.text :custom_js
    end

    create_table :marquee_sections do |t|
      t.json "content", default: {}
      t.string "css_class"
      t.integer "page_id", null: false
      t.integer "position", default: 0, null: false
      t.string "section_type", null: false
      t.json "settings", default: {}
      t.boolean "visible", default: true, null: false
      t.timestamps

      t.index [ "page_id", "position" ], name: "index_marquee_sections_on_page_id_and_position"
      t.index [ "page_id" ], name: "index_marquee_sections_on_page_id"
    end

    add_foreign_key "marquee_sections", "marquee_pages", column: "page_id"
  end
end
