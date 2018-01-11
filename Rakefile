require_relative 'lib/init'
require "rake/testtask"
require "sinatra/activerecord/rake"
require_relative 'lib/models'
require_relative 'lib/pull'

require ::File.expand_path('../config/environment', __FILE__)

ActiveRecord::Base.establish_connection ENV['DATABASE_URL']

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

desc 'refresh orders cache from shopify'
task :pull_orders do |t|
  pull_all(ShopifyAPI::Order, ShopifyOrder)
end

desc 'refresh products cache from shopify'
task :pull_products do |t|
  pull_all(ShopifyAPI::Product, Product)
end

desc 'refresh product_variants collects cache from shopify'
task :pull_product_variants do |t|
  pull_all(ShopifyAPI::ProductVariant, ProductVariant)
end

desc 'refresh custom collections cache from shopify'
task :pull_custom_collections do |t|
  pull_all(ShopifyAPI::CustomCollection, CustomCollection)
end

desc 'refresh collects cache from shopify'
task :pull_collects do |t|
  pull_all(ShopifyAPI::Collect, Collect)
end

desc 'create orders csv'
task :create_csv do |t|
  create_csv
end
