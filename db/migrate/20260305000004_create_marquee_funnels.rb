class CreateMarqueeFunnels < ActiveRecord::Migration[7.1]
  def change
    create_table :marquee_funnels do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :status, default: "draft", null: false
      t.timestamps
    end

    add_index :marquee_funnels, :slug, unique: true

    create_table :marquee_funnel_steps do |t|
      t.references :funnel, null: false, foreign_key: { to_table: :marquee_funnels }
      t.references :page, null: false, foreign_key: { to_table: :marquee_pages }
      t.integer :position, null: false
      t.string :label, null: false
      t.timestamps
    end

    add_index :marquee_funnel_steps, [ :funnel_id, :position ], unique: true

    create_table :marquee_funnel_progresses do |t|
      t.references :funnel_step, null: false, foreign_key: { to_table: :marquee_funnel_steps }
      t.string :visitor_token, null: false
      t.datetime :created_at, null: false
    end

    add_index :marquee_funnel_progresses, [ :funnel_step_id, :visitor_token ], unique: true, name: "idx_marquee_funnel_progresses_step_visitor"
  end
end
