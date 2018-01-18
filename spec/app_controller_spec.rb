require 'spec_helper'
require 'sinatra/basic_auth'

describe 'App Controller' do

  context 'get /' do
    it 'should render #index' do
      get '/'
      expect(last_response.status).to eq(200)
    end
  end

  context 'get /admin' do
    it 'should redirect if login is successful' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin'
      expect(last_response.status).to eq(302)
    end

    it 'should redirect to /admin/uploads/new if authorized' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin'
      expect(last_response.location).to include('/admin/uploads/new')
    end

    it 'should throw error if not authorized' do
      get '/admin'
      expect(last_response.status).to eq(401)
    end
  end

  context 'get /admin/uploads/new' do
    it 'should render uploads#new' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin/uploads/new'
      expect(last_response.status).to eq(200)
    end

  end

  xcontext 'post /admin/uploads' do
    it 'should render uploads#show' do
    end

  end

  context 'get /admin/orders/new' do
    it 'should render orders#new' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin/orders/new'
      expect(last_response.status).to eq(200)
    end

  end

  xcontext 'post /admin/orders' do
    # authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
  end

end
