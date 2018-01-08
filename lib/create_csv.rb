require 'json'
require 'csv'
require 'date'


# IMPORTANT COLUMN INDEX REFERENCE FOR CSV:
# 0 order number
# 2 order date
# 3 merchant sku
# 4 quantity requested
# 6 customer name
# 7 shipping address
# 8 shipping address2
# 9 shipping address city
# 10 shipping address state
# 11 shipping address zipcode
# 12 shipping address country
# 23 item name
# 24 vendor id
# 27 billing name
# 28 billing address
# 29 billing city
# 30 billing state
# 31 billing zip
# 32 billing country
# 34 product weight (only for boxes)
# 35 product weight unit
# 40 customer phone number
# 46 sell price

def create_orders
  # get all unfulfilled orders
  my_shopify_orders = ShopifyOrder.where('created_at BETWEEN ? AND ?', 14.days.ago, Time.current)
  # *** ADD CONDITION FOR ONLY UNFULFILLED

  puts "** Number of orders to fulfill: #{my_shopify_orders.length} **"
  puts "*************"

  orders_for_csv = []

  # for each ShopifyOrder in DB, create at least one 'order' -- if ShopifyOrder only had one line item, only one order will be created, while multiple orders (CSV rows) will be created if the ShopifyOrder contains multiple line items
  my_shopify_orders.each do |order|
    puts "NEW ORDER"

    unique_order_number = "#IN" + SecureRandom.random_number(36**12).to_s(36).rjust(12,"0")


    billing_address = order.billing_address

    shipping_address = order.shipping_address

    line_items = order.line_items

    line_items.each do |item|

      variant_id = order.line_items[0]["variant_id"]

      props = order.line_items[0]["properties"].map{|prop| [prop['name'], prop['value']]}.to_h
      puts props

      sku = props["sku"]
      weight = props["weight"]
      weight_units = props["weight_unit"]
      item_name = props["title"]
      
      new_order = {
        unique_order_number: unique_order_number,
        email: order["contact_email"],
        phone: order["phone"],
        first_name: shipping_address["first_name"],
        last_name: shipping_address["last_name"],
        total_price: order["total_price"],
        subtotal: order["subtotal_price"],
        total_discounts: order["total_discounts"],
        sku: sku,
        weight: weight,
        weight_unit: weight_units,
        item_name: item_name,
        billing_customer_name: billing_address["name"],
        billing_address: billing_address["address1"],
        billing_city: billing_address["city"],
        billing_zip: billing_address["zip"],
        billing_state: billing_address["province"],
        billing_country: billing_address["country"],
        shipping_address: shipping_address["address1"],
        shipping_address2: shipping_address["address2"],
        shipping_city: shipping_address["city"],
        shipping_zip: shipping_address["zip"],
        shipping_state: shipping_address["province"],
        shipping_country: shipping_address["country"]
      }

      puts "_____"
      puts "Order:"
      puts JSON.pretty_generate(new_order)

      orders_for_csv.push(new_order)
    end
  end
  fill_csv(orders_for_csv)
end

def create_csv
  # create empty CSV file with appropriate name
  current_date = DateTime.now
  rand_num_addon = rand(0..200).to_s
  name = "TEST_Orders" + current_date.strftime("_%^B%Y") + rand_num_addon + ".csv"
  name
end

def fill_csv(orders)
  filename = create_csv
  # CSV COLUMNS:
  header_arr = ["order_number","groupon_number","order_date","merchant_sku_item","quantity_requested","shipment_method_requested","shipment_address_name","shipment_address_street","shipment_address_street_2","shipment_address_city","shipment_address_state","shipment_address_postal_code","shipment_address_country","gift","gift_message","quantity_shipped","shipment_carrier","shipment_method","shipment_tracking_number","ship_date","groupon_sku","custom_field_value","permalink","item_name","vendor_id","salesforce_deal_option_id","groupon_cost","billing_address_name","billing_address_street","billing_address_city","billing_address_state","billing_address_postal_code","billing_address_country","purchase_order_number","product_weight","product_weight_unit","product_length","product_width","product_height","product_dimension_unit","customer_phone","incoterms","hts_code","3pl_name","3pl_warehouse_location","kitting_details","sell_price","deal_opportunity_id","shipment_strategy","fulfillment_method","country_of_origin","merchant_permalink","feature_start_date","feature_end_date","bom_sku","payment_method","color_code","tax_rate","tax_price\n"]

  CSV.open(filename, "w+") do |file|
    file << header_arr
    # in this context, an 'order' will have one line item, so a multi-item order will add more than one row to the CSV file, but they will share a unique_order_number
    orders.each do |order|
      data_out = []

      # single CSV row -- skipped indices are blank in output CSV
      data_out[0] = order[:unique_order_number]
      data_out[2] = order[:created_at]
      data_out[3] = order[:sku]
      data_out[6] = order[:first_name] + " " + order[:last_name]
      data_out[7] = order[:shipping_address]
      data_out[8] = order[:shipping_address2]
      data_out[9] = order[:shipping_city]
      data_out[10] = order[:shipping_state]
      data_out[11] = order[:shipping_zip]
      data_out[12] = order[:shipping_country]
      data_out[23] = order[:item_name]
      data_out[27] = order[:billing_customer_name]
      data_out[28] = order[:billing_address]
      data_out[29] = order[:billing_city]
      data_out[30] = order[:billing_state]
      data_out[31] = order[:billing_zip]
      data_out[32] = order[:billing_country]
      data_out[34] = order[:weight]
      data_out[35] = order[:weight_unit]
      data_out[40] = order[:phone]
      data_out[46] = order[:total_price]
      data_out[-1] = " \n"

      file << data_out
    end
  end
end

