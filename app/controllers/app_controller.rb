enable :sessions
require_relative '../../lib/init'
require_relative '../../lib/process_users'
require_relative '../../lib/create_csv'
require_relative '../../lib/models'
require_relative '../../lib/ftp'
require 'sinatra/basic_auth'

$apikey = ENV['SHOPIFY_API_KEY']
$password = ENV['SHOPIFY_PASSWORD']
$shopname = ENV['SHOPIFY_SHOP_NAME']
$secret = ENV['SHOPIFY_SHARED_SECRET']

ShopifyAPI::Base.site = "https://#{$apikey}:#{$password}@#{$shopname}.myshopify.com/admin"
ShopifyAPI::Session.setup(api_key: $apikey, secret: $secret)

authorize "Admin" do |username, password|
  username == ENV['AUTH_USERNAME'] && password == ENV['AUTH_PASSWORD']
end

protect "Admin" do

  get '/' do
    erb :'index'
  end

  get '/admin' do
    redirect '/admin/uploads/new'
  end

  get '/admin/uploads/new' do
    erb :'uploads/new'
  end

  post '/admin/uploads' do
    filename = '/tmp/invalid.txt'
    File.truncate(filename,0)
    influencer_data = params[:file][:tempfile].read
    utf_data = influencer_data.force_encoding('iso8859-1').encode('utf-8')
    influencer_rows = CSV.parse(utf_data, headers: true, header_converters: :symbol)

    if !check_email(influencer_rows)
      status 422
      return erb :'uploads/new', locals: { errors: ["Oops! Some of the records you submitted are incorrect."] }
    else
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

  get '/admin/influencers/delete' do
    @title = 'Reset All Influencers'
    erb :'influencers/delete'
  end

  delete '/admin/influencers' do
    Influencer.destroy_all
    redirect '/'
  end

  get '/admin/influencers/download' do
    file_to_download = Influencer.to_csv
    send_file(file_to_download, :filename => file_to_download)
  end

  # orders


  get '/admin/orders' do
    @table = InfluencerOrder.all.group(:name).order(uploaded_at: :asc).map do |line_items|
      OpenStruct.new(
        ids: line_items.pluck(:id),
        name: line_items.first.name,
        processed_at: line_items.first.processed_at,
        billing_address: line_items.first.billing_address,
        shipping_address: line_items.first.shipping_address,
        line_items: line_items.pluck(:line_item),
        influencer: line_items.first.influencer,
        uploaded_at: line_items.first.uploaded_at,
        tracking: line_items.first.tracking,
      )
    end
    erb :'orders/index'
  end

  get '/admin/orders/new' do
    erb :'orders/new'
  end

  post '/admin/orders' do
    order_params = params[:order]
    placeholder_3item_id = order_params['collection_3_id']
    placeholder_5item_id = order_params['collection_5_id']
    orders = Influencer.generate_orders(placeholder_3item_id, placeholder_5item_id)

    puts "Total orders: #{orders.length}"
    csv_file = create_output_csv orders
    # todo: orders should really not be marked uploaded until the upload succeeds.
    # This should be retooled in the future

    queued = EllieFtp.async :upload_orders_csv, csv_file
    if queued
      InfluencerOrder.where(name: orders.pluck('name').uniq)
        .update_all(uploaded_at: Time.current)
    end
    #send_file File.open csv_file, 'r'
    erb :'orders/show'
  end


  get '/admin/orders/show_unprocessed' do
    orders = InfluencerOrder.where(:processed_at => nil)
    file = create_output_csv(orders)
    send_file(file, :filename => "TEST_unprocessed_#{Time.current.strftime("%Y_%m_%d_%H_%M_%S")}.csv")
  end

  # get '/admin/orders/show_processed' do
  #
  # end

  get '/admin/orders/delete' do
    @title = 'Clear All Orders'
    erb :'orders/delete'
  end

  delete '/admin/orders' do
    InfluencerOrder.destroy_all
    redirect '/'
  end

  # ftp

  get '/admin/ftp' do
    erb :ftp
  end

  post '/admin/ftp' do
    orders = InfluencerOrder.where.not(uploaded_at: nil)
    csv_file = create_output_csv orders
    EllieFtp.async :upload_orders_csv, csv_file
  end

  post '/admin/refresh_cache' do
    case params['cache']
    when 'all'
      ShopifyCache.async :pull_all
      erb success ? 'Success' : 'Failure'
    when 'products'
      ShopifyCache.async :pull_products
      erb success ? 'Success' : 'Failure'
    when 'orders'
      ShopifyCache.async :pull_orders
      erb success ? 'Success' : 'Failure'
    when 'collects'
      ShopifyCache.async :pull_collects
      erb success ? 'Success' : 'Failure'
    when 'custom_collections'
      success = ShopifyCache.async :pull_custom_collections
      erb success ? 'Success' : 'Failure'
    else
      404
    end
  end
end
