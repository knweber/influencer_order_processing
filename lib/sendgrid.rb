require 'sendgrid-ruby'
require 'json'
require 'base64'
include SendGrid

def create_email(users)
  users.each do |user|

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
    response = sg.client.mail._('send').post(request_body: mail.to_json)

    puts response.status_code
    puts response.body
    puts response.headers
  end
end
