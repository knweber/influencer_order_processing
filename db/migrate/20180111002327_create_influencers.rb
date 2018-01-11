class CreateInfluencers < ActiveRecord::Migration[5.1]
  def change
    create_table :influencers do |t|
      t.string :first_name, null:false
      t.string :last_name, null:false
      t.string :address1, null:false
      t.string :address2
      t.string :city, null:false
      t.string :state, null:false
      t.string :zip, null:false
      t.string :email, null:false
      t.string :phone
      t.string :bra_size, null:false
      t.string :top_size, null:false
      t.string :bottom_size, null:false
      t.string :sports_jacket_size, null:false
      t.boolean :three_item, null:false
    end
  end
end
