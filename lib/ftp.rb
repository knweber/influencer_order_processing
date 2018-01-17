require 'net/ftp'
require_relative 'async'

module FTP
  include Async

  def self.upload_orders_csv(file)
    ftp = Net::FTP.new(ENV['FTP_HOST'], username: ENV['FTP_USER'], password: ENV['FTP_PASSWORD'], debug_mode: true)
    ftp.chdir 'ReceiveOrder'
    ftp.put(File.open file)
    puts 'i put it!'
    ftp.close
  end
end
