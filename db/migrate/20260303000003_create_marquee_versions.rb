class CreateMarqueeVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :marquee_versions do |t|
      t.string :versionable_type, null: false
      t.bigint :versionable_id, null: false
      t.bigint :user_id
      t.string :action, null: false
      t.json :changeset, default: {}
      t.json :snapshot, default: {}
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :marquee_versions, [ :versionable_type, :versionable_id ]
    add_index :marquee_versions, :user_id
  end
end
