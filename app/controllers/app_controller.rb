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
  InfluencerOrder.destroy_all
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

    new_order = InfluencerOrder.new({
      'name' => generate_order_number,
      'billing_address' => billing_address,
      'shipping_address' => shipping_address,
      'processed_at' => Time.current,
      'influencer_id' => user.id
      })

    order_items.each do |prod|
      prod_type = prod[0]['product_type']
      prod_title = prod[0]['title']
      user_item_size = map_user_sizes(user,prod_type)
      specific_var = ""
      prod[0]['variants'].each do |var|
        if user_item_size == var['title']
          specific_var = var
        end
      end

      # prod weight?
      new_order['line_item'] = {
        'product_id' => prod[0]['options'][0]['product_id'],
        'merchant_sku_item' => specific_var['sku'],
        'size' => specific_var['title'],
        'quantity_requested' => prod[0]['quantity'],
        'item_name' => prod_title,
        'sell_price' => specific_var['price'],
        'product_weight' => specific_var['weight']
      }
      new_order.save!
      orders.push(new_order)
    end
  end
  create_output_csv(orders)
  erb :'orders/show'
end

get '/download' do
  send_file '/tmp/invalid.txt'
end
