require 'sinatra'
require_relative '../../lib/process_users'
require_relative '../../lib/create_csv'
require_relative '../../lib/models'
require 'httparty'
require 'dotenv'
require 'shopify_api'

$apikey = ENV['SHOPIFY_API_KEY']
$password = ENV['SHOPIFY_PASSWORD']
$shopname = ENV['SHOPIFY_SHOP_NAME']
$secret = ENV['SHOPIFY_SHARED_SECRET']

ShopifyAPI::Base.site = "https://#{$apikey}:#{$password}@#{$shopname}.myshopify.com/admin"
ShopifyAPI::Session.setup(api_key: $apikey, secret: $secret)

base_url = "https://#{$apikey}:#{$password}@#{$shopname}.myshopify.com/admin"

get '/' do
  redirect '/uploads/new'
end

get '/uploads/new' do
  Influencer.destroy_all
  erb :'uploads/new'
end

post '/uploads' do
  puts "NUM OF INFLUENCERS: " + Influencer.count.to_s
  filename = '/tmp/invalid.txt'
  File.open(filename,'a+') do |file|
    file.truncate(0)
  end
  influencer_data = params[:file][:tempfile].read
  utf_data = influencer_data.force_encoding('iso8859-1').encode('utf-8')
  influencer_rows = CSV.parse(utf_data, headers: true, header_converters: :symbol)

  if !check_email(influencer_rows)
    status 422
    return erb :'uploads/new', locals: { errors: ["Oops! Some of the records you submitted are incorrect."] }
  else
    Influencer.destroy_all
    influencer_rows.each do |user|
      if !create_user(user)
        File.open(filename,'a+') do |file|
          file.write(user)
        end
        return erb :'uploads/new', locals: { errors: ["Oops! Some of the records you submitted are incorrect."] }
      end
    end
    erb :'orders/new'
  end
end

get '/orders/new' do
  erb :'orders/new'
end

post '/orders' do
  order_params = params[:order]
  placeholder_id = order_params['collection_id']

  collection = ShopifyAPI::CustomCollection.find(placeholder_id)

  local_collects = Collect.where(collection_id: collection.id)
  order_items = []
  local_collects.each do |coll|
    line_item = Product.find(coll.product_id)
     order_items.push(map_multiple_products(MULTIPLE_PRODUCT_DATA,SIZE_SKU_DATA,line_item))
  end


  orders = []
  Influencer.all.each do |user|
    address = {
      'address1' => user.address1,
      'address2' => user.address2,
      'city' => user.city,
      'zip' => user.zip,
      'province_code' => user.state,
      'country_code' => 'US',
      'phone' => user.phone
    }

    shipping_address = address
    shipping_address['first_name'] = user['first_name']
    shipping_address['last_name'] = user['last_name']
    billing_address = address
    billing_address['name'] = user['first_name'] + " " + user['last_name']

    new_order = {
      'name' => generate_order_number,
      'billing_address' => billing_address,
      'shipping_address' => shipping_address,
      'processed_at' => Time.current
      }

    order_items.each do |prod|
      prod_type = prod[0]['product_type']
      prod_title = prod[0]['title']
      vars = prod[0]['variants']
      var_id = ""
      var_sku = ""
      var_price = ""
      var_size = ""

      vars.each do |var|
        if prod_type == "Leggings"
          if var['title'] == user.bottom_size
            var_size = var['title']
            var_id = var['id']
            var_sku = var['sku']
            var_price = var['price']
          end
        elsif prod_type == "Sports Bra"
          if var['title'] == user.bra_size
            var_size = var['title']
            var_id = var['id']
            var_sku = var['sku']
            var_price = var['price']
          end
        elsif prod_type == "Jacket"
          if var['title'] == user.sports_jacket_size
            var_size = var['title']
            var_id = var['id']
            var_sku = var['sku']
            var_price = var['price']
          end
        elsif prod_type == "Tops"
          if var['title'] == user.top_size
            var_size = var['title']
            var_id = var['id']
            var_sku = var['sku']
            var_price = var['price']
          end


          # THIS ISN'T MAPPING CORRECTLY
        elsif prod_type == "Wrap" || prod_type == "Equipment" || prod_type == "Accessories"
          var_size == "ONE SIZE"
          var_id = var['id']
          var_sku = var['sku']
          var_price = var['price']
        end
      end
      # prod weight?
      new_order['line_item'] = {
        'merchant_sku_item' => var_sku,
        'size' => var_size,
        'quantity_requested' => prod[0]['quantity'],
        'item_name' => prod_title,
        'sell_price' => var_price
      }
      orders.push(new_order.as_json)
    end
    puts "______"
  end
  puts JSON.pretty_generate(orders)
  # create_csv(orders)

  erb :'orders/show'
end

get '/download' do
  send_file '/tmp/invalid.txt'
end
