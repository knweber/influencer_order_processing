require 'sinatra'
require_relative '../../lib/process_users'
require_relative '../../lib/models'

get '/' do
  redirect '/uploads/new'
end

get '/uploads/new' do
  if Influencer.any?
    Influencer.destroy_all
  end
  erb :'uploads/new'
end

post '/uploads' do
  File.open('/tmp/invalid.txt','a+') do |file|
    file.truncate(0)
  end
  influencer_data = params[:file][:tempfile].read
  utf_data = influencer_data.force_encoding('iso8859-1').encode('utf-8')
  influencer_rows = CSV.parse(utf_data, headers: true, header_converters: :symbol)


  if process_users(influencer_rows)
    erb :'uploads/show'
  else
    return erb :'uploads/new', locals: { errors: ["Oops! Some of the records you submitted are incorrect."]}
  end

end

get '/orders/new' do
  erb :'orders/new'
end

post '/orders' do
  erb :'orders/show'
end

get '/download' do
  send_file '/tmp/invalid.txt'
end
