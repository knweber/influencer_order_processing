require 'sendgrid-ruby'
include SendGrid
require 'json'
require 'base64'


my_global_table = arg1
my_subject = "Blank Sku Report for #{my_global_table}"
my_value = "Here is the attachment for the blank skus at #{my_global_table}"
my_local_file = "#{my_global_table}_blank_sku.csv"
my_report = "#{my_global_table} Blank Skus report"
#----- New Code for sending multiple receipients
mail = Mail.new
mail.from = Email.new(email: ENV['OUR_EMAIL'])
#mail.subject = my_subject
personalization = Personalization.new
personalization.to = Email.new(email: ENV['RECIPIENT_EMAIL'], name: ENV['RECIPIENT_NAME'])

  personalization.subject = my_subject
  mail.personalizations = personalization

  mail.contents = Content.new(type: 'text/plain', value: my_value)

  #for attachments
mystring = Base64.strict_encode64(File.open(my_local_file, "rb").read)

  attachment = Attachment.new
  attachment.content =  mystring
  attachment.type = 'application/csv'
  attachment.filename = my_local_file
  attachment.disposition = 'attachment'
  attachment.content_id = my_report
  mail.attachments = attachment

  puts mail.to_json

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'], host: 'https://api.sendgrid.com')
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
