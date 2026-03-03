class CreateMarqueeSections < ActiveRecord::Migration[7.1]
  def change
    create_table :marquee_sections do |t|
      t.references :page, null: false, foreign_key: { to_table: :marquee_pages }
      t.string :section_type, null: false
      t.json :content, default: {}
      t.json :settings, default: {}
      t.integer :position, null: false, default: 0
      t.boolean :visible, null: false, default: true
      t.string :css_class

      t.timestamps
    end

    add_index :marquee_sections, [:page_id, :position]
  end
end
