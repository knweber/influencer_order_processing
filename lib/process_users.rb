require 'date'
require 'csv'
require 'email_address'

def process_users(user_csv_data)
  user_mapping = {
        first_name: user_csv_data[0],
        last_name: user_csv_data[1],
        address1: user_csv_data[2],
        address2: user_csv_data[3],
        city: user_csv_data[4],
        state: user_csv_data[5],
        zip: user_csv_data[6],
        email: user_csv_data['email'],
        phone: user_csv_data[8],
        bra_size: user_csv_data[9],
        top_size: user_csv_data[10],
        bottom_size: user_csv_data[11],
        sports_jacket_size: user_csv_data[12],
        three_item: user_csv_data[13]
      }

  user_csv_data.each do |user|
    if check_email(user['email'])
      check_accented_char(user[0])
      check_accented_char(user[1])
      three_item_to_bool(user[13])
      new_influencer = Influencer.new(user_mapping)
      if new_influencer.valid?
        new_influencer.save
        puts "New Influencer: #{new_influencer.first_name} #{new_influencer.last_name}, #{new_influencer.email}"
      end
    else
      filename = '/tmp/invalid.txt'
      File.open(filename,'w+') do |file|
        file.write(DateTime.now)
        file.write("\n")
        file.write(user)
      end
      return false
    end
  end
end

def three_item_to_bool(user_three_item)
  if user_three_item.downcase == "yes" || user_three_item.downcase == "y"
    user_three_item = true
  else
    user_three_item = false
  end
end

def check_accented_char(name)
  accented_letters = 'ŠšŽžÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸÞàáâãäåæçèéêëìíîïñòóôõöøùúûüýÿþƒ'
  without_accents = 'SsZzAAAAAAACEEEEIIIINOOOOOOUUUUYYBaaaaaaaceeeeiiiinoooooouuuuyybf'
  name.tr(accented_letters,without_accents)
end

def check_email(user_email)
  EmailAddress.valid?(user_email)
end
