class Influencer < ActiveRecord::Base
  has_many :orders, class_name: 'InfluencerOrder'
  has_many :tracking_info, class_name: 'InfluencerTracking'
  alias :tracking_numbers :tracking_info
  alias :tracking :tracking_info

  INFLUENCER_HEADERS = ["first_name", "last_name", "address1", "address2", "city", "state", "zip", "email", "phone", "bra_size", "top_size", "bottom_size", "sports_jacket_size", "three_item"]

  def self.generate_orders(three_item_id, five_item_id, influencer_ids = nil)
    influencers = influencer_ids ? where(id: influencer_ids) : all
    orders = []

    collection3 = CustomCollection.find(three_item_id)
    collection5 = CustomCollection.find(five_item_id)

    order_3_items = InfluencerOrder::items_from_collection_id(collection3.id)
    order_5_items = InfluencerOrder::items_from_collection_id(collection5.id)

    influencers.each do |user|
      address = InfluencerOrder::address(user)
      shipping_address = InfluencerOrder::shipping_address(user)
      billing_address = InfluencerOrder::billing_address(user)

      user_order_number = generate_order_number

      items_for_order = []

      if user['three_item'].equal? false
        items_for_order = order_5_items
      else
        items_for_order = order_3_items
      end

      items_for_order.each do |prod|

        new_order = InfluencerOrder.new({
          'billing_address' => billing_address,
          'shipping_address' => shipping_address,
          'processed_at' => DateTime.now,
          'influencer_id' => user.id
        })

        prod_type = prod[0]['product_type']
        prod_title = prod[0]['title']

        user_item_size = map_user_sizes(user,prod_type)
        specific_var = InfluencerOrder::get_corresponding_variant(user_item_size,prod)
        new_order['line_item'] = InfluencerOrder::add_item_variant(prod,specific_var)
        new_order['name'] = user_order_number

        if new_order.valid?
          new_order.save!
          orders.push(new_order)
        end
      end
    end

    orders
  end

  def self.to_csv
    filename = '/tmp/' + 'current_influencers.csv'
    CSV.open(filename, 'w+', headers: INFLUENCER_HEADERS) do |csv|
      csv << INFLUENCER_HEADERS
      Influencer.all.each do |user|
        csv << INFLUENCER_HEADERS.map do |key|
          user[key]
        end
      end
    end
    filename
  end

end
