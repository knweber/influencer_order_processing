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

  def self.get_csv
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
      influencer_id: influencer.id,
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
