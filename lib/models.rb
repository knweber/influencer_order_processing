class ShopifyOrder < ActiveRecord::Base
  self.table_name = 'shopify_orders'
end

class Product < ActiveRecord::Base
  self.table_name = 'shopify_products'
end

class ProductVariant < ActiveRecord::Base
  self.table_name = 'shopify_product_variants'
end

class CustomCollection < ActiveRecord::Base
  self.table_name = 'shopify_custom_collections'
end

class Collect < ActiveRecord::Base
  self.table_name = 'shopify_collects'
end

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

class InfluencerOrder < ActiveRecord::Base
  belongs_to :influencer
  has_many :tracking, class_name: 'InfluencerTracking'

  def uploaded?
    !uploaded_at.nil?
  end

  def self.items_from_collection_id(collection_id)
    order_items = []
    local_collects = Collect.where(collection_id: collection_id)
    local_collects.each do |coll|
      line_item = Product.find(coll.product_id)
      order_items.push(map_multiple_products(MULTIPLE_PRODUCT_DATA,SIZE_SKU_DATA,line_item))
    end
    order_items
  end

  def self.address(user)
    {
      'address1' => user.address1,
      'address2' => user.address2,
      'city' => user.city,
      'zip' => user.zip,
      'province_code' => user.state,
      'country_code' => 'US',
      'phone' => user.phone
    }
  end

  def self.shipping_address(user)
    shipping_address = InfluencerOrder::address(user)
    shipping_address['first_name'] = user['first_name']
    shipping_address['last_name'] = user['last_name']
    shipping_address
  end

  def self.billing_address(user)
    billing_address = InfluencerOrder::address(user)
    billing_address['name'] = "#{user['first_name']} #{user['last_name']}"
    billing_address
  end

  def self.get_corresponding_variant(user_item_size,prod)
    prod[0]['variants'].each do |var|
      return var if user_item_size == var['title']
    end
  end

  def self.add_item_variant(prod,var)
    {
      'product_id' => prod[0]['options'][0]['product_id'],
      'merchant_sku_item' => var['sku'],
      'size' => var['title'],
      'quantity_requested' => prod[0]['quantity'],
      'item_name' => prod[0]['title'],
      'sell_price' => var['price'],
      'product_weight' => var['weight']
    }
  end
end

class InfluencerTracking < ActiveRecord::Base
  self.table_name = 'influencer_tracking'
  belongs_to :order, class_name: 'InfluencerOrder'
  has_one :influencer, through: 'order'

  def email_data
    {
      influencer_id: order.influencer_id,
      carrier: carrier,
      tracking_num: tracking_number,
    }
  end

  def email_sent?
    !email_sent_at.nil?
  end

  def send_email
    Resque.enqueue_to(:default, 'SendEmail', id)
  end
end
