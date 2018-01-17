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

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task 'resque:setup' do
  ENV['QUEUE'] = '*'
end

desc 'refresh orders cache from shopify'
task :pull_orders do |t|
  pull_all(ShopifyAPI::Order, ShopifyOrder)
end

desc 'refresh products cache from shopify'
task :pull_products do |t|
  pull_all(ShopifyAPI::Product, Product)
  variants = Product.all.pluck(:variants).flatten
  puts "adding #{variants.count} product variants"
  variants.each do |variant|
    ProductVariant.find_or_initialize_by(id: variant['id'])
      .update(variant)
  end
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
  create_csv(unprocessed_orders)
end

desc 'create tracking from csv'
task :process_tracking do |t|
  OrderTracking.process_tracking_csv file_input
end

desc 'echo stdin'
task :echo do |t|
  puts STDIN.read
end

desc 'test ftp uploads'
task :ftp_upload do |t|
  raise ArgumentError.new 'FILE=<filename> argument requires.' unless ENV['FILE']
  FTP.upload_orders_csv ENV['FILE']
end

desc 'send email'
task :send_email do |t|
  Resque.enqueue(SendEmail, params)
end
