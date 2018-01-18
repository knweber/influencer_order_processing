require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'] || :development)
require 'dotenv'
require 'sinatra/basic_auth'
Dotenv.load
Dir[File.dirname(__FILE__) + '/../lib/initializers/*.rb'].each do |file|
  require file
end
