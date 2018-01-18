require 'sendgrid-ruby'
require 'json'
include SendGrid

class SendEmail

  @queue = :send_emails

  # task a InfluencerTracking id and sends an email with the appropriate
  # tracking number and carrier
  def self.perform(tracking_id)
    tracking = InfluencerTracking.find tracking_id
    influencer = tracking.influencer

    begin
      from = Email.new(email: ENV['OUR_EMAIL'], name: 'Ellie')
      subject = "Your order has been shipped!"
      to = Email.new(email: influencer.email)

      content = Content.new(type: 'text/plain', value: "#{influencer.first_name}, your order is on its way! Your tracking information is below: \n
      Carrier: #{tracking.carrier} \n
      Tracking Number: #{tracking.tracking_number} \n
      Order Number: #{tracking.order.name}")

      mail = Mail.new(from, subject, to, content)
      puts mail.to_json

      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')

      response = sg.client.mail._('send').post(request_body: mail.to_json)
      puts response.status_code
      puts response.body
      puts response.headers
      
      tracking.email_sent_at = Time.current
      tracking.save
      puts "** Sent! **"
    rescue Exception => e
      puts e
    end

  end
end

klass, args = Resque.reserve(:emails_queue)
klass.perform(*args) if klass.respond_to? :perform
