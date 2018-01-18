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
end

class InfluencerOrder < ActiveRecord::Base
  belongs_to :influencer
  has_many :tracking, class_name: 'InfluencerTracking'

  def uploaded?
    !uploaded_at.nil?
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
