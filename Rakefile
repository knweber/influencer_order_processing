require "bundler"
Bundler.require
require "rake/testtask"
require "sinatra/activerecord/rake"

ActiveRecord::Base.establish_connection ENV['DATABASE_URL']

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task :pull_all do |t|
end

task :pull_orders do |t|
end

task :pull_products do |t|
end

task :pull_product_variants do |t|
end

task :pull_collections do |t|
end

task :pull_collects do |t|
end
