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
  influencer_data = params[:file][:tempfile].read
  influencer_rows = CSV.parse(influencer_data, headers: true)
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
