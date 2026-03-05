class CreateMarqueeAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :marquee_assignments do |t|
      t.references :experiment, null: false, foreign_key: { to_table: :marquee_experiments }
      t.references :variant, null: false, foreign_key: { to_table: :marquee_variants }
      t.string :visitor_token, null: false
      t.datetime :assigned_at, null: false
      t.timestamps
    end

    add_index :marquee_assignments, :visitor_token
    add_index :marquee_assignments, [ :experiment_id, :visitor_token ], unique: true, name: "idx_marquee_assignments_experiment_visitor"
  end
end
