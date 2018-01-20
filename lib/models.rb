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

  CSV_DATE_FMT = '%m/%d/%Y %H:%M'
  CSV_HEADERS = ["order_number","groupon_number","order_date","merchant_sku_item","quantity_requested","shipment_method_requested","shipment_address_name","shipment_address_street","shipment_address_street_2","shipment_address_city","shipment_address_state","shipment_address_postal_code","shipment_address_country","gift","gift_message","quantity_shipped","shipment_carrier","shipment_method","shipment_tracking_number","ship_date","groupon_sku","custom_field_value","permalink","item_name","vendor_id","salesforce_deal_option_id","groupon_cost","billing_address_name","billing_address_street","billing_address_city","billing_address_state","billing_address_postal_code","billing_address_country","purchase_order_number","product_weight","product_weight_unit","product_length","product_width","product_height","product_dimension_unit","customer_phone","incoterms","hts_code","3pl_name","3pl_warehouse_location","kitting_details","sell_price","deal_opportunity_id","shipment_strategy","fulfillment_method","country_of_origin","merchant_permalink","feature_start_date","feature_end_date","bom_sku","payment_method","color_code","tax_rate","tax_price"]

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

  def self.create_csv(orders_list = nil)
    orders = orders_list || where(uploaded_at: nil)
    # create empty CSV file with appropriate name
    filename = '/tmp/' + name_csv
    rows = orders.map(&:to_row_hash)
    puts "#{orders.length} Order line items"
    file = CSV.open(filename, 'w', headers: CSV_HEADERS) do |csv|
      csv << CSV_HEADERS
      rows.each{|data| csv << CSV_HEADERS.map{|key| data[key]} }
    end
    filename
  end

  def to_row_hash
    {
      'order_number' => name,
      'order_date' => processed_at.try(:strftime, CSV_DATE_FMT),
      'customer_phone' => billing_address["phone"].try('gsub', /[^0-9]/, ''),
      'sell_price' => line_item['sell_price'],
      'quantity_requested' => 1,
      'merchant_sku_item' => line_item['merchant_sku_item'],
      'product_weight' => line_item['product_weight'],
      'item_name' => line_item['item_name'],
      'billing_address_name' => billing_address["name"],
      'billing_address_street' => billing_address["address1"],
      'billing_address_city' => billing_address["city"],
      'billing_address_postal_code' => billing_address["zip"],
      'billing_address_state' => billing_address["province_code"],
      'billing_address_country' => billing_address["country_code"],
      'shipment_address_name' => "#{shipping_address["first_name"]} #{shipping_address["last_name"]}",
      'shipment_address_street' => shipping_address["address1"],
      'shipment_address_street_2' => shipping_address["address2"],
      'shipment_address_city' => shipping_address["city"],
      'shipment_address_postal_code' => shipping_address["zip"],
      'shipment_address_state' => shipping_address["province_code"],
      'shipment_address_country' => shipping_address["country_code"],
      'gift' => 'FALSE',
    }
  end

  private

  def self.name_csv
    "Orders_#{Time.current.strftime("%Y_%m_%d_%H_%M_%S_%L")}.csv"
  end

  def self.generate_order_number
    "#IN" + SecureRandom.random_number(36**12).to_s(36).rjust(11,"0")
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
