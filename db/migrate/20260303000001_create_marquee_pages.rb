class CreateMarqueePages < ActiveRecord::Migration[7.1]
  def change
    create_table :marquee_pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :page_type, null: false, default: "custom"
      t.string :status, null: false, default: "draft"
      t.string :meta_title
      t.text :meta_description
      t.string :og_image
      t.text :schema_markup
      t.string :template_path
      t.string :current_version
      t.datetime :published_at
      t.bigint :created_by_id
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :marquee_pages, :slug, unique: true
    add_index :marquee_pages, :status
    add_index :marquee_pages, :position
  end
end
