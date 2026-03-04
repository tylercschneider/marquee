class CreateMarqueeLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :marquee_leads do |t|
      t.string :email, null: false
      t.string :name
      t.json :data, default: {}
      t.references :source_page, null: false, foreign_key: { to_table: :marquee_pages }
      t.string :visitor_token
      t.string :status, default: "new", null: false
      t.bigint :converted_experiment_id
      t.bigint :converted_variant_id
      t.timestamps
    end

    add_index :marquee_leads, :email
    add_index :marquee_leads, :visitor_token
    add_index :marquee_leads, :converted_experiment_id
    add_index :marquee_leads, :converted_variant_id
  end
end
