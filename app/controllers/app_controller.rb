require 'sinatra'
require_relative '../../lib/process_users'
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
  puts collection.as_json

  collects = ShopifyAPI::Collect.find(:params => {:collection_id => collection.id})
  # prod = ShopifyAPI::Product.find(collects.product_id)
  # curr_prod = ShopifyAPI::Product.where(:params => {:collection_id => collects.as_json[0]['product_id']})

  # puts "Collection:"
  # puts collection.as_json
  # puts "_________"
  # puts "Collect:"
  puts collects
  # puts "_________"

  # puts "Prod:"
  # puts prod.as_json
  # puts "Curr Prod:"
  # puts curr_prod.as_json[0]
  # puts "***"
  # puts curr_prod.as_json[1]

  erb :'orders/show'
end

get '/download' do
  send_file '/tmp/invalid.txt'
end
