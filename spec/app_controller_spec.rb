require 'spec_helper'
require 'sinatra/basic_auth'
require 'rack/test'

describe 'App Controller' do

  context 'get /' do

    it 'should render #index if authorized' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/'
      expect(last_response.status).to eq(200)
    end

    it 'should throw error if not authorized' do
      get '/'
      puts last_response.body
      expect(last_response.status).to eq(401)
    end
  end

  context 'get /admin' do

    it 'should redirect if authorized' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin'
      expect(last_response.status).to eq(302)
    end

    it 'should redirect to /admin/uploads/new if authorized' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin'
      expect(last_response.location).to include('/admin/uploads/new')
    end
  end

  context 'get /admin/uploads/new' do

    it 'should render uploads#new' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin/uploads/new'
      expect(last_response.status).to eq(200)
    end

  end

  context 'post /admin/uploads' do

    context 'valid influencer info' do

      it 'should have a status of 200 after submission' do
        authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
        post '/admin/uploads', 'file' => Rack::Test::UploadedFile.new('valid_influencers_sample_upload.csv',
        'application/csv')

        expect(last_response.status).to eq(200)
      end

      # it 'should not write to /tmp/invalid.txt' do
      #   authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      #   p Influencer.all.count
      #   post '/admin/uploads', 'file' => Rack::Test::UploadedFile.new('valid_influencers_sample_upload.csv',
      #   'application/csv')
      #   file_length = File.open('/tmp/invalid.txt').read.length
      #   expect(file_length).to be_empty
      # end
    end

    context 'invalid influencer info' do

      it 'should not create any new influencers' do
        authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
        influencer_count = Influencer.all.count
        post '/admin/uploads', 'file' => Rack::Test::UploadedFile.new('invalid_influencers_sample_upload.csv',
        'application/csv')

        expect(Influencer.all.count).to eq(influencer_count)
      end

      it 'should write to /tmp/invalid.txt' do
        authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
        post '/admin/uploads', 'file' => Rack::Test::UploadedFile.new('invalid_influencers_sample_upload.csv',
        'application/csv')
        file_length = File.open('/tmp/invalid.txt').read.length

        expect(file_length).not_to eq(0)
      end
    end

  end

  context 'get /admin/orders/new' do
    it 'should render orders#new' do
      authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
      get '/admin/orders/new'
      expect(last_response.status).to eq(200)
    end

  end

  # context 'post /admin/orders' do
  #   context 'valid collection ID\'s' do
  #     authorize ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
  #     browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  #
  #     post '/admin/orders', params={ params[:order]['collection_3_id']= , params[:order]['collection_5_id']= }
  #   end
  # end

end
