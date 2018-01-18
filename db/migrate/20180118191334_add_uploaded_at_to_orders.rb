class AddUploadedAtToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :influencer_orders, :uploaded_at, :timestamp
  end
end
