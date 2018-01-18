require 'rubygems'
require 'factory_bot'
require 'faker'

# All our specs should require 'spec_helper' (this file)

# If RACK_ENV isn't set, set it to 'test'.  Sinatra defaults to development,
# so we have to override that unless we want to set RACK_ENV=test from the
# command line when we run rake spec.  That's tedious, so do it here.
ENV['RACK_ENV'] = 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rack/test'
require 'capybara'
require 'capybara/rspec'

FactoryBot.definition_file_paths = [File.expand_path('../factories', __FILE__)]

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

Capybara.app = app.new
