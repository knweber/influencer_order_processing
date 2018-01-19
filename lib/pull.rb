require_relative 'async'

module ShopifyCache
  include Async

  def pull_products
    pull_entity(ShopifyAPI::Product, Product)
    variants = Product.all.pluck(:variants).flatten
    puts "adding #{variants.count} product variants"
    variants.each do |variant|
      ProductVariant.find_or_initialize_by(id: variant['id'])
        .update(variant)
    end
  end

  def pull_order
    pull_entity ShopifyAPI::Order, ShopifyOrder
  end

  def pull_collects
    pull_entity ShopifyAPI::Collect, Collect
  end

  def pull_custom_collections
    pull_entity ShopifyAPI::CustomCollection, CustomCollection
  end

  def pull_all
    pull_entity ShopifyAPI::Order, ShopifyOrder
    pull_entity ShopifyAPI::CustomCollection, CustomCollection
    pull_entity ShopifyAPI::Collect, Collect
    pull_products
  end

  private

  def pull_entity(api_entity, db_entity, query_params = {})
    count = api_entity.count
    limit = 250
    pages = count.fdiv(limit).ceil
    (1..pages).each do |page|
      where_args = query_params.merge(limit: limit, page: page)
      objects = ShopifyAPI.throttle { api_entity.where(where_args) }
      objects.each{|order| db_entity.find_or_initialize_by(id: order.id).update(order.attributes.as_json)}
    end
  end
end
