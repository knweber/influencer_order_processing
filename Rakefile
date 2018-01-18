require_relative 'lib/init'
require "rake/testtask"
require "sinatra/activerecord/rake"
require_relative 'lib/models'
require_relative 'lib/pull'
require 'resque/tasks'
require_relative 'worker/send_email'

require ::File.expand_path('../config/environment', __FILE__)

ActiveRecord::Base.establish_connection ENV['DATABASE_URL']

def file_input(env_var = 'FILE')
  if ENV['FILE'].nil?
    puts 'Requires FILE for processing. Usage: rake process_tracking FILE=<filepath>'
    exit
  elsif ENV['FILE'] == 'STDIN'
    STDIN
  else
    File.open(ENV['FILE'], 'r')
  end
end

def pull_products
  pull_all(ShopifyAPI::Product, Product)
  variants = Product.all.pluck(:variants).flatten
  puts "adding #{variants.count} product variants"
  variants.each do |variant|
    ProductVariant.find_or_initialize_by(id: variant['id'])
      .update(variant)
  end
end

# many if not all of these tasks are called via a cron job. Make sure to update
# the crontab when changing things in the namespace.
namespace :pull do

  desc 'refresh all caches from shopify'
  task :all do |t|
      pull_all ShopifyAPI::Order, ShopifyOrder
      pull_all ShopifyAPI::CustomCollection, CustomCollection
      pull_all ShopifyAPI::Collect, Collect
      pull_products
  end

  desc 'refresh orders cache from shopify'
  task :pull_orders do |t|
      pull_all ShopifyAPI::Order, ShopifyOrder
  end

  desc 'refresh products cache from shopify'
  task :pull_products do |t|
    pull_products
  end

  desc 'refresh custom collections cache from shopify'
  task :pull_custom_collections do |t|
    pull_all(ShopifyAPI::CustomCollection, CustomCollection)
  end

  desc 'refresh collects cache from shopify'
  task :pull_collects do |t|
    pull_all(ShopifyAPI::Collect, Collect)
  end

end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task 'resque:setup' do
  ENV['QUEUE'] = '*'
end

desc 'create orders csv'
task :create_csv do |t|
  create_csv(unprocessed_orders)
end

desc 'create tracking from csv'
task :process_tracking do |t|
  OrderTracking.process_tracking_csv file_input
end

desc 'send tracking email. Usage: `rake send_email TRACKING_ID=<ID>`'
task :send_email do |t|
  unless ENV['TRACKING_ID']
    raise ArgumentError.new 'Requires TRACKING_ID. Usage: `rake send_email TRACKING_ID=<ID>`'
  end
  Resque.enqueue(SendEmail, ENV['TRACKING_ID'])
end

# if this is changed be sure to update the crontab
desc 'poll order tracking ftp server. Optional FTP_PATH. Usage: `rake poll_order_tracking [FTP_PATH=/my/path]`'
task :poll_order_tracking do
  path = ENV['FTP_PATH'] || '/SendOrder'
  EllieFtp.poll_order_tracking path
end
