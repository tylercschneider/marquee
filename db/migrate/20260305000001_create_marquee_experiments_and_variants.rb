class CreateMarqueeExperimentsAndVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :marquee_experiments do |t|
      t.references :page, null: false, foreign_key: { to_table: :marquee_pages }
      t.string :name, null: false
      t.string :status, default: "draft", null: false
      t.string :metric, default: "lead_capture", null: false
      t.datetime :started_at
      t.datetime :ended_at
      t.bigint :winning_variant_id
      t.timestamps
    end

    create_table :marquee_variants do |t|
      t.references :experiment, null: false, foreign_key: { to_table: :marquee_experiments }
      t.string :name, null: false
      t.string :template_path, null: false
      t.integer :weight, default: 1, null: false
      t.boolean :is_control, default: false, null: false
      t.timestamps
    end
  end
end
