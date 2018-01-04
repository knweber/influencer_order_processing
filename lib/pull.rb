def pull_all(api_entity, db_entity, query_params = {})
  count = api_entity.count
  limit = 250
  pages = count.fdiv(limit).ceil
  (1..pages).each do |page|
    where_args = query_params.merge(limit: limit, page: page)
    objects = ShopifyAPI.throttle { api_entity.where(where_args) }
    objects.each{|order| db_entity.find_or_initialize_by(id: order.id).assign_or_new(order.attributes.as_json)}
  end
end
