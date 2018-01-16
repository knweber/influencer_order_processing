require_relative 'resque_helper'
require 'sendgrid-ruby'
require 'json'
include SendGrid

class SendEmail

  @queue = :emails_queue

  def self.perform(args = {})
    user = Influencer.find(args['influencer_id'])
    send_email(user,carrier,tracking_num)
  end

  private

  def send_email(user,carrier,tracking_num)
    user_orders = InfluencerOrder.where(:influencer_id => user.id)
    order_num = user_orders.first.name

    from = Email.new(email: ENV['OUR_EMAIL'])
    subject = "Your order has been shipped!"
    to = Email.new(email: user.email)

    content = Content.new(type: 'text/plain', value: "#{user.first_name}, your order is on its way! Your tracking information is below: \n
    Carrier: #{carrier} \n
    Tracking Number: #{tracking_num} \n
    Order Number: #{order_num}")

    mail = Mail.new(from, subject, to, content)
    puts mail.to_json

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')

    begin
      puts "Sending email to #{user}"
      response = sg.client.mail._('send').post(request_body: mail.to_json)
      puts response.status_code
      puts response.body
      puts response.headers
    rescue Exception => e
      puts e.message
    end
  end
end
