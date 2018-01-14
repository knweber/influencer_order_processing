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
  self.table_name = 'influencers'
end

class InfluencerOrder < ActiveRecord::Base
  self.table_name = 'influencer_orders'
end
