enable :sessions
require_relative '../../lib/init'
require_relative '../../lib/process_users'
require_relative '../../lib/create_csv'
require_relative '../../lib/models'
require_relative '../../lib/ftp'
require_relative '../../worker/send_email'

$apikey = ENV['SHOPIFY_API_KEY']
$password = ENV['SHOPIFY_PASSWORD']
$shopname = ENV['SHOPIFY_SHOP_NAME']
$secret = ENV['SHOPIFY_SHARED_SECRET']

ShopifyAPI::Base.site = "https://#{$apikey}:#{$password}@#{$shopname}.myshopify.com/admin"
ShopifyAPI::Session.setup(api_key: $apikey, secret: $secret)

get '/' do
  if session[:user_id] && session[:user_id] == ENV['AUTH_SESSION_ID']
    redirect '/admin/uploads/new'
  else
    erb :'sessions/new'
  end
end

get '/sessions/new' do
  erb :'sessions/new'
end

post '/sessions' do
  if params[:username] == ENV['AUTH_USERNAME'] && params[:password] == ENV['AUTH_PASSWORD']
    session[:user_id] = ENV['AUTH_SESSION_ID']
    redirect '/admin/uploads/new'
  else
    status 422
    erb :'sessions/new', locals: { errors: ["Invalid credentials"] }
  end
end

delete '/sessions' do
  session[:user_id] = nil
  redirect '/'
end

get '/admin/uploads/new' do
  puts "Destroying influencers"
  Influencer.destroy_all
  erb :'uploads/new'
end

post '/admin/uploads' do
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

get '/admin/orders/new' do
  InfluencerOrder.destroy_all
  erb :'orders/new'
end

post '/admin/orders' do
  order_params = params[:order]
  placeholder_3item_id = order_params['collection_3_id']
  placeholder_5item_id = order_params['collection_5_id']
  orders = []

  collection3 = ShopifyAPI::CustomCollection.find(placeholder_3item_id)
  puts "___"
  p collection3
  collection5 = ShopifyAPI::CustomCollection.find(placeholder_5item_id)
  puts "*****"
  p collection5

  local_collects3 = Collect.where(collection_id: collection3.id)
  local_collects5 = Collect.where(collection_id: collection5.id)

  order_3_items = []
  order_5_items = []

  local_collects3.each do |coll|
    line_item = Product.find(coll.product_id)
     order_3_items.push(map_multiple_products(MULTIPLE_PRODUCT_DATA,SIZE_SKU_DATA,line_item))
  end
  local_collects5.each do |coll|
    line_item = Product.find(coll.product_id)
     order_5_items.push(map_multiple_products(MULTIPLE_PRODUCT_DATA,SIZE_SKU_DATA,line_item))
  end

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
      specific_var = ""

      prod[0]['variants'].each do |var|
        if user_item_size == var['title']
          specific_var = var
        end
      end

      new_order['line_item'] = {
        'product_id' => prod[0]['options'][0]['product_id'],
        'merchant_sku_item' => specific_var['sku'],
        'size' => specific_var['title'],
        'quantity_requested' => prod[0]['quantity'],
        'item_name' => prod_title,
        'sell_price' => specific_var['price'],
        'product_weight' => specific_var['weight']
      }

      new_order['name'] = user_order_number
      if new_order.valid?
        new_order.save!
        orders.push(new_order)
      end
    end
  end

  puts "Total orders: #{orders.length}"
  csv_file = create_output_csv orders
  EllieFtp.async :upload_orders_csv, csv_file
  send_file File.open csv_file, 'r'
  erb :'orders/show'
end


get '/admin/download' do
  send_file '/tmp/invalid.txt'
end
