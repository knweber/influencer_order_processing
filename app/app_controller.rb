require 'sinatra'

get '/' do
  redirect '/uploads/new'
end

get '/uploads/new' do
  erb :'uploads/new'
end

post '/uploads' do
  influencer_data = params[:file][:tempfile].read
  erb :'uploads/show'
end

get '/orders/new' do
  erb :'orders/new'
end

post '/orders' do
  erb :'orders/show'
end

get '/download' do
  erb :'tickets/show'
end
