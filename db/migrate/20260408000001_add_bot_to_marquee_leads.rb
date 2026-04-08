class AddBotToMarqueeLeads < ActiveRecord::Migration[8.0]
  def change
    add_column :marquee_leads, :bot, :boolean, default: false, null: false
  end
end
