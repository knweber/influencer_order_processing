class AddTimestampsToTracking < ActiveRecord::Migration[5.1]
  def change
    add_column :influencer_tracking, :created_at, :timestamp
    add_column :influencer_tracking, :updated_at, :timestamp
  end
end
