require "bundler"
Bundler.require
require "rake/testtask"
require "sinatra/activerecord/rake"
require_relative 'lib/pull'

ActiveRecord::Base.establish_connection ENV['DATABASE_URL']

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task :pull_orders do |t|
  pull_all(ShopifyAPI::Order, ShopifyOrder)
end

task :pull_products do |t|
  pull_all(ShopifyAPI::Product, Product)
end

task :pull_product_variants do |t|
  pull_all(ShopifyAPI::ProductVariant, ProductVariant)
end

task :pull_collections do |t|
  pull_all(ShopifyAPI::CustomCollection, CustomCollection)
end

task :pull_collects do |t|
  pull_all(ShopifyAPI::Collect, Collect)
end
