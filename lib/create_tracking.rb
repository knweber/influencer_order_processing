# line_item_id is formatted to match the order object's name property.
# Since there is no identifier for the line items we will just make a
# fulfillment object per order_id and carrier pair, collecting the tracking ids.
def fulfill_order(line_item_id, carrier, tracking)
  order = ShopifyOrder.find_by name: line_item_id
  unique_data = {
    order_id: order.id,
    tracking_company: carrier_map(carrier),
  }
  # find or initialize a fulfilment with the associated order and carrier
  begin
    fulfillment = ShopifyAPI::Fulfillment.find(:first, params: unique_data)
    fulfillment.tracking_numbers = (fulfillment.tracking_numbers + [tracking]).uniq
    fulfilment.save
  rescue ActiveResource::ResourceNotFound
    ShopifyAPI::Fulfillment.create(unique_data.merge({
      line_items: order.line_items.map{|line_item| { id: line_item['id'] }},
      notify_customer: true,
      tracking_numbers: [tracking],
    }))
  end

  # using the setter/getter methods results in MethodMissing errors, so interact
  # with the attribute hash instead


end

# map common csv carriers to the required shopify tracking_company string
def carrier_map(carrier_str)
  {
    'fedex' => 'FedEx',
    'usps' => 'USPS',
  }[carrier_str.downcase]
end

def process_tracking_csv(filepath)
  tracking_lines = CSV.open(filename, 'r').read
  traching_lines.each do |line|
    fulfill_order(*line)
  end
end
