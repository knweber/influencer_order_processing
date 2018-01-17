class CreateInfluencerTracking < ActiveRecord::Migration[5.1]
  def change
    create_table :influencer_tracking do |t|
      t.bigint :order_id
      t.string :carrier
      t.string :tracking_number
      t.timestamp :email_sent_at
    end
  end
end
