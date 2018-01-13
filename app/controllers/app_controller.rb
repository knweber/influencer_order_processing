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

  prods = ShopifyAPI::Product.where(:collection_id => collection.id)

  type_mapping = {
    'Sports Bra' => 'bra_size',
    'Leggings' => 'bottom_size',
    'Tops' => 'top_size',
    'Jacket' => 'sports_jacket_size'
  }

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
    shipping_address.first_name = user.first_name
    shipping_address.last_name = user.last_name
    billing_address = address
    billing_address.name = user.first_name + " " + user.last_name

    new_order = {
      'name' => generate_order_number,
      'billing_address' => billing_address,
      'shipping_address' => shipping_address,
      'processed_at' => Time.current
    }

    prods.each do |prod|
      type = prod.type
      size_label = type_mapping[type]
      options = []
      SIZE_SKU_DATA.each do |row|
        if row[1] == type && row[3] ==
          options.push(row)
        end
      end

      variants = map_multiple_products(MULTIPLE_PRODUCT_DATA, SIZE_SKU_DATA, prod.to_json).variants
      user.bra_size
      user.top_size
      user.bottom_size
      user.sports_jacket_size
    end
    orders.push(to_row_hash(new_order))
  end
  create_csv(orders)

  # puts "_________"
  # puts "**COLLECT:"
  # puts collection.collects
  # collect = ShopifyAPI::Collect.find(:params => {:collection_id => 2509570066})
  # puts collect.to_json


  erb :'orders/show'
end

get '/download' do
  send_file '/tmp/invalid.txt'
end
