require 'sendgrid-ruby'
require 'json'
include SendGrid

class SendEmail

  @queue = :send_emails

  def self.perform(influencer_id, carrier={}, tracking_num={})
    @influencer = Influencer.find(influencer_id)
    sent = false

    begin
      @orders = InfluencerOrder.find_by(:influencer_id => @influencer.id )
      carrier = args['carrier']
      tracking_num = args['tracking_num']
      order_num = @orders.first.name

      from = Email.new(email: ENV['OUR_EMAIL'], name: 'Ellie')
      subject = "Your order has been shipped!"
      to = Email.new(email: @influencer.email)

      content = Content.new(type: 'text/plain', value: "#{@influencer.first_name}, your order is on its way! Your tracking information is below: \n
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
      
      sent = true
      puts "** Sent! **"
    rescue Exception => e
      puts e
    end


  end
end

klass, args = Resque.reserve(:emails_queue)
klass.perform(*args) if klass.respond_to? :perform
