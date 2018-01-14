class CreateInfluencerOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :influencer_orders do |t|
      t.string :name
      t.datetime :processed_at
      t.jsonb :billing_address
      t.jsonb :shipping_address
      t.jsonb :shipping_lines
      t.jsonb :line_item
      t.integer :influencer_id
    end
  end
end
