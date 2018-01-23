source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'sinatra', require: 'sinatra/base'
gem 'shopify_api'
gem 'recharge-api'
gem 'activerecord'
gem 'activesupport'
gem 'sinatra-activerecord'
gem 'sinatra-basic-auth', require: 'sinatra/basic_auth'
gem 'pg'
gem 'rake'
gem 'httparty'
gem 'sendgrid-ruby'
gem 'resque'
gem 'redis'
gem "shopify-api-throttle", git: 'https://github.com/bradrees/shopify-api-throttle.git'
gem 'puma'

group :development do
  gem 'pry'
  #gem 'pry-debugger'
  gem 'pry-stack_explorer'
  gem 'pry-rescue'
  gem 'shotgun'
  gem 'sqlite3'
  gem 'rspec'
  gem 'factory_bot'
  gem 'capybara'
  gem 'faker'
end

# Added at 2018-01-04 19:08:52 -0800 by ryan:
gem "dotenv", "~> 2.2"
